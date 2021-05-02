function [oData,v] = dataThresh(data, varargin)
% This function is for thresholding some brain data (that we assume that
% you want to patch but that should be irrelevant).
%
% Mandatory arguments------------------------------------------------------ 
%
% data: data matrix or vector n x p where p corresponds to the number of
% different "brain maps" over which to iterate specified threshold
% commands.
%
% Output------------------------------------------------------------------- 
%
% oData: thresholded data (n x p).
%
% v: data converted using the values (vls) argument (i.e., not thresholded).
%
% Optional (threshold) arguments-------------------------------------------
%
% The ordering of these optional arguments here represents the order in
% which the various thresholds/data manipulations will be applied. You
% don't have to supply these arguments in this order. All defaults refer to
% what will occur if the optional argument isn't passed in.
%
% 'pos': if set to 'off' positive values will be removed from data (default
%       is 'on'; this is the first operation that will be performed on the
%       data)
%
% 'neg': if set to 'off' negative values will be removed from data (default
%       is 'on'; this is the first operation that will be performed on the
%       data)
%
% 'pMap': if a separate map of p-values is provided (must have same n x p
%       dimensionality as data), it will be used to perform a threshold
%       (default is an n x p matrix of ones)
%
% 'pThresh': a threshold for the p-map (i.e., 0.05 means p > 0.05; default
%       is 1)
%
% 'vls' has various effects all of which normalize/scale/standardize the
% overlay data (default is 'raw'):
%       'raw': will patch raw values (in data) 'prct': will convert values
%           to percentiles 'prctSep': will convert values to percentiles
%           (separately for positive and negative values)
%       'norm': will normalize values (z-scores) 
%       'normSep': will normalize (z-scores) positive and negative values
%           separately
%       'scl': will scale values. (Default is between 0 and 1 but can be
%           changed using the 'sclLims' optional argument, which will
%           expect two values [minScaleValue maxScaleValue]) 
%       'sclSep': will scale values separately for positive
%           and negative values (see scl for controlling scale limits)
%       'sclAbs': will scale absolute values (see scl for controlling scale
%           limits)
%       'sclAbsSep': will scale values separately for positive
%           and negative values (see scl for controlling scale limits)
%
% 'thresh': will remove data falling in the interval [a b] (deafult is [0 0]).
%
% 'operations': performs an operation across data maps, returning one map
%       'sum' : add up all the maps (i.e., cols of data) 
%       'pc' : extract the first PC from all the maps (scores). When using
%           this you can also specify 'compKeep' followed by the number of
%           components you'd like to keep.
%       'subtract' : column-wise subtraction (i.e. col1 - col2 - col3, etc)
%       'multiply' : product of all the maps
%       'divide' : column-wise division
%       'mean' : mean of all maps
%       'standard deviation' : standard deviation of all maps
%
% Call: 
% [oData] = dataThresh(data,'thresh',[-2 2]);
% [oData] = dataThresh(data,'pos','off','neg','off','vls','scl','sclLims',[-1 1],'thresh',[-2 2],'pMap',pVals,'pThresh',0.05,'operation','pc','compKeep',1);

% Defaults
options = struct('vls','raw','thresh',[0 0],'pos','on','neg','on','pMap',ones(size(data)),'pThresh',1,'operation','false','sclLims',[0 1],'compKeep',1);
optionNames = fieldnames(options);

% Check number of arguments passed
if length(varargin) > (length(fieldnames(options))*2)
    error('You have supplied too many arguments')
end
nArgs = length(varargin);
if round(nArgs/2)~=nArgs/2
    error('You are missing an argument name somewhere in your list of inputs')
end

% now parse the arguments
vleft = varargin(1:end);
for pair = reshape(vleft,2,[]) %pair is {propName;propValue}
    inpName = pair{1}; % make case insensitive by using Odatawer() here but this can be buggy
    if any(strcmp(inpName,optionNames))
        options.(inpName) = pair{2};
    else
        error('%s is not a recognized parameter name',inpName)
    end
end

% % first remove positive or negative values if necessary
% if strcmp(options.pos,'off')
%     id = find(data > 0);
%     data(id) = 0;
% end
% if strcmp(options.neg,'off')
%     id = find(data < 0);
%     data(id) = 0;
% end

% now apply the p-threshold
id = find(options.pMap > options.pThresh);
data(id) = 0;

