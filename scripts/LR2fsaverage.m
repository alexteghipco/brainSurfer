function [d, tmpOut] = LR2fsaverage(f, hemi, d, pths)
% Resamples data from fs_LR to fsaverage space.
%
% This function converts surface data from the fs_LR surface space (used in 
% the Human Connectome Project) to the fsaverage surface space (used in 
% FreeSurfer). It supports resampling both metric and label data using the 
% Workbench command-line tools.
%
% **Syntax**
% -------
%   [d, tmpOut] = LR2fsaverage(f, hemi, d, pths)
%
% **Description**
% ---------
%   [d, tmpOut] = LR2fsaverage(f, hemi, d, pths) resamples surface data
%   from fs_LR space to fsaverage space using predefined templates for
%   each hemisphere.
%
% **Inputs**
% ------
%   f       - (String) Path to the input surface file.
%             - Supported format: `.gii`.
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
%             * `pths.wrkbnch`  - Path to the Workbench command-line tool (`wb_command`).
%             * `pths.fsrs`     - Path to the FreeSurfer directory.
%             * `pths.sep`      - Path separator (e.g., `/` or `\`).
%
% **Outputs**
% -------
%   d       - (Matrix) Resampled data in fsaverage space.
%
%   tmpOut  - (String) Path to the output file in fsaverage space.
%
% **Functionality**
% ----------------------------
%   1. **Metric and Label Data Support**:
%      - Handles both metric data and label data resampling.
%      - Automatically determines the appropriate resampling method:
%        * Metric data: Resampled using `wb_command -metric-resample`.
%        * Label data: Resampled using `wb_command -label-resample`.
%
%   2. **Hemisphere-Specific Processing**:
%      - Uses predefined templates for left ('L') and right ('R') hemispheres.
%      - Determines the hemisphere based on the `hemi` input.
%
%   3. **Path Management**:
%      - Dynamically constructs paths using `pths.sep` to ensure compatibility
%        across different operating systems.
%
%   4. **Workbench Command Integration**:
%      - Executes the resampling process via `system` calls to `wb_command`.
%
% **Examples**
% -------
%   **Example 1: Resample Metric Data**
%   % Define input parameters
%   f = 'path/to/metric_file.gii';  % Input file
%   hemi = 'left';  % Hemisphere
%   d = rand(32492, 1);  % Example metric data (32492 vertices for fs_LR 32k)
%   pths.wrkbnch = 'path/to/workbench';
%   pths.fsrs = 'path/to/freesurfer';
%   pths.sep = '/';
%
%   % Resample the data
%   [resampledData, outputFile] = LR2fsaverage(f, hemi, d, pths);
%
%   **Example 2: Resample Label Data**
%   % Define input parameters
%   f = 'path/to/label_file.gii';  % Input file
%   hemi = 'right';  % Hemisphere
%   d = randi([0, 1], 32492, 1);  % Example label data
%   pths.wrkbnch = 'path/to/workbench';
%   pths.fsrs = 'path/to/freesurfer';
%   pths.sep = '/';
%
%   % Resample the label data
%   [resampledLabels, outputFile] = LR2fsaverage(f, hemi, d, pths);
%
% **Notes**
% -----
%   - **Dependencies**:
%     * Workbench (`wb_command`) must be installed and accessible via `pths.wrkbnch`.
%     * FreeSurfer directory must contain required templates for fs_LR and fsaverage spaces.
%   - **Metric vs Label Data**:
%     * Metric data is resampled using `-metric-resample`.
%     * Label data is resampled using `-label-resample`.
%     * The function determines the data type by checking whether all values in `d` are integers.
%   - **Template Files**:
%     * Ensure required template files (e.g., `fs_LR-deformed_to-fsaverage` and `fsaverage_std_sphere`) are available in the FreeSurfer directory.
%
% **Author**
% -------
%   Alex Teghipco // alex.teghipco@uci.edu // Last Updated: 2024-12-01
%
% **See Also**
% --------
%   wb_command, gifti

[pg, ng, eg] = fileparts(f);

if strcmpi(hemi, 'left')
    h = 'L';
elseif strcmpi(hemi, 'right')
    h = 'R';
end

if sum(logical(~rem(d, 1)))/size(d, 1) ~= 1
    o = [pg pths.sep ng '_to_fsaverage' eg];
    toE = [pths.wrkbnch pths.sep 'wb_command -metric-resample ' pg pths.sep ng eg ' ' ...
        pths.fsrs pths.sep 'fs_LR-deformed_to-fsaverage.' h '.sphere.32k_fs_LR.surf.gii ' ...
        pths.fsrs pths.sep 'fsaverage_std_sphere.' h '.164k_fsavg_' h '.surf.gii' ' ADAP_BARY_AREA ' o ' -area-metrics ' ...
        pths.fsrs pths.sep 'fs_LR.' h '.midthickness_va_avg.32k_fs_LR.shape.gii' ' ' ...
        pths.fsrs pths.sep 'fsaverage.' h '.midthickness_va_avg.164k_fsavg_' h '.shape.gii'];
else
    o = [pg pths.sep ng '_to_fsaverage.label' eg];
    toE = [pths.wrkbnch pths.sep 'wb_command -label-resample ' pg pths.sep ng eg ' ' ...
        pths.fsrs pths.sep 'fs_LR-deformed_to-fsaverage.' h '.sphere.32k_fs_LR.surf.gii ' ...
        pths.fsrs pths.sep 'fsaverage_std_sphere.' h '.164k_fsavg_' h '.surf.gii' ' ADAP_BARY_AREA ' o ' -area-metrics ' ...
        pths.fsrs pths.sep 'fs_LR.' h '.midthickness_va_avg.32k_fs_LR.shape.gii' ' ' ...
        pths.fsrs pths.sep 'fsaverage.' h '.midthickness_va_avg.164k_fsavg_' h '.shape.gii'];
end

system(toE);
tmpOut = o;
g = gifti(o);
d = double(g.cdata);
