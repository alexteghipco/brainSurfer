function [varargout] = patchOverlay(brainFig, allData, underlays, hemi, varargin)
% This function will patch curvature onto an existing surface. It will
% require you to pass in left and right hemisphere curvature data
% separately (either both, or only one) and specify the hemisphere. There
% are a number of optional arguments that may be passed as well. The
% arguments that affect cruvature data values will be processed in the
% following order: i) if positive or negative values are set to 'off' they
% will be removed from the passed in curvature data, ii) 'vls' will be
% processed in order to scale, normalize, or convert data to percentiles,
% iii) a threshold will be applied to the resulting data.
%
% Remaining optional arguments deal with the way in which data is plotted,
% etc.
%
% Mandatory arguments------------------------------------------------------ 
%
% figID: handle to figure containing surface onto which we will patch
%
% underlays: a structure containing left and right surface patches (i.e.,
% underlays.left and underlays.right; one of these can be empty)
%
% 'lh' and 'rh': Left and/or right hemisphere curvature data must be passed
% in as well (as an argument pair; the name of the variable containing the
% data does not matter)
%
% Outputs------------------------------------------------------------------ 
%
% underlays: returns the updated patch information
%
% colormapSG: returns a structure containing the colormaps and the colorbar
%
% ticksSG: returns a structure containing information about where you should
% put your ticks if you want to generate your own colorbar (colorbar in
% colormapSG just contains a value for each bin in colormap).
%
% Optional arguments------------------------------------------------------- 
%
% 'pos': if set to 'off' positive values will be removed from curvature
% data (deafult is 'on').
%
% 'neg': if set to 'off' negative values will be removed from curvature
% data (deafult is 'on').
%
% 'vls' has various effects all of which normalize/scale/standardize the
% curvature data (default is 'raw'):
%   'raw': will patch raw values
%   'prct': will convert values to percentiles
%   'prctSep': will convert values to percentiles (separately for positive
%       and negative values)
%   'norm': will normalize values
%   'normSep': will normalize positive and negative values separately
%   'scl': will scale values between -1 and 1
%   'sclSep': will scale values between -1 and 1 (separately for positive
%       and negative values)
%   'sclAbs': will scale values between 0 and 1
%   'sclAbsSep': will scale values between 0 and 1 (separately for positive
%       and negative values)
%
% 'thresh': will remove data falling in the interval [a b] (deafult is [0 0]).
%
% 'colormap': an internal matlab colormap, or the name of any other
%       colormap redistributed with brainSurfer: 'jet', parula, hsv, hot,
%       cool, spring, summer, autumn, winter, gray, bone, copper, pink,
%       lines, colorcube, prism, spectral, RdYlBu, RdGy, RdBu, PuOr, PRGn,
%       PiYG, BrBG, YlOrRd, YlOrBr, YlGnBu, YlGn, Reds, RdPu, Purples,
%       PuRd, PuBuGn, PuBu, OrRd, oranges, greys, greens, GnBu, BuPu, BuGn,
%       blues, set3, set2, set1, pastel2, pastel1, paired, dark2, accent,
%       inferno, plasma, vega10, vega20b, vega20c, viridis, thermal,
%       haline, solar, ice, oxy, deep, dense, algae, matter, turbid, speed,
%       amp, tempo, balance, delta, curl, phase, perceptually distinct
%       (default is jet). 
%       
%       Colormap can also be an l x 3 matrix of colors specifying a custom
%       colormap
%
% 'colorSpacing': determines how colors are spaced in between the limits. 
%       'even': evenly spaced between limits (default)
%       'center on zero': the midpoint of the colorbar is forced to be zero
%       'center on threshold': the midpoint of the colorbar is forced to be
%       the thresholds you've applied to your data
%
% 'colorBins': number of color bins in the colorbar (default: 1000)
%   
% 'colorSpecial': this option can assign colors in special ways: 
%       'randomizeClusterColors': each cluster in data is assigned a random
%       color on colorbar (default: 'none')
%
% 'invertColors': invert colormap (default: 'false')
%
% 'limits': two numbers that represent the limits of the colormap (default
%       is: [min(data) max(data)])
% 'opacity': sets opactiy of the patch (default: 1)
%
% 'binarize': this binarizes sulcal/gyral info into two colors
%
% 'inclZero': this determines if zeros will be patched (default: 'no')
%
% 'lights': this determines if we need to "fix" the lights
%
% 'smoothSteps': number of times to repeat smoothing procedure (i.e.,
% smoothness "kernel"; default: 0; i.e., no smoothing is performed)
%
% 'smoothArea': this is the number of closest vertices in euclidean
% distance that will be used to smooth each data point (default: 0)
%
% 'smoothThreshold': determines whether smoothing will only be applied to
% vertices that meet the thresholds that have been applied to the data
% (i.e., 'above') or to vertices below threshold. You might want to do the
% latter to shrink your map (default: 'above').
% 
% 'smoothType': 'neighbors' or 'neighborhood' (default: 'neighbors').
%
% Call: 
% [underlay, colormap, brain, data] = plotUnderlay(figID, underlays, 'lh', curv1)
% [underlay, colormap, brain, data] = plotUnderlay(figID, underlays, 'lh', curv1, 'rh', curv2)
% [underlay, colormap, brain, data] = plotUnderlay(figID, underlays, ,'lh', curv1, 'rh', curv2, 'pos','off','neg','off','vls','prct','thresh',[-2 2],)
% [underlay, colormap, brain, data] = plotUnderlay(figID, underlays, ,'lh', curv1, 'rh', curv2, 'pos','off','neg','off','vls','scl','sclLims',[-1 1],'thresh',[-2 2],'pMap',pVals,'pThresh',0.05,'operation','pc','compKeep',1,'smoothSteps',2,'smoothArea',1,'smoothThreshold','above','smoothType','neighbors');
 
