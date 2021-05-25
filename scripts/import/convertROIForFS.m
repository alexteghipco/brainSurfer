function [outFiles] = convertROIForFS(inFile, weight)
% This function will convert an ROI map from nifti's MNI 152 template to
% Freesurfers' fsaverage template. It will seperate out all intensities
% (i.e., ROIs) in the input file into their own individual files, and then
% convert them to surface space. For every vertex, a percentage is
% calculated for each ROI that represents the degree to which it maps onto
% that vertex (i.e, 100% for  roi i at vertex j means that all voxels k,l,m
% that map onto j belong to i). The script will then assign one ROI to each
% vertex by looking at which percentage is highest. This ROI map is written
% out along with a confidence map, which provides the exact percentage at
% each vertex for the 'winning' ROI.
%ed
% You may provide the script with a weight vector that tells it which ROIs
% to give preference to. This means that the best mapping within the list
% of preferred ROIs will be considered first, before moving onto the
% remaining ROIs. The script will move onto to the non-preferred ROIs only
% if none of the preferred ROIs maps onto a given vertex at all. This
% functionality is useful in the case that inFile contains a combination of
% actual ROIs and ROIs that represent the overlap between those initial
% ROIs. In such cases, a vertex may correspond more strongly to ROI i, but
% if ROI k is an overlap between ROI i and ROI j, and it maps weakly onto
% the same vertex, you might want to give preference to ROI k.
%
% The weight vector is as long as the number of rois in inFile and is
% comprised of 1s and 0s. By default it is set to all 1s, thereby giving no
% preference to any ROI. *NOTE* this option requires you to know the number
% of unique ROIs in your file ahead of time. For instance, maybe you
% created your ROI file (i.e., inFile) so that there can be 7 ROIs in
% principle (e.g., because there are 3 ROIs and 4 different overlap
% combinations). However, if your map does not end up containing overlaps
% between two of the ROIs, the file itself will only have 5 ROIs
% represented within it.
%
% Example calls:
% convertROIForFS('/Users/ateghipc/Projects/PT/matlabVars/ROI.nii',[0 1 0 1 1]);
% convertROIForFS('/Users/ateghipc/Projects/PT/matlabVars/ROI.nii',[]);
%
% Alex Teghipco // alex.teghipco@uci.edu // 10/19/18

%% Defaults
verbose = 0;

%% 1) Convert one map to many depending on how many intensities are present
%inFile = load_untouch_nii(inFile);
inNifti = load_nifti(inFile);
rois = unique(inNifti.vol);
idx = find(rois == 0);
rois(idx) = [];
outFile = inNifti;

[inPath,inName,inExt] = fileparts(inFile);
if strfind(inName,'.nii') ~= 0
    inName = inName(1:end-4);
    inExt = '.nii.gz';
end

if ispc == 0
    slash = '/';
else
    slash = '\';
end

if isempty(weight) == 1
    weight = logical(ones(1,[length(rois)])); % weights preference later numbers
end

if isa(weight,'double') == 1
    weight = logical(weight);
end

for roi = 1:length(rois)
    idx = find(inNifti.vol == rois(roi));
    outFile.vol = zeros(size(inNifti.vol,1),size(inNifti.vol,2),size(inNifti.vol,3));
    outFile.vol(idx) = rois(roi);
    tmpName = [inName '_ROI_' num2str(rois(roi))];
    save_nifti(outFile,[inPath slash tmpName inExt]);
    toConvert{roi,1} = [inPath slash tmpName inExt];
end

%% 2) Convert individual intensity maps into surface space
for i = 1:length(toConvert)
    convertMNI2FS(toConvert{i},[]);
    [path, file, ext] = fileparts(toConvert{i});
    if strfind(file,'.nii') ~= 0
        file = file(1:end-4);
        ext = '.nii.gz';
    end
    toConvertFS_LH{i,1} = [path slash file '_RF_ANTs_MNI152_to_fsaverage_LH.nii.gz'];
    toConvertFS_RH{i,1} = [path slash file '_RF_ANTs_MNI152_to_fsaverage_RH.nii.gz'];
end

if verbose == 0
    for i = 1:length(toConvert)
        delete(toConvert{i})
    end
end

%% 3) Loop over maps and determine which intensity is most strongly associated with each vertex
for i = 1:length(toConvertFS_LH)
    disp(num2str(i))
    hdr = load_nifti(toConvertFS_LH{i});
    allVol(:,i) = hdr.vol;
