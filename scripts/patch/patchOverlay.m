function [varargout] = patchOverlay(brainFig, allData, underlays, hemi, varargin)
% patchOverlay Patches scalar data onto an existing brain surface.
%
% This function overlays scalar data (e.g., curvature, activation values) onto
% an existing brain surface visualization. It supports overlaying data on the
% left and/or right hemispheres, with extensive customization options for
% data processing, visualization parameters, colormapping, smoothing, and
% statistical thresholding.
%
% **Syntax**
% ----------
%   [overlay, colormapSG, ticksSG, dataCAll, dataTSAll, dataClust, transp, modCmap] = ...
%       patchOverlay(brainFig, allData, underlays, hemi, 'Name', Value, ...)
%
% **Description**
% -----------
%   patchOverlay overlays scalar data onto a brain surface within a specified
%   figure. The function handles data normalization, scaling, thresholding, and
%   colormapping to create visually informative representations of the data.
%   It supports both hemispheres ('lh' for left, 'rh' for right, or 'both') and
%   allows for extensive customization through optional name-value pair arguments.
%
%   The function processes data in the following order:
%     1. Removes positive/negative values based on 'pos' and 'neg' options.
%     2. Applies scaling, normalization, or conversion to percentiles via the 'vls' option.
%     3. Applies thresholding to the processed data.
%
%   Additionally, the function can perform clustering, smoothing, and apply
%   customized transparency based on auxiliary data.
%
% **Inputs**
% -------
%   brainFig  - (Figure Handle) Handle to the existing figure containing the brain
%               surface onto which data will be overlaid.
%
%   allData   - (Matrix) Scalar data to be patched onto the brain surface.
%               - Dimensions: (nVertices x nDataSets)
%               - Each column represents a separate data set to overlay.
%
%   underlays - (Structure) Contains existing surface patches for the brain:
%               - underlays.left  : Handle to the left hemisphere patch (can be empty).
%               - underlays.right : Handle to the right hemisphere patch (can be empty).
%
%   hemi      - (String) Specifies which hemisphere(s) to overlay data on.
%               Options:
%                 'lh'   - Left Hemisphere
%                 'rh'   - Right Hemisphere
%                 'both' - Both Hemispheres
%
% **Outputs**
% --------
%   The function can return up to eight outputs, depending on the user's request:
%
%   1. overlay    - (Patch Object) Handle to the created overlay patch.
%
%   2. colormapSG - (Structure) Contains colormap information:
%                  - colormapSG.map      : Colormap used for the overlay.
%                  - colormapSG.dataMap  : Data mapped to the colormap.
%
%   3. ticksSG    - (Structure) Contains colorbar tick information:
%                  - ticksSG.ticks  : Positions of the ticks.
%                  - ticksSG.labels : Labels for the ticks.
%
%   4. dataCAll   - (Cell Array) Contains color data for each data set.
%
%   5. dataTSAll  - (Cell Array) Contains thresholded and scaled data for each data set.
%
%   6. dataClust  - (Cell Array) Contains cluster information if clustering was applied.
%
%   7. transp     - (Structure) Contains transparency information:
%                  - transp.vals      : Transparency values for each vertex.
%                  - transp.map       : Transparency mapping based on colormap.
%
%   8. modCmap    - (Matrix) Modified colormap if alpha modulation was applied.
%
% **Name-Value Pair Arguments**
% -----------------------------
%   The following optional arguments can be specified as name-value pairs to
%   customize the behavior of the function:
%
%   'pos'            - (String) Controls inclusion of positive values.
%                      Options:
%                        'on'  - Include positive values (default).
%                        'off' - Exclude positive values.
%
%   'neg'            - (String) Controls inclusion of negative values.
%                      Options:
%                        'on'  - Include negative values (default).
%                        'off' - Exclude negative values.
%
%   'vls'            - (String) Normalization/scaling method for data.
%                      Options:
%                        'raw'       - Patch raw values (default).
%                        'prct'      - Convert values to percentiles.
%                        'prctSep'   - Convert positive and negative values to percentiles separately.
%                        'norm'      - Normalize values.
%                        'normSep'   - Normalize positive and negative values separately.
%                        'scl'       - Scale values between -1 and 1.
%                        'sclSep'    - Scale positive and negative values between -1 and 1 separately.
%                        'sclAbs'    - Scale absolute values between 0 and 1.
%                        'sclAbsSep' - Scale absolute positive and negative values between 0 and 1 separately.
%
%   'thresh'         - (2-element Vector) Threshold interval [a b] to remove data.
%                      - Data within [a, b] are set to zero.
%                      - Default: [0 0] (no thresholding).
%
%   'colormap'       - (Matrix or String) Colormap to use for overlay.
%                      - Options:
%                          * MATLAB built-in colormap name (e.g., 'jet', 'parula', etc.).
%                          * Custom colormap as an l x 3 RGB matrix.
%                          * Lots of other colormaps as detailed in
%                          colormapper.m
%                      - Default: 'jet'.
%
%   'colorSpacing'   - (String) Spacing method for colors between limits.
%                      Options:
%                        'even'               - Evenly spaced (default).
%                        'center on zero'     - Midpoint of colorbar is zero.
%                        'center on threshold'- Midpoint is the threshold applied to data.
%
%   'colorBins'      - (Integer) Number of color bins in the colorbar.
%                      - Determines the granularity of the colormap.
%                      - Default: 1000.
%
%   'colorSpecial'   - (String) Special color assignment method.
%                      Options:
%                        'none'                   - Default (no special assignment).
%                        'randomizeClusterColors' - Assign random colors to each data cluster.
%                      - Default: 'none'.
%
%   'invertColors'   - (String) Invert the colormap.
%                      Options:
%                        'true'  - Invert colormap.
%                        'false' - Do not invert (default).
%
%   'limits'         - (2-element Vector) Limits of the colormap [min max].
%                      - Overrides automatic scaling based on data.
%                      - Default: [min(allData(:)) max(allData(:))].
%
%   'opacity'        - (Scalar) Sets opacity of the patch.
%                      - Range: [0, 1], where 0 is fully transparent and 1 is fully opaque.
%                      - Default: 1.
%
%   'binarize'       - (String) Binarize sulcal/gyral information into two colors.
%                      Options:
%                        'none'      - No binarization (default).
%                        'map'       - Binarize based on map values.
%                        'clusters'  - Binarize based on clusters.
%
%   'inclZero'       - (String) Determine if zeros will be patched.
%                      Options:
%                        'on'  - Include zeros in the patch (default).
%                        'off' - Exclude zeros from the patch.
%
%   'lights'         - (String | n x 2 Array) Lighting configuration.
%                      - 'off' : Disables lighting.
%                      - [azimuth elevation] pairs to specify custom lighting angles.
%                      - Default: Uses existing lighting settings in the figure.
%
%   'smoothSteps'    - (Integer) Number of smoothing iterations.
%                      - Determines how many times the smoothing procedure is applied.
%                      - Default: 0 (no smoothing).
%
%   'smoothArea'     - (Integer) Number of closest vertices used for smoothing.
%                      - Defines the neighborhood for each vertex during smoothing.
%                      - Default: 0 (no smoothing).
%
%   'smoothThreshold'- (String) Apply smoothing based on threshold.
%                      Options:
%                        'above' - Apply smoothing to vertices above the threshold (default).
%                        'below' - Apply smoothing to vertices below the threshold.
%
%   'smoothType'     - (String) Type of smoothing.
%                      Options:
%                        'neighbors'    - Use immediate neighbors for smoothing (default).
%                        'neighborhood' - Use a broader neighborhood based on 'smoothArea'.
%
%   'clusterThresh'  - (Integer) Minimum cluster size to retain.
%                      - Clusters smaller than this threshold are removed.
%                      - Default: 0 (no clustering thresholding).
%
%   'pMap'           - (Matrix) P-value map for statistical thresholding.
%                      - Same dimensions as 'allData'.
%                      - Used in conjunction with 'pThresh' to mask data.
%                      - Default: zeros(size(allData)).
%
%   'pThresh'        - (Scalar) P-value threshold for statistical masking.
%                      - Data with p-values below this threshold are retained.
%                      - Default: 1 (no masking).
%
%   'operation'      - (String) Operation for handling multiple data sets.
%                      - Options:
%                          * 'false' - No special operation (default).
%                          * Other operations as defined by the function's implementation.
%                      - Default: 'false'.
%
%   'compKeep'       - (Integer) Number of principal components to keep (if applicable).
%                      - Default: 1.
%
%   'colormapLims'   - (Vector) Limits for scaling the colormap.
%                      - Overrides 'limits' if specified.
%                      - Default: [].
%
%   'modData'        - (Matrix) Data for alpha modulation.
%                      - Same dimensions as 'allData'.
%                      - Controls transparency based on auxiliary data.
%                      - Default: [].
%
%   'modCmap'        - (Matrix) Custom colormap for modulation.
%                      - Used in conjunction with 'modData'.
%                      - Default: [].
%
%   'multiCmap'      - (Matrix) Multi-dimensional colormap.
%                      - Facilitates complex colormap mappings for multiple data sets.
%                      - Default: [].
%
%   'absMod'         - (String) Apply absolute modulation.
%                      Options:
%                        'On'  - Apply absolute value before modulation (default).
%                        'Off' - Do not apply absolute value.
%
%   'incZeroMod'     - (String) Include zeros in modulation.
%                      Options:
%                        'On'  - Include zeros (default).
%                        'Off' - Exclude zeros.
%
%   'minAlphaMod'    - (Scalar) Minimum alpha value for modulation.
%                      - Range: [0, 1].
%                      - Default: 0.
%
%   'maxAlphaMod'    - (Scalar) Maximum alpha value for modulation.
%                      - Range: [0, 1].
%                      - Default: 1.
%
%   'alphaModLims'   - (Vector) Limits for alpha modulation scaling.
%                      - Specifies the range of 'modData' for scaling alpha.
%                      - Default: [] (auto-scaled based on 'modData').
%
%   'scndCbarAxis'   - (String) Secondary colorbar axis setting.
%                      Options:
%                        'same' - Use the same axis as the primary colorbar (default).
%                        'different' - Use a different axis for the secondary colorbar.
%                      - Additional options may be implemented in future updates.
%
%   'multiCmapTicks' - (Matrix) Ticks for multi-dimensional colorbar.
%                      - Aligns ticks across multiple colormaps.
%                      - Default: [].
%
%   'multiCbData'    - (Matrix) Data for multi-dimensional colorbar.
%                      - Facilitates complex data mappings.
%                      - Default: [].
%
%   'sclLims'        - (Vector) Scaling limits for data normalization.
%                      - Specifies the range for scaling data values.
%                      - Default: [0 1].
%
%   'smoothToAssign' - (String) Determines the assignment method after smoothing.
%                      Options:
%                        'all'      - Assign to all relevant vertices (default).
%                        'specific' - Assign based on specific criteria.
%                      - Default: 'all'.
%
%   'UI'             - (UI Handle) Handle to a user interface for displaying progress.
%                      - Enables progress dialogs during long operations.
%                      - Default: [] (no UI).
%
%   'outline'        - (String) Outlining method for clusters.
%                      Options:
%                        'none'  - No outlining (default).
%                        'roi'   - Outline based on regions of interest
%                                   (whole integers)
%                        'bins'  - Outline based on color bins.
%                        'map'   - Outline the entire map.
%
%   'grow'           - (Integer) Number of vertices to grow or shrink clusters.
%                      - Positive values grow clusters; negative values shrink.
%                      - Default: 0 (no growth/shrinkage).
%
%   'clusterOrder'   - (String) Order in which clusters are processed.
%                      Options:
%                        'random'     - Randomize cluster processing order (default).
%                        'sequential' - Process clusters sequentially.
%
%   'growVal'        - (String) Value assignment method during cluster growth.
%                      Options:
%                        'edge' - Assign edge values during growth (default).
%                        'mean' - Assign mean values during growth.
%
%   'priorClusters'  - (Cell Array) Predefined clusters to use instead of computing new clusters.
%                      - Each cell contains indices of vertices belonging to a cluster.
%                      - Default: [] (compute clusters based on data).
%
% **Outputs (Detailed)**
% ---------------------
%   1. overlay    - Handle to the created overlay patch. This patch represents the
%                 visualized data on the specified hemisphere(s) within the
%                 provided figure.
%
%   2. colormapSG - Structure containing colormap information:
%                  - colormapSG.map      : The RGB colormap used for the overlay.
%                  - colormapSG.dataMap  : Numerical data mapped to the colormap bins.
%
%   3. ticksSG    - Structure containing colorbar tick information:
%                  - ticksSG.ticks  : Numeric positions of ticks on the colorbar.
%                  - ticksSG.labels : String labels corresponding to the ticks.
%
%   4. dataCAll   - Cell array where each cell contains the color data for a specific
%                 data set. Useful for handling multiple overlays.
%
%   5. dataTSAll  - Cell array where each cell contains the thresholded and scaled
%                 data corresponding to each data set.
%
%   6. dataClust  - Cell array containing cluster information if clustering was applied.
%                 Each cell corresponds to a data set and contains indices of vertices
%                 belonging to clusters.
%
%   7. transp     - Structure containing transparency information:
%                  - transp.vals      : Vector of transparency values for each vertex.
%                  - transp.map       : Mapping of data values to transparency levels.
%
%   8. modCmap    - Modified colormap matrix if alpha modulation was applied.
%                 Facilitates advanced transparency effects based on auxiliary data.
%
% **Function Workflow**
% --------------------
%   1. **Input Validation**:
%      - Ensures mandatory inputs (`brainFig`, `allData`, `underlays`, `hemi`) are provided.
%      - Validates the number of optional arguments.
%
%   2. **Argument Parsing**:
%      - Parses and validates name-value pair arguments, setting defaults where necessary.
%      - Handles multi-dimensional data by ensuring options are cell arrays matching data dimensions.
%
%   3. **Data Preprocessing**:
%      - Transposes `allData` and `pMap` if necessary to match vertex count.
%      - Handles NaN and Inf values by setting them to zero or the maximum finite value.
%
%   4. **Thresholding**:
%      - Applies positive/negative value filtering based on 'pos' and 'neg' options.
%      - Applies scaling, normalization, or percentile conversion based on 'vls'.
%      - Applies thresholding to remove data within the specified interval.
%
%   5. **Clustering (Optional)**:
%      - Identifies and retains clusters based on `clusterThresh`.
%      - Supports ROI-based clustering and bin-based outlines.
%
%   6. **Boundary Processing (Optional)**:
%      - Generates cluster boundaries if outlining or map growing/shrinking is specified.
%
%   7. **Smoothing (Optional)**:
%      - Applies vertex-based smoothing based on `smoothSteps`, `smoothArea`, and `smoothType`.
%
%   8. **Binarization (Optional)**:
%      - Converts data to binary values based on the 'binarize' option.
%
%   9. **Colormap Mapping**:
%      - Maps processed data to the specified colormap, handling multi-dimensional mappings if necessary.
%
%   10. **Alpha Modulation (Optional)**:
%       - Adjusts transparency based on `modData` and related parameters.
%
%   11. **Patch Creation**:
%       - Creates the overlay patch within the specified figure, applying vertex and face data,
%         color data, and transparency settings.
%
%   12. **Output Structuring**:
%       - Assigns outputs based on the processed data and visualization settings.
%
% **Error Handling**
% -----------------
%   The function includes several error checks to ensure robust operation:
%
%   - **Missing Arguments**:
%     - Throws an error if any of the mandatory inputs (`brainFig`, `allData`, `underlays`, `hemi`) are missing.
%     ```matlab
%     error('You are missing a mandatory argument: brainFig, allData, underlays, or hemi.');
%     ```
%
%   - **Excessive Arguments**:
%     - Throws an error if more optional arguments are provided than expected.
%     ```matlab
%     error('You have supplied too many arguments. Check the name-value pair inputs.');
%     ```
%
%   - **Invalid Parameter Names**:
%     - Throws an error if an unrecognized parameter name is provided.
%     ```matlab
%     error('%s is not a recognized parameter name', inpName);
%     ```
%
%   - **Dimension Mismatch**:
%     - Throws an error if optional parameters do not match the dimensions of `allData`.
%     ```matlab
%     error('%s has too many inputs for the parameter name', flds{i});
%     ```
%
%   - **Data Integrity**:
%     - Handles NaN and Inf values gracefully by setting them to zero or the maximum finite value.
%
% **Examples**
% --------
%   Below are several examples demonstrating how to use the `patchOverlay` function
%   in various scenarios.
%
%   **Example 1: Basic Overlay on Left Hemisphere**
%   ```matlab
%   brainFig = figure;
%   load('underlays.mat'); % Assume this loads underlays.left and underlays.right
%
%   % Prepare your data
%   curvatureData = randn(10000, 1); % Example data for left hemisphere
%
%   % Patch the data onto the left hemisphere
%   [overlay, cmapSG, ticksSG] = patchOverlay(brainFig, curvatureData, underlays, 'lh');
%   ```
%
%   **Example 2: Overlay on Both Hemispheres with Percentile Scaling and Thresholding**
%   ```matlab
%   % Prepare your data for both hemispheres
%   curvatureData = randn(20000, 1); % Example data for both hemispheres
%
%   % Patch the data onto both hemispheres with percentile scaling and thresholding
%   [overlay, cmapSG, ticksSG] = patchOverlay(brainFig, curvatureData, underlays, 'both', ...
%       'vls', 'prct', 'thresh', [-2 2]);
%   ```
%
%   **Example 3: Overlay with Custom Colormap and Inverted Colors**
%   ```matlab
%   % Define a custom colormap (e.g., parula) and invert it
%   customCmap = parula(256);
%
%   % Patch the data onto the right hemisphere with custom colormap and inverted colors
%   [overlay, cmapSG, ticksSG] = patchOverlay(brainFig, curvatureData, underlays, 'rh', ...
%       'colormap', customCmap, 'invertColors', 'true');
%   ```
%
%   **Example 4: Overlay with Smoothing and Opacity Adjustment**
%   ```matlab
%   [overlay, cmapSG, ticksSG] = patchOverlay(brainFig, curvatureData, underlays, 'lh', ...
%       'smoothSteps', 2, 'smoothArea', 1, 'opacity', 0.8);
%   ```
%
%   **Example 5: Overlay with Statistical Thresholding and Clustering**
%   ```matlab
%   pValues = rand(10000, 1);        % Example p-values
%   % Patch the data with p-value thresholding and cluster size filtering
%   [overlay, cmapSG, ticksSG, ~, ~, dataClust] = patchOverlay(brainFig, curvatureData, underlays, 'lh', ...
%       'pMap', pValues, 'pThresh', 0.05, 'clusterThresh', 10);
%   ```
%
%   **Example 6: Overlay with Alpha Modulation Based on Auxiliary Data**
%   ```matlab
%   auxData = rand(10000, 1);         % Auxiliary data for alpha modulation
%   [overlay, cmapSG, ticksSG, ~, ~, ~, transp, modCmap] = patchOverlay(brainFig, curvatureData, underlays, 'lh', ...
%       'modData', auxData, 'absMod', 'On', 'minAlphaMod', 0.2, 'maxAlphaMod', 0.8);
%   ```
%
%   **Example 7: Advanced Usage with Multiple Colormaps and Custom Tick Data**
%   ```matlab
%   % Prepare multiple data sets
%   dataSet1 = randn(10000, 1);
%   dataSet2 = randn(10000, 1);
%
%   % Define a multi-dimensional colormap
%   multiCmap = rand(256, 256, 3); % Example multi-dimensional colormap
%
%   % Define custom ticks for each dimension
%   multiCmapTicks = [linspace(min(dataSet1), max(dataSet1), 10)', linspace(min(dataSet2), max(dataSet2), 10)'];
%
%   % Patch both data sets with the multi-dimensional colormap
%   [overlay, cmapSG, ticksSG] = patchOverlay(brainFig, [dataSet1 dataSet2], underlays, 'both', ...
%       'multiCmap', multiCmap, 'multiCmapTicks', multiCmapTicks);
%   ```
%
% **Notes**
% -----
%   - **Data Alignment**: Ensure that the number of vertices in `allData` matches the number of vertices in the specified hemisphere(s) within `underlays`.
%   - **Handling NaN and Inf**: The function automatically replaces NaN values with zero and Inf values with the maximum finite value in their respective data sets to prevent visualization issues.
%   - **Clustering and Thresholding**: When applying `clusterThresh`, only clusters larger than or equal to the specified threshold are retained. This is useful for highlighting significant regions while suppressing noise.
%   - **Smoothing**: The `smoothSteps` and `smoothArea` parameters allow for iterative smoothing of the data, which can help in creating more visually coherent maps by averaging over neighboring vertices.
%   - **Colormap Customization**: Users can specify any MATLAB-supported colormap or provide a custom RGB matrix. The `invertColors` option allows for reversing the colormap, which can be useful for emphasizing different data aspects.
%   - **Alpha Modulation**: The `modData` parameter enables dynamic transparency based on auxiliary data, allowing for multi-layered visualizations where transparency conveys additional information.
%   - **Multi-Dimensional Colormaps**: When working with multiple data sets, `multiCmap`, `multiCmapTicks`, and `multiCbData` facilitate complex color mappings across different dimensions of data.
%   - **Lighting Configuration**: The `'lights'` option allows users to customize lighting in the visualization. Setting it to `'off'` disables lighting, while providing `[azimuth elevation]` pairs enables custom lighting angles.
%
% **Author**
% -------
%   Alex Teghipco // alex.teghipco@uci.edu // Last Updated: 2024-12-01
%
% **See Also**
% --------
%   plotUnderlay, colormapper, smoothVertData, getClusters, getClusterBoundary, growMap