% Defaults
options = struct('vls','raw','thresh',[0 0],'pos','on','neg','on','operation','false','sclLims',[0 1],'compKeep',1,'smoothSteps', 0, 'smoothArea', 0, 'smoothToAssign','all','smoothThreshold', 'above', 'smoothType', 'neighbors','colormap','jet','colorSpacing','even','colorBins',1000,'colorSpecial','none','invertColors','false','limits',[],'binarize','none','inclZero','off','opacity',1,'UI',[],'clusterThresh',0,'pMap',zeros(size(allData)),'pThresh',1,'outline','none','grow',0,'clusterOrder','random','growVal','edge','priorClusters',[],'modData',[],'modCmap',[],'multiCmap',[],'absMod','On','incZeroMod','Off','minAlphaMod',0,'maxAlphaMod',1,'alphaModLims',[],'scndCbarAxis','same','multiCmapTicks',[],'multiCbData',[]);
optionNames = fieldnames(options);
oneDImp = {'pMap';'sclLims';'operation';'inclZero';'opacity';'UI';'clusterThresh';'outline';'grow';'clusterOrder';'growVal';'priorClusters';'modData';'modCmap';'multiCmap';'absMod';'incZeroMod';'minAlphaMod';'maxAlphaMod';'alphaModLims';'scndCbarAxis';'multiCmapTicks';'multiCbData'};
 
% Check inputs
if length(varargin) < 3
    error('You are missing an argument')
end
if length(varargin) > (length(fieldnames(options))*2)
    error('You have supplied too many arguments')
end  
 
% now parse the arguments
vleft = varargin(1:end);
for pair = reshape(vleft,2,[]) %pair is {propName;propValue}
    inpName = pair{1}; % make case insensitive by using lower() here but this can be buggy
    if any(strcmpi(inpName,optionNames)) % check if arg pair matches default
        def = options.(inpName); % default argument
        if ~isempty(pair{2}) % if passed in argument isn't empty, then write that in as the option
            options.(inpName) = pair{2};
        else
            options.(inpName) = def; % otherwise use the default values for the option
        end
    else
        error('%s is not a recognized parameter name',inpName)
    end
end

% loop over options and make sure everything is contained in a cell if it
% needs to be, and that there is an option specified for each dimension of
% the data
flds = fieldnames(options);
for i = 1:numel(flds)
    def = options.(flds{i});
    if ~any(strcmpi(flds{i},oneDImp)) % if this wasn't an argument that is 1-dimensional
        if ~iscell(options.(flds{i})) % then it should be a cell
            options.(flds{i}) = {options.(flds{i})};
        end
        if length(options.(flds{i})) < min(size(allData)) % and the cell should match the length of dimensions...
            options.(flds{i}) = [options.(flds{i}) repmat({def},[1,min(size(allData))-1])];
        elseif length(options.(flds{i})) > min(size(allData))
            error('%s too many inputs for parameter name',flds{i})
        end
    end
