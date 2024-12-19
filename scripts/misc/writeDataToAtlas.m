function writeDataToAtlas(atLabs, atFile, data, dataLabs, ofAppend)
% Write Data Values to Atlas ROIs in NIfTI Files
%
%   This function updates atlas NIfTI files by writing new data values into
%   each Region of Interest (ROI) defined in the atlas. It matches the
%   provided data labels with the atlas labels and assigns the corresponding
%   data values to the respective ROIs within the atlas volumes.
%
% **Mandatory Arguments**
% -----------------------
%   atLabs     - (String) Path to a text file containing labels for each ROI in the atlas.
%                Each line in the file should correspond to an ROI label.
%                - Example:
%                  atLabs = 'D:\Science\Matlab\GitHub\brainSurfer\atlases\jhu_resampled_to_FSL_fixed_noWM.txt';
%
%   atFile     - (Cell Array of Strings) Cell array containing paths to the NIfTI atlas files.
%                Typically, this includes separate files for left and right hemispheres.
%                - Example:
%                  atFile = {
%                      'D:\Science\Matlab\GitHub\brainSurfer\atlases\jhu_resampled_to_FSL_fixed_noWM_renamed_CombinedClusters_FSSpace_LH.nii.gz',
%                      'D:\Science\Matlab\GitHub\brainSurfer\atlases\jhu_resampled_to_FSL_fixed_noWM_renamed_CombinedClusters_FSSpace_RH.nii.gz'
%                  };
%
%   data       - (Numeric Vector, n x 1) A vector containing the data values to be written into the atlas.
%                Each element corresponds to a specific ROI.
%                - Example:
%                  data = [0.2; 0.2];
%
%   dataLabs   - (Cell Array of Strings, n x 1) A cell array containing the names of the ROIs.
%                Each label must match exactly with the corresponding label in `atLabs`.
%                The order of labels should correspond to the order of data values.
%                - Example:
%                  dataLabs = {'MTG L cbf', 'Cu L cbf'};
%
%   ofAppend   - (String) A string to append to the output NIfTI filenames, typically indicating
%                the type of data appended.
%                - Example:
%                  ofAppend = '_updated';
%
% **Output**
% ----------
%   The function does not return any output arguments. Instead, it saves the updated NIfTI files
%   with the appended filename provided by `ofAppend`. The original atlas files remain unchanged.
%
% **Function Call Example**
% --------------------------
%   % Define input parameters
%   atLabs = 'D:\Science\Matlab\GitHub\brainSurfer\atlases\jhu_resampled_to_FSL_fixed_noWM.txt';
%   atFile = {
%       'D:\Science\Matlab\GitHub\brainSurfer\atlases\jhu_resampled_to_FSL_fixed_noWM_renamed_CombinedClusters_FSSpace_LH.nii.gz',
%       'D:\Science\Matlab\GitHub\brainSurfer\atlases\jhu_resampled_to_FSL_fixed_noWM_renamed_CombinedClusters_FSSpace_RH.nii.gz'
%   };
%   data = [0.2; 0.2];
%   dataLabs = {'MTG L cbf', 'Cu L cbf'};
%   ofAppend = '_cbf_values';
%
%   % Call the function
%   writeDataToAtlas(atLabs, atFile, data, dataLabs, ofAppend);
%
%   % Result:
%   % - Updated NIfTI files saved as:
%   %   'jhu_resampled_to_FSL_fixed_noWM_renamed_CombinedClusters_FSSpace_LH_cbf_values.nii.gz'
%   %   'jhu_resampled_to_FSL_fixed_noWM_renamed_CombinedClusters_FSSpace_RH_cbf_values.nii.gz'
%
% **Detailed Description**
% ------------------------
%   The `writeDataToAtlas` function performs the following steps:
%
%   1. **Load Atlas Labels and NIfTI Files:**
%      - Reads the atlas labels from the specified text file `atLabs` into a table.
%      - Loads each NIfTI file specified in `atFile` using the `load_nifti` function.
%
%   2. **Initialize Output NIfTI Structures:**
%      - Creates copies of the loaded NIfTI structures for output (`of`).
%      - Initializes the volume data in each output NIfTI structure to zero.
%
%   3. **Assign Data to ROIs:**
%      - Iterates over each data point in `data`.
%      - Processes the corresponding label in `dataLabs` to match the format in `atLabs`.
%        - Replaces spaces with underscores to standardize the label format.
%      - Finds the ROI ID in the atlas labels that matches the processed label.
%      - Identifies the corresponding voxel indices in the atlas NIfTI volumes.
%      - Assigns the data value to the matched voxel indices in the appropriate hemisphere.
%      - If a label from `dataLabs` is not found in `atLabs`, a message is displayed.
%
%   4. **Save Updated NIfTI Files:**
%      - Saves the updated NIfTI structures to new files with the `ofAppend` string appended
%        to the original filenames, preserving the `.nii.gz` extension.
%
% **Notes**
% ----------
%   - Ensure that the labels in `dataLabs` exactly match those in the `atLabs` file after
%     replacing spaces with underscores. Mismatches will result in labels not being found.
%
%   - The function assumes that `atFile` contains exactly two NIfTI files corresponding to
%     the left and right hemispheres. Modify the function accordingly if using a different
%     number of atlas files.
%
%   - The `load_nifti` and `save_nifti` functions must be available in the MATLAB path.
%     These functions are typically part of neuroimaging toolboxes such as NIfTI Tools.
%
%   - The `ofAppend` string should not include file extensions. It is appended directly
%     before the `.nii.gz` extension in the output filenames.
%
% **Error Handling**
% -------------------
%   - If a label in `dataLabs` does not match any label in `atLabs`, the function
%     displays a message indicating that the label was not found.
%   - Ensure that the length of `data` and `dataLabs` is the same to avoid indexing errors.
%
% **Author**
% -------
%   Alex Teghipco // alex.teghipco@uci.edu // Last Updated: 2024-12-01
%
% **Dependencies**
% -----------------
%   - `load_nifti`: Function to load NIfTI files.
%   - `save_nifti`: Function to save NIfTI files.