% Defaults
options = struct('vls','raw','thresh',[0 0],'pos','on','neg','on','operation','false','sclLims',[0 1],'compKeep',1,'smoothSteps', 0, 'smoothArea', 0, 'smoothToAssign','all','smoothThreshold', 'above', 'smoothType', 'neighbors','colormap','jet','colorSpacing','even','colorBins',1000,'colorSpecial','none','invertColors','false','limits',[],'binarize','none','inclZero','off','opacity',1,'UI',[],'clusterThresh',0,'pMap',zeros(size(allData)),'pThresh',1,'outline','none','grow',0,'clusterOrder','random','growVal','edge','priorClusters',[],'modData',[],'modCmap',[],'multiCmap',[],'absMod','On','incZeroMod','Off','minAlphaMod',0,'maxAlphaMod',1,'alphaModLims',[],'scndCbarAxis','same','multiCmapTicks',[],'multiCbData',[]);
optionNames = fieldnames(options);
oneDImp = {'pMap';'sclLims';'operation';'inclZero';'opacity';'UI';'clusterThresh';'outline';'grow';'clusterOrder';'growVal';'priorClusters';'modData';'modCmap';'multiCmap';'absMod';'incZeroMod';'minAlphaMod';'maxAlphaMod';'alphaModLims';'scndCbarAxis';'multiCmapTicks';'multiCbData'};
 