end

% flip input data if necessary
if ~isempty(allData)
    if size(allData,1) < size(allData,2)
        allData = allData';
    end
end
if ~isempty(options.pMap)
    if size(options.pMap,1) < size(options.pMap,2)
        options.pMap = options.pMap';
    end
end
 
% remove invalid data if necessary (inf, nan; these are un-patchable)
if ~isempty(allData)
    invIdx = find(isnan(allData));
    allData(invIdx) = 0;
end
if ~isempty(options.pMap)
    invIdx = find(isnan(options.pMap));
    options.pMap(invIdx) = 0;
end
if ~isempty(allData)
    for j = 1:size(allData,2)
        invIdx = find(isinf(allData(:,j)));
        dm = max(allData(:,j));
        allData(invIdx,j) = dm;
    end
end
if ~isempty(options.pMap)
    for j = 1:size(options.pMap,2)
        invIdx = find(isinf(options.pMap(:,j)));
        dm = max(options.pMap(:,j));
        options.pMap(invIdx,j) = dm;
    end
end
 
% if there is a UI passed in, start loading bar...
if ~isempty(options.UI)
    d = uiprogressdlg(options.UI,'Title','Patching underlay',...
        'Message','Thresholding values...');
end

for di = 1:size(allData,2)
    data = allData(:,di);
    % threshold values
    [dataT{di},dataC{di}] = dataThresh(data,'pos',options.pos{di},'neg',options.neg{di},'vls',lower(options.vls{di}),'sclLims',options.sclLims,'thresh',options.thresh{di},'pMap',options.pMap(:,di),'pThresh',options.pThresh{di});

    % find min and max
    pos{di} = find(dataT{di} > 0);
    neg{di} = find(dataT{di} < 0);
    minThreshPos{di} = min(dataT{di}(pos{di}));
    minThreshNeg{di} = max(dataT{di}(neg{di}));
    
    if isempty(options.limits{di})
        options.limits{di} = [min(dataT{di}) max(dataT{di})];
    end
    
    if minThreshPos{di} > options.limits{di}(2)
        minThreshPos{di} = options.limits{di}(2);
    end
    
    if minThreshNeg{di} < options.limits{di}(1)
        minThreshNeg{di} = options.limits{di}(1);
    end
    
    if isempty(minThreshNeg{di})
        minThreshNeg{di} = 0;
    end
    if isempty(minThreshPos{di})
        minThreshPos{di} = 0;
    end
end

% Get clusters if they are needed
if options.clusterThresh ~= 0 | options.grow ~= 0 | strcmpi(options.outline,'map') | strcmpi(options.binarize,'clusters') == 1 | ~isempty(options.priorClusters)
    if ~isempty(options.UI)
        d.Message = ['Finding blobs...this may take some time if you have large blobs in your map'];
        d.Value = 0.1;
    end
    
    if isempty(options.priorClusters)
        atv = find(all(horzcat(dataT{:}) == 0,2)==0);
        [dataClust, clusterLen] = getClusters(atv, underlays.(hemi).Faces);
    else
        dataClust = options.priorClusters;
        clusterLen = cellfun('length',dataClust);
    end
    
    dataClustOrig = dataClust;
    % remove clusters with cluster size less than threshold
    clustIdx = find(clusterLen < options.clusterThresh);
    dataClust(clustIdx) = [];

    atv = vertcat(dataClust{:});
    [clustThresh,~] = setdiff([1:size(allData,1)],atv);
    for i = 1:length(dataT)
        dataT{i}(clustThresh) = 0;
    end
    
    % save maximum cluster size to options
    options.clusterLimit = max(clusterLen);
    options.clusters = dataClust;
end