% Read the atlas labels from the specified text file
atLabsTable = readtable(atLabs);

% Load the NIfTI files for both hemispheres
atNii{1} = load_nifti(atFile{1});
atNii{2} = load_nifti(atFile{2});

% Initialize output NIfTI structures with zeroed volumes
of{1} = atNii{1};
of{1}.vol = zeros(size(of{1}.vol));
of{2} = atNii{2};
of{2}.vol = zeros(size(of{2}.vol));

% Iterate over each data point to assign values to the atlas ROIs
for i = 1:length(data)
    % Find the position of spaces in the current data label
    spaceIndices = strfind(dataLabs{i}, ' ');

    % Process the label to match the atlas label format
    if contains(dataLabs{i}, 'pole')
        tmpLabel = dataLabs{i}(1:spaceIndices(end) - (spaceIndices(end) - spaceIndices(end-1)) - 1);
    else
        tmpLabel = dataLabs{i}(1:spaceIndices(end) - (spaceIndices(end) - spaceIndices(end-2)) - 1);
    end

    % Replace spaces with underscores in the processed label
    spaceIndices = strfind(tmpLabel, ' ');
    tmpLabel(spaceIndices) = '_';

    % Find the ROI ID corresponding to the processed label
    roiID = find(ismember(atLabsTable.Var2, tmpLabel));

    if isempty(roiID)
        % Display a message if the label is not found in the atlas
        disp([dataLabs{i} ' not found']);
    else
        % Retrieve the numerical ID for the ROI
        roiNumericalID = atLabsTable.Var1(roiID);

        % Check which hemisphere the ROI belongs to and assign the data value
        c1 = intersect(atNii{1}.vol, roiNumericalID);
        c2 = intersect(atNii{2}.vol, roiNumericalID);

        if ~isempty(c1)
            % Find voxel indices in the left hemisphere atlas and assign the data value
            voxelIndices = find(atNii{1}.vol == roiNumericalID);
            of{1}.vol(voxelIndices) = data(i);
        elseif ~isempty(c2)
            % Find voxel indices in the right hemisphere atlas and assign the data value
            voxelIndices = find(atNii{2}.vol == roiNumericalID);
            of{2}.vol(voxelIndices) = data(i);
        end
    end
end

% Save the updated NIfTI files with the appended filename
save_nifti(of{1}, [atFile{1}(1:end-7) ofAppend '.nii.gz']);
save_nifti(of{2}, [atFile{2}(1:end-7) ofAppend '.nii.gz']);