% Check inputs
if isempty(brainFig) || isempty(hemi) || isempty(underlays) || isempty(allData)
    error('You are missing an argument')
end
if length(varargin) > (length(fieldnames(options))*2)
    error('You have supplied too many arguments')
end  
 
% now parse the arguments
vleft = varargin(1:end);
for pair = reshape(vleft,2,[]) %pair is {propName;propValue}
    inpName = pair{1}; % make case insensitive by using lower() here but this can be buggy
    if any(strcmpi(inpName,optionNames)) % check if arg pair matches default
        def = options.(inpName); % default argument
        if ~isempty(pair{2}) % if passed in argument isn't empty, then write that in as the option
            options.(inpName) = pair{2};
        else
            options.(inpName) = def; % otherwise use the default values for the option
        end
    else
        error('%s is not a recognized parameter name',inpName)
    end
end

% loop over options and make sure everything is contained in a cell if it
% needs to be, and that there is an option specified for each dimension of
% the data
flds = fieldnames(options);
for i = 1:numel(flds)
    def = options.(flds{i});
    if ~any(strcmpi(flds{i},oneDImp)) % if this wasn't an argument that is 1-dimensional
        if ~iscell(options.(flds{i})) % then it should be a cell
            options.(flds{i}) = {options.(flds{i})};
        end
        if length(options.(flds{i})) < min(size(allData)) % and the cell should match the length of dimensions...
            options.(flds{i}) = [options.(flds{i}) repmat({def},[1,min(size(allData))-1])];
        elseif length(options.(flds{i})) > min(size(allData))
            error('%s too many inputs for parameter name',flds{i})
        end
    end
