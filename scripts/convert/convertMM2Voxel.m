function [outCoords] = convertMM2Voxel(inFile,inCoords)
inFileNifti = load_untouch_nii(inFile);
tsfMat = vertcat(inFileNifti.hdr.hist.srow_x,inFileNifti.hdr.hist.srow_y,inFileNifti.hdr.hist.srow_z,[0 0 0 1]);
tsfMatInvt = inv(tsfMat);
tsfMatInvt(4,:) = [];

% find which dimensions are of size 3
 dimdim = find(size(inCoords) == 3);

% 3x3 matrices are ambiguous
% default to coordinates within a row
if dimdim == [1 2]
  disp('input is an ambiguous 3 by 3 matrix')
  disp('assuming coordinates are row vectors')
  dimdim = 2;
end

% transpose if necessary
if dimdim == 2
  inCoords = inCoords';
end

% apply the transformation matrix
inCoords = [inCoords; ones(1, size(inCoords, 2))];
inCoords = tsfMatInvt * inCoords;

% format the outpoints, transpose if necessary
outCoords = fix(inCoords(1:3, :));
if dimdim == 2
  outCoords = outCoords';
end
