function writeDataToAtlas(atLabs,atFile,data,dataLabs,ofAppend)
% This function will take an atlas file and write in new values for each
% ROI in the atlas. 
%
% atLabs: a text file showing labels for each ROI. See
% jhu_resampled_to_FSL_fixed_noWM as an example
%
% atFile: a path to a nifti file
%
% data: an n x 1 matrix where n corresponds to number of ROIs
%
% dataLabs: an n x 1 matrix where n corresponds to the name of the ROI,
% which must match the names in atLabs. Note, each row in dataLabs has to
% correspond to the same region as the row in data. 
% 
% example call: writeDataToAtlas('D:\Science\Matlab\GitHub\brainSurfer\atlases\jhu_resampled_to_FSL_fixed_noWM.txt',{'D:\Science\Matlab\GitHub\brainSurfer\atlases\jhu_resampled_to_FSL_fixed_noWM_renamed_CombinedClusters_FSSpace_LH.nii.gz';'D:\Science\Matlab\GitHub\brainSurfer\atlases\jhu_resampled_to_FSL_fixed_noWM_renamed_CombinedClusters_FSSpace_RH.nii.gz'},[0.2; 0.2],{'MTG L cbf ','Cu L cbf'})

atLabs = readtable(atLabs);
atNii{1} = load_nifti(atFile{1});
atNii{2} = load_nifti(atFile{2});

of{1} = atNii{1};
of{1}.vol = zeros(size(of{1}.vol));
of{2} = atNii{2};
of{2}.vol = zeros(size(of{2}.vol));

for i = 1:length(data)
    id = strfind(dataLabs{i},' ');
    if contains(dataLabs{i},'pole')
        tmp = dataLabs{i}(1:id(end)-(id(end)-id(end-1))-1);
    else
        tmp = dataLabs{i}(1:id(end)-(id(end)-id(end-2)-1)); %dataLabs{i}(1:id(end)-5);
    end

    id = strfind(tmp,' ');
    tmp(id) = '_';
    id = find(ismember(atLabs.Var2,tmp));
    if isempty(id)
        disp([dataLabs{i} ' not found'])
    else
        id = atLabs.Var1(id);
        c1 = intersect(atNii{1}.vol,id);
        c2 = intersect(atNii{2}.vol,id);
        if ~isempty(c1)
            mid = find(atNii{1}.vol == id);
            of{1}.vol(mid) = data(i);
        elseif ~isempty(c2)
            mid = find(atNii{2}.vol == id);
            of{2}.vol(mid) = data(i);
        end
    end
end
save_nifti(of{1},[atFile{1}(1:end-7) ofAppend '.nii.gz'])
save_nifti(of{2},[atFile{2}(1:end-7) ofAppend '.nii.gz'])