end

% flip input data if necessary
if ~isempty(allData)
    if size(allData,1) < size(allData,2)
        allData = allData';
    end
end
if ~isempty(options.pMap)
    if size(options.pMap,1) < size(options.pMap,2)
        options.pMap = options.pMap';
    end
end
 
% remove invalid data if necessary (inf, nan; these are un-patchable)
if ~isempty(allData)
    invIdx = find(isnan(allData));
    allData(invIdx) = 0;
end
if ~isempty(options.pMap)
    invIdx = find(isnan(options.pMap));
    options.pMap(invIdx) = 0;
end
if ~isempty(allData)
    for j = 1:size(allData,2)
        invIdx = find(isinf(allData(:,j)));
        dm = max(allData(:,j));
        allData(invIdx,j) = dm;
    end
end
if ~isempty(options.pMap)
    for j = 1:size(options.pMap,2)
        invIdx = find(isinf(options.pMap(:,j)));
        dm = max(options.pMap(:,j));
        options.pMap(invIdx,j) = dm;
    end
end
 
% if there is a UI passed in, start loading bar...
if ~isempty(options.UI)
    d = uiprogressdlg(options.UI,'Title','Patching underlay',...
        'Message','Thresholding values...');
end

for di = 1:size(allData,2)
    data = allData(:,di);
    % threshold values
    [dataT{di},dataC{di}] = dataThresh(data,'pos',options.pos{di},'neg',options.neg{di},'vls',lower(options.vls{di}),'sclLims',options.sclLims,'thresh',options.thresh{di},'pMap',options.pMap(:,di),'pThresh',options.pThresh{di});

    % find min and max
    pos{di} = find(dataT{di} > 0);
    neg{di} = find(dataT{di} < 0);
    minThreshPos{di} = min(dataT{di}(pos{di}));
    minThreshNeg{di} = max(dataT{di}(neg{di}));
    
    if isempty(options.limits{di})
        options.limits{di} = [min(dataT{di}) max(dataT{di})];
    end
    
    if minThreshPos{di} > options.limits{di}(2)
        minThreshPos{di} = options.limits{di}(2);
    end
    
    if minThreshNeg{di} < options.limits{di}(1)
        minThreshNeg{di} = options.limits{di}(1);
    end
    
    if isempty(minThreshNeg{di})
        minThreshNeg{di} = 0;
    end
    if isempty(minThreshPos{di})
        minThreshPos{di} = 0;
    end
