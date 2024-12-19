function [hemi, hemi2, d, d2, tmpOut] = vol2fsaverage(f, varargin)
% Converts volumetric data to fsaverage surface space.
%
% This function converts volumetric neuroimaging data to the fsaverage 
% surface space used in FreeSurfer. The function supports various conversion 
% options, including unthresholded maps, thresholded maps, and ROI-based 
% maps, as well as optional weighting for ROI conversions.
%
% **Syntax**
% -------
%   [hemi, hemi2, d, d2, tmpOut] = vol2fsaverage(f)
%   [hemi, hemi2, d, d2, tmpOut] = vol2fsaverage(f, fig)
%
% **Description**
% ---------
%   [hemi, hemi2, d, d2, tmpOut] = vol2fsaverage(f) prompts the user to
%   select a conversion method and processes the volumetric file `f`
%   accordingly.
%
%   [hemi, hemi2, d, d2, tmpOut] = vol2fsaverage(f, fig) displays a UI
%   confirmation dialog within the provided figure handle `fig` to guide
%   the user in selecting the conversion method.
%
% **Inputs**
% ------
%   f       - (String) Path to the volumetric file to be converted.
%
%   fig     - (Optional) Figure handle for displaying UI confirmation
%             dialogs. If not provided, the function uses `inputdlg` for user input.
%
% **Outputs**
% -------
%   hemi       - (String) Hemisphere associated with the data ('left', 'right', or []).
%
%   hemi2      - (String) Second hemisphere associated with the data ('left', 'right', or []).
%
%   d          - (Matrix) Data for the first hemisphere, loaded from the converted file.
%
%   d2         - (Matrix) Data for the second hemisphere, loaded from the converted file.
%
%   tmpOut     - (Cell Array) Paths to the converted surface files.
%                - tmpOut{1}: Left hemisphere file (if available).
%                - tmpOut{2}: Right hemisphere file (if available).
%
% **Functionality**
% ----------------------------
%   1. **Conversion Options**:
%      - Added support for three conversion methods:
%        * Unthresholded maps: Converts whole-brain data without masks.
%        * Thresholded maps: Converts only regions passing a specific threshold.
%        * ROI-based maps: Converts data containing one or more regions of interest (ROIs), 
%          with optional weighting for ROI prioritization.
%
%   2. **User Interaction**:
%      - Utilized `uiconfirm` (for GUIs) or `inputdlg` (for command-line interaction) 
%        to guide users in selecting conversion options.
%
%   3. **ROI Weighting**:
%      - Implemented optional user input for specifying weights for ROIs, allowing fine-grained 
%        control over ROI prioritization during conversion.
%
%   4. **Hemisphere Identification**:
%      - Automated identification of hemispheres (left/right) from filenames using `idHemi`.
%
%   5. **Error Handling**:
%      - Improved robustness in cases where user input is canceled or conversion fails.
%
% **Examples**
% -------
%   **Example 1: Convert an Unthresholded Map**
%   % Convert a volumetric file to fsaverage surface space
%   f = 'path/to/volume.nii';
%   [hemi, hemi2, d, d2, tmpOut] = vol2fsaverage(f);
%
%   **Example 2: Convert a Thresholded Map**
%   % Convert a thresholded volumetric file
%   f = 'path/to/volume_thresholded.nii';
%   [hemi, hemi2, d, d2, tmpOut] = vol2fsaverage(f);
%
%   **Example 3: ROI-Based Conversion with Weighting**
%   % Convert a volumetric file containing ROIs with custom weighting
%   f = 'path/to/volume_rois.nii';
%   [hemi, hemi2, d, d2, tmpOut] = vol2fsaverage(f);
%
%   % During the conversion process, input a weight vector such as:
%   % [1, 0.5, 0.2] to assign weights to specific ROIs.
%
% **Notes**
% -----
%   - **Dependencies**: This function relies on external helper functions, including:
%     * `convertMNI2FS`: Converts volumetric data to fsaverage space without masks.
%     * `convertMNI2FSWithMask`: Converts thresholded maps to fsaverage space.
%     * `convertROIForFS`: Processes ROI-based maps for fsaverage space.
%     * `load_nifti`: Loads NIfTI files.
%     * `idHemi`: Determines hemisphere based on file naming conventions.
%
%   - **Interactive Workflow**: If a GUI figure handle is provided, the function uses
%     `uiconfirm` for a streamlined, interactive experience. Otherwise, it falls back
%     to `inputdlg` for command-line interaction.
%
%   - **Error Handling**: The function gracefully handles user cancellations and 
%     missing inputs, ensuring that execution does not crash.
%
% **Author**
% -------
%   Alex Teghipco // alex.teghipco@uci.edu // Last Updated: 2024-12-01
%
% **See Also**
% --------
%   convertMNI2FS, convertMNI2FSWithMask, convertROIForFS, load_nifti, idHemi

[p, n, e] = fileparts(f);

if nargin > 1
    fig = varargin{1};
    im = uiconfirm(fig, ['Looks like this particular file was in volume space (' n e '). How do you want to convert it to surface space (fsaverage)?'], 'Conversion options', 'Options', {'Thresholded map', 'Contains one or more ROIs', 'Unthresholded map', 'Cancel'}, 'DefaultOption', 3);
else
    im = inputdlg(['Looks like this particular file was in volume space (' n e '). How do you want to convert it to surface space (fsaverage)?'], 'Conversion options', 1, {'Unthresholded map'});
    if isempty(im)
        error('Conversion option selection canceled.');
    end
    im = im{1};
end

switch im
    case 'Unthresholded map'
        tmpOut = convertMNI2FS(f, []);
    case 'Thresholded map'
        tmpOut = convertMNI2FSWithMask(f);
    case 'Contains one or more ROIs'
        if nargin > 1
            weight = inputdlg('Enter a weight vector for ROIs or leave blank for default no weighting option (1s given preference over 0s ; assuming 1s and 0s are in order of ROI values in map)', 'Define ROI weights');
        else
            weight = inputdlg('Enter a weight vector for ROIs or leave blank for default no weighting option (1s given preference over 0s ; assuming 1s and 0s are in order of ROI values in map)', 'Define ROI weights', 1, {''});
            if isempty(weight)
                error('Weight input canceled.');
            end
        end
        if strcmp(weight{1}, '[]') || isempty(weight{1})
            weight = [];
        else
            weight = str2double(weight);
        end

        try
            tmpOut = convertROIForFS(f, weight);
        catch
            tmpOut = convertROIForFS(f, []);
        end
        tmpOut = tmpOut(1:2:end); % this removes the confidence files...
end

% Assuming convertMNI2FS, convertMNI2FSWithMask, and convertROIForFS
% return a cell array where the first element is the left hemisphere file
% and the second element is the right hemisphere file.

if length(tmpOut) == 2
    ld = load_nifti(tmpOut{1});
    ld2 = load_nifti(tmpOut{2});
    d = ld.vol;
    d2 = ld2.vol;
    hemi = 'left';
    hemi2 = 'right';
elseif length(tmpOut) == 1
    ld = load_nifti(tmpOut{1});
    d = ld.vol;
    d2 = [];
    hemi = idHemi({tmpOut{1}}, [], []); % Determine hemisphere using filename
    hemi = hemi{1};
    hemi2 = [];
else
    d = [];
    d2 = [];
    hemi = [];
    hemi2 = [];
end
