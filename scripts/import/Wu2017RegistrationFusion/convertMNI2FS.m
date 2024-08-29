function [outFiles] = convertMNI2FS(inFile,outFolder)
% inFile is a path to file you want to convert (must be in 2mm MNI space)
% outFolder is where you want to put the transformed output files (in fsaverage space)
%
% Written by Alex Teghipco
if ispc == 1
    slash = '\';
else
    slash = '/';
end

toolboxPath = which('convertMNI2FS.m');
[toolboxPath, ~] = fileparts(toolboxPath);

defaultWarp = 'avgMapping_allSub_RF_ANTs_MNI152_orig_to_fsaverage.mat';
[inFilePath,inFileName,ext] = fileparts(inFile);
%ext = '.nii.gz';
if strcmpi(ext,'.gz')
    inFileName = inFileName(1:end-4);
    %ext = '.nii.gz';
end

if isempty(outFolder) == 1
   outFolder = inFilePath; 
end

input = MRIread(inFile);
[lh_proj_data, rh_proj_data] = CBIG_RF_projectVol2fsaverage(inFile,'linear',[toolboxPath slash 'final_warps_FS5.3' slash 'lh.' defaultWarp],[toolboxPath slash 'final_warps_FS5.3' slash 'rh.' defaultWarp]); 
input.vol = permute(lh_proj_data, [4 2 3 1]);  
MRIwrite(input,[outFolder slash inFileName '_RF_ANTs_MNI152_to_fsaverage_LH.nii.gz']);                                          
input.vol = permute(rh_proj_data, [4 2 3 1]);                                          
MRIwrite(input,[outFolder slash inFileName '_RF_ANTs_MNI152_to_fsaverage_RH.nii.gz']);

outFiles{1} = [outFolder slash inFileName '_RF_ANTs_MNI152_to_fsaverage_LH.nii.gz'];
outFiles{2} = [outFolder slash inFileName '_RF_ANTs_MNI152_to_fsaverage_RH.nii.gz'];

end