end

% Get clusters if they are needed
if options.clusterThresh ~= 0 | options.grow ~= 0 | strcmpi(options.outline,'map') | strcmpi(options.outline,'bins') | strcmpi(options.binarize,'clusters') == 1 | ~isempty(options.priorClusters)
    if ~isempty(options.UI)
        d.Message = ['Finding blobs...this may take some time if you have large blobs in your map'];
        d.Value = 0.1;
    end
    
    if isempty(options.priorClusters)
        atv = find(all(horzcat(dataT{:}) == 0,2)==0);
        [dataClust, clusterLen] = getClusters(atv, underlays.(hemi).Faces);
    else
        dataClust = options.priorClusters;
        clusterLen = cellfun('length',dataClust);
    end
    
    dataClustOrig = dataClust;
    % remove clusters with cluster size less than threshold
    clustIdx = find(clusterLen < options.clusterThresh);
    dataClust(clustIdx) = [];

    atv = vertcat(dataClust{:});
    [clustThresh,~] = setdiff([1:size(allData,1)],atv);
    for i = 1:length(dataT)
        dataT{i}(clustThresh) = 0;
    end
    
    % save maximum cluster size to options
    options.clusterLimit = max(clusterLen);
    options.clusters = dataClust;
end

% Roi-based clusters are a little different so convert here...
if strcmpi(options.outline,'roi') %& isempty(options.priorClusters)
    if ~isempty(options.UI)
        d.Message = ['Finding ROI blobs...this may take some time if you have large blobs in your map'];
        d.Value = 0.1;
    end
    
    atv = find(all(horzcat(dataT{:}) == 0,2)==0);

    hz = horzcat(dataT{:});
    inUn = unique(hz(atv,:));
    
    id = find(inUn == 0);
    inUn(id) = [];
    for roii = 1:length(inUn)
        id = find(all(horzcat(dataT{:}) == inUn(roii),2)==1);
        dataClust{roii} = id;
    end
    clusterLen = cellfun('length',dataClust);
    
    % remove clusters with cluster size less than threshold
    clustIdx = find(clusterLen < options.clusterThresh);
    dataClust(clustIdx) = [];
    
    atv = vertcat(dataClust{:});
    [clustThresh,~] = setdiff([1:size(allData,1)],atv);
    for i = 1:length(dataT)
        dataT{i}(clustThresh) = 0;
    end
    
    % save maximum cluster size to options
    options.clusterLimit = max(clusterLen);
    options.clusters = dataClust;
end
  
% Bin-based outlines are a little different too...we will turn bins into
% clusters...
if strcmpi(options.outline,'bins')
   % other outline functions have to occur before colormapping so this is
   % temporary...
   warning('This option is still under development!!! It may break lots of things.')
   [colormapMapTmp,cDataTmp,colormapdataMapTmp,ticksTicksTmp,tickslabelsTmp,m] = colormapper(dataT{:},'colormap',options.colormap{1},'colorSpacing',options.colorSpacing{1},'colorBins',options.colorBins{1},'colorSpecial',options.colorSpecial{1},'invertColors',options.invertColors{1},'limits',[min(options.limits{1}) max(options.limits{1})],'thresh',options.thresh{1});
   un = unique(m);
   clear dataClust
   for i = 1:length(un)
       dataClust{i} = find(m == un(i));
   end
end