% Roi-based clusters are a little different so convert here...
if strcmpi(options.outline,'roi') & isempty(options.priorClusters)
    if ~isempty(options.UI)
        d.Message = ['Finding ROI blobs...this may take some time if you have large blobs in your map'];
        d.Value = 0.1;
    end
    
    atv = find(all(horzcat(dataT{:}) == 0,2)==0);

    hz = horzcat(dataT{:});
    inUn = unique(hz(atv,:));
    
    id = find(inUn == 0);
    inUn(id) = [];
    for roii = 1:length(inUn)
        id = find(all(horzcat(dataT{:}) == inUn(roii),2)==1);
        dataClust{roii} = id;
    end
    clusterLen = cellfun('length',dataClust);
    
    % remove clusters with cluster size less than threshold
    clustIdx = find(clusterLen < options.clusterThresh);
    dataClust(clustIdx) = [];
    
    atv = vertcat(dataClust{:});
    [clustThresh,~] = setdiff([1:size(allData,1)],atv);
    for i = 1:length(dataT)
        dataT{i}(clustThresh) = 0;
    end
    
    % save maximum cluster size to options
    options.clusterLimit = max(clusterLen);
    options.clusters = dataClust;
end
  
% Turn clusters into boundaries if necessary
if ~strcmpi(options.outline,'none') | options.grow ~= 0
    if ~isempty(options.UI)
        d.Message = ['Fetching boundary vertices...'];
        d.Value = 0.2;
    end
        dataClust_all = dataClust;
        dataClust = getClusterBoundary(dataClust, underlays.(hemi).Faces);
        hz = horzcat(dataT{:});
    for clusteri = 1:length(dataClust)
        % if you are doing an outline we need to get mean value for
        % each cluster
        if ~strcmpi(options.outline,'none')
            tmp = mean(mean(hz(dataClust_all{clusteri},:)));
            if tmp <= 0 & tmp >= min(vertcat(minThreshNeg{:}))
                tmp = min(vertcat(minThreshNeg{:}))-0.0001;
            end
            if tmp >= 0 & tmp <= min(vertcat(minThreshPos{:}))
                tmp = min(vertcat(minThreshPos{:}))+0.00001;
            end

            oVals{clusteri} = repmat(tmp,[length(dataClust{clusteri}),1]);
        end
        % if you are growing your map then we get closest non-zero edges
        if strcmpi(options.outline,'none') & options.grow ~= 0
            [~,neighborhood] = pdist2(underlays.(hemi).Vertices(dataClust_all{clusteri},:),underlays.(hemi).Vertices(dataClust{clusteri},:),'seuclidean','Smallest',1);
            oVals{clusteri} = mean(hz(dataClust_all{clusteri}(neighborhood),:),2);
        end
    end

    % now grow the boundary
    if ~isempty(options.UI)
        d.Message = ['Growing/shrinking map...'];
        d.Value = 0.5;
    end

    atv = vertcat(dataClust_all{:});
    if ~strcmpi(options.outline,'none')
        if options.grow > 0
            options.grow = options.grow+1;
        elseif options.grow < 0
            options.grow = options.grow-1;
        end
    end

    [grownVert,atv2,growVertTracker2] = growMap(dataClust,options.grow,atv,underlays.(hemi).Faces); % grownVert is boundary vertices + expansion of them

    gwTmp = vertcat(growVertTracker2{:});

    if options.grow > 0
        gw = setdiff(gwTmp,atv);
    elseif options.grow <= 0
        gw = gwTmp;
    end

    ov = vertcat(oVals{:});
    bv = vertcat(dataClust{:}); % boundary verts

    if options.grow ~= 0
        if ~strcmpi(options.outline,'none') & options.grow < 0
            gw = [gw; bv];
        end

        [~,neighborhood] = pdist2(underlays.(hemi).Vertices(bv,:),underlays.(hemi).Vertices(gw,:),'seuclidean','Smallest',1);
    else
        neighborhood = 1:length(ov);
    end

    if options.grow >= 0
        ov2 = ov(neighborhood);
    elseif options.grow < 0
        if strcmpi(options.outline,'none')
            ov2 = mean(hz(gw,:));
        else
            ov2 = ov(neighborhood);
        end
    end

    % now write out the data
    if ~strcmpi(options.outline,'none') %& options.grow == 0
        % if outlining, write in the boundary vertices
        % (which should have not been expanded) and then remove all
        % other vertices
        for di = 1:length(dataT)
            dataT{di}(gw) = ov2;
            [c,~] = setdiff(1:length(dataT{di}),gw);
            dataT{di}(c) = 0;
        end
    end

    if strcmpi(options.outline,'none') & options.grow ~= 0
        if options.grow > 0
            % if growing without outline, you neeed to just add oVals/gw
            % to dataT
            for di = 1:length(dataT)
                dataT{di}(gw) = ov2;
            end
        elseif options.grow < 0
            % if shrinking without outline, you neeed to just remove gw
            % from dataT
            for di = 1:length(dataT)
                dataT{di}(gw) = 0;
            end
        end
    end
