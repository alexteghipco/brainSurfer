function [voxelROI_matlabSpaceS, voxelROI_niftiSpaceS, voxelROI_empty_matlabSpaceS, voxelROI_empty_niftiSpaceS, voxelROI_matlabSpaceI, emptyVoxels_matlabSpaceI, voxelROI_mm, emptyVoxels_mm, voxelData] = voxelize(inFile,nonzero)
if ischar(inFile) == 1
    inFileNifti = load_untouch_nii(inFile); %assumes file in 2mm space
    inFileMat = inFileNifti.img;
    dim = size(inFileMat);
    if size(dim,2) == 4
        warning('Your file has multiple brain maps...extracting only the first')
        inFileMat = inFileMat(:,:,:,1);
    end    
else
    inFileMat = inFile;
    %deal with linear indices here
end

switch nonzero
    case 'true'
        voxelROI_matlabSpaceI = find(inFileMat);
        emptyVoxels_matlabSpaceI = find(inFileMat==0);
        
        [voxelROI_matlabSpaceS(:,1),voxelROI_matlabSpaceS(:,2),voxelROI_matlabSpaceS(:,3)] = ind2sub(size(inFileMat),voxelROI_matlabSpaceI);
        [voxelROI_empty_matlabSpaceS(:,1),voxelROI_empty_matlabSpaceS(:,2),voxelROI_empty_matlabSpaceS(:,3)] = ind2sub(size(inFileMat),voxelROI_matlabSpaceI);
        voxelROI_niftiSpaceS = voxelROI_matlabSpaceS - 1;
        voxelROI_empty_niftiSpaceS = voxelROI_empty_matlabSpaceS - 1;
        voxelData = inFileMat(voxelROI_matlabSpaceI);
        voxelROI_mm = convertVoxel2MM(inFile,voxelROI_niftiSpaceS);
        emptyVoxels_mm = [];
    case 'false'
        voxelROI_matlabSpaceI = 1:prod(size(inFileMat));
        emptyVoxels_matlabSpaceI = find(inFileMat == 0);
        
        [voxelROI_matlabSpaceS(:,1),voxelROI_matlabSpaceS(:,2),voxelROI_matlabSpaceS(:,3)] = ind2sub(size(inFileMat),voxelROI_matlabSpaceI);
        [voxelROI_empty_matlabSpaceS(:,1),voxelROI_empty_matlabSpaceS(:,2),voxelROI_empty_matlabSpaceS(:,3)] = ind2sub(size(inFileMat),voxelROI_matlabSpaceI);
        voxelROI_niftiSpaceS = voxelROI_matlabSpaceS - 1;
        voxelROI_empty_niftiSpaceS = voxelROI_empty_matlabSpaceS - 1;
        voxelData = inFileMat(voxelROI_matlabSpaceI);
        voxelROI_mm = convertVoxel2MM(inFile,voxelROI_niftiSpaceS);
        emptyVoxels_mm = convertVoxel2MM(inFile,voxelROI_empty_niftiSpaceS);
end
