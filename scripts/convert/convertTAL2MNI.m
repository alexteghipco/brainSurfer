function [outpoints] = convertTAL2MNI(points)
% --------------------------------------------------------
% This script is taken from ginger ale. It converts talairach coordinates  
% to MNI coordinates in mm space.
% http://www.brainmap.org/icbm2tal/
 
% --------------------------------------------------------
% Alex Teghipco -- ateghipc@u.rochester.edu -- 2015
% --------------------------------------------------------


dimdim = find(size(points) == 3);
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
  points = points';
end

% Transformation matrices, different for each software package
        
icbm_fsl = [0.9464 0.0034 -0.0026 -1.0680
		   -0.0083 0.9479 -0.0580 -1.0239
            0.0053 0.0617  0.9010  3.1883
            0.0000 0.0000  0.0000  1.0000];

% apply the transformation matrix
icbm_fsl = inv(icbm_fsl);
points = [points; ones(1, size(points, 2))];
points = icbm_fsl * points;

% format the outpoints, transpose if necessary
outpoints = points(1:3, :);
if dimdim == 2
  outpoints = outpoints';
end