function fsNative2fsLR(con, toCon, currSphereOut, midNewOut, midCurrOut, free_currSphere, fs_pial, fs_white, pths, hemi)
% Resamples data from FreeSurfer native space to fs_LR space.
%
% This function converts surface data from the FreeSurfer native space to the fs_LR surface
% space (used in the Human Connectome Project). It utilizes the Workbench command-line
% tools for surface resampling.
%
% **Syntax**
% -------
%   fsNative2fsLR(con, toCon, currSphereOut, midNewOut, midCurrOut, free_currSphere, fs_pial, fs_white, pths, hemi)
%
% **Description**
% ---------
%   fsNative2fsLR(con, toCon, currSphereOut, midNewOut, midCurrOut, free_currSphere, fs_pial, fs_white, pths, hemi)
%   performs surface-based resampling to align data from FreeSurfer's native space to
%   the fs_LR 32k space. It uses predefined templates for each hemisphere.
%
% **Inputs**
% ------
%   con             - (String) Path to the input surface file in FreeSurfer native space.
%
%   toCon           - (String) Path to the output file in fs_LR space.
%
%   currSphereOut   - (String) Path to the current sphere output file.
%
%   midNewOut       - (String) Path to the new midthickness output file.
%
%   midCurrOut      - (String) Path to the current midthickness output file.
%
%   free_currSphere - (String) Path to the FreeSurfer current sphere file.
%
%   fs_pial         - (String) Path to the FreeSurfer pial surface file.
%
%   fs_white        - (String) Path to the FreeSurfer white surface file.
%
%   pths            - (Structure) Contains paths required for processing.
%                     Fields:
%                     * `pths.wrkbnch` - Path to the Workbench command-line tool (`wb_command`).
%                     * `pths.sep`     - Path separator (e.g., `/` or `\`).
%
%   hemi            - (String) Hemisphere for the data.
%                     - Options: 'left', 'right'.
%                     - Determines whether to use left ('L') or right ('R') hemisphere templates.
%
% **Examples**
% -------
%   **Example: Convert Surface Data to fs_LR Space**
%   % Define input parameters
%   con = 'path/to/native_surface.surf.gii';  % Input surface file
%   toCon = 'path/to/fs_LR_surface.surf.gii';  % Output file in fs_LR space
%   currSphereOut = 'path/to/current_sphere.surf.gii';  % Current sphere output
%   midNewOut = 'path/to/new_midthickness.surf.gii';  % New midthickness output
%   midCurrOut = 'path/to/current_midthickness.surf.gii';  % Current midthickness output
%   free_currSphere = 'path/to/current_sphere';  % FreeSurfer current sphere
%   fs_pial = 'path/to/pial.surf.gii';  % FreeSurfer pial surface
%   fs_white = 'path/to/white.surf.gii';  % FreeSurfer white surface
%   pths.wrkbnch = 'path/to/workbench';  % Workbench command-line tool
%   pths.sep = '/';  % Path separator
%   hemi = 'left';  % Hemisphere
%
%   % Convert the data
%   fsNative2fsLR(con, toCon, currSphereOut, midNewOut, midCurrOut, free_currSphere, fs_pial, fs_white, pths, hemi);
%
% **Notes**
% -----
%   - **Dependencies**:
%     * Workbench (`wb_command`) must be installed and accessible via `pths.wrkbnch`.
%     * FreeSurfer surfaces (e.g., pial, white) and spheres (e.g., current sphere) must be available.
%   - **Hemisphere Templates**:
%     * Left and right hemisphere templates must be provided to ensure correct alignment with fs_LR.
%   - **Path Management**:
%     * Ensure all paths are correctly specified in the `pths` structure.
%   - **Output**:
%     * The output file (`toCon`) will be in fs_LR 32k space, ready for further processing or analysis.
%
% **Author**
% -------
%   Alex Teghipco // alex.teghipco@uci.edu // Last Updated: 2024-12-01
%
% **See Also**
% --------
%   wb_command, FreeSurfer

if strcmpi(hemi, 'left')
    h = 'L';
elseif strcmpi(hemi, 'right')
    h = 'R';
end

toE = [pths.wrkbnch pths.sep 'wb_command -surface-resample ' con ' ' free_currSphere ' ' currSphereOut ' ' toCon ' -midthickness ' fs_pial ' ' fs_white ' ' midCurrOut ' -midthickness '  pths.fsrs pths.sep 'fs_LR.' h '.pial_va_avg.32k_fs_LR.surf.gii' ' ' pths.fsrs pths.sep 'fs_LR.' h '.white_va_avg.32k_fs_LR.surf.gii' ' ' midNewOut];
system(toE);
