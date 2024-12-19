function [varargout] = patchUnderlaySG(underlays, varargin)
% Patch Curvature Data Onto Surface Underlays
%
%   [underlays, colormapSG, ticksSG, v, o] = PATCHUNDERLAYSG(underlays, ...)
%   patches curvature data onto existing surface underlays for left and/or 
%   right hemispheres. The function processes curvature data, applies various 
%   transformations and thresholds, and maps the data onto the surface with 
%   customizable visualization options.
%
% **Mandatory Input:** 
% -----------------
%       underlays   - Structure containing left and right surface patches.
%                     Fields:
%                       .left   - Left hemisphere surface patch (can be empty).
%                       .right  - Right hemisphere surface patch (can be empty).
%
% **Name-Value Pair Arguments:**
% ----------------------------
%       'lh'            - Left hemisphere curvature data (numeric array).
%       'rh'            - Right hemisphere curvature data (numeric array).
%       'pos'           - Include positive curvature values ('on' | 'off'). 
%                         Default: 'on'.
%       'neg'           - Include negative curvature values ('on' | 'off'). 
%                         Default: 'on'.
%       'vls'           - Data normalization/scaling method (string). 
%                         Options:
%                           'raw'        - Patch raw values (default).
%                           'prct'       - Convert values to percentiles.
%                           'prctSep'    - Convert values to percentiles 
%                                          separately for positive and
%                                          negative values.edit brainS
%                           'norm'       - Normalize values.
%                           'normSep'    - Normalize positive and negative values separately.
%                           'scl'        - Scale values between -1 and 1.
%                           'sclSep'     - Scale values between -1 and 1 
%                                          separately for positive and negative values.
%                           'sclAbs'     - Scale values between 0 and 1.
%                           'sclAbsSep'  - Scale values between 0 and 1 
%                                          separately for positive and negative values.
%                         Default: 'raw'.
%       'thresh'        - Threshold interval [a b] to remove data. 
%                         Default: [0 0].
%       'colormap'      - Colormap specification. Can be:
%                           - Name of a MATLAB colormap or a custom colormap 
%                             from BrainSurfer (e.g., 'jet', 'parula', 'viridis', etc.).
%                           - An Lx3 matrix specifying a custom colormap.
%                         Default: 'jet'.
%       'colorSpacing'  - Method to space colors between limits (string). 
%                         Options:
%                           'even'                - Evenly spaced between limits (default).
%                           'center on zero'     - Midpoint of colorbar at zero.
%                           'center on threshold'- Midpoint of colorbar at specified thresholds.
%       'colorBins'     - Number of color bins in the colorbar (numeric). 
%                         Default: 1000.
%       'colorSpecial'  - Special color assignments (string). 
%                         Options:
%                           'randomizeClusterColors' - Assign random colors to each data cluster.
%                           'none'                   - No special color assignments (default).
%       'invertColors'  - Invert the colormap ('true' | 'false'). 
%                         Default: 'false'.
%       'limits'        - Two-element vector specifying the colormap limits [min max]. 
%                         Default: [min(data) max(data)].
%       'opacity'       - Opacity of the patch (numeric between 0 and 1). 
%                         Default: 1.
%       'binarize'      - Binarize sulcal/gyral information into two colors (numeric threshold).
%       'inclZero'      - Determine if zero values are patched ('on' | 'off'). 
%                         Default: 'no'.
%       'lights'        - Fix lighting conditions ('on' | 'off').
%       'smoothSteps'   - Number of smoothing iterations (numeric). 
%                         Default: 0 (no smoothing).
%       'smoothArea'    - Number of closest vertices for smoothing (numeric). 
%                         Default: 0.
%       'smoothThreshold'- Apply smoothing based on data threshold ('above' | 'below'). 
%                         Default: 'above'.
%       'smoothType'    - Type of smoothing ('neighbors' | 'neighborhood'). 
%                         Default: 'neighbors'.
%       'sclLims'       - Scaling limits for 'scl' and related options [min max]. 
%                         Default: [0 1].
%       'pMap'          - P-value map for statistical thresholding (numeric array).
%       'pThresh'       - P-value threshold for significance (numeric). 
%                         Default: 1.
%       'operation'     - Operation mode for data manipulation (string). 
%                         Default: 'false'.
%       'compKeep'      - Number of components to keep (numeric). 
%                         Default: 1.
%       'surfC'         - Surface color as RGB triplet (1x3 numeric array). 
%                         Default: [0.5 0.5 0.5].
%       'sulci'         - Sulcal information for opacity mapping (numeric array).
%       'gyri'          - Gyral information for opacity mapping (numeric array).
%       'surfOpacity'   - Opacity of the surface (numeric between 0 and 1). 
%                         Default: 1.
%       'sgOpacity'     - Opacity of sulcal/gyral regions (numeric between 0 and 1). 
%                         Default: 1.
%       'UI'            - User interface handle for progress dialog (UI object).
%
% **Outputs:**
% ------------
%       underlays  - Updated structure with patched surface information.
%       colormapSG - Structure containing colormaps and colorbar information.
%       ticksSG    - Structure with tick positions and labels for custom colorbar.
%       v          - Structure containing thresholded data values.
%       o          - Structure containing smoothed data values.
%
% **Examples:**
% -------------
%       % Example 1: Patch left hemisphere curvature data with default settings
%       [underlay, colormap, brain, data] = patchUnderlaySG(underlays, 'lh', curv1);
%
%       % Example 2: Patch both hemispheres with custom colormap and threshold
%       [underlay, colormap, brain, data] = patchUnderlaySG(underlays, ...
%           'lh', curv1, 'rh', curv2, ...
%           'pos', 'off', 'neg', 'off', ...
%           'vls', 'prct', 'thresh', [-2 2], ...
%           'colormap', 'viridis');
%
%       % Example 3: Advanced usage with smoothing and custom limits
%       [underlay, colormap, brain, data] = patchUnderlaySG(underlays, ...
%           'lh', curv1, 'rh', curv2, ...
%           'pos', 'off', 'neg', 'off', ...
%           'vls', 'scl', 'sclLims', [-1 1], ...
%           'thresh', [-2 2], ...
%           'pMap', pVals, 'pThresh', 0.05, ...
%           'operation', 'pc', 'compKeep', 1, ...
%           'smoothSteps', 2, 'smoothArea', 1, ...
%           'smoothThreshold', 'above', 'smoothType', 'neighbors');
%
% **Notes:**
% ----------
%       - Ensure that the curvature data provided for 'lh' and/or 'rh' matches 
%         the vertices of the corresponding surface patches.
%       - The function handles NaN and Inf values by setting them to zero or 
%         the maximum finite value, respectively.
%       - Smoothing is performed based on the number of steps and area specified.
%       - The progress dialog (if 'UI' is provided) updates during thresholding, 
%         binarizing, smoothing, and color mapping stages.
%
% **Author**
% -------
%   Alex Teghipco // alex.teghipco@uci.edu // Last Updated: 2024-12-01
%
%   See also:
%       dataThresh, smoothVertData, colormapper, customColorMapInterp