end
    
for j = 1:size(allVol,1)
    vert = allVol(j,:); % get all roi values at vertex j
    if all(vert == 0) == 0 % check if no roi maps onto that vertex at all
       vertNorm = vert ./ double(rois)'; % normalize mapping into percentage
       % split roi values into a prefered vector and a non-preferred vector
       vertPrefVals = vertNorm(weight); % weighted values
       vertPrefROI = rois(weight); % weighted rois
       idx = find(vertPrefVals == 0); % remove empty weighted values
       vertPrefVals(idx) = [];
       vertPrefROI(idx) = [];
       if isempty(vertPrefVals) == 0 % if set of weighted values is empty then select greatest overlap from unweighted values
          [maxVal,maxRow] = max(vertPrefVals); % get strongest mapping ROI onto vertex
          fsmap(j,1) = vertPrefROI(maxRow); % get the ROI associated with the max  
          fsmapCert(j,1) = maxVal; % write in the overlap %
       else
           vertUnprefVals = vertNorm(~weight);
           vertUnprefROI = rois(~weight);
           idx = find(vertUnprefVals == 0);
           vertUnprefVals(idx) = [];
           vertUnprefROI(idx) = [];
           [maxVal,maxRow] = max(vertUnprefVals);
           fsmap(j,1) = vertUnprefROI(maxRow);
           fsmapCert(j,1) = maxVal;
       end
    else
        fsmap(j,1) = 0;
        fsmapCert(j,1) = 0;
    end
end
       
hdr.vol = fsmap;
save_nifti(hdr,[inPath slash inName '_CombinedClusters_FSSpace_LH.nii.gz']);
hdr.vol = fsmapCert;
save_nifti(hdr,[inPath slash inName '_CombinedClusters_Confidence_FSSpace_LH.nii.gz']);

outFiles{1,1} = [inPath slash inName '_CombinedClusters_FSSpace_LH.nii.gz'];
outFiles{2,1} = [inPath slash inName '_CombinedClusters_Confidence_FSSpace_LH.nii.gz'];

if verbose == 0
    for i = 1:length(toConvertFS_LH)
        delete(toConvertFS_LH{i})
    end
end
    

for i = 1:length(toConvertFS_RH)
    hdr = load_nifti(toConvertFS_RH{i});
    allVol(:,i) = hdr.vol;
end
for j = 1:size(allVol,1)
    vert = allVol(j,:); % get all roi values at vertex j
    if all(vert == 0) == 0 % check if no roi maps onto that vertex at all
        vertNorm = vert ./ rois'; % normalize mapping into percentage
        % split roi values into a prefered vector and a non-preferred vector
        vertPrefVals = vertNorm(weight); % weighted values
        vertPrefROI = rois(weight); % weighted rois
        idx = find(vertPrefVals == 0); % remove empty weighted values
        vertPrefVals(idx) = [];
        vertPrefROI(idx) = [];
        if isempty(vertPrefVals) == 0 % if set of weighted values is empty then select greatest overlap from unweighted values
            [maxVal,maxRow] = max(vertPrefVals); % get strongest mapping ROI onto vertex
            fsmap(j,1) = vertPrefROI(maxRow); % get the ROI associated with the max
            fsmapCert(j,1) = maxVal; % write in the overlap %
        else
            vertUnprefVals = vertNorm(~weight);
            vertUnprefROI = rois(~weight);
            idx = find(vertUnprefVals == 0);
            vertUnprefVals(idx) = [];
            vertUnprefROI(idx) = [];
            [maxVal,maxRow] = max(vertUnprefVals);
            fsmap(j,1) = vertUnprefROI(maxRow);
            fsmapCert(j,1) = maxVal;
        end
    else
        fsmap(j,1) = 0;
        fsmapCert(j,1) = 0;
    end
end

hdr.vol = fsmap;
save_nifti(hdr,[inPath slash inName '_CombinedClusters_FSSpace_RH.nii.gz']);
hdr.vol = fsmapCert;
save_nifti(hdr,[inPath slash inName '_CombinedClusters_Confidence_FSSpace_RH.nii.gz']);

outFiles{3,1} = [inPath slash inName '_CombinedClusters_FSSpace_RH.nii.gz'];
outFiles{4,1} = [inPath slash inName '_CombinedClusters_Confidence_FSSpace_RH.nii.gz'];

if verbose == 0
    for i = 1:length(toConvertFS_RH)
        delete(toConvertFS_RH{i})
    end
end