% Turn clusters into boundaries if necessary
if ~strcmpi(options.outline,'none') | options.grow ~= 0
    if ~isempty(options.UI)
        d.Message = ['Fetching boundary vertices...'];
        d.Value = 0.2;
    end
    
    dataClust_all = dataClust;
    if strcmpi(options.outline,'roi')
        dataClust2 = getClusterBoundary(dataClust, underlays.(hemi).Faces);
        dataClust = cellfun(@(x,y) setdiff(x,intersect(vertcat(dataClust2{:}),x)),dataClust,dataClust2, 'UniformOutput', false);
    end
    
    dataClust = getClusterBoundary(dataClust, underlays.(hemi).Faces);
    hz = horzcat(dataT{:});

    for clusteri = 1:length(dataClust)
        % if you are doing an outline we need to get mean value for
        % each cluster
        if ~strcmpi(options.outline,'none')
            tmp = mean(mean(hz(dataClust_all{clusteri},:)));
            if tmp <= 0 & tmp >= min(vertcat(minThreshNeg{:}))
                tmp = min(vertcat(minThreshNeg{:}))-0.0001;
            end
            if tmp >= 0 & tmp <= min(vertcat(minThreshPos{:}))
                tmp = min(vertcat(minThreshPos{:}))+0.00001;
            end

            oVals{clusteri} = repmat(tmp,[length(dataClust{clusteri}),1]);
        end
        % if you are growing your map then we get closest non-zero edges
        if strcmpi(options.outline,'none') & options.grow ~= 0
            [~,neighborhood] = pdist2(underlays.(hemi).Vertices(dataClust_all{clusteri},:),underlays.(hemi).Vertices(dataClust{clusteri},:),'seuclidean','Smallest',1);
            oVals{clusteri} = mean(hz(dataClust_all{clusteri}(neighborhood),:),2);
        end
    end

    % now grow the boundary
    if ~isempty(options.UI)
        d.Message = ['Growing/shrinking map...'];
        d.Value = 0.5;
    end

    atv = vertcat(dataClust_all{:});
    if ~strcmpi(options.outline,'none')
        if options.grow > 0
            options.grow = options.grow+1;
        elseif options.grow < 0
            options.grow = options.grow-1;
        end
    end

    [grownVert,atv2,growVertTracker2] = growMap(dataClust,options.grow,atv,underlays.(hemi).Faces); % grownVert is boundary vertices + expansion of them

    gwTmp = vertcat(growVertTracker2{:});

    if options.grow > 0
        gw = setdiff(gwTmp,atv);
    elseif options.grow <= 0
        gw = gwTmp;
    end

    ov = vertcat(oVals{:});
    bv = vertcat(dataClust{:}); % boundary verts

    if options.grow ~= 0
        if ~strcmpi(options.outline,'none') & options.grow < 0
            gw = [gw; bv];
        end

        [~,neighborhood] = pdist2(underlays.(hemi).Vertices(bv,:),underlays.(hemi).Vertices(gw,:),'seuclidean','Smallest',1);
    else
        neighborhood = 1:length(ov);
    end

    if options.grow >= 0
        ov2 = ov(neighborhood);
    elseif options.grow < 0
        if strcmpi(options.outline,'none')
            ov2 = mean(hz(gw,:));
        else
            ov2 = ov(neighborhood);
        end
    end

    % now write out the data
    if ~strcmpi(options.outline,'none') %& options.grow == 0
        % if outlining, write in the boundary vertices
        % (which should have not been expanded) and then remove all
        % other vertices
        for di = 1:length(dataT)
            dataT{di}(gw) = ov2;
            [c,~] = setdiff(1:length(dataT{di}),gw);
            dataT{di}(c) = 0;
        end
    end

    if strcmpi(options.outline,'none') & options.grow ~= 0
        if options.grow > 0
            % if growing without outline, you neeed to just add oVals/gw
            % to dataT
            for di = 1:length(dataT)
                dataT{di}(gw) = ov2;
            end
        elseif options.grow < 0
            % if shrinking without outline, you neeed to just remove gw
            % from dataT
            for di = 1:length(dataT)
                dataT{di}(gw) = 0;
            end
        end
    end
end

if ~isempty(options.UI)
    if vertcat(options.smoothArea{:}) ~= 0
        d.Message = ['Smoothing...This can take some time depending on your settings'];
        d.Value = 0.3;
    end
end

% smooth data
for di = 1:length(dataT)
    dataTS{di} = smoothVertData(dataT{di}, underlays.(hemi).Vertices, underlays.(hemi).Faces, 'smoothSteps', options.smoothSteps{di}, 'smoothArea', options.smoothArea{di}, 'toAssign', options.smoothToAssign{di});
end

if ~isempty(options.UI) & ~strcmpi(options.binarize,'none')
    d.Message = ['Binarizing...'];
    d.Value = 0.4;
end

for di = 1:length(dataTS)
    switch (lower(options.binarize{di}))
        case 'map'
            id = find(dataTS{di} ~= 0);
            dataTS{di}(id) = 1;
            %options.limits{di} = [0 1];
        case 'clusters'
            % one problem is that smaller clusters will predominantly map onto
            % one end of the spectrum unless they are shuffled so lets do that
            % now
            if di == 1
                switch options.clusterOrder
                    case 'random'
                        if isempty(options.priorClusters)
                            randi = randperm(length(dataClust));
                            dataClust = dataClust(randi);
                        end
                end
            end
            for clusteri = 1:length(dataClust)
                dataTS{di}(dataClust{clusteri}) = clusteri;
            end
            options.limits{di} = [min(dataTS{di}) max(dataTS{di})];
            atv = vertcat(dataClust{:});
            try
                [c, ia] = setdiff([1:dataTS{di}],atv);
            catch
                [c, ia] = setdiff([1:length(dataTS{di})],atv);
            end
            dataTS{di}(c) = 0;
    end
end

% map colors onto data
if ~isempty(options.UI)
    d.Message = ['Mapping colors...'];
    d.Value = 0.6;
end
 
