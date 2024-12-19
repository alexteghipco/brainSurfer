function [colorMapInterp] = customColorMapInterpBars(colorMap, colorBins, interpDir)
% Creates a custom interpolated colormap with bar-style blending.
%
% This function interpolates between two given colormaps to create a new colormap
% matrix. The interpolation can occur either uniformly ('same') or with different
% blending patterns ('different') across the colormap bins.
%
% **Syntax**
% -------
%   colorMapInterp = customColorMapInterpBars(colorMap, colorBins, interpDir)
%
% **Description**
% ---------
%   colorMapInterp = customColorMapInterpBars(colorMap, colorBins, interpDir)
%   generates an interpolated colormap based on the input `colorMap`. The
%   interpolation method depends on the `interpDir` argument:
%   - 'same': Linear interpolation between the two colormaps.
%   - 'different': Averaging-based blending with varying intensities.
%
% **Inputs**
% ------
%   colorMap    - (n x 3 x 2 Matrix) Input colormap.
%                 - `colorMap(:, :, 1)` represents the first colormap (RGB).
%                 - `colorMap(:, :, 2)` represents the second colormap (RGB).
%                 - The number of rows `n` corresponds to the number of colors in the colormaps.
%
%   colorBins   - (Integer) Number of bins (rows) in the output colormap.
%                 - Determines the resolution of the interpolated colormap.
%
%   interpDir   - (String) Interpolation direction.
%                 - Options:
%                   * 'same'      - Linear interpolation across all bins.
%                   * 'different' - Weighted averaging of colormaps.
%
% **Output**
% ------
%   colorMapInterp - (colorBins x colorBins x 3 Matrix) Interpolated colormap.
%                    - Contains RGB values for the specified number of bins.
%
% **Examples**
% -------
%   **Example 1: Uniform Interpolation ('same')**
%   % Define input colormaps
%   colorMap = cat(3, ...
%       [1, 0, 0; 0, 1, 0; 0, 0, 1], ...  % First colormap (red, green, blue)
%       [0, 0, 1; 1, 0, 0; 0, 1, 0]);     % Second colormap (blue, red, green)
%
%   % Interpolate with 10 bins
%   colorMapInterp = customColorMapInterpBars(colorMap, 10, 'same');
%
%   **Example 2: Weighted Averaging ('different')**
%   % Define input colormaps
%   colorMap = cat(3, ...
%       [1, 0, 0; 0, 1, 0; 0, 0, 1], ...  % First colormap
%       [0, 0, 1; 1, 0, 0; 0, 1, 0]);     % Second colormap
%
%   % Interpolate with 10 bins
%   colorMapInterp = customColorMapInterpBars(colorMap, 10, 'different');
%
% **Notes**
% -----
%   - **Input Dimensions**: Ensure `colorMap` is of size (n x 3 x 2), where
%     `n` matches the number of colors in each colormap, and there are two
%     colormaps (one for each interpolation direction).
%   - **Output Size**: The output colormap will have `colorBins` rows and
%     correspond to a square grid of bins.
%   - **Interpolation Methods**: Use 'same' for smooth blending and 'different'
%     for patterns with varying intensities.
%   - **Visualization**: Use the output colormap with plotting functions such as
%     `imagesc` or `surf` to visualize the results.
%
% **Author**
% -------
%   Alex Teghipco // alex.teghipco@uci.edu // Last Updated: 2024-12-01
%
% **See Also**
% --------
%   colormap, imagesc, surf

verbose = false;
% Debug input parameters
if verbose
    fprintf('CustomColorMapInterpBars input dimensions: [%d, %d, %d]\n', size(colorMap,1), size(colorMap,2), size(colorMap,3));
    fprintf('ColorBins: %d, interpDir: %s\n', colorBins, interpDir);
end

% Initialize output colormap
colorMapInterp = ones(colorBins,colorBins,3);

switch interpDir
    case 'same'
        % For each RGB channel
        for c = 1:3
            % Get the color values for this channel from both colormaps
            cmap1 = squeeze(colorMap(:,c,1));  % First colormap
            cmap2 = squeeze(colorMap(:,c,2));  % Second colormap

            % Create the 2D interpolation for this channel
            for i = 1:colorBins
                % Interpolate between the corresponding points in both colormaps
                colorMapInterp(i,:,c) = linspace(cmap1(i), cmap2(i), colorBins);
            end
        end

    case 'different'
        for beti = 1:size(colorMapInterp,1)
            for j = 1:3
                tmp1 = colorMap(:,j,1);
                tmp2 = repmat(colorMap(beti,j,2),size(tmp1));
                colorMapInterp(:,beti,j) = (tmp1+tmp2)./2;
            end
        end
end

% Debug output dimensions
if verbose
    fprintf('Output colorMapInterp dimensions: [%d, %d, %d]\n', size(colorMapInterp,1), size(colorMapInterp,2), size(colorMapInterp,3));
end