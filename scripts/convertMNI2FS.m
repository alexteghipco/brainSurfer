function [outFiles] = convertMNI2FS(inFile,outFolder)
% created by Alex Teghipco. Only works with 2mm MNI as inFile. 
% setup 
defaultWarp = 'avgMapping_allSub_RF_ANTs_MNI152_orig_to_fsaverage.mat';
[inFilePath,inFileName,ext] = fileparts(inFile);

if isempty(outFolder) == 1
   outFolder = inFilePath; 
end

input = MRIread(inFile);
[lh_proj_data, rh_proj_data] = CBIG_RF_projectVol2fsaverage(inFile,'linear',['/Users/ateghipc/MATLAB-Drive/Published/projectFSAVERAGE/final_warps_FS5.3/lh.' defaultWarp],['/Users/ateghipc/MATLAB-Drive/Published/projectFSAVERAGE/final_warps_FS5.3/rh.' defaultWarp]); 
input.vol = permute(lh_proj_data, [4 2 3 1]);  
MRIwrite(input,[outFolder '/lh.MNI_' inFileName '_RF_ANTs_MNI152_orig_to_fsaverage.nii.gz']);                                          
input.vol = permute(rh_proj_data, [4 2 3 1]);                                          
MRIwrite(input,[outFolder '/rh.MNI_' inFileName '_RF_ANTs_MNI152_orig_to_fsaverage.nii.gz']);

outFiles{1} = [outFolder '/lh.MNI_' inFileName '_RF_ANTs_MNI152_orig_to_fsaverage.nii.gz']
outFiles{2} = [outFolder '/rh.MNI_' inFileName '_RF_ANTs_MNI152_orig_to_fsaverage.nii.gz']

end