end

if ~isempty(options.UI)
    if vertcat(options.smoothArea{:}) ~= 0
        d.Message = ['Smoothing...This can take some time depending on your settings'];
        d.Value = 0.3;
    end
end

% smooth data
for di = 1:length(dataT)
    dataTS{di} = smoothVertData(dataT{di}, underlays.(hemi).Vertices, underlays.(hemi).Faces, 'smoothSteps', options.smoothSteps{di}, 'smoothArea', options.smoothArea{di}, 'toAssign', options.smoothToAssign{di});
end

if ~isempty(options.UI) & ~strcmpi(options.binarize,'none')
    d.Message = ['Binarizing...'];
    d.Value = 0.4;
end

for di = 1:length(dataTS)
    switch (lower(options.binarize{di}))
        case 'map'
            id = find(dataTS{di} ~= 0);
            dataTS{di}(id) = 1;
            options.limits{di} = [0 1];
        case 'clusters'
            % one problem is that smaller clusters will predominantly map onto
            % one end of the spectrum unless they are shuffled so lets do that
            % now
            if di == 1
                switch options.clusterOrder
                    case 'random'
                        if isempty(options.priorClusters)
                            randi = randperm(length(dataClust));
                            dataClust = dataClust(randi);
                        end
                end
            end
            for clusteri = 1:length(dataClust)
                dataTS{di}(dataClust{clusteri}) = clusteri;
            end
            options.limits{di} = [min(dataTS{di}) max(dataTS{di})];
            atv = vertcat(dataClust{:});
            try
                [c, ia] = setdiff([1:dataTS{di}],atv);
            catch
                [c, ia] = setdiff([1:length(dataTS{di})],atv);
            end
            dataTS{di}(c) = 0;
    end
end

% map colors onto data
if ~isempty(options.UI)
    d.Message = ['Mapping colors...'];
    d.Value = 0.6;
end
 
for di = 1:length(dataTS)
    %if length(dataTS) == 1 | (length(dataTS) > 1  & (isempty(options.multiCmap) | isempty(options.multiCmapTicks) | isempty(options.multiCbData)))
    if length(dataTS) == 1 | length(dataTS) > 1 | isempty(options.multiCmapTicks) | isempty(options.multiCbData)
        [colormapMapTmp,cDataTmp,colormapdataMapTmp,ticksTicksTmp,tickslabelsTmp] = colormapper(dataTS{di},'colormap',options.colormap{di},'colorSpacing',options.colorSpacing{di},'colorBins',options.colorBins{di},'colorSpecial',options.colorSpecial{di},'invertColors',options.invertColors{di},'limits',[min(options.limits{di}) max(options.limits{di})],'thresh',options.thresh{di});
        colormap{di}.map = colormapMapTmp;
        cData{di} = cDataTmp;
        colormap{di}.dataMap = colormapdataMapTmp;
        ticks{di}.ticks = ticksTicksTmp;
        ticks{di}.labels = tickslabelsTmp;
    end
end

