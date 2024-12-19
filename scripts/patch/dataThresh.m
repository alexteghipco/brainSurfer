function [oData, v] = dataThresh(data, varargin)
% Threshold and manipulate brain data matrices.
%
%   [oData, v] = dataThresh(data, ...) thresholds and manipulates brain
%   data based on specified parameters. This function allows for the removal
%   of positive or negative values, application of p-value thresholds, 
%   normalization, scaling, and various operations across data maps.
%
% **Mandatory Arguments**
% -----------------------
%   data    - (n x p) Data matrix or vector where n corresponds to observations
%             (e.g., vertices) and p corresponds to different "brain maps" over
%             which thresholding and data manipulations are performed.
%
% **Outputs**
% ----------
%   oData   - (n x p) Thresholded and manipulated data matrix.
%
%   v       - (n x p) Data matrix converted using the 'vls' parameter 
%             (i.e., normalized, scaled, etc., but not thresholded).
%
% **Optional Parameters**
% -----------------------
%   'pos'        - (String) Determines whether to retain positive values.
%                  Options: 'on' | 'off'
%                  - 'on' (default): Retains positive values.
%                  - 'off': Removes positive values by setting them to zero.
%
%   'neg'        - (String) Determines whether to retain negative values.
%                  Options: 'on' | 'off'
%                  - 'on' (default): Retains negative values.
%                  - 'off': Removes negative values by setting them to zero.
%
%   'pMap'       - (n x p) Matrix of p-values corresponding to the data. Must
%                  have the same dimensions as 'data'.
%                  Default: An n x p matrix of ones (no p-value thresholding).
%
%   'pThresh'    - (Scalar) Threshold for the pMap. Data points with p-values
%                  greater than 'pThresh' are set to zero.
%                  Default: 1 (no data points are thresholded).
%
%   'vls'        - (String) Specifies how to convert/transform the data values.
%                  Options:
%                     'raw'                           - Use raw data values (default).
%                     'percentile'                    - Convert values to percentiles.
%                     'percentile (separate for pos/neg)' - Convert positive and negative 
%                                                           values to percentiles separately.
%                     'percentile (absolute)'         - Convert absolute values to percentiles.
%                     'normalized'                    - Normalize data (z-scores).
%                     'normalized (separate for pos/neg)' - Normalize positive and negative 
%                                                             values separately.
%                     'normalized (absolute)'         - Normalize absolute values.
%                     'scaled (0 to 1)'               - Scale data to the range [0, 1].
%                     'scaled (-1 to 1)'              - Scale data to the range [-1, 1].
%                     'scaled (separate for pos/neg)' - Scale positive and negative values separately.
%                     'scaled (absolute)'             - Scale absolute values.
%                     'scaled (absolute and separate for pos/neg)' - Scale absolute values separately 
%                                                                      for positive and negative data.
%
%   'sclLims'    - (1x2 Vector) Specifies the scaling limits when 'vls' includes scaling.
%                  Format: [minScaleValue maxScaleValue]
%                  Default: [0 1]
%
%   'thresh'     - (1x2 Vector) Interval [a b] within which data points are removed
%                  (set to zero). Data points outside this interval are retained.
%                  Default: [0 0] (no thresholding).
%
%   'operation'  - (String) Operation to perform across data maps, resulting in a single map.
%                  Options:
%                     'sum'                   - Sum all data maps.
%                     'mean'                  - Compute the mean of all data maps.
%                     'pc'                    - Perform Principal Component Analysis and retain
%                                               the first 'compKeep' principal components.
%                     'subtract'              - Perform column-wise subtraction (e.g., col1 - col2 - ...).
%                     'multiply'              - Compute the product of all data maps.
%                     'divide'                - Perform column-wise division.
%                     'standard deviation'    - Compute the standard deviation across data maps.
%                  Default: 'false' (no operation performed).
%
%   'compKeep'   - (Positive Integer) Number of principal components to retain when
%                  'operation' is set to 'pc'.
%                  Default: 1
%
% **Function Call Examples**
% --------------------------
%   % Basic thresholding with default parameters
%   [oData, v] = dataThresh(data);
%
%   % Threshold data by removing values between -2 and 2
%   [oData, v] = dataThresh(data, 'thresh', [-2 2]);
%
%   % Remove positive and negative values, scale data between -1 and 1, 
%   % apply threshold, use a custom pMap and pThresh, and perform PCA retaining 1 component
%   [oData, v] = dataThresh(data, ...
%       'pos', 'off', ...
%       'neg', 'off', ...
%       'vls', 'scaled (-1 to 1)', ...
%       'sclLims', [-1 1], ...
%       'thresh', [-2 2], ...
%       'pMap', pVals, ...
%       'pThresh', 0.05, ...
%       'operation', 'pc', ...
%       'compKeep', 1);
%
% **Notes**
% ----------
%   - The order of optional arguments determines the sequence of operations.
%     However, arguments do not need to be supplied in the listed order.
%   - The 'vls' parameter controls how the data is transformed before thresholding.
%   - When using 'operation' with 'pc', the function displays the percentage of variance 
%     explained by the retained principal components.
%   - Ensure that 'pMap', if provided, has the same dimensions as 'data'.
%   - The function sets data points to zero when they do not meet the specified criteria.
%
% **Author**
% -------
%   Alex Teghipco // alex.teghipco@uci.edu // Last Updated: 2024-12-01
%
% **See Also**
% ----------
%   normalize, prctile, pca, scaleData

    % Defaults
    options = struct(...
        'vls', 'raw', ...
        'thresh', [0 0], ...
        'pos', 'on', ...
        'neg', 'on', ...
        'pMap', ones(size(data)), ...
        'pThresh', 1, ...
        'operation', 'false', ...
        'sclLims', [0 1], ...
        'compKeep', 1 ...
    );
    optionNames = fieldnames(options);
    
    % Check number of arguments passed
    if length(varargin) > (length(optionNames) * 2)
        error('You have supplied too many arguments.');
    end
    nArgs = length(varargin);
    if round(nArgs / 2) ~= nArgs / 2
        error('You are missing an argument value for a parameter name.');
    end
    
    % Parse the arguments
    vleft = varargin;
    for pair = reshape(vleft, 2, []) % pair is {propName; propValue}
        inpName = pair{1};
        if any(strcmpi(inpName, optionNames))
            matchedName = optionNames{strcmpi(inpName, optionNames)};
            options.(matchedName) = pair{2};
        else
            error('''%s'' is not a recognized parameter name.', inpName);
        end
    end
    
    % Apply p-value threshold
    id = options.pMap > options.pThresh;
    data(id) = 0;
    
    % Convert data values based on 'vls' parameter
    switch lower(options.vls)
        case 'raw'
            oData = data;
        case 'percentile'
            oData = zeros(size(data));
            for i = 1:size(data, 2)
                p = prctile(data(:,i), 0:100);
                for j = 1:size(data, 1)
                    oData(j,i) = find(data(j,i) >= p, 1, 'last') - 1;
                end
            end
        case 'percentile (separate for pos/neg)'
            oData = zeros(size(data));
            for i = 1:size(data, 2)
                posId = data(:,i) > 0;
                negId = data(:,i) < 0;
                posV = data(posId, i);
                negV = abs(data(negId, i));
                
                if ~isempty(posV)
                    p = prctile(posV, 0:100);
                    for j = 1:length(posV)
                        oData(posId, i) = find(posV(j) >= p, 1, 'last') - 1;
                    end
                end
                
                if ~isempty(negV)
                    p = prctile(negV, 0:100);
                    for j = 1:length(negV)
                        oData(negId, i) = find(negV(j) >= p, 1, 'last') - 1;
                    end
                end
            end
        case 'percentile (absolute)'
            oData = zeros(size(data));
            for i = 1:size(data, 2)
                p = prctile(abs(data(:,i)), 0:100);
                for j = 1:size(data, 1)
                    oData(j,i) = find(abs(data(j,i)) >= p, 1, 'last') - 1;
                end
            end
        case {'normalized', 'normalize', 'z-scores'}
            oData = normalize(data);
        case 'normalized (separate for pos/neg)'
            oData = zeros(size(data));
            for i = 1:size(data, 2)
                posId = data(:,i) > 0;
                negId = data(:,i) < 0;
                if any(posId)
                    oData(posId, i) = normalize(data(posId, i));
                end
                if any(negId)
                    oData(negId, i) = normalize(abs(data(negId, i)));
                end
            end
        case 'normalized (absolute)'
            oData = normalize(abs(data));
        case 'scaled (0 to 1)'
            oData = zeros(size(data));
            for i = 1:size(data, 2)
                oData(:,i) = scaleData(data(:,i), 0, 1, 'true');
            end
        case 'scaled (-1 to 1)'
            oData = zeros(size(data));
            for i = 1:size(data, 2)
                oData(:,i) = scaleData(data(:,i), -1, 1, 'true');
            end
        case 'scaled (separate for pos/neg)'
            oData = zeros(size(data));
            for i = 1:size(data, 2)
                posId = data(:,i) > 0;
                negId = data(:,i) < 0;
                posV = data(posId, i); 
                negV = abs(data(negId, i));
                if ~isempty(posV)
                    oData(posId, i) = scaleData(posV, 0, 1, 'true');
                end
                if ~isempty(negV)
                    oData(negId, i) = scaleData(negV, 0, 1, 'true');
                end
            end
        case 'scaled (absolute)'
            oData = zeros(size(data));
            for i = 1:size(data, 2)
                oData(:,i) = scaleData(abs(data(:,i)), 0, 1, 'true');
            end
        case 'scaled (absolute and separate for pos/neg)'
            oData = zeros(size(data));
            for i = 1:size(data, 2)
                posId = data(:,i) > 0;
                negId = data(:,i) < 0;
                posV = data(posId, i);
                negV = abs(data(negId, i));
                if ~isempty(posV)
                    oData(posId, i) = scaleData(abs(posV), 0, 1, 'true');
                end
                if ~isempty(negV)
                    oData(negId, i) = scaleData(abs(negV), 0, 1, 'true');
                end
            end
        otherwise
            error('Unsupported value for ''vls'' parameter: %s', options.vls);
    end
    v = oData;
    
    % Remove positive or negative values if specified
    if strcmpi(options.pos, 'off')
        oData(oData > 0) = 0;
    end
    if strcmpi(options.neg, 'off')
        oData(oData < 0) = 0;
    end
    
    % Apply normal thresholding
    if ~isequal(options.thresh, [0 0])
        id = oData > min(options.thresh) & oData < max(options.thresh);
        oData(id) = 0;
    end
    
    % Perform specified operation across data maps
    switch lower(options.operation)
        case 'sum'
            oData = sum(oData, 2);
        case 'mean'
            oData = mean(oData, 2);
        case 'pc'
            [~, score, ~, ~, explained, ~] = pca(oData, 'NumComponents', options.compKeep);
            oData = score(:, 1:options.compKeep);
            disp(['PCA components (kept) explain: ' num2str(sum(explained(1:options.compKeep))) '% of variance in the data.']);
        case 'subtract'
            oData = oData(:,1);
            for i = 2:size(oData, 2)
                oData = oData - oData(:,i);
            end
        case 'multiply'
            oData = prod(oData, 2);
        case 'divide'
            oData = oData(:,1);
            for i = 2:size(oData, 2)
                oData = oData ./ oData(:,i);
            end
        case 'standard deviation'
            oData = std(oData, 0, 2);
        case 'false'
            % No operation performed
        otherwise
            error('Unsupported operation: %s', options.operation);
    end
end
