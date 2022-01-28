function [rgb_out, data_out, data_rgb_out, ticks, stmp] = colorcubes(n, w, inData, plotSwitch, limits, ax, cmapIn, mapData)
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
    if nargin < 5, limits = []; end    
    if nargin < 6, ax = []; end
    if nargin < 7, cmapIn = []; end 
    if nargin < 8, mapData = 'no'; end

    if isempty(limits) & strcmpi(mapData,'yes')
        limits(1,1) = min(inData(:,1));
        limits(2,1) = max(inData(:,1));
        limits(1,2) = min(inData(:,2));
        limits(2,2) = max(inData(:,2));
        limits(1,3) = min(inData(:,3));
        limits(2,3) = max(inData(:,3));
    end
    
    if strcmp(plotSwitch,'true')
        if isempty(ax)
            initgraphics(n)
        end
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
                if isempty(cmapIn)
                    r = k/m;
                    r_out(i+1,j+1,k+1) = r;
                    g = 1-j/m;
                    g_out(i+1,j+1,k+1) = g;
                    b = 1-i/m;
                    b_out(i+1,j+1,k+1) = b;
                else
                    r = cmapIn(i+1,j+1,k+1,1);
                    g = cmapIn(i+1,j+1,k+1,2);
                    b = cmapIn(i+1,j+1,k+1,3);
                end
                switch plotSwitch
                    case 'true'
                        if ~isempty(ax)
                            stmp{i+1,j+1,k+1} = surface(ax,i+x,j+y,k+z, ...
                                'facecolor',[r g b], ...
                                'facelighting','gouraud','EdgeAlpha',0);
                        else
                            stmp{i+1,j+1,k+1} = surface(i+x,j+y,k+z, ...
                                'facecolor',[r g b], ...
                                'facelighting','gouraud','EdgeAlpha',0);
                        end
                        drawnow
                end
            end %k
        end %j
    end %i
    
    if ~strcmpi(plotSwitch,'true')
        stmp = [];
    end
    
    % combine
    if isempty(cmapIn)
        rgb_out = cat(4, r_out, g_out, b_out);
    else
        rgb_out = cmapIn;
    end
    
    % now we will map the data you provided onto your colorcube
    % first create a linear scale for each of your 3 coordinates that is
    % the length of your cube. These are your 3d bins.
    if strcmpi(mapData,'yes')
        if size(limits,1) == 1
            limits = [limits; limits; limits];
        end
        
        xLinSpace = linspace(limits(1,1),limits(2,1),n);
        yLinSpace = linspace(limits(1,2),limits(2,2),n);
        zLinSpace = linspace(limits(1,3),limits(2,3),n);
        
        ticks(:,1) = xLinSpace;
        ticks(:,2) = yLinSpace;
        ticks(:,3) = zLinSpace;
        
        idx1 = xLinSpace >= inData(:,1);
        [~,idx1] = max(idx1,[],2);
        xbin = find(idx1 == 0);
        if ~isempty(xbin)
            for i = 1:length(xbin)
                if inData(xbin(i),1) > limits(2,1)
                    idx1(xbin(i)) = length(xLinSpace);
                elseif inData(xbin(i),1) < limits(1,1)
                    idx1(xbin(i)) = 1;
                end
            end
        end
        
        idx2 = yLinSpace >= inData(:,2);
        [~,idx2] = max(idx2,[],2);
        ybin = find(idx2 == 0);
        if ~isempty(ybin)
            for i = 1:length(ybin)
                if inData(ybin(i),2) > limits(2,2)
                    idx2(ybin(i)) = length(yLinSpace);
                elseif inData(ybin(i),2) < limits(1,2)
                    idx2(ybin(i)) = 1;
                end
            end
        end
        
        idx3 = zLinSpace >= inData(:,3);
        [~,idx3] = max(idx3,[],2);
        zbin = find(idx3 == 0);
        if ~isempty(zbin)
            for i = 1:length(zbin)
                if inData(zbin(i),3) > limits(2,3)
                    idx3(zbin(i)) = length(zLinSpace);
                elseif inData(zbin(i),3) < limits(1,3)
                    idx3(zbin(i)) = 1;
                end
            end
        end
        
        
        for i = 1:length(inData)
            data_rgb_out(i,:) = rgb_out(idx1(i),idx2(i),idx3(i),:);
        end
    else
        data_out = [];
        data_rgb_out = [];
        ticks = [];
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