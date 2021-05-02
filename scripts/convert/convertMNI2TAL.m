function [outpoints] = convertMNI2TAL(inpoints)
% --------------------------------------------------------
% This script is taken from ginger ale. It converts MNI coordinates 
% in mm space to talairach coordinates. 
% http://www.brainmap.org/icbm2tal/
 
% --------------------------------------------------------
% Alex Teghipco -- ateghipc@u.rochester.edu -- 2015
% --------------------------------------------------------


% find which dimensions are of size 3

dimdim = find(size(inpoints) == 3);
if isempty(dimdim)
  error('input must be a N by 3 or 3 by N matrix')
end

% 3x3 matrices are ambiguous
% default to coordinates within a row
if dimdim == [1 2]
  disp('input is an ambiguous 3 by 3 matrix')
  disp('assuming coordinates are row vectors')
  dimdim = 2;
end

% transpose if necessary
if dimdim == 2
  inpoints = inpoints';
end

% Transformation matrices, different for each software package
icbm_fsl = [0.9464 0.0034 -0.0026 -1.0680
		   -0.0083 0.9479 -0.0580 -1.0239
            0.0053 0.0617  0.9010  3.1883
            0.0000 0.0000  0.0000  1.0000];

% apply the transformation matrix
inpoints = [inpoints; ones(1, size(inpoints, 2))];
inpoints = icbm_fsl * inpoints;

% format the outpoints, transpose if necessary
outpoints = inpoints(1:3, :);
if dimdim == 2
  outpoints = outpoints';
end