for di = 1:length(dataTS)
    %if length(dataTS) == 1 | (length(dataTS) > 1  & (isempty(options.multiCmap) | isempty(options.multiCmapTicks) | isempty(options.multiCbData)))
    if length(dataTS) == 1 | length(dataTS) > 1 | isempty(options.multiCmapTicks) | isempty(options.multiCbData)
        if  ~strcmpi(options.outline,'bins')
            [colormapMapTmp,cDataTmp,colormapdataMapTmp,ticksTicksTmp,tickslabelsTmp] = colormapper(dataTS{di},'colormap',options.colormap{di},'colorSpacing',options.colorSpacing{di},'colorBins',options.colorBins{di},'colorSpecial',options.colorSpecial{di},'invertColors',options.invertColors{di},'limits',[min(options.limits{di}) max(options.limits{di})],'thresh',options.thresh{di});
        end
        colormap{di}.map = colormapMapTmp;
        cData{di} = cDataTmp;
        colormap{di}.dataMap = colormapdataMapTmp;
        ticks{di}.ticks = ticksTicksTmp;
        ticks{di}.labels = tickslabelsTmp;
    end
end

% generate multidimensional colormap data if it's missing...
if length(dataTS) > 1  
    % if isempty(options.multiCmap)
    %     for di = 1:length(dataTS)
    %         cmap(:,:,di) = colormap{di}.map;
    %     end
    %     cust = customColorMapInterpBars(cmap,size(cmap,1),options.scndCbarAxis);
    %     options.multiCmap = flipud(cust);
    % end
    if isempty(options.multiCmap)
        for di = 1:length(dataTS)
            cmap(:,:,di) = colormap{di}.map;
        end
        cust = customColorMapInterpBars(cmap,size(cmap,1),options.scndCbarAxis);
        
        % Debug output
        % fprintf('MultiCmap size: [%d, %d, %d]\n', size(cust));
        % figure;
        % subplot(1,2,1);
        % imagesc(squeeze(cust(:,:,1)));
        % title('Red Channel');
        % subplot(1,2,2);
        % imagesc(cust(:,:,2));
        % title('Green Channel');
        % colorbar;
        
        options.multiCmap = flipud(cust);
    end


    % if isempty(options.multiCmapTicks)
    %     for di = 1:length(dataTS)
    %         options.multiCmapTicks(:,di) = ticks{di}.labels;
    %     end
    % end
    if isempty(options.multiCmapTicks)
        % Get number of ticks for each dimension
        numTicks1 = length(ticks{1}.labels);
        numTicks2 = length(ticks{2}.labels);

        % Create matrix with max number of ticks
        maxTicks = max(numTicks1, numTicks2);
        options.multiCmapTicks = zeros(maxTicks, 2);

        % Fill in ticks, padding with NaN if needed
        options.multiCmapTicks(1:numTicks1, 1) = ticks{1}.labels;
        options.multiCmapTicks(1:numTicks2, 2) = ticks{2}.labels;

        % If dimensions are different, pad shorter one with last value
        if numTicks1 < maxTicks
            options.multiCmapTicks(numTicks1+1:end, 1) = options.multiCmapTicks(numTicks1, 1);
        end
        if numTicks2 < maxTicks
            options.multiCmapTicks(numTicks2+1:end, 2) = options.multiCmapTicks(numTicks2, 2);
        end
    end
    % if isempty(options.multiCbData)
    %      for di = 1:length(dataTS)
    %         options.multiCbData(:,di) = colormap{di}.dataMap;
    %     end
    % end
    
    % now map data onto this new colormap...
    for di = 1:length(dataTS)
        tf = options.multiCbData(:,di)' >= dataTS{di};
        [~,m] = max(tf,[],2);
        ma(:,di) = m;
        id = find(dataTS{di} > max(options.multiCmapTicks(:,di)));
        %id = find(options.multiCbData(:,di) > max(options.multiCmapTicks(:,di)));
        ma(id,di) = size(options.multiCbData(:,di),1);
        %id = find(options.multiCbData(:,di) < min(options.multiCmapTicks(:,di)));
        id = find(dataTS{di} < min(options.multiCmapTicks(:,di)));
        ma(id,di) = 1;
    end
    clear cData
    
    if length(dataTS) == 2
        sz = length(ma);
        m = [ma(:,1); ma(:,1); ma(:,1)];
        m2 = [ma(:,2); ma(:,2); ma(:,2)];
        m3 = ones([sz,1]);
        m3 = [m3; m3+1; m3+2];

        try
            ind = sub2ind([size(options.multiCmap)],m,m2,m3);
        catch
            m = min(m, size(options.multiCbData,1)-1); % Clamp to max size
            m2 = min(m2, size(options.multiCbData,2)-1); % Clamp to max size
            ind = sub2ind([size(options.multiCmap)],m,m2,m3);
        end

        cData{1} = options.multiCmap(ind);
        cData{1} = reshape(cData{1},[sz,3]);
        cData{1} = squeeze(cData{1});
        % sz = length(ma);
        % m = ma(:,1);
        % m2 = ma(:,2);
        % cData{1} = zeros(sz,3);
        % 
        % for k = 1:3
        %     ind = sub2ind(size(options.multiCmap), m, m2, k*ones(sz,1));
        %     cData{1}(:,k) = options.multiCmap(ind);
        % end
    elseif length(dataTS) == 3
        sz = length(ma);
        m = [ma(:,1); ma(:,1); ma(:,1)];
        m2 = [ma(:,2); ma(:,2); ma(:,2)];
        m3 = [ma(:,3); ma(:,3); ma(:,3)];
        m4 = ones([sz,1]);
        m4 = [m4; m4+1; m4+2];
        
        ind = sub2ind([size(options.multiCmap)],m,m2,m3,m4);
        cData{1} = options.multiCmap(ind);
        cData{1} = reshape(cData{1},[sz,3]);
        cData{1} = squeeze(cData{1});
    end
end

