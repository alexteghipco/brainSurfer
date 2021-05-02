function [varargout] = patchOverlay(brainFig, data, underlays, hemi, varargin)
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
options = struct('vls','raw','thresh',[0 0],'pos','on','neg','on','operation','false','sclLims',[0 1],'compKeep',1,'smoothSteps', 0, 'smoothArea', 0, 'smoothToAssign','all','smoothThreshold', 'above', 'smoothType', 'neighbors','colormap','jet','colorSpacing','even','colorBins',1000,'colorSpecial','none','invertColors','false','limits',[],'binarize','false','inclZero','on','opacity',1,'UI',[],'clusterThresh',0,'pMap',zeros(size(data)),'pThresh',1,'outline','none','grow',0,'clusterOrder','random','growVal','edge','priorClusters',[]);
optionNames = fieldnames(options);
 
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
    if any(strcmpi(inpName,optionNames))
        options.(inpName) = pair{2};
    else
        error('%s is not a recognized parameter name',inpName)
    end
end
 
% flip input data if necessary
if ~isempty(data)
    if size(data,1) < size(data,2)
        data = data';
    end
end
if ~isempty(options.pMap)
    if size(options.pMap,1) < size(options.pMap,2)
        options.pMap = options.pMap';
    end
end
 
% remove invalid data if necessary (inf, nan; these are un-patchable)
if ~isempty(data)
    invIdx = find(isnan(data));
    data(invIdx) = 0;
end
if ~isempty(options.pMap)
    invIdx = find(isnan(options.pMap));
    options.pMap(invIdx) = 0;
end
if ~isempty(data)
    invIdx = find(isinf(data));
    dm = max(data);
    data(invIdx) = dm;
end
if ~isempty(options.pMap)
    invIdx = find(isinf(options.pMap));
    dm = max(options.pMap);
    options.pMap(invIdx) = dm;
end
 
% if there is a UI passed in, start loading bar...
if ~isempty(options.UI)
    d = uiprogressdlg(options.UI,'Title','Patching underlay',...
        'Message','Thresholding values...');
end
 
% threshold values
[dataT,dataC] = dataThresh(data,'pos',options.pos,'neg',options.neg,'vls',lower(options.vls),'sclLims',options.sclLims,'thresh',options.thresh,'pMap',options.pMap,'pThresh',options.pThresh);

% find min and max
pos = find(dataT > 0);
neg = find(dataT < 0);
minThreshPos = min(dataT(pos));
minThreshNeg = max(dataT(neg));
 
if isempty(options.limits)
    options.limits = [min(dataT) max(dataT)];
end

if minThreshPos > options.limits(2)
    minThreshPos = options.limits(2);
end
 
if minThreshNeg < options.limits(1)
    minThreshNeg = options.limits(1);
end
 
if isempty(minThreshNeg)
    minThreshNeg = 0;
end
if isempty(minThreshPos)
    minThreshPos = 0;
end
 
% Get clusters if they are needed
if options.clusterThresh ~= 0 | options.grow ~= 0 | strcmpi(options.outline,'map') | strcmpi(options.binarize,'clusters') == 1
    if ~isempty(options.UI)
        d.Message = ['Finding blobs...this may take some time if you have large blobs in your map'];
        d.Value = 0.1;
    end
    
    if isempty(options.priorClusters)
        % extract the faces
        atv = find(dataT ~= 0);
        [dataClust, clusterLen] = getClusters(atv, underlays.(hemi).Faces);
    else
        dataClust = options.priorClusters;
        clusterLen = cellfun('length',dataClust);
    end
    
    % remove clusters with cluster size less than threshold
    clustIdx = find(clusterLen < options.clusterThresh);
    dataClust(clustIdx) = [];
    atv = vertcat(dataClust{:});
    [clustThresh,~] = setdiff([1:length(dataT)],atv);
    dataT(clustThresh) = 0;
    
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
    
    atv = find(dataT ~= 0);
    inUn = unique(dataT(atv));
    id = find(inUn == 0);
    inUn(id) = [];
    for roii = 1:length(inUn)
        dataClust{roii} = find(dataT == inUn(roii));
    end
    clusterLen = cellfun('length',dataClust);
