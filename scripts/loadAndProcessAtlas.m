function [atlas, sz] = loadAndProcessAtlas(f, hemi, underlay, lg)
% Loads and Processes Atlas Data from Various File Formats
%
%   [atlas, sz] = loadAndProcessAtlas(f, hemi, underlay, lg)
%
% **Description**
% ------------
%   The `loadAndProcessAtlas` function is designed to load and process atlas data from
%   multiple file formats, including NIFTI, GIFTI, CIFTI, annotation, and label files.
%   It supports both left and right hemispheres, handles region naming, and manages
%   atlas overlays and clusters. The function is robust, attempting to load the atlas
%   data through various supported formats and providing informative messages upon
%   success or failure.
%
% **Inputs**
% ----------
%   f         - (Cell array of strings) A cell array containing the full file paths to
%               the atlas files to be loaded. Each element should be a string specifying
%               the path to an atlas file.
%               *Example:*
%                   f = { 'path/to/atlas1.nii', 'path/to/atlas2.gii' };
%
%   hemi      - (Cell array of strings or empty arrays) A cell array indicating the
%               hemisphere(s) associated with each atlas file in `f`. Each element should
%               be one of the following:
%                   - 'left'  : Indicates the atlas file corresponds to the left hemisphere.
%                   - 'right' : Indicates the atlas file corresponds to the right hemisphere.
%                   - []      : Indicates the atlas file is bilateral or does not specify a hemisphere.
%               *Example:*
%                   hemi = { 'left', 'right' };
%
%   underlay  - (Structure) A structure containing mesh information for both hemispheres.
%               It must include the following fields:
%                   - underlay.left.Vertices  : (N x 3 matrix) Vertex coordinates for the left hemisphere.
%                   - underlay.left.Faces     : (M x 3 matrix) Face indices for the left hemisphere.
%                   - underlay.right.Vertices : (N x 3 matrix) Vertex coordinates for the right hemisphere.
%                   - underlay.right.Faces    : (M x 3 matrix) Face indices for the right hemisphere.
%               This structure is essential for processing cluster boundaries and regions.
%
%   lg        - (Optional, string) Path to a file containing atlas region names. Supported file
%               formats are XML (.xml) and plain text (.txt). This file is used to assign
%               meaningful names to atlas regions based on their identifiers.
%               *Example:*
%                   lg = 'path/to/regionNames.xml';
%
% **Outputs**
% -----------
%   atlas     - (Structure) A comprehensive structure containing the processed atlas data. It includes:
%                   - atlas.bm.left/right      : (Vector) Binary mask data for left and/or right hemispheres.
%                   - atlas.overlay.left/right : (Handles) Graphics handles for atlas overlays.
%                   - atlas.cBar              : (Handle) Color bar handle.
%                   - atlas.cBarText          : (Handle) Color bar text handle.
%                   - atlas.cBarAx            : (Handle) Color bar axis handle.
%                   - atlas.regions.left/right : (Cell array) Region names for each vertex in left and/or right hemispheres.
%                   - atlas.clusters.left/right : (Cell array) Clusters of vertices for each region.
%                   - atlas.borders.left/right  : (Cell array) Boundary information for each cluster.
%                   - atlas.name.left/right     : (String) File names for left and/or right hemispheres.
%                   - atlas.path.left/right     : (String) File paths for left and/or right hemispheres.
%                   - atlas.defaultColors.left/right : (Matrix) Default colors assigned to regions.
%                   - atlas.defaultCbar.left/right   : (Matrix) Default color bar colors.
%
%   sz        - (Vector) The size of the loaded atlas data for the current hemisphere. Typically,
%               this represents the dimensions of the binary mask (`atlas.bm`) and is used to
%               verify the integrity and dimensionality of the loaded data.
%
% **Functionality**
% -----------------
%   The function performs the following steps for each atlas file provided:
%     1. **Initialization**: Sets up the `atlas` structure with necessary fields for both hemispheres.
%     2. **Clearing Existing Data**: Resets existing atlas data for the specified hemisphere(s) to prevent
%        data overlap or corruption.
%     3. **Loading Atlas Data**: Attempts to load the atlas data using supported file formats in the following order:
%           a. NIFTI (.nii)
%           b. GIFTI (.gii)
%           c. CIFTI (.dlabel.nii, etc.)
%           d. Annotation files
%           e. Label files
%        Each loading attempt is wrapped in a `try-catch` block to handle failures gracefully.
%     4. **Assigning Region Names**: If a region names file (`lg`) is provided, the function assigns meaningful
%        names to each atlas region based on the provided XML or TXT file.
%     5. **Generating Clusters and Borders**: Identifies and processes clusters of regions and their boundaries
%        within each hemisphere.
%
% **Usage Examples**
% ------------------
%   % Example 1: Loading Bilateral NIFTI Atlas with Region Names from XML
%   f = { 'path/to/leftAtlas.nii', 'path/to/rightAtlas.nii' };
%   hemi = { 'left', 'right' };
%   underlay.left.Vertices = ...; % Define left vertices
%   underlay.left.Faces = ...;    % Define left faces
%   underlay.right.Vertices = ...;% Define right vertices
%   underlay.right.Faces = ...;   % Define right faces
%   lg = 'path/to/regionNames.xml';
%   [atlas, sz] = loadAndProcessAtlas(f, hemi, underlay, lg);
%
%   % Example 2: Loading a Bilateral GIFTI Atlas without Specifying Hemisphere
%   f = { 'path/to/bilateralAtlas.gii' };
%   hemi = { [] };
%   underlay.left.Vertices = ...; % Define left vertices
%   underlay.left.Faces = ...;    % Define left faces
%   underlay.right.Vertices = ...;% Define right vertices
%   underlay.right.Faces = ...;   % Define right faces
%   lg = 'path/to/regionNames.txt';
%   [atlas, sz] = loadAndProcessAtlas(f, hemi, underlay, lg);
%
% **Notes**
% --------
%   - **Supported File Formats**:
%       - **NIFTI**: Commonly used for volumetric brain imaging data (.nii) but also surface-based data
%       - **GIFTI**: Often used for surface-based brain data (.gii).
%       - **CIFTI**: Combines cortical surface and subcortical volumetric data (.dlabel.nii, etc.).
%       - **Annotation & Label Files**: Used for labeling regions on cortical surfaces.
%
%   - **Hemisphere Handling**:
%       - When `hemi` is empty (`[]`), the atlas data is assumed to be bilateral, and the same data is assigned to both hemispheres.
%       - Specifying 'left' or 'right' in `hemi` allows for unilateral atlas loading.
%
%   - **Region Naming**:
%       - Providing the `lg` parameter allows for meaningful naming of atlas regions. If not provided, region identifiers remain numeric or unspecified.
%       - The function supports both XML and TXT files for region names. Ensure the file format matches the expected structure.
%
%   - **Error Handling**:
%       - The function includes multiple `try-catch` blocks to attempt loading atlas data through various formats.
%       - Messages are displayed upon each loading attempt, facilitating debugging if a particular format fails to load.
%       - If all loading attempts fail, the function outputs an empty `sz` and notifies the user of the failure.
%
%   - **Data Size Verification**:
%       - After loading, the function checks if the atlas data is three-dimensional (not supported by *this* specific function)
%
%   - **Clusters and Borders**:
%       - The function identifies unique regions (clusters) within the atlas and computes their boundaries based on the mesh faces provided in `underlay`.
%       - This information is useful for visualization and further analysis of atlas regions.
%
%   - **Performance Considerations**:
%       - Loading large atlas files, especially in CIFTI format, may be computationally intensive. Ensure sufficient memory and processing resources are available.
%
%   - **Dependencies**:
%       - Ensure that necessary toolboxes or external functions (e.g., `load_nifti`, `gifti`, `cifti_read`, `read_annotation`, `read_label`, `xml2struct`) are available in the MATLAB path.
%
% **Author**
% -------
%   Alex Teghipco // alex.teghipco@uci.edu // Last Updated: 2024-12-01
%
% **See Also**
% ----------
%   load_nifti, gifti, cifti_read, read_annotation, read_label, xml2struct