% generate multidimensional colormap data if it's missing...
if length(dataTS) > 1  
    if isempty(options.multiCmap)
        for di = 1:length(dataTS)
            cmap(:,:,di) = colormap{di}.map;
        end
        cust = customColorMapInterpBars(cmap,size(cmap,1),options.scndCbarAxis);
        options.multiCmap = flipud(cust);
    end
    if isempty(options.multiCmapTicks)
        for di = 1:length(dataTS)
            options.multiCmapTicks(:,di) = ticks{di}.labels;
        end
    end
    if isempty(options.multiCbData)
         for di = 1:length(dataTS)
            options.multiCbData(:,di) = colormap{di}.dataMap;
        end
    end
    
    % now map data onto this new colormap...
    for di = 1:length(dataTS)
        tf = options.multiCbData(:,di)' >= dataTS{di};
        [~,m] = max(tf,[],2);
        ma(:,di) = m;
        id = find(options.multiCbData(:,di) > max(options.multiCmapTicks(:,di)));
        ma(id,di) = size(options.multiCbData(:,di),1);
        id = find(options.multiCbData(:,di) < min(options.multiCmapTicks(:,di)));
        ma(id,di) = 1;
    end
    clear cData
    
    if length(dataTS) == 2
        sz = length(ma);
        m = [ma(:,1); ma(:,1); ma(:,1)];
        m2 = [ma(:,2); ma(:,2); ma(:,2)];
        m3 = ones([sz,1]);
        m3 = [m3; m3+1; m3+2];
        
        ind = sub2ind([size(options.multiCmap)],m,m2,m3);
        cData{1} = options.multiCmap(ind);
        cData{1} = reshape(cData{1},[sz,3]);
        cData{1} = squeeze(cData{1});
    elseif length(dataTS) == 3
        sz = length(ma);
        m = [ma(:,1); ma(:,1); ma(:,1)];
        m2 = [ma(:,2); ma(:,2); ma(:,2)];
        m3 = [ma(:,3); ma(:,3); ma(:,3)];
        m4 = ones([sz,1]);
        m4 = [m4; m4+1; m4+2];
        
        ind = sub2ind([size(options.multiCmap)],m,m2,m3,m4);
        cData{1} = options.multiCmap(ind);
        cData{1} = reshape(cData{1},[sz,3]);
        cData{1} = squeeze(cData{1});
    end
end

if ~isempty(options.modData)    
    id1 = find(options.modData >= 0);
    id2 = find(options.modData < 0);
    
    if isempty(options.alphaModLims)
        if strcmpi(options.absMod ,'On')
            minVal1 = min(options.modData(id1));
            maxVal1 = max(options.modData(id1));
            minVal2 = min(options.modData(id2));
            maxVal2 = max(options.modData(id2));
            
            options.alphaModLims(2) = max([maxVal1 maxVal2]);
            options.alphaModLims(1) = min([minVal1 minVal2]);
        else
            options.alphaModLims(1) = min(options.modData);
            options.alphaModLims(2) = max(options.modData);
        end
    end
    
    if strcmpi(options.absMod ,'On')
        l(:,1) = linspace(0,options.alphaModLims(1),size(colormap{1}.map,1));
        l(:,2) = linspace(0,options.alphaModLims(2),size(colormap{1}.map,1));
    else
        l(:,1) = linspace(options.alphaModLims(1),options.alphaModLims(2),size(colormap{1}.map,1));
    end
    
    lv = linspace(options.minAlphaMod,options.maxAlphaMod,size(colormap{1}.map,1));
    s = zeros(size(options.modData));
    if size(l,2) == 2
        tf = l(:,1)' <= options.modData(id2);
        [~,m] = max(tf,[],2);
        mData = lv(m);
        id = find(options.modData(id2) < options.alphaModLims(1));
        mData(id) = lv(end);
        id = find(options.modData(id2) > 0);
        mData(id) = lv(1);
        s(id2) = mData;
        
        tf = l(:,2)' >= options.modData(id1);
        [~,m] = max(tf,[],2);
        mData = lv(m);
        id = find(options.modData(id1) < 0);
        mData(id) = lv(1);
        id = find(options.modData(id1) > options.alphaModLims(2));
        mData(id) = lv(end);
        s(id1) = mData;
    else
        tf = l' >= options.modData;
        [~,m] = max(tf,[],2);
        mData = lv(m);
        id = find(options.modData < options.alphaModLims(1));
        mData(id) = lv(1);
        id = find(options.modData > options.alphaModLims(2));
        mData(id) = lv(end);
        s = mData;
    end
                                
    if isempty(options.modCmap)
        modCmapIn(:,:,1) = colormap{1}.map;
        modCmapIn(:,:,2) = ones(size(colormap{1}.map));
        modCmap = customColorMapInterpBars(modCmapIn,size(modCmapIn,1),'same');
        modCmap = flipud(modCmap);
    else
        modCmap = options.modCmap;
    end
