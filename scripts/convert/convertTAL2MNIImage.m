function [] = convertTAL2MNIImage(inFiles,thresh,binarize)
if isempty(inFiles) == 1
    inFiles = uipickfiles;
end

for i = 1:length(inFiles)
    [pathstr,name,ext] = fileparts(inFiles{i});
    if strfind(ext,'.gz') == 1
        gunzip(inFiles{i});
        [~, voxelROI_niftiSpaceS, ~, ~, ~, ~, data] = voxelize(inFiles{i}(1:end-3),'true');
        if isempty(thresh) == 0
            idx = find(data > thresh);
        else
            idx = find(data);
        end
        voxelROI_niftiSpaceS = voxelROI_niftiSpaceS(idx,:);
        voxelROI_niftiSpaceS_MM = convertVoxel2MM(inFiles{i}(1:end-3),voxelROI_niftiSpaceS);
        voxelROI_niftiSpaceS_MM2TAL = convertTAL2MNI(voxelROI_niftiSpaceS_MM);
        voxelROI_niftiSpaceS_MM2TAL_Voxel = convertMM2Voxel(inFiles{i}(1:end-3),voxelROI_niftiSpaceS_MM2TAL);
        if binarize == 0
            writeROI(ones(size(voxelROI_niftiSpaceS_MM2TAL_Voxel,1),1),voxelROI_niftiSpaceS_MM2TAL_Voxel,[inFiles{i}(1:end-7) '_TAL_thresh' num2str(thresh) '.nii'],[],'false',[],[],[],'false')
        else
            writeROI(data(idx),voxelROI_niftiSpaceS_MM2TAL_Voxel,[inFiles{i}(1:end-7) '_TAL_thresh' num2str(thresh) '.nii'],[],'false',[],[],[],'false')
        end
    else
        [~, voxelROI_niftiSpaceS, ~, ~, ~, ~, data] = voxelize(inFiles{i},'true');
        if isempty(thresh) == 0
            idx = find(data > thresh);
        else
            idx = find(data);
        end
        voxelROI_niftiSpaceS = voxelROI_niftiSpaceS(idx,:);
        voxelROI_niftiSpaceS_MM = convertVoxel2MM(inFiles{i},voxelROI_niftiSpaceS);
        voxelROI_niftiSpaceS_MM2TAL = convertMNI2TAL(voxelROI_niftiSpaceS_MM);
        voxelROI_niftiSpaceS_MM2TAL_Voxel = convertMM2Voxel(inFiles{i},voxelROI_niftiSpaceS_MM2TAL);
        if binarize == 0
            writeROI(data(idx),voxelROI_niftiSpaceS_MM2TAL_Voxel,[inFiles{i}(1:end-4) '_MNI_thresh' num2str(thresh) '.nii'],[],'false',[],[],[],[])
        else
            writeROI(ones(size(voxelROI_niftiSpaceS_MM2TAL_Voxel,1),1),voxelROI_niftiSpaceS_MM2TAL_Voxel,[inFiles{i}(1:end-4) '_MNI_thresh' num2str(thresh) '.nii'],[],'false',[],[],[],[])
        end
    end
end