pths.sep = filesep;

% Initialize the atlas structure with both 'left' and 'right' fields
atlas = struct();
atlas.bm = struct('left', [], 'right', []);
atlas.overlay = struct('left', [], 'right', []);
atlas.cBar = [];
atlas.cBarText = [];
atlas.cBarAx = [];
atlas.regions = struct('left', [], 'right', []);
atlas.clusters = struct('left', [], 'right', []);
atlas.borders = struct('left', [], 'right', []);
atlas.name = struct('left', [], 'right', []);
atlas.path = struct('left', [], 'right', []);
atlas.defaultColors = struct('left', [], 'right', []);
atlas.defaultCbar = struct('left', [], 'right', []);

for i = 1:length(f)
    currentHemi = hemi{i};

    % Clear existing atlas data for the current hemisphere(s)
    if strcmpi(currentHemi, 'left')
        atlas.defaultColors.left = [];
        atlas.bm.left = [];
        atlas.regions.left = [];
        atlas.clusters.left = [];
        atlas.borders.left = [];
        atlas.name.left = [];
        atlas.path.left = [];

        if ~isempty(atlas.overlay.left)
            delete(atlas.overlay.left)
            atlas.overlay.left = [];
        end
    end
    if strcmpi(currentHemi, 'right')
        atlas.defaultColors.right = [];
        atlas.bm.right = [];
        atlas.regions.right = [];
        atlas.clusters.right = [];
        atlas.borders.right = [];
        atlas.name.right = [];
        atlas.path.right = [];

        if ~isempty(atlas.overlay.right)
            delete(atlas.overlay.right)
            atlas.overlay.right = [];
        end
    end
    if isempty(currentHemi)
        [p, n, e] = fileparts(f{i});
        atlas.path.left = [p pths.sep];
        atlas.name.left = [n e];
        atlas.path.right = [p pths.sep];
        atlas.name.right = [n e];
    else
        [p, n, e] = fileparts(f{i});
        atlas.path.(currentHemi) = [p pths.sep];
        atlas.name.(currentHemi) = [n e];
    end

    disp(['Trying to load atlas: ' f{i}])

    % Load the atlas data based on file type
    try
        % Attempt to load as a conventional NIFTI file
        disp('Attempting to load as conventional nifti file...')
        ld = load_nifti([p pths.sep n e]);
        if isempty(currentHemi)
            % If hemisphere is empty, assign to both hemispheres
            atlas.bm.left = ld.vol;
            atlas.bm.right = ld.vol; % Adjust as needed based on actual data
        else
            atlas.bm.(currentHemi) = ld.vol;
        end
        sz = size(atlas.bm.(currentHemi));
    catch
        disp('NIFTI LOAD FAILED!')
        try
            % Attempt to load as a GIFTI file
            disp('Attempting to load as gifti file...')
            ld = gifti([p pths.sep n e]);
            if isfield(ld, 'cdata')
                if isempty(currentHemi)
                    atlas.bm.left = ld.cdata;
                    atlas.bm.right = ld.cdata; % Adjust as needed
                    atlas.regions.left = repmat({'No region information'}, size(underlay.left.Vertices, 1), 1);
                    atlas.regions.right = repmat({'No region information'}, size(underlay.right.Vertices, 1), 1);
                else
                    atlas.bm.(currentHemi) = ld.cdata;
                    atlas.regions.(currentHemi) = repmat({'No region information'}, size(underlay.(currentHemi).Vertices, 1), 1);
                end
                sz = size(atlas.bm.(currentHemi));
            else
                error(['Could not find cdata structure (' f{i} ')']);
            end
        catch
            disp('GIFTI LOAD FAILED!')
            try
                % Attempt to load as a CIFTI file
                disp('Attempting to load as cifti file...')
                ld = cifti_read([p pths.sep n e]);
                c = cell2mat(ld.diminfo{1}.models);
                c = {c.struct};
                l = find(contains(c, 'CORTEX_LEFT'));
                r = find(contains(c, 'CORTEX_RIGHT'));
                key = [ld.diminfo{2}.maps.table.key]';
                name = {ld.diminfo{2}.maps.table.name};

                if isempty(currentHemi)
                    atlas.bm.left = zeros([ld.diminfo{1}.models{1}.numvert, 1]);
                    atlas.bm.right = zeros([ld.diminfo{1}.models{2}.numvert, 1]);
                    atlas.defaultColors.left = zeros([ld.diminfo{1}.models{1}.numvert, 3]);
                    atlas.defaultColors.right = zeros([ld.diminfo{1}.models{2}.numvert, 3]);

                    atlas.bm.left(ld.diminfo{1}.models{l}.vertlist + 1) = ld.cdata(ld.diminfo{1}.models{l}.start : ld.diminfo{1}.models{l}.start + ld.diminfo{1}.models{l}.count - 1);
                    atlas.bm.right(ld.diminfo{1}.models{r}.vertlist + 1) = ld.cdata(ld.diminfo{1}.models{r}.start : ld.diminfo{1}.models{r}.start + ld.diminfo{1}.models{r}.count - 1);

                    cmap = [ld.diminfo{2}.maps.table(:).rgba]';
                    [~, is2] = ismember(atlas.bm.left, key);
                    atlas.regions.left = name(is2);
                    atlas.defaultColors.left = cmap(is2, 1:3);
                    atlas.defaultCbar.left = cmap(:, 1:3);

                    [~, is2] = ismember(atlas.bm.right, key);
                    atlas.regions.right = name(is2);
                    atlas.defaultColors.right = cmap(is2, 1:3);
                    atlas.defaultCbar.right = cmap(:, 1:3);

                    sz = size(atlas.bm.left);

                    if length(f) > 2
                        error('You have a CIFTI file with no reference to a hemisphere, meaning it is bilateral. Make sure you are loading in only one atlas file in this case.');
                    end
                elseif strcmpi(currentHemi, 'left')
                    atlas.bm.left = zeros([ld.diminfo{1}.models{1}.numvert, 1]);
                    atlas.bm.left(ld.diminfo{1}.models{l}.vertlist + 1) = ld.cdata(ld.diminfo{1}.models{l}.start : ld.diminfo{1}.models{l}.start + ld.diminfo{1}.models{l}.count - 1);
                    atlas.defaultColors.left = zeros([ld.diminfo{1}.models{1}.numvert, 3]);
                    sz = size(atlas.bm.left);
                    [~, is2] = ismember(atlas.bm.left, key);
                    atlas.regions.left = name(is2);
                    cmap = [ld.diminfo{2}.maps.table(:).rgba]';
                    atlas.defaultColors.left = cmap(is2, 1:3);
                    atlas.defaultCbar.left = cmap(:, 1:3);
                    if i == 2
                        if ~isequal(atlas.defaultCbar.left, atlas.defaultCbar.right)
                            atlas.bm.right = atlas.bm.right + (max(atlas.bm.left) + 1);
                        end
                    end
                elseif strcmpi(currentHemi, 'right')
                    atlas.bm.right = zeros([ld.diminfo{1}.models{1}.numvert, 1]);
                    atlas.bm.right(ld.diminfo{1}.models{r}.vertlist + 1) = ld.cdata(ld.diminfo{1}.models{r}.start : ld.diminfo{1}.models{r}.start + ld.diminfo{1}.models{r}.count - 1);
                    sz = size(atlas.bm.right);
                    [~, is2] = ismember(atlas.bm.right, key);
                    atlas.regions.right = name(is2);
                    cmap = [ld.diminfo{2}.maps.table(:).rgba]';
                    atlas.defaultColors.right = cmap(is2, 1:3);
                    atlas.defaultCbar.right = cmap(:, 1:3);
                    if i == 2
                        if ~isequal(atlas.defaultCbar.left, atlas.defaultCbar.right)
                            atlas.bm.right = atlas.bm.right + (max(atlas.bm.left) + 1);
                        end
                    end
                end

            catch
                disp('CIFTI LOAD FAILED!')
                try
                    % Attempt to load as an annotation file
                    disp('Attempting to load as annotation file...')
                    [vertices, label, ctab] = read_annotation([p pths.sep n e]);
                    if isempty(currentHemi)
                        % Assign to both hemispheres
                        [~, is2] = ismember(label, ctab.table(:, end));
                        atlas.bm.left = is2;
                        atlas.bm.right = is2; % Assign to both

                        cmap = ctab.table(:, 1:3);
                        z = find(ctab.table(:, end) == 0);
                        if isempty(z) && any(label == 0)
                            id = find(is2 == 0);
                            is2(id) = 1;
                        else
                            id = [];
                        end

                        atlas.defaultColors.left = cmap(is2, 1:3);
                        atlas.defaultColors.right = cmap(is2, 1:3);
                        cmap(is2(id), :) = 1; % Set unknown regions to white
                        atlas.regions.left = ctab.struct_names(is2);
                        atlas.regions.right = ctab.struct_names(is2);
                        atlas.regions.left(is2(id)) = {'Unknown'};
                        atlas.regions.right(is2(id)) = {'Unknown'};
                        atlas.defaultCbar.left = [1 1 1; ctab.table(:, 1:3)];
                        atlas.defaultCbar.right = [1 1 1; ctab.table(:, 1:3)];

                        if i == 2 || any(intersect(unique(atlas.bm.left), unique(atlas.bm.right)))
                            if ~isequal(atlas.defaultCbar.left, atlas.defaultCbar.right)
                                atlas.bm.right = atlas.bm.right + (max(atlas.bm.left) + 1);
                            end
                        end
                        sz = size(atlas.bm.left); % or right, since both are same
                    else
                        [~, is2] = ismember(label, ctab.table(:, end));
                        atlas.bm.(currentHemi) = is2;
                        cmap = ctab.table(:, 1:3);
                        z = find(ctab.table(:, end) == 0);
                        if isempty(z) && any(label == 0)
                            id = find(is2 == 0);
                            is2(id) = 1;
                        else
                            id = [];
                        end
                        atlas.defaultColors.(currentHemi) = cmap(is2, 1:3);
                        cmap(is2(id), :) = 1; % Set unknown regions to white
                        atlas.regions.(currentHemi) = ctab.struct_names(is2);
                        atlas.regions.(currentHemi)(is2(id)) = {'Unknown'};
                        atlas.defaultCbar.(currentHemi) = [1 1 1; ctab.table(:, 1:3)];

                        if i == 2 || any(intersect(unique(atlas.bm.left), unique(atlas.bm.right)))
                            if ~isequal(atlas.defaultCbar.left, atlas.defaultCbar.right)
                                if strcmpi(currentHemi, 'right')
                                    atlas.bm.right = atlas.bm.right + (max(atlas.bm.left) + 1);
                                else
                                    atlas.bm.left = atlas.bm.left + (max(atlas.bm.right) + 1);
                                end
                            end
                        end
                        sz = size(atlas.bm.(currentHemi));
                    end
                catch
                    disp('ANNOTATION LOAD FAILED!')
                    try
                        % Attempt to load as a label file
                        disp('Attempting to load as label...')
                        [l_template, ~] = read_label([], [p pths.sep n e]);
                        if isempty(currentHemi)
                            atlas.regions.left = repmat({'No region information'}, size(underlay.left.Vertices, 1), 1);
                            atlas.regions.right = repmat({'No region information'}, size(underlay.right.Vertices, 1), 1);
                            atlas.regions.left(l_template(:, 1) + 1) = {'ROI'};
                            atlas.regions.right(l_template(:, 1) + 1) = {'ROI'};
                            atlas.bm.left = zeros(size(underlay.left.Vertices, 1), 1);
                            atlas.bm.right = zeros(size(underlay.right.Vertices, 1), 1);
                            atlas.bm.left(l_template(:, 1) + 1, 1) = 1;
                            atlas.bm.right(l_template(:, 1) + 1, 1) = 1;
                        else
                            atlas.regions.(currentHemi) = repmat({'No region information'}, size(underlay.(currentHemi).Vertices, 1), 1);
                            atlas.regions.(currentHemi)(l_template(:, 1) + 1) = {'ROI'};
                            atlas.bm.(currentHemi) = zeros(size(underlay.(currentHemi).Vertices, 1), 1);
                            atlas.bm.(currentHemi)(l_template(:, 1) + 1, 1) = 1;
                        end
                        sz = size(atlas.bm.(currentHemi));
                    catch
                        disp('Uh-oh...your file could not be loaded as nifti, gifti, cifti, annotation or label')
                        sz = [];
                    end
                end
            end
        end
    end

    % Check if data size is 3D
    if ~isempty(sz) && length(sz) > 1 && sz(2) > 1
        error('You cannot import a volume space atlas at the moment');
    end

    % Get atlas names from lg
    if ~isempty(lg)
        [~, ~, e] = fileparts(lg);
        switch e
            case '.xml'
                if i == 1
                    xml = xml2struct(lg);
                    name = {};
                    key = [];
                    for j = 1:length(xml.Children(4).Children)
                        if ~isempty(xml.Children(4).Children(j).Children)
                            name{end+1,1} = xml.Children(4).Children(j).Children.Data;
                            key(end+1,1) = str2double(xml.Children(4).Children(j).Attributes(1).Value);
                        end
                    end
                end
                if isempty(currentHemi)
                    hemis = {'left', 'right'};
                else
                    hemis = {currentHemi};
                end
                for h = 1:length(hemis)
                    hName = hemis{h};
                    id = find(atlas.bm.(hName) ~= 0);
                    id2 = find(atlas.bm.(hName) == 0);
                    [~, is2] = ismember(atlas.bm.(hName), key);
                    atlas.regions.(hName) = cell(size(atlas.bm.(hName)));
                    atlas.regions.(hName)(id) = name(is2(id));
                    atlas.regions.(hName)(id2) = {'No region information'};
                end
            case '.txt'
                if i == 1
                    fid = fopen(lg);
                    tline = fgetl(fid);
                    tlines = {};
                    while ischar(tline)
                        tlines{end+1,1} = tline;
                        tline = fgetl(fid);
                    end
                    fclose(fid);
                end
                if isempty(currentHemi)
                    hemis = {'left', 'right'};
                else
                    hemis = {currentHemi};
                end
                for h = 1:length(hemis)
                    hName = hemis{h};
                    id = find(atlas.bm.(hName) ~= 0);
                    id2 = find(atlas.bm.(hName) == 0);
                    atlas.regions.(hName) = cell(size(atlas.bm.(hName)));
                    atlas.regions.(hName)(id) = tlines(atlas.bm.(hName)(id));
                    atlas.regions.(hName)(id2) = {'No region information'};
                end
        end
    end

    % Get clusters and borders
    if isempty(currentHemi)
        hemis = {'left', 'right'};
    else
        hemis = {currentHemi};
    end
    for h = 1:length(hemis)
        hName = hemis{h};
        if ~isempty(atlas.bm.(hName))
            atv = find(atlas.bm.(hName) ~= 0);
            inUn = unique(atlas.bm.(hName)(atv));
            dataClust = cell(length(inUn), 1);
            for roii = 1:length(inUn)
                dataClust{roii} = find(atlas.bm.(hName) == inUn(roii));
            end
            atlas.clusters.(hName) = dataClust;
            try
                dataClust = getClusterBoundary(atlas.clusters.(hName), underlay.(hName).Faces);
            catch
                dataClust = [];
            end
            atlas.borders.(hName) = dataClust;
        end
    end
end
