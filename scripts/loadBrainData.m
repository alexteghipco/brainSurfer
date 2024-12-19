function [hemi, hemi2, d, d2, sz, ci] = loadBrainData(f, underlayVertices, ln, rn, varargin)
% Loads Brain Data from Various File Formats
%
%   [hemi, hemi2, d, d2, sz, ci] = loadBrainData(f, underlayVertices, ln, rn, app)
%
% **Description**
% ----------------
%   The `loadBrainData` function loads brain imaging data from various file formats, such as NIFTI, GIFTI,
%   CIFTI, annotation, label, and FreeSurfer morphometry files. It processes data for left and right hemispheres,
%   determines hemisphere assignments, and outputs key properties of the data. Integration with App Designer
%   allows seamless user interaction for resolving ambiguities or missing information.
%
% **Inputs**
% ----------
%   f                 - (String) Path to the brain data file. Supported formats:
%                           - NIFTI (.nii)
%                           - GIFTI (.gii)
%                           - CIFTI (.dlabel.nii, etc.)
%                           - Annotation files
%                           - Label files
%                           - FreeSurfer morphometry files (.curv, etc.)
%                       Example: `f = 'path/to/brainData.nii';`
%
%   underlayVertices  - (Struct) Vertex data for both hemispheres. Required for label files.
%                           - underlayVertices.left : (N x 3 matrix) Left hemisphere vertices.
%                           - underlayVertices.right: (N x 3 matrix) Right hemisphere vertices.
%                       Example:
%                           `underlayVertices.left.Vertices = [...];`
%
%   ln                - (Cell array of strings) Substrings identifying left hemisphere in filenames.
%                       Example: `ln = {'_left', 'lh_', 'L_'};`
%
%   rn                - (Cell array of strings) Substrings identifying right hemisphere in filenames.
%                       Example: `rn = {'_right', 'rh_', 'R_'};`
%
%   app               - (Optional, App Designer Object) App Designer object for integrating user prompts
%                       within the app's UI. If provided, prompts such as hemisphere selection are
%                       displayed using `uiconfirm` dialogs within the app figure.
%
% **Outputs**
% ----------
%   hemi     - (String) Hemisphere of the loaded data ('left', 'right', or []).
%   hemi2    - (String) Secondary hemisphere (for CIFTI files).
%   d        - (Matrix or Vector) Loaded data for the primary hemisphere.
%   d2       - (Matrix or Vector) Loaded data for the secondary hemisphere (CIFTI).
%   sz       - (Vector) Size of the loaded data matrix.
%   ci       - (Integer) Data type flag:
%               - 1: Data is in CIFTI format.
%               - 0: Data is not in CIFTI format.
%
% **Functionality**
% -----------------
% 1. **File Parsing**: Reads file extension to determine format.
% 2. **Data Loading**:
%       - Attempts to load data as NIFTI, GIFTI, CIFTI, annotation, label, or FreeSurfer morphometry.
%       - Fails gracefully with informative messages.
% 3. **Hemisphere Assignment**:
%       - Assigns hemispheres for unilateral, bilateral, or unspecified data.
%       - Prompts the user for hemisphere selection if needed. Uses App Designer dialogs when `app` is provided.
% 4. **Error Handling**:
%       - Handles unsupported formats with descriptive errors.
%       - Verifies loaded data size and format.
%
% **Usage Examples**
% ------------------
%   % Example 1: Load a NIFTI file
%   f = 'path/to/brainData.nii';
%   underlayVertices.left.Vertices = [...]; % Define left vertices
%   underlayVertices.right.Vertices = [...]; % Define right vertices
%   [hemi, hemi2, d, d2, sz, ci] = loadBrainData(f, underlayVertices, ln, rn);
%
%   % Example 2: Load a label file with App Designer integration
%   app = MyAppDesignObject; % App Designer object
%   f = 'path/to/brainData.label';
%   underlayVertices.left.Vertices = [...];
%   underlayVertices.right.Vertices = [...];
%   [hemi, hemi2, d, d2, sz, ci] = loadBrainData(f, underlayVertices, ln, rn, app);
%
% **Notes**
% ---------
%   - Hemisphere resolution relies on `idHemi` and may require user input if ambiguous.
%   - `app` enhances user prompts with a GUI but is optional.
%   - Unsupported volumetric data triggers an error.
%
% **Author**
% -------
%   Alex Teghipco // alex.teghipco@uci.edu // Last Updated: 2024-12-01
%
% **See Also**
% ----------
%   load_nifti, gifti, cifti_read, read_annotation, read_label, read_curv, idHemi, uiconfirm

useApp = false;

if nargin > 4
    brainSurferUIFigure = varargin{1};
    useApp = true;
end

[p, n, e] = fileparts(f);
disp(['Trying to load file: ' [n e]])

% Initialize variables
ci = 0;
d = [];
d2 = [];
sz = [];
hemi = [];
hemi2 = [];

try % try to load a regular nifti file
    disp('Attempting to load as conventional nifti file...')
    ld = load_nifti(f);
    sz = size(ld.vol);
    d = ld.vol;
