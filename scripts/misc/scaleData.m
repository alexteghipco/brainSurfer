function [scaledData] = scaleData(array, x, y, incZero)
% Scale Data to a Specified Range with Optional Zero Inclusion
%
%   [scaledData] = scaleData(array, x, y, incZero)
%
%   This function scales the input data in `array` to a specified range [x, y].
%   It provides the option to include or exclude zero values from the scaling
%   process. If `incZero` is set to 'false', zero values in the array are not
%   considered when calculating the scaling parameters and are preserved as zeros
%   in the output.
%
% **Mandatory Arguments**
% -----------------------
%   array     - (Numeric Array) The input data array to be scaled. This can be a
%               vector or a multi-dimensional matrix.
%               - Example:
%                 array = [0, 2, 4, 6, 8, 0, 10];
%
%   x         - (Numeric Scalar) The lower bound of the desired scaling range.
%               - Example:
%                 x = 1;
%
%   y         - (Numeric Scalar) The upper bound of the desired scaling range.
%               - Example:
%                 y = 5;
%
%   incZero   - (String) A flag indicating whether to include zeros in the scaling
%               calculations.
%               - `'true'`: Include zeros in the scaling.
%               - `'false'`: Exclude zeros from the scaling.
%               - Example:
%                 incZero = 'false';
%
% **Output**
% ----------
%   scaledData - (Numeric Array) The scaled data array with values adjusted to the
%                specified range [x, y]. The output array maintains the same
%                dimensions as the input `array`. If `incZero` is `'false'`,
%                zero values in the input are preserved as zeros in the output.
%                - Example:
%                  scaledData = [0, 1, 2, 3, 4, 0, 5];
%
% **Function Call Examples**
% --------------------------
%   % Example 1: Scaling with zeros excluded
%   array = [0, 2, 4, 6, 8, 0, 10];
%   x = 1;
%   y = 5;
%   incZero = 'false';
%   scaledData = scaleData(array, x, y, incZero);
%   % Expected Output:
%   % scaledData = [0, 1, 2, 3, 4, 0, 5];
%
%   % Example 2: Scaling with zeros included
%   array = [0, 2, 4, 6, 8, 0, 10];
%   x = -1;
%   y = 1;
%   incZero = 'true';
%   scaledData = scaleData(array, x, y, incZero);
%   % Expected Output:
%   % scaledData = [-1, -0.6, -0.2, 0.2, 0.6, -1, 1];
%
% **Detailed Description**
% ------------------------
%   The `scaleData` function performs linear scaling of the input `array` to fit
%   within the specified range [x, y]. The function offers flexibility in handling
%   zero values through the `incZero` parameter:
%
%   1. **Input Handling:**
%      - Determines the dimensions of `array`. If `array` is a multi-dimensional
%        matrix, it is reshaped into a column vector for processing.
%      - A flag `reTouch` is set to `'true'` if the original `array` was multi-dimensional,
%        indicating that the output should be reshaped back to the original dimensions.
%
%   2. **Scaling Process:**
%      - **Excluding Zeros (`incZero = 'false'`):**
%        - Identifies the indices of zero values in `array`.
%        - Creates a temporary array by removing zero values from `array`.
%        - Determines the minimum value and the range of the non-zero data.
%        - Normalizes the non-zero data based on the calculated minimum and range.
%        - Scales the normalized data to the [x, y] range.
%        - Reconstructs `scaledData` by reinserting zeros at their original positions.
%
%      - **Including Zeros (`incZero = 'true'`):**
%        - Determines the minimum value and the range of the entire `array`, including zeros.
%        - Normalizes the entire `array` based on the calculated minimum and range.
%        - Scales the normalized data to the [x, y] range.
%
%   3. **Output Formatting:**
%      - If the original `array` was multi-dimensional, reshapes `scaledData` back to its original dimensions.
%
% **Notes**
% ----------
%   - The function assumes that `incZero` is provided as a string ('true' or 'false').
%     Ensure that the input adheres to this format to avoid unexpected behavior.
%
%   - When `incZero` is `'false'`, zero values in the input `array` are preserved as zeros
%     in the output `scaledData`. All non-zero values are scaled based on the non-zero data range.
%
%   - The function supports both vector and multi-dimensional arrays. Multi-dimensional
%     inputs are processed by reshaping them into vectors during scaling and then
%     reshaping the output back to the original dimensions.
%
%   - Ensure that the input `array` contains at least one non-zero element when
%     `incZero` is `'false'` to avoid errors during scaling.
%
% **Error Handling**
% -------------------
%   - If the scaling range results in zero (i.e., all non-zero elements have the same value),
%     the function will throw an error indicating that scaling cannot be performed.
%
%   - If `incZero` is neither `'true'` nor `'false'`, the function will throw an error.
%
% **Author**
% -------
%   Alex Teghipco // alex.teghipco@uci.edu // Last Updated: 2024-12-01

% Validate number of input arguments
if nargin ~= 4
    error('scaleData requires exactly four input arguments: array, x, y, incZero.');
end

% Get the size of the input array
[l, p] = size(array);

% Determine if the input array is multi-dimensional
if l > 1 && p > 1
    array = array(:);      % Reshape to a column vector
    reTouch = 'true';      % Flag to reshape output later
else
    reTouch = 'false';
end

% Switch based on whether to include zeros in scaling
switch incZero
    case 'false'
        aId = 1:length(array);          % All indices
        zId = find(array == 0);        % Indices of zeros
        tmp = array;
        tmp(zId) = [];                   % Remove zeros from temporary array

        % Calculate minimum and range of non-zero data
        m = min(tmp);
        range = max(tmp) - m;
        if range == 0
            error('All non-zero elements have the same value. Cannot perform scaling.');
        end
        tmp = (tmp - m) / range;        % Normalize to [0, 1]

        % Scale to [x, y]
        range2 = y - x;
        scaledData1 = (tmp * range2) + x;

        % Initialize scaledData with zeros
        scaledData = zeros(size(aId));

        % Assign scaled values to non-zero positions
        [~, ia] = setdiff(aId, zId);
        scaledData(ia) = scaledData1;

    case 'true'
        % Normalize to [0, 1] including zeros
        m = min(array);
        range = max(array) - m;
        if range == 0
            error('All elements have the same value. Cannot perform scaling.');
        end
        array = (array - m) / range;

        % Scale to [x, y]
        range2 = y - x;
        scaledData = (array * range2) + x;

    otherwise
        error('incZero must be either ''true'' or ''false''.');
end

% Reshape back to original dimensions if necessary
if strcmp(reTouch, 'true')
    scaledData = reshape(scaledData, [l, p]);
end
