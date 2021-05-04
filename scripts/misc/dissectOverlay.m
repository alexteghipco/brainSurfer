function [mEffect,oLap,roiSz] = dissectOverlay(overlayFile,annotFile,varargin)
%[mEffect,oLap,roiSz] = dissectOverlay(overlayFile,annotFile,plotSwitch,saveAnatAsOverlay)
%
% dissectOverlay will analyze overlap between an atlas provided in
% 'annotFile' and some input file provided in 'overlayFile'. It will ouput
% 'mEffect' which gives the mean non-zero value within each ROI in the atlas
% file, 'oLap', which gives the percentage of voxels in each ROI that is
% covered in overlayFile, and 'roiSz' which contains the size of each ROI
% in 'annotFile'. 
%
% 'annotFile' can be the path to an annotation file, in which case it is
% read in using freesurfer's read_annotation.m. However, you can instead
% provide the path to a nifti file here that is comprised only of ROIs
% (i.e., whole integers). In that case, you must supply additional argument
% 'mannot' followed by an n x 1 cell array with labels corresponding to
% each ROI (i.e., the label in 'mannot' array{2} corresponds to ROI 2 in
% supplied 'annotFile'). 
%
% If 'saveAnatAsOverlay','true' is supplied the annotated file provided
% will also be saved as a NIFTI (for instance to display in brainSurfer).
% Files will be appended '_AS_OVERLAY.nii.gz'.
%
% Examples: 
% annotFile = '/Applications/freesurfer/subjects/fsaverage/label/lh.aparc.a2009s.annot';
% overlayFile = '/Volumes/LaCie/phono/net/association-test_z_FDR_0.05_RF_ANTs_MNI152_to_fsaverage_LH.nii.gz';
% overlayFile = '/Users/ateghipc/MATLAB-Drive/brainSurfer-master/brainMapsforTesting/MNI_TFCE_LPT_FC_pFWER-05.nii_RF_ANTs_MNI152_orig_to_fsaverage_LH.nii.gz';
% load stuff in...


% DEFAULTS
removeNaNs = 'true'; % if true effect size / % overlap of zero will not be output as NaN but zero

% read in arguments
options = struct('saveAnatAsOverlay','false','plotSwitch','false','mannot',[]);

% Read in the acceptable argument names
optionNames = fieldnames(options);

% Check the number of arguments passed
nArgs = length(varargin);
if round(nArgs/2)~=nArgs/2
    error('You are missing an argument name somewhere in your list of inputs')
end

% Assign supplied values to each argument in input
for pair = reshape(varargin,2,[]) %pair is {propName;propValue}
    inpName = pair{1}; % make case insensitive by using lower() here but this can be buggy
    if any(strcmp(inpName,optionNames))
        options.(inpName) = pair{2};
    else
        error('%s is not a recognized parameter name',inpName)
    end
end

% read in data
overlayNii = load_nifti(overlayFile);

if isempty(options.mannot)
    [v, L, ct] = read_annotation(annotFile);
else
    anNifti = load_nifti(annotFile);
    L = anNifti.vol;
end

% get unique roi names from annotations
roiI = unique(L);
id = find(roiI == 0);
roiI(id) = [];

% relabel them
roiI(:,2) = 1:length(roiI);
L2 = zeros([length(L),1]);
for i = 1:size(roiI,1)
    vTmp = find(L == roiI(i,1));
    L2(vTmp) = roiI(i,2);
end

% get roi sizes
for i = 1:size(roiI,1)
   tmp = find(L == roiI(i,1));
   roiSz(i,1) = length(tmp);
end

% save out as an 'overlay' nifti
switch options.saveAnatAsOverlay
    case 'true'
        %[ovPath,ovName,ovExt] = fileparts(overlayFile);
        [anPath,anName,anExt] = fileparts(annotFile);
        overlayNii2 = overlayNii;
        overlayNii2.vol = zeros(size(overlayNii2.vol));
        overlayNii2.vol = L2; 
        save_nifti(overlayNii2,[anPath '/' anName '_AS_OVERLAY.nii.gz']);
end

% now get % overlap for every roi in annat and magnitude of effect in every
% roi
for i = 1:size(roiI,1)
    vTmp = find(L == roiI(i,1));
    oTmp = overlayNii.vol(vTmp);
    id = find(oTmp == 0);
    oTmp(id) = [];
    
    mEffect(i,1) = mean(oTmp);
    oLap(i,1) = length(oTmp)/length(vTmp);
end

switch removeNaNs
    case 'true'
        id = find(isnan(mEffect));
        mEffect(id) = 0;
        
        id = find(isnan(oLap));
        oLap(id) = 0;
end

% reorg labels
if isempty(options.mannot)
    for i = 1:size(roiI,1)
        tmp = find(ct.table(:,5) == roiI(i));
        labels{i,1} = ct.struct_names{tmp};
    end
end

% now make some kind of nice plot...
switch options.plotSwitch
    case 'true'
    
    
    
end


