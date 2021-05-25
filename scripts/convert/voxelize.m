function [voxelROI_matlabSpaceS, voxelROI_niftiSpaceS, voxelROI_empty_matlabSpaceS, voxelROI_empty_niftiSpaceS, voxelROI_matlabSpaceI, emptyVoxels_matlabSpaceI, voxelROI_mm, emptyVoxels_mm, voxelData] = voxelize(inFile,nonzero)
% Call: 
% [voxelROI_matlabSpaceS, voxelROI_niftiSpaceS, voxelROI_empty_matlabSpaceS, voxelROI_empty_niftiSpaceS, voxelROI_matlabSpaceI, emptyVoxels_matlabSpaceI, voxelROI_mm, emptyVoxels_mm, voxelData] = voxelize(inFile,nonzero)
%
% voxelize(inFile,nonzero) returns multiple coordinates for voxels in
% inFile, including: i) coordinates presumed to reflect mm space (ie after
% applying the sform transformation matrix), ii) coordinates in 'voxel
% space' (ie subscripts of voxels in 3D image that correspond to x,y,and z
% dimensions) and iv) 'matlab' adjusted voxel space coordinates provided as
% both subscripts and indices of voxels in 3D image (same as voxel
% coordinates but all indexing is fixed to start at 1 because matlab
% indexing starts at 1).
%
% Inputs: 
% inFile -- either a structure as output by load_nifti or a fullfile path
% to a nifti file.
% Nonzero -- either set to 'true' to only extract coordinates for nonzero
% voxels in inFile or 'false' to extract the coordinates of all voxels from
% inFile (*note* output coordinates for voxels that have a value of zero
% are stored in a separate variables emptyVoxels_mm and
% emptyVoxels_matlabSpaceI)
%
% Outputs: 
% voxelROI_matlabSpaceS -- Subscripts of non-zero valued voxels in image, but
%   indexing starts at 1 instead of 0 (Columns 1,2,3 correspond to x,y,z
%   dimensions respectively)
%
% voxelROI_niftiSpaceS -- Subscripts of non-zero valued voxels in image, but
%   indexing starts at 0 just as you would see when loading the image into
%   your favorite visualization software (Columns 1,2,3 correspond to x,y,z
%   dimensions respectively)
%
% voxelROI_empty_matlabSpaceS -- Subscripts of zero valued voxels in image, but
%   indexing starts at 1 instead of 0 (Columns 1,2,3 correspond to x,y,z
%   dimensions respectively)
%
% voxelROI_empty_niftiSpaceS -- Subscripts of zero valued voxels in image, but
%   indexing starts at 0 just as you would see when loading the image into
%   your favorite visualization software (Columns 1,2,3 correspond to x,y,z
%   dimensions respectively)
%
% voxelROI_matlabSpaceI -- Indices of non-zero valued voxels in image but
%   indexing starts at 1 instead of 0
%
% emptyVoxels_matlabSpaceI -- Indices of zero valued voxels in image but
%   indexing starts at 1 instead of 0
%
% voxelROI_mm -- Subscripts of non-zero valued voxels in image, after
%   applying the inverse of the sform matrix (i.e., in 'mm' space although)
%   it might actually be some other space if you haven't registered your
%   image to a template (Columns 1,2,3 correspond to x,y,z
%   dimensions respectively)
%
% emptyVoxels_mm -- Subscripts of zero valued voxels in image, after
%   applying the inverse of the sform matrix (i.e., in 'mm' space although)
%   it might actually be some other space if you haven't registered your
%   image to a template. This variable will be empty if 'nonzero' argument
%   is set to 'true' (Columns 1,2,3 correspond to x,y,z
%   dimensions respectively)
%
% voxelData -- Values assigned to voxels. Rows in voxelData correspond to
%   the same voxels as the rows of all of the coordinates.
%
% Alex Teghipco // alex.teghipco@uci.edu

if ischar(inFile) == 1
    inFileNifti = load_nifti(inFile); %assumes file in 2mm space
    inFileMat = inFileNifti.vol;
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
