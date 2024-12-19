function [outFiles] = convertROIForFS(inFile, weight)
% Converts an ROI map from MNI space to FreeSurfer fsaverage space.
%
% This function converts a volumetric ROI map in the MNI152 template space to 
% FreeSurfer's fsaverage surface space. It separates ROIs based on intensities in 
% the input file, calculates their mapping percentages for each vertex, and assigns 
% the most likely ROI to each vertex based on either default or user-defined weighting.
%
% **Syntax**
% -------
%   outFiles = convertROIForFS(inFile)
%   outFiles = convertROIForFS(inFile, weight)
%
% **Description**
% ---------
%   outFiles = convertROIForFS(inFile) converts the ROIs in `inFile` to surface space
%   and assigns them to vertices based on the highest mapping percentage, assuming no ROI preference.
%
%   outFiles = convertROIForFS(inFile, weight) prioritizes certain ROIs based on the binary
%   weight vector `weight`, which allows the user to specify preferences for certain ROIs.
%
% **Inputs**
% ------
%   inFile   - (String) Path to the input ROI file in NIfTI format.
%              - Must be in MNI152 volumetric space.
%
%   weight   - (Vector) Binary vector indicating ROI preference.
%              - 1: ROI is preferred.
%              - 0: ROI is not preferred.
%              - Default: A vector of ones (all ROIs are treated equally).
%
% **Outputs**
% -------
%   outFiles - (Cell Array) Paths to the generated output files.
%              - outFiles{1}: Combined ROI map for the left hemisphere.
%              - outFiles{2}: Confidence map for the left hemisphere.
%              - outFiles{3}: Combined ROI map for the right hemisphere.
%              - outFiles{4}: Confidence map for the right hemisphere.
%
% **Features**
% ---------
%   1. **Separation of ROIs**:
%      - Splits the input volumetric map into individual ROIs based on intensity values.
%      - Each ROI is saved as a separate NIfTI file.
%
%   2. **Surface Mapping**:
%      - Converts the volumetric ROIs into FreeSurfer fsaverage surface space for both 
%        left and right hemispheres using the `convertMNI2FS` function.
%
%   3. **Vertex Assignment**:
%      - Calculates the mapping percentage for each vertex and assigns the ROI with
%        the highest percentage to that vertex.
%      - Produces a combined ROI map and a confidence map indicating the mapping percentage.
%
%   4. **ROI Weighting**:
%      - Allows user-defined preferences for specific ROIs via the `weight` input.
%      - Weighted ROIs are prioritized for vertex assignment, with fallback to unweighted ROIs
%        if no weighted ROI maps to a given vertex.
%
% **Examples**
% -------
%   **Example 1: Default ROI Mapping**
%   % Convert an ROI map without weighting preferences
%   inFile = '/path/to/ROI_map.nii.gz';
%   outFiles = convertROIForFS(inFile);
%
%   **Example 2: ROI Mapping with Preferences**
%   % Convert an ROI map with user-defined weighting
%   inFile = '/path/to/ROI_map.nii.gz';
%   weight = [0, 1, 0, 1, 1];  % Prefer ROIs 2, 4, and 5
%   outFiles = convertROIForFS(inFile, weight);
%
% **Notes**
% -----
%   - **Dependencies**:
%     * Requires external functions: `convertMNI2FS`, `load_nifti`, `save_nifti`.
%   - **ROI Count**:
%     * The number of unique intensities in the input file determines the number of ROIs.
%     * Ensure the weight vector matches the number of ROIs in the input file.
%   - **Output Files**:
%     * Each hemisphere generates two output files:
%       - Combined ROI map: Indicates the most likely ROI at each vertex.
%       - Confidence map: Indicates the mapping percentage for the assigned ROI.
%   - **Performance**:
%     * The function processes each ROI individually, which can be computationally intensive
%       for files with a large number of ROIs.
%   - **File Cleanup**:
%     * Intermediate volumetric ROI files are deleted by default unless `verbose` is set.
%
% **Author**
% -------
%   Alex Teghipco // alex.teghipco@uci.edu // Last Updated: 2018-10-19
%
% **See Also**
% --------
%   convertMNI2FS, load_nifti, save_nifti

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