else
    modCmap = [];
    s = [];
end

% setup alpha data
transp.vals = ones([size(allData,1)],1)*options.opacity;
if strcmpi(options.inclZero,'off')
    for di = 1:length(dataTS)
        id = find(all(horzcat(dataTS{:}) == 0,2)==1);
        transp.vals(id) = 0;
    end
end

% find alpha mapping for each "color" here. transp.map will be this.
% transp.vals can be alph from below.
try
    transp.map = ones(size(colormap{1}.dataMap))*options.opacity;
catch
    transp.map = ones(size(options.multiCbData,1),1)*options.opacity;
end

% if strcmpi(options.inclZero,'off') & isempty(s)
%    id = find(all(horzcat(dataTS{:}) == 0,2)==1);
%    transp.vals(id) = 0;
% end

if ~isempty(s)
    if find(size(s) == size(transp.vals,1)) == 2
        s = s';
    end
    transp.vals = transp.vals.*s;
end

allVert = [1:size(allData,1)];
atv = allVert;
f = underlays.(hemi).Faces;
v = underlays.(hemi).Vertices;
switch options.inclZero
    case 'off'
        id = find(any(horzcat(dataTS{:}) ~= 0,2)==1);
        v = v(id,:);
        %da = dataTS(id);        
        c = cData{1}(id,:);
        atv = atv(id);
        transp.vals = transp.vals(id);
    case 'on'
        v = underlays.(hemi).Vertices;
        %da = dataTS;
        c = cData{1};
end

[C,ia] = setdiff(allVert,atv);
removeVert = allVert(ia); % all faces that don't have these verts
removeVertX = ismember(f(:,1),removeVert);
removeVertY = ismember(f(:,2),removeVert);
removeVertZ = ismember(f(:,3),removeVert);
removeVertXYZ = removeVertX+removeVertY+removeVertZ;
removeVertXYZIdx = find(removeVertXYZ > 0);
f(removeVertXYZIdx,:) = [];

vl = [1:length(atv)];
[M, ia] = ismember(f, atv);
f(M) = vl(ia(M));

if ~isempty(options.UI)
    d.Message = ['Replacing zeros and making intial patch...'];
    d.Value = 0.7;
end
 
if ~isempty(brainFig)
    % save properties    
    figure(brainFig)
    tmp = findall(brainFig.Children,'Type','Axes');
    if length(tmp) > 1
        tmp = tmp(end);
    end
    overlay = patch(tmp,'Faces',f,'FaceAlpha','interp','EdgeAlpha','interp','EdgeColor','none','Vertices',v,'FaceVertexCData',c,'FaceVertexAlphaData',transp.vals,'AlphaDataMapping','none','CDataMapping','direct','facecolor','interp','edgecolor','none','SpecularColorReflectance',underlays.(hemi).SpecularColorReflectance,'SpecularExponent',underlays.(hemi).SpecularExponent,'SpecularStrength',underlays.(hemi).SpecularStrength,'FaceLighting',underlays.(hemi).FaceLighting,'DiffuseStrength',underlays.(hemi).DiffuseStrength,'AmbientStrength',underlays.(hemi).AmbientStrength,'BackFaceLighting',underlays.(hemi).BackFaceLighting);
end
 
if ~exist('dataClust','var')
    dataClust = [];
end

if exist('dataClust_all','var')
   dataClust = dataClust_all; 
end

if exist('dataClustOrig','var')
   dataClust = dataClustOrig; 
end

%multiCmap = options.multiCmap;

if length(dataTS) == 1
    colormap = colormap{1};
    ticks = ticks{1};
    dataTSAll = dataTS{1};
    dataCAll = dataC{1};
else
    colormap = options.multiCmap;
    ticks = options.multiCmapTicks;
    dataCAll = dataC;
    dataTSAll = dataTS;
end

varargout{1} = overlay;
varargout{2} = colormap;
varargout{3} = ticks;
varargout{4} = dataCAll;
varargout{5} = dataTSAll;
varargout{6} = dataClust;
varargout{7} = transp;
varargout{8} = modCmap;
% varargout{9} = multiCmap;
% varargout{10} = options.multiCmapTicks;
% varargout{11} = options.multiCbData;
%varargout{13} = options.multiCbData;