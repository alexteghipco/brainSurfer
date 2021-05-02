function [rgb_out, data_out, data_rgb_out] = colorcubes(n, w, inData, plotSwitch, limits)
% Creates a cube of cubes in the RGB color space.
%   COLORCUBES, with no arguments, shows 5^3 = 125 cubes with
%      colors equally spaced in the RGB color space.
%   COLORCUBES(n) shows n-by-n-by-n colors.
%   COLORCUBES(2) shows 8 colors: R, G, B, C, M, Y, W, K (black).
%   COLORCUBES(n,w) uses cubes of width w.  Default is w = 0.85.
%   Rotate the cube with the mouse or arrow keys.
%
%   [rgb_out] contains 3d matrix with each coordinate corresponding to a cube
%   within colorcube. 4th dimension contains the r,g,b data. 
%
%   COLORCUBES(n,w,inData) maps m x 3 inData matrix onto rgb_out. Each col
%   corresponds to a dimension of data being mapped onto colorcube.
%   [data_out] is m x 3 output containing the closest coordinate in
%   colorcube for each of the three dimensions. Data will be mapped onto
%   each dimension of cube by linearly spacing values in each inData column
%   between its min and max using as many bins as there are cubes within a
%   face (i.e., your n parameter). [data_rgb_out] contains the direct r g b
%   data for each datapoint m.
%
%   Copyright 2016 The MathWorks, Inc.
%   Mapping data onto colorcube added by Alex Teghipco

    if nargin < 1, n = 5; end
    if nargin < 2, w = 0.85; end
    if nargin < 3, inData = []; end
    if nargin < 4, plotSwitch = 'true'; end
    if nargin < 5
        limits(1,1) = min(inData(:,1));
        limits(2,1) = max(inData(:,1));
        limits(1,2) = min(inData(:,2));
        limits(2,2) = max(inData(:,2));
        limits(1,3) = min(inData(:,3));
        limits(2,3) = max(inData(:,3));
    end    
    if strcmp(plotSwitch,'true')
        initgraphics(n)
    end
    [x,y,z] = cube(w);
    m = n-1;
    
    % this is for colorcube
    iLen = m:-1:0;
    jLen = m:-1:0;
    kLen = m:-1:0;

    r_out = zeros([length(iLen),length(jLen),length(kLen)]);
    
    for i = iLen
      for j = jLen
         for k = kLen
            r = k/m;
            r_out(i+1,j+1,k+1) = r;
            g = 1-j/m;
            g_out(i+1,j+1,k+1) = g;
            b = 1-i/m;
            b_out(i+1,j+1,k+1) = b;
            switch plotSwitch
                case 'true'
                    surface(i+x,j+y,k+z, ...
                        'facecolor',[r g b], ...
                        'facelighting','gouraud');
                    drawnow
            end
         end %k
      end %j
    end %i
    
    % combine
    rgb_out = cat(4, r_out, g_out, b_out);
    
    % now we will map the data you provided onto your colorcube
    % first create a linear scale for each of your 3 coordinates that is
    % the length of your cube. These are your 3d bins.
    if size(limits,1) == 1
       limits = [limits; limits; limits];
    end
    
    xLinSpace = linspace(limits(1,1),limits(2,1),n);
    yLinSpace = linspace(limits(1,2),limits(2,2),n);
    zLinSpace = linspace(limits(1,3),limits(2,3),n);

    % for each data point in overlay, find closest 3d bin 
    for i = 1:length(inData)
        disp(['Mapping data onto colorcube...' num2str((i/length(inData))* 100) '%'])
        % get closest bin in the x dim
        idx1 = find(xLinSpace <= inData(i,1));
        if isempty(idx1)
            xbin = 1;
        else
            % Bins need to be adjusted if closest value is negative
            xbin = idx1(end);
        end
        if xLinSpace(xbin) < 0
            xbin = xbin+1;
        end
        
        % Repeat for y dim
        idx2 = find(yLinSpace <= inData(i,2));
        if isempty(idx2)
            ybin = 1;
        else
            ybin = idx2(end);
        end
        if yLinSpace(ybin) < 0
            ybin = ybin+1;
        end
       
        % Repeat for z dim
        idx3 = find(zLinSpace <= inData(i,3));
        if isempty(idx3)
            zbin = 1;
        else
            zbin = idx3(end);
        end
        if zLinSpace(zbin) < 0
            zbin = zbin+1;
        end
       
        % get coordinate on colorcube
        data_out(i,1) = xbin;
        data_out(i,2) = ybin;
        data_out(i,3) = zbin;
        
        % get color directly
        data_rgb_out(i,:) = rgb_out(xbin,ybin,zbin,:);
    end
        
    
    % ------------------------
    
    % INITGRAPHCS  Inialize the colorcubes axis.
    %   INITGRAPHICS(n) for n-by-n-by-n display.

    function initgraphics(n)
       clf reset
       shg
       set(gcf,'color','white')
       axis([0 n 0 n 0 n]);
       axis off
       axis vis3d
       rotate3d on
    end %initgraphics

    function [x,y,z] = cube(w)
    % CUBE  Coordinates of the faces of a cube.
    %   [x,y,z] = cube(w); surface(x,y,z)
    %   plots a cube of with w.

       u = [0 0; 0 0; w w; w w];
       v = [0 w; 0 w; 0 w; 0 w];
       z = [w w; 0 0; 0 0; w w];
       s = [nan nan]; 
       x = [u; s; v];
       y = [v; s; u];
       z = [z; s; w-z];
    end %cube

end % colorcubes