end
 
% Turn clusters into boundaries if necessary
if ~strcmpi(options.outline,'none') | options.grow ~= 0
        if ~isempty(options.UI)
            d.Message = ['Fetching boundary vertices...'];
            d.Value = 0.2;
        end
        if isempty(options.priorClusters)
            % if we do want to make an outline, do so for each cluster
            dataClust_all = dataClust;
            dataClust = getClusterBoundary(dataClust, underlays.(hemi).Faces);
        else
            dataClust_all = dataClust;
        end
        
        for clusteri = 1:length(dataClust)
            % if you are doing an outline we need to get mean value for
            % each cluster
            if ~strcmpi(options.outline,'none')
                tmp = mean(dataT(dataClust_all{clusteri}));
                if tmp <= 0 & tmp >= minThreshNeg
                    tmp = minThreshNeg-0.0001;
                end
                if tmp >= 0 & tmp <= minThreshPos
                    tmp = minThreshPos+0.00001;
                end
                
                oVals{clusteri} = repmat(tmp,[length(dataClust{clusteri}),1]);
            end
            % if you are growing your map then we get closest non-zero edges
            if strcmpi(options.outline,'none') & options.grow ~= 0
                [~,neighborhood] = pdist2(underlays.(hemi).Vertices(dataClust_all{clusteri},:),underlays.(hemi).Vertices(dataClust{clusteri},:),'seuclidean','Smallest',1);
                oVals{clusteri} = dataT(dataClust_all{clusteri}(neighborhood));
            end
        end
        
        % now grow the boundary
        if ~isempty(options.UI)
            d.Message = ['Growing/shrinking map...'];
            d.Value = 0.5;
        end
       
        atv = vertcat(dataClust_all{:});
        %atvC = underlays.(hemi).Vertices;
        [grownVert,atv2,growVertTracker2] = growMap(dataClust,options.grow,atv,underlays.(hemi).Faces); % grownVert is boundary vertices + expansion of them       
        
        av = vertcat(dataClust_all{:});
        gwTmp = vertcat(growVertTracker2{:});
        
        if options.grow > 0
            gw = setdiff(gwTmp,av);
        elseif options.grow <= 0
            gw = gwTmp;
        end
        
        ov = vertcat(oVals{:});
        bv = vertcat(dataClust{:}); % boundary verts
      
        if options.grow ~= 0
            [~,neighborhood] = pdist2(underlays.(hemi).Vertices(bv,:),underlays.(hemi).Vertices(gw,:),'seuclidean','Smallest',1);
        else
            neighborhood = 1:length(ov);
        end
        
        if options.grow >= 0
            ov2 = ov(neighborhood);
        elseif options.grow < 0
            ov2 = dataT(gw);
        end
        
        % now write out the data
        if ~strcmpi(options.outline,'none') %& options.grow == 0
           % if outlining, write in the boundary vertices
           % (which should have not been expanded) and then remove all
           % other vertices
            if options.grow >= 0
                dataT(gw) = ov2;
            end
            [c,~] = setdiff(1:length(dataT),gw);
            dataT(c) = 0;
        end
        
        if strcmpi(options.outline,'none') & options.grow ~= 0
            if options.grow > 0
                % if growing without outline, you neeed to just add oVals/gw
                % to dataT
                dataT(gw) = ov2;
            elseif options.grow < 0
                % if shrinking without outline, you neeed to just remove gw
                % from dataT
                dataT(gw) = 0;
            end
        end
end
 
if ~isempty(options.UI)
    if options.smoothArea ~= 0
        d.Message = ['Smoothing...This can take some time depending on your settings'];
        d.Value = 0.3;
    end