% now change values if necessary...
switch options.vls
    case 'raw'
        oData = data;
    case 'percentile'
        for i = 1:size(data,2)
            p = prctile(data(:,i),[0:100],'all');
            for j = 1:size(data,1)
                id = find(data(j,i) >= p);
                oData(j,i) = max(id) - 1;
            end
        end
    case 'percentile (separate for pos/neg)'
        oData = zeros(size(data));
        for i = 1:size(data,2)
            posId = find(data(:,i) > 0);
            negId = find(data(:,i) < 0);
            posV = data(posId,i);
            negV = abs(data(negId,i));
            
            p = prctile(posV,[0:100],'all');
            for j = 1:length(posV)
                id = find(posV(j) >= p);
                p2_1(j,1) = max(id) - 1;
            end
            p = prctile(negV,[0:100],'all');
            for j = 1:length(negV)
                id = find(negV(j) >= p);
                p2_2(j,1) = max(id) - 1;
            end
            oData(posId,i) = p2_1;
            oData(negId,i) = p2_2;
        end
    case 'percentile (absolute)'
        for i = 1:size(data,2)
            p = prctile(abs(data),[0:100],'all');
            for j = 1:length(data)
                id = find(abs(data(j,i)) >= p);
                oData(j,i) = max(id) - 1;
            end
        end
    case 'normalized'
        for i = 1:size(data,2)
            oData(:,i) = normalize(data(:,i));
        end
    case 'normalized (separate for pos/neg)'
        oData = zeros(size(data));
        for i = 1:size(data,2)
            posId = find(data(:,i) > 0);
            negId = find(data(:,i) < 0);
            posV = data(posId,i);
            negV = abs(data(negId,i));
            n1 = normalize(posV);
            n2 = normalize(negV);
            oData(posId,i) = n1;
            oData(negId,i) = n2;
        end
    case 'normalized (absolute)'
        for i = 1:size(data,2)
            oData(:,i) = normalize(abs(data(:,i)));
        end
    case 'scaled (0 to 1)'
        for i = 1:size(data,2)
            oData(:,i) = scaleData(data(:,i),0,1,'true');
        end
    case 'scaled (-1 to 1)'
        for i = 1:size(data,2)
            oData(:,i) = scaleData(data(:,i),-1,1,'true');
        end
    case 'scaled (separate for pos/neg)'
        oData = zeros(size(data));
        for i = 1:size(data,2)
            posId = find(data(:,i) > 0);
            negId = find(data(:,i) < 0);
            posV = data(posId);
            negV = abs(data(negId,i));
            s1 = scaleData(posV,0,1,'true');
            s2 = scaleData(negV,0,1,'true');
            oData(posId,i) = s1;
            oData(negId,i) = s2;
        end
    case 'scaled (absolute)'
        for i = 1:size(data,2)
            oData(:,i) = scaleData(abs(data(:,i)),0,1,'true');
        end
    case 'scaled (absolute and separate for pos/neg)'
        oData = zeros(size(data));
        for i = 1:size(data,2)
            posId = find(data(:,i) > 0);
            negId = find(data(:,i) < 0);
            posV = data(posId);
            negV = abs(data(negId,i));
            s1 = scaleData(abs(posV),0,1,'true');
            s2 = scaleData(abs(negV),0,1,'true');
            oData(posId,i) = s1;
            oData(negId,i) = s2;
        end
end
v = oData;

% first remove positive or negative values if necessary
if strcmp(options.pos,'off')
    id = find(oData > 0);
    oData(id) = 0;
end
if strcmp(options.neg,'off')
    id = find(oData < 0);
    oData(id) = 0;
end

% and now apply normal threshold
id = find(oData > min(options.thresh) & oData < max(options.thresh));
oData(id) = 0;

% now perform any operations required...
switch options.operation
    case 'sum'
        oData = sum(oData')';
    case 'mean'
        oData = mean(oData')';
    case 'pc'
        [~,oData,~,~,explained,~] = pca(oData,'NumComponents',compKeep);
        disp(['PCA components (that were kept) explain: ' num2str(sum(explained(1:compKeep))) '% of variance in the data']);
    case 'subtract'
        sub = oData(:,1);
        for i = 2:size(oData,2)
            sub = sub - oData(:,i);
        end
        oData = sub;
    case 'multiply'
        sub = ones(size(oData(:,1)));
        for i = 1:size(oData,2)
            sub = sub .* oData(:,i);
        end
        oData = sub;
    case 'divide'
        sub = ones(size(oData(:,1)));
        for i = 1:size(oData,2)
            sub = sub ./ oData(:,i);
        end
        oData = sub;
    case 'standard deviation'
        oData = std(oData')';
end