if ~isempty(options.modData)    
    id1 = find(options.modData >= 0);
    id2 = find(options.modData < 0);
    
    if isempty(options.alphaModLims)
        if strcmpi(options.absMod ,'On')
            minVal1 = min(options.modData(id1));
            maxVal1 = max(options.modData(id1));
            minVal2 = min(options.modData(id2));
            maxVal2 = max(options.modData(id2));
            
            options.alphaModLims(2) = max([maxVal1 maxVal2]);
            options.alphaModLims(1) = min([minVal1 minVal2]);
        else
            options.alphaModLims(1) = min(options.modData);
            options.alphaModLims(2) = max(options.modData);
        end
    end
    
    if strcmpi(options.absMod ,'On')
        l(:,1) = linspace(0,options.alphaModLims(1),size(colormap{1}.map,1));
        l(:,2) = linspace(0,options.alphaModLims(2),size(colormap{1}.map,1));
    else
        l(:,1) = linspace(options.alphaModLims(1),options.alphaModLims(2),size(colormap{1}.map,1));
    end
    
    lv = linspace(options.minAlphaMod,options.maxAlphaMod,size(colormap{1}.map,1));
    s = zeros(size(options.modData));
    if size(l,2) == 2
        tf = l(:,1)' <= options.modData(id2);
        [~,m] = max(tf,[],2);
        mData = lv(m);
        id = find(options.modData(id2) < options.alphaModLims(1));
        mData(id) = lv(end);
        id = find(options.modData(id2) > 0);
        mData(id) = lv(1);
        s(id2) = mData;
        
        tf = l(:,2)' >= options.modData(id1);
        [~,m] = max(tf,[],2);
        mData = lv(m);
        id = find(options.modData(id1) < 0);
        mData(id) = lv(1);
        id = find(options.modData(id1) > options.alphaModLims(2));
        mData(id) = lv(end);
        s(id1) = mData;
    else
        tf = l' >= options.modData;
        [~,m] = max(tf,[],2);
        mData = lv(m);
        id = find(options.modData < options.alphaModLims(1));
        mData(id) = lv(1);
        id = find(options.modData > options.alphaModLims(2));
        mData(id) = lv(end);
        s = mData;
    end
                                
    if isempty(options.modCmap)
        modCmapIn(:,:,1) = colormap{1}.map;
        modCmapIn(:,:,2) = ones(size(colormap{1}.map));
        modCmap = customColorMapInterpBars(modCmapIn,size(modCmapIn,1),'same');
        modCmap = flipud(modCmap);
    else
        modCmap = options.modCmap;
    end
else
    modCmap = [];
    s = [];
end

% setup alpha data
transp.vals = ones([size(allData,1)],1)*options.opacity;
if strcmpi(options.inclZero,'off')
    for di = 1:length(dataTS)
        id = find(all(horzcat(dataTS{:}) == 0,2)==1);
        transp.vals(id) = 0;
    end
end

% find alpha mapping for each "color" here. transp.map will be this.
% transp.vals can be alph from below.
try
    if strcmpi(options.colorSpacing,'even')
        transp.map = ones(1,length(colormap{1}.dataMap)-1)*options.opacity;
    else
        transp.map = ones(size(colormap{1}.dataMap))*options.opacity;
    end
catch
    transp.map = ones(size(options.multiCbData,1),1)*options.opacity;
end


% if strcmpi(options.inclZero,'off') & isempty(s)
%    id = find(all(horzcat(dataTS{:}) == 0,2)==1);
%    transp.vals(id) = 0;
% end

if ~isempty(s)
    if find(size(s) == size(transp.vals,1)) == 2
        s = s';
    end
    transp.vals = transp.vals.*s;
end

allVert = [1:size(allData,1)];
atv = allVert;
f = underlays.(hemi).Faces;
v = underlays.(hemi).Vertices;
switch options.inclZero
    case 'off'
        id = find(any(horzcat(dataTS{:}) ~= 0,2)==1);
        v = v(id,:);
        %da = dataTS(id);        
        c = cData{1}(id,:);
        atv = atv(id);
        transp.vals = transp.vals(id);
    case 'on'
        v = underlays.(hemi).Vertices;
        %da = dataTS;
        c = cData{1};
end

[C,ia] = setdiff(allVert,atv);
removeVert = allVert(ia); % all faces that don't have these verts
removeVertX = ismember(f(:,1),removeVert);
removeVertY = ismember(f(:,2),removeVert);
removeVertZ = ismember(f(:,3),removeVert);
removeVertXYZ = removeVertX+removeVertY+removeVertZ;
removeVertXYZIdx = find(removeVertXYZ > 0);
f(removeVertXYZIdx,:) = [];

vl = [1:length(atv)];
[M, ia] = ismember(f, atv);
f(M) = vl(ia(M));

if ~isempty(options.UI)
    d.Message = ['Replacing zeros and making intial patch...'];
    d.Value = 0.7;
end
 
if ~isempty(brainFig)
    % save properties    
    figure(brainFig)
    tmp = findall(brainFig.Children,'Type','Axes');
    if length(tmp) > 1
        tmp = tmp(end);
    end
    overlay = patch(tmp,'Faces',f,'FaceAlpha','interp','EdgeAlpha','interp','EdgeColor','none','Vertices',v,'FaceVertexCData',c,'FaceVertexAlphaData',transp.vals,'AlphaDataMapping','none','CDataMapping','direct','facecolor','interp','edgecolor','none','SpecularColorReflectance',underlays.(hemi).SpecularColorReflectance,'SpecularExponent',underlays.(hemi).SpecularExponent,'SpecularStrength',underlays.(hemi).SpecularStrength,'FaceLighting',underlays.(hemi).FaceLighting,'DiffuseStrength',underlays.(hemi).DiffuseStrength,'AmbientStrength',underlays.(hemi).AmbientStrength,'BackFaceLighting',underlays.(hemi).BackFaceLighting);
end
 
if ~exist('dataClust','var')
    dataClust = [];
end

if exist('dataClust_all','var')
   dataClust = dataClust_all; 
end

if exist('dataClustOrig','var')
   dataClust = dataClustOrig; 
end

%multiCmap = options.multiCmap;

if length(dataTS) == 1
    colormap = colormap{1};
    ticks = ticks{1};
    dataTSAll = dataTS{1};
    dataCAll = dataC{1};
else
    colormap = options.multiCmap;
    ticks = options.multiCmapTicks;
    dataCAll = dataC;
    dataTSAll = dataTS;
end

varargout{1} = overlay;
varargout{2} = colormap;
varargout{3} = ticks;
varargout{4} = dataCAll;
varargout{5} = dataTSAll;
varargout{6} = dataClust;
varargout{7} = transp;
varargout{8} = modCmap;
% varargout{9} = multiCmap;
% varargout{10} = options.multiCmapTicks;
% varargout{11} = options.multiCbData;
%varargout{13} = options.multiCbData;
