function [colorMapInterp] = customColorMapInterp(colorMap, colorBins)
% customColorMapInterp Generates a custom interpolated colormap.
%
% This function interpolates between the colors in an input colormap to 
% create a customized colormap with a specified number of bins. The interpolation 
% ensures smooth transitions between colors.
%
% **Syntax**
% -------
%   colorMapInterp = customColorMapInterp(colorMap, colorBins)
%
% **Description**
% ---------
%   colorMapInterp = customColorMapInterp(colorMap, colorBins) creates a new 
%   colormap by interpolating between the colors specified in `colorMap`.
%   The resulting colormap will have `colorBins` rows, evenly spaced between
%   the input colors.
%
% **Inputs**
% ------
%   colorMap    - (m x 3 Matrix) Input colormap.
%                 - Each row represents a color in RGB format, where:
%                   * First column: Red channel (0 to 1).
%                   * Second column: Green channel (0 to 1).
%                   * Third column: Blue channel (0 to 1).
%                 - The number of rows `m` represents the number of input colors.
%
%   colorBins   - (Integer) Number of bins in the output colormap.
%                 - Determines the number of colors in the interpolated colormap.
%
% **Output**
% ------
%   colorMapInterp - (colorBins x 3 Matrix) Interpolated colormap.
%                    - Contains RGB values for the specified number of bins.
%
% **Examples**
% -------
%   **Example 1: Interpolation Between Three Colors**
%   % Define an input colormap with three colors
%   colorMap = [1, 0, 0; ...  % Red
%               0, 1, 0; ...  % Green
%               0, 0, 1];     % Blue
%
%   % Interpolate with 100 bins
%   colorMapInterp = customColorMapInterp(colorMap, 100);
%
%   % Visualize the interpolated colormap
%   colormap(colorMapInterp);
%   colorbar;
%
% **Notes**
% -----
%   - **Input Dimensions**: Ensure `colorMap` is an (m x 3) matrix representing
%     RGB colors, where `m` is the number of input colors.
%   - **Output Resolution**: The `colorBins` parameter controls the resolution
%     of the resulting colormap. Larger values will produce smoother transitions.
%   - **Channel Interpolation**: The function uses linear interpolation for each
%     RGB channel independently, ensuring smooth color transitions.
%   - **Edge Cases**: The function automatically adjusts the number of interpolated
%     steps to match `colorBins`, ensuring the output always has the specified number of rows.
%
% **Author**
% -------
%   Alex Teghipco // alex.teghipco@uci.edu // Last Updated: 2018-11-28
%
% **See Also**
% --------
%   colormap, linspace, colorbar

betweenNum = round(colorBins/(size(colorMap,1) - 1));
for beti = 1:(size(colorMap,1)-1)
    if beti == (size(colorMap,1)-1)
        betweenNumRound(beti) = colorBins - sum(betweenNum(1:beti-1));
    else
        betweenNumRound(beti) = betweenNum;
    end
end

for beti = 1:(size(betweenNumRound,2))
    R{beti} = linspace(colorMap(beti,1),colorMap(beti+1,1),betweenNumRound(beti));  %// Red from 1 to 0
    B{beti} = linspace(colorMap(beti,2),colorMap(beti+1,2),betweenNumRound(beti));  %// Blue from 0 to 1
    G{beti} = linspace(colorMap(beti,3),colorMap(beti+1,3),betweenNumRound(beti));   %// Green all zero
end

R = horzcat(R{:});
B = horzcat(B{:});
G = horzcat(G{:});
colorMapInterp = vertcat(R,B,G)';