catch
    disp('NIFTI LOAD FAILED!')
    try % if that did not work, load a gifti file
        disp('Attempting to load as gifti file...')
        ld = gifti(f);
        if isfield(ld, 'cdata')
            sz = size(ld.cdata);
            d = ld.cdata;
        else
            error(['Could not find cdata structure (' f ')']);
        end
    catch
        disp('GIFTI LOAD FAILED!')
        try % if gifti did not work, try cifti
            disp('Attempting to load as cifti file...')
            ld = cifti_read(f);
            l = find(cellfun(@(s) any(strcmp(s.struct, 'CORTEX_LEFT')), ld.diminfo{1}.models));
            r = find(cellfun(@(s) any(strcmp(s.struct, 'CORTEX_RIGHT')), ld.diminfo{1}.models));
            if ~isempty(l)
                d = zeros([ld.diminfo{1}.models{l}.numvert, 1]);
                d(ld.diminfo{1}.models{l}.vertlist + 1) = ld.cdata(ld.diminfo{1}.models{l}.start : ld.diminfo{1}.models{l}.start + ld.diminfo{1}.models{l}.count - 1);
            end
            if ~isempty(r)
                d2 = zeros([ld.diminfo{1}.models{r}.numvert, 1]);
                d2(ld.diminfo{1}.models{r}.vertlist + 1) = ld.cdata(ld.diminfo{1}.models{r}.start : ld.diminfo{1}.models{r}.start + ld.diminfo{1}.models{r}.count - 1);
            end
            ci = 1;
        catch
            disp('CIFTI LOAD FAILED!')
            try
                disp('Attempting to load as annotation file...')
                [vertices, label, ctab] = read_annotation(f);
                [~, is2] = ismember(label, ctab.table(:, end));
                d = is2;
                sz = size(d);
            catch
                disp('ANNOTATION LOAD FAILED!')
                try
                    disp('Attempting to load as label...')
                    [l_template, ~] = read_label([], f);
                    %hemi = idHemi({f}); % Assuming idHemi is also refactored
                    if useApp
                        hemi = idHemi({f}, ln, rn, brainSurferUIFigure);
                    else
                        hemi = idHemi({f}, ln, rn);
                    end

                    if isempty(hemi{1})
                        if useApp
                            s = uiconfirm(brainSurferUIFigure, ...
                                ['It looks like a file you have loaded does not clearly reference a hemisphere. Which hemisphere do you associate with:' n e '?'], ...
                                'Confirm Hemisphere', 'Options', {'Left', 'Right'}, 'DefaultOption', 1);
                            hemi = lower(s);
                        else
                            s = questdlg(['It looks like a file you have loaded does not clearly reference a hemisphere. Which hemisphere do you associate with: ' n e '?'], ...
                            	'Confirm Hemisphere', ...
                            	'Left','Right','Left');
                            hemi = lower(s);
                        end
                    else
                        hemi = hemi{1};
                    end
                    
                    d = zeros(size(underlayVertices.(hemi).Vertices, 1), 1); % Using the provided underlayVertices
                    d(l_template(:, 1) + 1) = 1;
                    sz = size(d);
                catch
                    try
                        disp('Attempting to load as freesurfer morphometry file...')
                        d = read_curv([p filesep n e]);
                        sz = size(d);
                    catch
                        disp('Uh-oh...your file could not be loaded as nifti, gifti, cifti, annotation, label, or morphometry file')
                        error('Unsupported file format.');
                    end
                end
            end
        end
    end
end

if ci == 1
    if ~isempty(d) && ~isempty(d2)
        hemi = 'left';
        hemi2 = 'right';
    elseif ~isempty(d) && isempty(d2)
        hemi = 'left';
    elseif isempty(d) && ~isempty(d2)
        hemi = 'right';
        d = d2;
    end
    sz = size(d);
else
    %if ~exist('hemi', 'var') && size(d, 2) == 1
    if isempty(hemi) && size(d, 2) == 1
        if useApp
            hemi = idHemi({f}, ln, rn, brainSurferUIFigure);
        else
            hemi = idHemi({f}, ln, rn);
        end
        %hemi = idHemi({f}); % Assuming idHemi is also refactored
        hemi = hemi{1};
        if isempty(hemi)
            if useApp
                s = uiconfirm(brainSurferUIFigure, ...
                    ['Looks like this file had no reference to a hemisphere (' n e '). Which hemisphere would you like to associate it with?'], ...
                    'Confirm Hemisphere', 'Options', {'Left', 'Right'}, 'DefaultOption', 1);
                hemi = lower(s);
            else
                s = questdlg(['Looks like this file had no reference to a hemisphere (' n e '). Which hemisphere would you like to associate it with?'], ...
                    'Confirm Hemisphere', ...
                    'Left','Right','Left');
                hemi = lower(s);
            end
            if isempty(hemi)
                error('Hemisphere selection canceled.');
            end
            hemi = hemi{1};
        end
    elseif size(d, 2) > 1
        hemi = [];
    end
end
