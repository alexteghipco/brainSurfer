function [outCoords] = convertVoxel2MM(inFile,inCoords)
%% [outCoords] = convertVoxel2MM(inFile,inCoords)
% Convert voxel coordinates in native space into MNI coordinates by using
% the srow matrix associated with the file from which you took your
% coordinates. The path to this file can be specified in inFile, or you can
% provide the script with a structure as load_untouch_nii 
warning on

if isempty(inFile) == 0
    inFileNifti = load_untouch_nii(inFile);
    tsfMat = vertcat(inFileNifti.hdr.hist.srow_x,inFileNifti.hdr.hist.srow_y,inFileNifti.hdr.hist.srow_z,[0 0 0 1]);
else
    % convert to MNI coordinates
    warning('Assuming your coordinates are in 2mm MNI space');
    scriptPath = which('convertVoxel2MM');
    scriptPath = scriptPath(1:end-18);
    template = load([scriptPath '/2mmTemplate.mat'],'template');
    template = template.template;
    tsfMat = vertcat(template.hdr.hist.srow_x,template.hdr.hist.srow_y,template.hdr.hist.srow_z,[0 0 0 1]);
end
%tsfMatInvt = inv(tsfMat);
%tsfMatInvt(4,:) = [];

% find which dimensions are of size 3
 dimdim = find(size(inCoords) == 3);

% 3x3 matrices are ambiguous
% default to coordinates within a row
if dimdim == [1 2]
  warning('input is an ambiguous 3 by 3 matrix...assuming coordinates are row vectors');
  dimdim = 2;
end

% transpose if necessary
if dimdim == 2
  inCoords = inCoords';
end

% apply the transformation matrix
inCoords = [inCoords; ones(1, size(inCoords, 2))];
inCoords = tsfMat * inCoords;

% format the outpoints, transpose if necessary
outCoords = fix(inCoords(1:3, :));
if dimdim == 2
  outCoords = outCoords';
end