% Default options structure
options = struct(...
    'lh', [], ...
    'rh', [], ...
    'vls', 'raw', ...
    'thresh', [0 0], ...
    'pos', 'on', ...
    'neg', 'on', ...
    'pMap', [], ...
    'pThresh', 1, ...
    'operation', 'false', ...
    'sclLims', [0 1], ...
    'compKeep', 1, ...
    'smoothSteps', 0, ...
    'smoothArea', 0, ...
    'smoothThreshold', 'above', ...
    'smoothType', 'neighbors', ...
    'smoothToAssign', 'all', ...
    'colormap', 'gray', ...
    'colorSpacing', 'even', ...
    'colorBins', 1000, ...
    'colorSpecial', 'none', ...
    'invertColors', 'false', ...
    'limits', [], ...
    'binarize', [], ...
    'inclZero', 'on', ...
    'surfC', [0.5 0.5 0.5], ...
    'sulci', [], ...
    'gyri', [], ...
    'surfOpacity', 1, ...
    'sgOpacity', 1, ...
    'UI', [] ...
);
optionNames = fieldnames(options);

% Check input arguments
if length(varargin) < 2
    error('PATCHUNDERLAYSG:InsufficientArguments', 'You are missing an argument.');
end
if length(varargin) > (length(optionNames) * 2)
    error('PATCHUNDERLAYSG:TooManyArguments', 'You have supplied too many arguments.');
end  

% Parse name-value pair arguments
vleft = varargin;
for pair = reshape(vleft, 2, []) % pair is {paramName; paramValue}
    inpName = pair{1};
    if any(strcmpi(inpName, optionNames))
        matchedName = optionNames{strcmpi(inpName, optionNames)};
        options.(matchedName) = pair{2};
    else
        error('PATCHUNDERLAYSG:UnknownParameter', '%s is not a recognized parameter name.', inpName);
    end
end

% Validate that at least one hemisphere curvature data is provided
if isempty(options.lh) && isempty(options.rh)
    error('PATCHUNDERLAYSG:NoCurvatureData', 'You must provide curvature data for at least one hemisphere using ''lh'' or ''rh''.');
end

% Initialize output structures
ticksSG = struct('left', struct('ticks', [], 'labels', []), ...
                'right', struct('ticks', [], 'labels', []));
colormapSG = struct('left', struct('map', [], 'dataMap', []), ...
                    'right', struct('map', [], 'dataMap', []));

