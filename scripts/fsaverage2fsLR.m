function [d, tmpOut] = fsaverage2fsLR(f, hemi, d, pths)
% Resamples data from fsaverage to fs_LR space.
%
% This function converts surface data from the fsaverage surface space (used in FreeSurfer)
% to the fs_LR surface space (used in the Human Connectome Project). It supports both
% metric and label data resampling using the Workbench command-line tools.
%
% **Syntax**
% -------
%   [d, tmpOut] = fsaverage2fsLR(f, hemi, d, pths)
%
% **Description**
% ---------
%   [d, tmpOut] = fsaverage2fsLR(f, hemi, d, pths) resamples surface data
%   from the fsaverage space to fs_LR space. It handles `.gii` and `.nii.gz`
%   input formats and generates an output file in fs_LR space.
%
% **Inputs**
% ------
%   f       - (String) Path to the input surface file.
%             - Supported formats: `.nii.gz` or `.gii`.
%
%   hemi    - (String) Hemisphere for the data.
%             - Options: 'left', 'right'.
%             - Determines whether to use left ('L') or right ('R') hemisphere templates.
%
%   d       - (Matrix) Data to be resampled.
%             - Should match the surface file dimensions.
%
%   pths    - (Structure) Contains paths required for processing.
%             Fields:
%             * `pths.scrptPth` - Path to the script directory.
%             * `pths.sep`      - Path separator (e.g., `/` or `\`).
%             * `pths.wrkbnch`  - Path to the Workbench command-line tool (`wb_command`).
%             * `pths.fsrs`     - Path to the FreeSurfer directory.
%
% **Outputs**
% -------
%   d       - (Matrix) Resampled data in fs_LR space.
%
%   tmpOut  - (String) Path to the output file in fs_LR space.
%
% **Functionality**
% ----------------------------
%   1. **Input Format Support**:
%      - Added support for `.nii.gz` and `.gii` input files.
%      - Conversion from `.nii.gz` to `.gii` using a template if required.
%
%   2. **Hemisphere Support**:
%      - Implemented hemisphere-specific resampling based on the `hemi` input.
%      - Uses templates for left ('L') and right ('R') hemispheres.
%
%   3. **Workbench Commands**:
%      - Used `wb_command` to perform resampling for:
%        * Metric data: Resampled using `wb_command -metric-resample`.
%        * Label data: Resampled using `wb_command -label-resample`.
%
%   4. **Error Handling**:
%      - Added checks for file extensions and format compatibility.
%      - Gracefully handles unsupported file formats.
%
%   5. **Path Management**:
%      - Dynamically constructs paths using `pths.sep` to ensure compatibility
%        across operating systems.
%
% **Examples**
% -------
%   **Example 1: Resample Metric Data**
%   % Define input parameters
%   f = 'path/to/metric_file.nii.gz';  % Input file
%   hemi = 'left';  % Hemisphere
%   d = rand(164000, 1);  % Example metric data
%   pths.scrptPth = 'path/to/scripts';
%   pths.sep = '/';
%   pths.wrkbnch = 'path/to/workbench';
%   pths.fsrs = 'path/to/freesurfer';
%
%   % Resample the data
%   [resampledData, outputFile] = fsaverage2fsLR(f, hemi, d, pths);
%
%   **Example 2: Resample Label Data**
%   % Define input parameters
%   f = 'path/to/label_file.nii.gz';  % Input file
%   hemi = 'right';  % Hemisphere
%   d = randi([0, 1], 164000, 1);  % Example label data
%   pths.scrptPth = 'path/to/scripts';
%   pths.sep = '/';
%   pths.wrkbnch = 'path/to/workbench';
%   pths.fsrs = 'path/to/freesurfer';
%
%   % Resample the label data
%   [resampledLabels, outputFile] = fsaverage2fsLR(f, hemi, d, pths);
%
% **Notes**
% -----
%   - **Dependencies**:
%     * Workbench (`wb_command`) must be installed and accessible via `pths.wrkbnch`.
%     * FreeSurfer directory must contain required templates for fsaverage and fs_LR spaces.
%   - **Metric vs Label Data**:
%     * Metric data is resampled using `-metric-resample`.
%     * Label data is resampled using `-label-resample`.
%     * The function automatically determines the resampling method based on the input data.
%   - **Template Files**:
%     * Ensure required template files (e.g., `fsaverage_std_sphere`, `fs_LR-deformed_to-fsaverage`) are available in the FreeSurfer directory.
%
% **Author**
% -------
%   Alex Teghipco // alex.teghipco@uci.edu // Last Updated: 2024-12-01
%
% **See Also**
% --------
%   wb_command, gifti, load_nifti

[p, n, e] = fileparts(f);
gF = f;

switch e
    case '.gz'
        if strcmpi(n(end - 2:end), 'nii')
            template = gifti([pths.scrptPth pths.sep 'fileTemplate' pths.sep 'template.gii']);
            template.cdata = d;
            gF = [f(1:end - 7) '.gii'];
            save(template, gF);
        else
            error(['Could not find a .nii.gz or .gii file extension for: ' n e]);
        end
end

[pg, ng, eg] = fileparts(gF);

if strcmpi(hemi, 'left')
    h = 'L';
elseif strcmpi(hemi, 'right')
    h = 'R';
end

if sum(logical(~rem(d, 1)))/size(d, 1) ~= 1
    o = [pg pths.sep ng '_to_fs_LR' eg];
    toE = [pths.wrkbnch pths.sep 'wb_command -metric-resample ' pg pths.sep ng eg ' ' ...
        pths.fsrs pths.sep 'fsaverage_std_sphere.' h '.164k_fsavg_' h '.surf.gii' ' ' ...
        pths.fsrs pths.sep 'fs_LR-deformed_to-fsaverage.' h '.sphere.32k_fs_LR.surf.gii' ' ADAP_BARY_AREA ' o ' -area-metrics ' ...
        pths.fsrs pths.sep 'fsaverage.' h '.midthickness_va_avg.164k_fsavg_' h '.shape.gii' ' ' ...
        pths.fsrs pths.sep 'fs_LR.' h '.midthickness_va_avg.32k_fs_LR.shape.gii'];
else
    o = [pg pths.sep ng '_to_fs_LR.label' eg];
    toE = [pths.wrkbnch pths.sep 'wb_command -label-resample ' pg pths.sep ng eg ' ' ...
        pths.fsrs pths.sep 'fsaverage_std_sphere.' h '.164k_fsavg_' h '.surf.gii' ' ' ...
        pths.fsrs pths.sep 'fs_LR-deformed_to-fsaverage.' h '.sphere.32k_fs_LR.surf.gii' ' ADAP_BARY_AREA ' o ' -area-metrics ' ...
        pths.fsrs pths.sep 'fsaverage.' h '.midthickness_va_avg.164k_fsavg_' h '.shape.gii' ' ' ...
        pths.fsrs pths.sep 'fs_LR.' h '.midthickness_va_avg.32k_fs_LR.shape.gii'];
end

system(toE);
tmpOut = o;
g = gifti(o);
d = double(g.cdata);
