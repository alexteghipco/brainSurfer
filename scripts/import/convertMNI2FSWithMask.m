function [outFiles] = convertMNI2FSWithMask(inFile)
% Projects thresholded volumetric data into FreeSurfer fsaverage space.
%
% This function resolves issues with projecting thresholded volumetric data into 
% surface space by using binary masks to account for voxels excluded during 
% thresholding. It calculates a surface mask to identify vertices associated 
% predominantly with empty or non-empty voxels and projects only valid vertices 
% into fsaverage space.
%
% **Syntax**
% -------
%   outFiles = convertMNI2FSWithMask(inFile)
%
% **Description**
% ---------
%   outFiles = convertMNI2FSWithMask(inFile) creates binary masks from `inFile`, 
%   one for empty voxels and another for non-empty voxels, and projects them 
%   into surface space. The function calculates a new surface mask to exclude 
%   vertices associated with predominantly empty voxels. The thresholded data is 
%   then projected to fsaverage space, producing output files for the left and 
%   right hemispheres.
%
% **Inputs**
% ------
%   inFile   - (String) Path to the input volumetric file in NIfTI format.
%              - Must be in MNI152 volumetric space.
%
% **Outputs**
% -------
%   outFiles - (Cell Array) Paths to the surface-masked output files.
%              - outFiles{1}: Masked data for the left hemisphere.
%              - outFiles{2}: Masked data for the right hemisphere.
%
% **Features**
% ---------
%   1. **Binary Mask Generation**:
%      - Creates two binary masks from `inFile`:
%        * Empty voxels (values = 0).
%        * Non-empty voxels (values ≠ 0).
%
%   2. **Surface Mapping**:
%      - Projects the binary masks and the original data into FreeSurfer fsaverage 
%        surface space for both hemispheres using `convertMNI2FS`.
%
%   3. **Thresholded Surface Masking**:
%      - Compares the empty and non-empty voxel masks in surface space to construct
%        a new mask. Vertices associated with predominantly empty voxels are excluded.
%
%   4. **Output Files**:
%      - Produces surface-masked files for the left and right hemispheres.
%
% **Examples**
% -------
%   **Example 1: Project Thresholded Data to Surface Space**
%   % Convert a volumetric file into fsaverage space with thresholding
%   inFile = '/path/to/thresholded_data.nii.gz';
%   outFiles = convertMNI2FSWithMask(inFile);
%
% **Notes**
% -----
%   - **Dependencies**:
%     * Requires external functions: `convertMNI2FS`, `load_nifti`, `save_nifti`.
%   - **Masking Logic**:
%     * Vertices are retained if the proportion of non-empty voxels is greater 
%       than the proportion of empty voxels associated with that vertex.
%   - **Intermediate Files**:
%     * Binary mask files are deleted after processing unless `verbose` is modified.
%   - **Output Files**:
%     * Surface-masked files are generated for both left and right hemispheres.
%
% **Author**
% -------
%   Alex Teghipco // alex.teghipco@uci.edu // Last Updated: 2018-10-23
%
% **See Also**
% --------
%   convertMNI2FS, load_nifti, save_nifti

% defaults
if ispc == 0
    slash = '/';
else
    slash = '\';
end

verbose = 0;

% import file and seperate empty vs nonempty voxels
[path, file, ext] = fileparts(inFile);
if isempty(path)
    path = pwd;
end

ext = '.nii.gz';
if strfind(file,'.nii') ~= 0
    file = file(1:end-4);
    %ext = '.nii.gz';
end

inNifti = load_nifti(inFile); % load inFile
emptVox = find(inNifti.vol == 0); % get empty voxels
valsVox = find(inNifti.vol ~= 0); % get nonempty voxels

% write out both empty and nonempty voxels as new nifti files
inNifti.vol = zeros(size(inNifti.vol));
inNifti.vol(emptVox) = 1;
save_nifti(inNifti,[path slash file '_EMPTY_MASK.nii']);

inNifti.vol = zeros(size(inNifti.vol));
inNifti.vol(valsVox) = 1;
save_nifti(inNifti,[path slash file '_VALS_MASK.nii']);

% convert file, and both masks (i.e., empty and non-empty voxel nifti
% files)
convertMNI2FS([path slash file '_EMPTY_MASK.nii'],[]);
convertMNI2FS([path slash file '_VALS_MASK.nii'],[]);
convertMNI2FS(inFile,[]);

if verbose == 0
    delete([path slash file '_EMPTY_MASK.nii'])
    delete([path slash file '_VALS_MASK.nii'])
end

% load in the converted files in LH and check vertices that are more
% closely associated with empty voxels
emptyMask = load_nifti([path slash file '_EMPTY_MASK_RF_ANTs_MNI152_to_fsaverage_LH.nii.gz']);
valMask = load_nifti([ path slash file '_VALS_MASK_RF_ANTs_MNI152_to_fsaverage_LH.nii.gz']);
vals = load_nifti([path slash file '_RF_ANTs_MNI152_to_fsaverage_LH.nii.gz']); %, ext ]);

for i = 1:length(emptyMask.vol) % compare masks at each vertex
    if emptyMask.vol(i) > valMask.vol(i)
        threshMask(i,1) = 0;
    else
        threshMask(i,1) = vals.vol(i);
    end
end
    
emptyMask.vol = threshMask; % save out these vertices as a surface mask
save_nifti(emptyMask,[path slash file '_SURFACE_MASKED_RF_ANTs_MNI152_to_fsaverage_LH.nii.gz']);
outFiles{1} = [path slash file '_SURFACE_MASKED_RF_ANTs_MNI152_to_fsaverage_LH.nii.gz'];

% repeat all of the same steps for right hemisphere now
emptyMask = load_nifti([path slash file '_EMPTY_MASK_RF_ANTs_MNI152_to_fsaverage_RH.nii.gz']);
valMask = load_nifti([ path slash file '_VALS_MASK_RF_ANTs_MNI152_to_fsaverage_RH.nii.gz']);
vals = load_nifti([path slash file '_RF_ANTs_MNI152_to_fsaverage_RH.nii.gz']);

for i = 1:length(emptyMask.vol) % compare masks at each vertex
    if emptyMask.vol(i) > valMask.vol(i)
        threshMask(i,1) = 0;
    else
        threshMask(i,1) = vals.vol(i);
    end
end

emptyMask.vol = threshMask; % save out these vertices as a surface mask
save_nifti(emptyMask,[path slash file '_SURFACE_MASKED_RF_ANTs_MNI152_to_fsaverage_RH.nii.gz']);
outFiles{2} = [path slash file '_SURFACE_MASKED_RF_ANTs_MNI152_to_fsaverage_RH.nii.gz'];