% Ensure curvature data is in column format
if ~isempty(options.lh) && size(options.lh, 1) < size(options.lh, 2)
    options.lh = options.lh';
end
if ~isempty(options.rh) && size(options.rh, 1) < size(options.rh, 2)
    options.rh = options.rh';
end

% Handle NaN and Inf values in curvature data
if ~isempty(options.lh)
    options.lh(isnan(options.lh)) = 0;
    finiteIdx = isfinite(options.lh);
    if any(~finiteIdx)
        dm = max(options.lh(finiteIdx));
        options.lh(~finiteIdx) = dm;
    end
end
if ~isempty(options.rh)
    options.rh(isnan(options.rh)) = 0;
    finiteIdx = isfinite(options.rh);
    if any(~finiteIdx)
        dm = max(options.rh(finiteIdx));
        options.rh(~finiteIdx) = dm;
    end
end

% Initialize progress dialog if UI is provided
if ~isempty(options.UI)
    d = uiprogressdlg(options.UI, 'Title', 'Patching Underlay', ...
                     'Message', 'Thresholding values...', ...
                     'Indeterminate', 'off', 'Cancelable', 'off');
end

% Threshold curvature values
if ~isempty(options.lh)
    [lo, vl] = dataThresh(options.lh, 'pos', options.pos, ...
                          'neg', options.neg, 'vls', lower(options.vls), ...
                          'sclLims', options.sclLims, 'thresh', options.thresh);
end
if ~isempty(options.rh)
    [ro, vr] = dataThresh(options.rh, 'pos', options.pos, ...
                          'neg', options.neg, 'vls', lower(options.vls), ...
                          'sclLims', options.sclLims, 'thresh', options.thresh);
end

% Update progress dialog
if ~isempty(options.UI)
    d.Message = 'Binarizing...';
    d.Value = 0.1;
end

% Binarize curvature data if specified
if ~isempty(options.binarize)
    if ~isempty(options.lh)
        id1 = lo >= options.binarize;
        id2 = lo < options.binarize;
        lo(id1) = 1;
        lo(id2) = 0.01;
        options.colorBins = 2;
        [~, mi] = min(options.limits);
        options.limits(mi) = 0;
    end
    if ~isempty(options.rh)
        id1 = ro >= options.binarize;
        id2 = ro < options.binarize;
        ro(id1) = 1;
        ro(id2) = 0.01;
        options.colorBins = 2;
        [~, mi] = min(options.limits);
        options.limits(mi) = 0;
    end
end

% Update progress dialog
if ~isempty(options.UI)
    d.Message = 'Smoothing... This may take some time depending on your settings.';
    d.Value = 0.3;
end

% Smooth curvature data
if ~isempty(options.lh)
    if any(underlays.left.Vertices(:,3))
        los = smoothVertData(lo, underlays.left.Vertices, underlays.left.Faces, ...
                            'smoothSteps', options.smoothSteps, ...
                            'smoothArea', options.smoothArea, ...
                            'toAssign', options.smoothToAssign);
    else
        los = lo;
    end
end
if ~isempty(options.rh)
    if any(underlays.right.Vertices(:,3))
        ros = smoothVertData(ro, underlays.right.Vertices, underlays.right.Faces, ...
                            'smoothSteps', options.smoothSteps, ...
                            'smoothArea', options.smoothArea, ...
                            'toAssign', options.smoothToAssign);
    else
        ros = ro;
    end
end

% Update progress dialog
if ~isempty(options.UI)
    d.Message = 'Mapping colors...';
    d.Value = 0.5;
end

% Determine colormap limits if not provided or if binarized
if isempty(options.limits) || ~isempty(options.binarize)
    if ~isempty(options.lh) && ~isempty(options.rh)
        tmp = [los; ros];
        if isempty(options.binarize)
            options.limits(1) = min(tmp);
        end
        options.limits(2) = max(tmp);
    elseif ~isempty(options.lh)
        if isempty(options.binarize)
            options.limits(1) = min(options.lh);
        end
        options.limits(2) = max(options.lh);
    elseif ~isempty(options.rh)
        if isempty(options.binarize)
            options.limits(1) = min(options.rh);
        end
        options.limits(2) = max(options.rh);
    end
end

% Map colors onto curvature data
if ~isempty(options.lh) 
    [colormapSG.left.map, lcData, colormapSG.left.dataMap, ...
     ticksSG.left.ticks, ticksSG.left.labels] = ...
        colormapper(los, 'colormap', options.colormap, ...
                   'colorSpacing', options.colorSpacing, ...
                   'colorBins', options.colorBins, ...
                   'colorSpecial', options.colorSpecial, ...
                   'invertColors', options.invertColors, ...
                   'limits', [min(options.limits) max(options.limits)], ...
                   'sulci', options.sulci, 'gyri', options.gyri, ...
                   'thresh', options.thresh);
