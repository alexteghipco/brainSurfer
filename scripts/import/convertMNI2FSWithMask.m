function [outFiles] = convertMNI2FSWithMask(inFile, smoothSteps, reps, templateDir)
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
if isempty(templateDir)
    templateDir = '/Applications/freesurfer/subjects/fsaverage/surf';
end

if ispc == 0
    slash = '/';
else
    slash = '\';
end

verbose = 0;

%reps = 1;

% import file and seperate empty vs nonempty voxels
[path, file, ext] = fileparts(inFile);
if strfind(file,'.nii') ~= 0
    file = file(1:end-4);
    ext = '.nii.gz';
end

inNifti = load_nifti(inFile); % load inFile
emptVox = find(inNifti.vol == 0); % get empty voxels
valsVox = find(inNifti.vol ~= 0); % get nonempty voxels

% write out both empty and nonempty voxels as new nifti files
inNifti.vol = zeros(91,109,91);
inNifti.vol(emptVox) = 1;
save_nifti(inNifti,[path slash file '_EMPTY_MASK.nii']);

inNifti.vol = zeros(91,109,91);
inNifti.vol(valsVox) = 1;
save_nifti(inNifti,[path slash file '_VALS_MASK.nii']);

% convert file, and both masks (i.e., empty and non-empty voxel nifti
% files)
convertMNI2FS([path slash file '_EMPTY_MASK.nii'],[]);
convertMNI2FS([path slash file '_VALS_MASK.nii'],[]);

if verbose == 0
    delete([path slash file '_EMPTY_MASK.nii'])
    delete([path slash file '_VALS_MASK.nii'])
end

% load in the converted files in LH and check vertices that are more
% closely associated with empty voxels
emptyMask = load_nifti([path slash file '_EMPTY_MASK_RF_ANTs_MNI152_to_fsaverage_LH.nii.gz']);
valMask = load_nifti([ path slash file '_VALS_MASK_RF_ANTs_MNI152_to_fsaverage_LH.nii.gz']);

% smooth the masks
if smoothSteps > 0
    [lhVertex, ~] = read_surf([templateDir slash 'lh.inflated']); % get vertex spatial coords
    emptyMaskIdx = find(emptyMask.vol ~= 0); % identify vertices to smooth
    valMaskIdx = find(valMask.vol ~= 0); % identify vertices to smooth
    
    [~,I] = pdist2(lhVertex,lhVertex(emptyMaskIdx,:),'euclidean','Smallest',smoothSteps); % get X nearest vertices to each vertex to smooth (x is smoothing steps)
    [~,I2] = pdist2(lhVertex,lhVertex(valMaskIdx,:),'euclidean','Smallest',smoothSteps); % get X nearest vertices to each vertex to smooth (x is smoothing steps)
    
    for i = 1:reps
        emptyMask.vol(emptyMaskIdx) = mean(emptyMask.vol(I),1);
        valMask.vol(valMaskIdx) = mean(valMask.vol(I2),1);
    end
end


for i = 1:length(emptyMask.vol) % compare masks at each vertex
    if emptyMask.vol(i) > valMask.vol(i)
        threshMask(i,1) = 1;
    else
        threshMask(i,1) = 0;
    end
end
    
emptyMask.vol = threshMask; % save out these vertices as a surface mask
save_nifti(emptyMask,[path slash file '_SURFACE_MASK_' num2str(smoothSteps) '_SMOOTHING_STEPS_WITH_' num2str(reps) '_REPS_RF_ANTs_MNI152_to_fsaverage_LH.nii.gz']);

% load in the original file projected into surface space and mask out
% vertices from the surface mask
data = load_nifti([ path slash file '_VALS_MASK_RF_ANTs_MNI152_to_fsaverage_LH.nii.gz']);
for i = 1:length(data.vol)
    if threshMask(i,1) == 1
        outMask(i,1) = 0;
    else
        outMask(i,1) = data.vol(i);
    end
end
data.vol = outMask;
save_nifti(data,[path slash file '_SURFACE_MASKED_' num2str(smoothSteps) '_SMOOTHING_STEPS_WITH_' num2str(reps) '_REPS_RF_ANTs_MNI152_to_fsaverage_LH.nii.gz']);
outFiles{1} = [path slash file '_SURFACE_MASKED_' num2str(smoothSteps) '_SMOOTHING_STEPS_WITH_' num2str(reps) '_REPS_RF_ANTs_MNI152_to_fsaverage_LH.nii.gz'];

% repeat all of the same steps for right hemisphere now
emptyMask = load_nifti([path slash file '_EMPTY_MASK_RF_ANTs_MNI152_to_fsaverage_RH.nii.gz']);
valMask = load_nifti([ path slash file '_VALS_MASK_RF_ANTs_MNI152_to_fsaverage_RH.nii.gz']);

% smooth the masks
if smoothSteps > 0
    [rhVertex, ~] = read_surf([templateDir slash 'rh.inflated']); % get vertex spatial coords
    emptyMaskIdx = find(emptyMask.vol ~= 0); % identify vertices to smooth
    valMaskIdx = find(valMask.vol ~= 0); % identify vertices to smooth
    
    [~,I] = pdist2(rhVertex,rhVertex(emptyMaskIdx,:),'euclidean','Smallest',10); % get X nearest vertices to each vertex to smooth (x is smoothing steps)
    [~,I2] = pdist2(rhVertex,rhVertex(valMaskIdx,:),'euclidean','Smallest',10); % get X nearest vertices to each vertex to smooth (x is smoothing steps)
    
    for i = 1:reps
        emptyMask.vol(emptyMaskIdx) = mean(emptyMask.vol(I),1);
        valMask.vol(valMaskIdx) = mean(valMask.vol(I2),1);
    end
end

for i = 1:length(emptyMask.vol) % compare masks at each vertex
    if emptyMask.vol(i) > valMask.vol(i)
        threshMask(i,1) = 1;
    else
        threshMask(i,1) = 0;
    end
end

emptyMask.vol = threshMask; % save out these vertices as a surface mask
save_nifti(emptyMask,[path slash file '_SURFACE_MASK_' num2str(smoothSteps) '_SMOOTHING_STEPS_WITH_' num2str(reps) '_REPS_RF_ANTs_MNI152_to_fsaverage_RH.nii.gz']);

% load in the original file projected into surface space and mask out
% vertices from the surface mask
data = load_nifti([ path slash file '_VALS_MASK_RF_ANTs_MNI152_to_fsaverage_RH.nii.gz']);
for i = 1:length(data.vol)
    if emptyMask.vol(i,1) == 1
        outMask(i,1) = 0;
    else
        outMask(i,1) = data.vol(i);
    end
end
data.vol = outMask;
save_nifti(data,[path slash file '_SURFACE_MASKED_' num2str(smoothSteps) '_SMOOTHING_STEPS_WITH_' num2str(reps) '_REPS_RF_ANTs_MNI152_to_fsaverage_RH.nii.gz']);
outFiles{2} = [path slash file '_SURFACE_MASKED_' num2str(smoothSteps) '_SMOOTHING_STEPS_WITH_' num2str(reps) '_REPS_RF_ANTs_MNI152_to_fsaverage_RH.nii.gz'];