end
 
% smooth data
dataTS = smoothVertData(dataT, underlays.(hemi).Vertices, underlays.(hemi).Faces, 'smoothSteps', options.smoothSteps, 'smoothArea', options.smoothArea, 'smoothThreshold', options.smoothThreshold, 'toAssign', options.smoothToAssign);
   
if ~isempty(options.UI) & strcmpi(options.binarize,'none')
    d.Message = ['Binarizing...'];
    d.Value = 0.4;
end

switch (lower(options.binarize))
    case 'map'
        id = find(dataTS ~= 0);
        dataTS(id) = 1;
        options.limits = [0 1];
    case 'clusters'
        % one problem is that smaller clusters will predominantly map onto
        % one end of the spectrum unless they are shuffled so lets do that
        % now
        switch options.clusterOrder
            case 'random'
                if isempty(options.priorClusters)
                    randi = randperm(length(dataClust));
                    dataClust = dataClust(randi);
                end
        end
        
        for clusteri = 1:length(dataClust)
            dataTS(dataClust{clusteri}) = clusteri;
        end
        options.limits = [min(dataTS) max(dataTS)];
        atv = vertcat(dataClust{:});
        [c, ia] = setdiff([1:dataTS],atv);
        dataTS(c) = 0;
end
 
% map colors onto data
if ~isempty(options.UI)
    d.Message = ['Mapping colors...'];
    d.Value = 0.6;
end
 
[colormap.map,cData,colormap.dataMap,ticks.ticks,ticks.labels] = colormapper(dataTS,'colormap',options.colormap,'colorSpacing',options.colorSpacing,'colorBins',options.colorBins,'colorSpecial',options.colorSpecial,'invertColors',options.invertColors,'limits',[min(options.limits) max(options.limits)],'thresh',options.thresh);
 
% setup alpha data
transp.vals = ones(size(data))*options.opacity;
if strcmpi(options.inclZero,'off')
   id = find(dataTS == 0);
   transp.vals(id) = 0;
end

% find alpha mapping for each "color" here. transp.map will be this.
% transp.vals can be alph from below.
transp.map = ones(size(colormap.dataMap))*options.opacity;
transp.op = 1*options.opacity;

if strcmpi(options.inclZero,'off')
   id = find(dataTS == 0);
   transp.vals(id) = 0;
end

allVert = [1:length(data)];
atv = allVert;
f = underlays.(hemi).Faces;
v = underlays.(hemi).Vertices;
switch options.inclZero
    case 'off'
        id = find(dataTS ~= 0);
        v = v(id,:);
        da = dataTS(id);
        c = cData(id,:);
        atv = atv(id);
        transp.vals = transp.vals(id);
    case 'on'
        v = underlays.(hemi).Vertices;
        da = dataTS;
        c = cData;
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
 
% this is for modulating transparency by a second map 
% if (~isempty(options.transparencyThresholds)| ~isempty(options.transparencyPThresh)) & ~isempty(options.transparencyLimits)
%     [C, ia, ib] = intersect(allThreshVert,opacityVert);
%     opacityVert = opacityVert(ib);
%     
%     % get secondary opacity threshold
%     overlayDataPosIdx = find(overlayData(opacityVert) > 0);
%     overlayDataNegIdx = find(overlayData(opacityVert) < 0);
%     secondaryThreshPos = min(overlayData(opacityVert(overlayDataPosIdx)));
%     secondaryThreshNeg = max(overlayData(opacityVert(overlayDataNegIdx)));
%     
%     minThreshPos = min([minThreshPos secondaryThreshPos]);
%     minThreshNeg = max([minThreshNeg secondaryThreshNeg]);
% end
 
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

varargout{1} = overlay;
varargout{2} = colormap;
varargout{3} = ticks;
varargout{4} = dataC;
varargout{5} = dataTS;
varargout{6} = dataClust;
varargout{7} = transp;
%varargout{5} = ticks;
