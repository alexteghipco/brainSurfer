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
%   Mapping data onto colorcube added by Alex Teghipco, including
%   plotSwitch, limits, ax, cmapIn, mapData.
%
% **Syntax**
% -------
%   colorcubes
%   [rgb_out] = colorcubes(n)
%   [rgb_out, data_out, data_rgb_out, ticks, stmp] = colorcubes(n, w, inData, plotSwitch, limits, ax, cmapIn, mapData)
%
% **Description**
% -----------
%   colorcubes() creates a 5x5x5 RGB color cube visualization.
%
%   colorcubes(n) generates an n-by-n-by-n color cube. For example:
%       * n = 2 creates a cube with 8 colors: R, G, B, C, M, Y, W, K.
%       * n = 5 creates a cube with 125 colors spaced equally in RGB space.
%
%   colorcubes(n, w) generates the RGB cube with cubes of width `w` (default: 0.85).
%
%   [rgb_out, data_out, data_rgb_out, ticks, stmp] = colorcubes(n, w, inData, plotSwitch, limits, ax, cmapIn, mapData)
%   provides additional functionalities for mapping 3D data onto the color cube,
%   customizing color mapping, plotting, and returning corresponding RGB values.
%
% **Inputs**
% ------
%   n          - (Integer) Size of the color cube (default: 5).
%                - The cube will contain `n^3` colors.
%
%   w          - (Float) Width of each cube in the visualization (default: 0.85).
%
%   inData     - (m x 3 Matrix) Input data to map onto the RGB cube (default: []).
%                - Columns represent data dimensions to be mapped onto RGB.
%
%   plotSwitch - (String) Whether to visualize the cube ('true' or 'false') (default: 'true').
%
%   limits     - (2 x 3 Matrix) Min and max values for scaling `inData` onto the RGB cube (default: []).
%                - Automatically computed if `mapData` is 'yes' and `limits` is empty.
%
%   ax         - (Handle) Axis handle for plotting the RGB cube (default: current axes).
%
%   cmapIn     - (n x n x n x 3 Matrix) Custom RGB colormap to use (default: []).
%                - If empty, a default RGB space is generated.
%
%   mapData    - (String) Flag to map `inData` onto the RGB cube ('yes' or 'no') (default: 'no').
%
% **Outputs**
% -------
%   rgb_out        - (n x n x n x 3 Matrix) RGB values of the cube.
%                    - Contains interpolated R, G, B channels at each cube location.
%
%   data_out       - (m x 3 Matrix) Cube coordinates corresponding to input `inData`.
%                    - Each row corresponds to the closest cube location for a data point.
%
%   data_rgb_out   - (m x 3 Matrix) RGB values corresponding to `inData`.
%                    - Each row provides the RGB color mapped to the input data point.
%
%   ticks          - (n x 3 Matrix) Linear scales used for mapping `inData` dimensions onto the cube.
%
%   stmp           - (Cell Array) Handles to plotted surfaces for each cube.
%                    - Empty if `plotSwitch` is set to 'false'.
%
% **Key Changes by Alex Teghipco**
% ----------------------------
%   1. Added support for mapping data (`inData`) onto the RGB cube:
%      - Input data is scaled to the cube using linear spacing (`limits`).
%      - Outputs `data_out` (cube coordinates) and `data_rgb_out` (RGB values).
%
%   2. Introduced `plotSwitch` for toggling cube visualization.
%      - 'true' to visualize the RGB cube.
%      - 'false' to disable plotting, saving computation time.
%
%   3. Added `limits` to define scaling ranges for input data.
%      - Automatically calculated from `inData` if `mapData` is 'yes' and `limits` is empty.
%
%   4. Added `cmapIn` for providing custom RGB mappings to override the default cube generation.
%
%   5. Implemented `mapData` flag to control data mapping functionality.
%      - 'yes' enables mapping of `inData` onto the RGB cube.
%      - 'no' disables data mapping and associated computations.
%
% **Examples**
% -------
%   **Example 1: Basic Color Cube**
%   % Generate a 5x5x5 RGB cube with default settings
%   colorcubes(5);
%
%   **Example 2: Mapping Data Onto the Cube**
%   % Generate a 10x10x10 RGB cube and map 3D data onto it
%   n = 10;  % Cube size
%   inData = rand(100, 3) * 10;  % Random data (100 points in 3D space)
%
%   % Map data onto cube and return RGB values
%   [rgb_out, data_out, data_rgb_out] = colorcubes(n, 0.85, inData, 'false', [], [], [], 'yes');
%
%   % Display mapped colors
%   scatter3(inData(:, 1), inData(:, 2), inData(:, 3), 36, data_rgb_out, 'filled');
%
% **Notes**
% -----
%   - **Visualization**: Set `plotSwitch` to 'false' for faster computations when visualization is not required.
%   - **Data Mapping**: Ensure `inData` has three columns to match the RGB cube dimensions.
%   - **Custom Colormaps**: Use `cmapIn` for advanced color mapping requirements.
%   - **Performance**: Large values of `n` or input data size may increase computational time.
%
% **See Also**
% --------
%   scatter3, linspace, surface

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