end
if ~isempty(options.rh)
    [colormapSG.right.map, rcData, colormapSG.right.dataMap, ...
     ticksSG.right.ticks, ticksSG.right.labels] = ...
        colormapper(ros, 'colormap', options.colormap, ...
                   'colorSpacing', options.colorSpacing, ...
                   'colorBins', options.colorBins, ...
                   'colorSpecial', options.colorSpecial, ...
                   'invertColors', options.invertColors, ...
                   'limits', [min(options.limits) max(options.limits)], ...
                   'sulci', options.sulci, 'gyri', options.gyri, ...
                   'thresh', options.thresh);
end

% Update progress dialog
if ~isempty(options.UI)
    d.Message = 'Replacing zeros and creating initial patch...';
    d.Value = 0.6;
end

% Assign color data to surface underlays
if ~isempty(options.lh)
    underlays.left.CDataMapping = 'scaled';
    underlays.left.FaceVertexCData = lcData;
    
    switch lower(options.inclZero)
        case 'off'
            zeroIdx = los == 0;
            underlays.left.FaceVertexCData(zeroIdx, 1) = options.surfC(1);
            underlays.left.FaceVertexCData(zeroIdx, 2) = options.surfC(2);
            underlays.left.FaceVertexCData(zeroIdx, 3) = options.surfC(3);
        case 'on'
            % Do nothing; zeros are included as per data mapping
    end
end

if ~isempty(options.rh)
    underlays.right.CDataMapping = 'scaled';
    underlays.right.FaceVertexCData = rcData;
    
    switch lower(options.inclZero)
        case 'off'
            zeroIdx = ros == 0;
            underlays.right.FaceVertexCData(zeroIdx, 1) = options.surfC(1);
            underlays.right.FaceVertexCData(zeroIdx, 2) = options.surfC(2);
            underlays.right.FaceVertexCData(zeroIdx, 3) = options.surfC(3);
        case 'on'
            % Do nothing; zeros are included as per data mapping
    end
end

% Update progress dialog
if ~isempty(options.UI)
    d.Message = 'Interpolating colormap for sulcal/gyral opacity...';
    d.Value = 0.8;
end

% Adjust opacity based on sulcal/gyral information
if options.sgOpacity ~= 1
    if ~isempty(options.lh)
        uniqueColors = unique(underlays.left.FaceVertexCData, 'rows');
        interpColors = zeros(size(uniqueColors, 1), 3);
        for i = 1:size(uniqueColors, 1)
            interpMap = customColorMapInterp([options.surfC; uniqueColors(i, :)], 100);
            interpColors(i, :) = interpMap(round(options.sgOpacity * 100), :);
        end
        % Map interpolated colors back to the surface
        [~, idx] = ismember(underlays.left.FaceVertexCData, uniqueColors, 'rows');
        underlays.left.FaceVertexCData = interpColors(idx, :);
    end
    if ~isempty(options.rh)
        uniqueColors = unique(underlays.right.FaceVertexCData, 'rows');
        interpColors = zeros(size(uniqueColors, 1), 3);
        for i = 1:size(uniqueColors, 1)
            interpMap = customColorMapInterp([options.surfC; uniqueColors(i, :)], 100);
            interpColors(i, :) = interpMap(round(options.sgOpacity * 100), :);
        end
        % Map interpolated colors back to the surface
        [~, idx] = ismember(underlays.right.FaceVertexCData, uniqueColors, 'rows');
        underlays.right.FaceVertexCData = interpColors(idx, :);
    end
end

% Finalize progress dialog
if ~isempty(options.UI)
    d.Message = 'Finalizing surface opacity and cleanup...';
    d.Value = 1;
    close(d);
end

% Set surface opacity
if ~isempty(options.lh)
    underlays.left.FaceVertexAlphaData = ones(size(underlays.left.Vertices, 1), 1) * options.surfOpacity;
    underlays.left.AlphaDataMapping = 'none';
    underlays.left.FaceAlpha = 'interp';
end
if ~isempty(options.rh)
    underlays.right.FaceVertexAlphaData = ones(size(underlays.right.Vertices, 1), 1) * options.surfOpacity;
    underlays.right.AlphaDataMapping = 'none';
    underlays.right.FaceAlpha = 'interp';
end

% Prepare additional output data
if ~isempty(options.lh)
    v.left = vl;
    o.left = los;
end
if ~isempty(options.rh)
    v.right = vr;
    o.right = ros;
end

% Assign output variables
varargout{1} = underlays;
varargout{2} = colormapSG;
varargout{3} = ticksSG;
varargout{4} = v;
varargout{5} = o;