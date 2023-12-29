function [outFiles] = convertMNI2FSWithMask(inFile)
% This function creates a mask of empty intensities in inFile and projects
% it into surface space in order to threshold the surface based projection
% of inFile.
%
% A problem for projecting your data into surface space is that it might
% already be thresholded in volume space. Because projection requires
% downsampling, some vertices will invariably map onto both voxels that are
% below the threshold (i.e., empty in volume space) and above threshold.
% This may result in vertices being assigned average intensities that are
% below the actual threshold value that was used to constrain the data in
% volume space.
%
% To project thresholded data into surface space, this script takes inFile
% and creates two masks, one of the empty voxels (i.e., zeros) and one of
% voxels with some intensity. It projects both binary masks onto surface
% space. In surface space, a value closer to 1 for each of these masks
% represents vertices whose associated group of voxels is comprised of a
% greater proportion of 1s. A new mask is constructed for all vertices
% where more voxels are associated with the mask of empty voxels than the
% mask of non-empty voxels. Finally, the script projects the original data
% in inFile into surface space and removes all vertices that are in this
% mask. 
%
% Alex Teghipco // ateghipc@uci.edu // 10/23/18

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
