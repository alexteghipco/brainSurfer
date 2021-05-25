function [varargout] = plotOverlay(underlay, overlayData, varargin)
% Plot statistical data (i.e., overlay), either on top of an underlay
% figure (i.e., brain surface(s)) that you have already generated, or after
% generating an underlay figure from scratch using underlay data that is
% provided.
%
% Basic call:
% [overlay] = plotUnderlay(underlay, overlayData)
%
% The call to plotOverlay must include an underlay structure in 'underlay',
% and some overlay data in 'overlayData'.
%
% Mandatory variables:
% underlay -- underlay must have at least one and up to two fields. The
% fields are 'left' and/or 'right', corresponding to data about either the
% left or right hemisphere. In both 'left' and 'right' fields there must be
% a 'Faces' field, a 'Vertices' field and a 'FaceVertexCData' field. Faces
% and vertices can be read in from any surface space nifti file using
% load_nifti. FaceVertexCData has as many rows as there are 'Vertices'. It
% has 3 columns and corresponds to a color associated with every individual
% vertex (in this case corresponding to sulci and gyri). This data can be
% read in from a .curv file with read_curv or generated through
% plotUnderlay, which will allow you to edit the color of the
% sulci/gyri. Can be patch object (e.g., from plotUnderlay).
%
% overlayData -- this is the statistical data you want to patch on top of
% the underlay. It should have one column and as many rows as there are
% vertices (i.e., you need a data point for each vertex).
%
% Optional variables:
% 'hemisphere' -- this string tells the script which hemisphere the overlay
% data is to be patched on. It can either be 'lh' or 'rh'. Alternatively,
% you can pass along any filename as long as it contains either a 'lh' or a
% 'rh' string.
%
% 'figHandle' -- this is the handle to a figure you want
% to patch statistical data on top of (i.e., the underlay). If this is not
% provided, an underlay will be created using data in the 'underlay'
% structure.
%
% 'multiOverlay' -- if this string is 'on' then any prior overlays that are
% supplied with the 'overlay' argument will not be be deleted prior to
% patching of current data (i.e., the output of this script will not
% contain a handle by which you can alter prior overlays).
%
% 'threshold' -- this is a two digit threshold for statistical data. The
% digits represent the minimum and maximum values that will be removed from
% the data. All statistcal data falling in between these two values (i.e.,
% threshold(1):threshold(2)) will be removed from the overlay patch by
% deleting all patches that involve the thresholded vertices. If your data
% only contains positive or negative values, you can make either the
% minimum or maximum threshold 0. For example, if my map contains only
% positive correlations, a minimum threshold of 0 and a maximum threshold
% of 0.5 will remove all values between 0 and 0.5. Default is no threshold
% (i.e., [0 0]).
%
% 'limits' -- this two digit array sets the color axis limits (i.e., the
% maximum and minimum statistical data points asscoiated with the maximum
% and minimum colors in the colorMap you selected). Default is an empty
% variable that will be based on the min/max of your overlay data.
%
% 'opacity' -- this sets the opacity of he patch. Default is 1.
%
% 'colorMap' -- this string determines which colormap will be used. This can
% be set to any colorMap that is supported in matlab. It can also be set to
% 'custom'. Default is 'jet'.
%
% 'colorSampling' -- this string can either be set to 'even' or 'uneven'. In
% the case of 'even' the spacing of colors on your selected colorMap will
% be linear between the color axis limits. In the case of uneven, both
% positive and negative values in your overlay will get half the color
% spectrum in the colorMap you've selected. If my limits are from -20 to
% 100, then values between -20 to 0, and values between 0 to 100 will each
% get half the colors in colorMap. Default is 'uneven'.
%
% 'colorBins' -- this digit will set the number of different colors you want
% within the colorMap you have selected. Default is 1000.
%
% 'pMap' -- you can also pass along p-values for each of the data points you
% are overlaying (i.e., overlayData). This will set a secondary threshold
% based on p-values.
%
% 'pThreshold' -- All faces that have vertices with p-values above this digit
% will be removed from the overlay. Default = 0.05.
%
% 'lights' -- if this string is 'on' and you are generating a new figure,
% camera lights will be turned on. If 'off' they will not be added to the
% new figure.
%
% 'binarize' -- the number this is set to will make the whole map equal to
% this number
%
% 'clusterThreshold' -- this number is the minimum cluster size that will
% be patched
%
% 'outline' -- if 'true' only the outline of the data will be patched
%
% 'smoothSteps' -- number of times to smooth your data before patching
%
% 'smoothArea' -- area to smooth at once for every step (in number of
% closest vertices)
%
% 'smoothThreshold' -- 'above' will smooth all vertices that meet your
% thresholds. 'below' will smooth all vertices  we've removed (across the
% same thresholds).
%
% 'customColor' -- this is an n x 3 matrix of colors specifying a custom
% colormap
%
% 'binarizeClusters' -- if 'true' this will color each cluster a different
% color from your colormap
%
% 'clusterOrder' -- if set to 'random', the colors of clusters is randomly
% taken from your colormap. If 'descending' clusters will be organized by
% size (i.e., small clusters will be predominantly sample one side of your
% colormap and large clusters will be predominantly sample the other side
% of your colormap; this results in less color diversity).
%
% Complex call example:
% [overlay] = plotUnderlay(underlay, overlayData,'opacity',0.5)
%
% Alex Teghipco // 12/18/18 // alex.teghipco@uci.edu 
% Fixed accent selection, and bug where an overlay w/pos and neg values
% could not have a positive minimum limit

%% 1.Parse options and initialize variables
growVal = 'mean'; % edge or mean

% Setup default options as a structure
options = struct('hemisphere','left','figHandle',[],'overlay',[],'limits',[],'threshold',[0 0],'opacity',1,'colorMap','jet','colorSampling','even','colorBins',1000,'pMap',[],'pThresh',0.05,'lights','on','clusterThresh',0,'binarize',0,'inclZero','true','outline','false','outlineROIs','false','smoothSteps',0,'smoothArea',1,'smoothThreshold','above','customColor',[],'binarizeClusters','false','clusterOrder','random','transparencyLimits',[0 1],'transparencyThresholds',[],'transparencyData',[],'transparencyPThresh',[],'invertColor','false','invertOpacity','false','growROI',0,'smoothType','neighbors','plotSwitch','on');

% Read in the acceptable argument names
optionNames = fieldnames(options);

% Check the number of arguments passed
nArgs = length(varargin);
if round(nArgs/2)~=nArgs/2
    error('You are missing an argument name somewhere in your list of inputs')
end

% Start up a waitbar
h = waitbar(0,'Checking/setting up variables');
titleHandle = get(findobj(h,'Type','axes'),'Title');
set(titleHandle,'FontSize',8)

% Assign supplied values to each argument in input
for pair = reshape(varargin,2,[]) %pair is {propName;propValue}
    inpName = pair{1}; % make case insensitive by using lower() here but this can be buggy
    if any(strcmp(inpName,optionNames))
        options.(inpName) = pair{2};
    else
        error('%s is not a recognized parameter name',inpName)
    end
end

% search for invalid data and remove it
invIdx = find(isnan(overlayData));
if ~isempty(invIdx)
    overlayData(invIdx) = 0;
    warning('The data that were just plotted contained NaNs, which were converted to 0s')
end
invIdx = find(isinf(overlayData));
if ~isempty(invIdx)
    overlayData(invIdx) = 0;
    dataMax = max(overlayData);
    warning(['The data that were just plotted contained Infs, which were converted to ' num2str(dataMax)])
end

% If you did not provide transparency data, make that data overlay
if isempty(options.transparencyData) && ~isempty(options.transparencyLimits)
    options.transparencyData = overlayData;
    options.modulate = 'true';
    options.changeLim = 'true';
elseif ~isempty(options.transparencyData) && ~isempty(options.transparencyLimits)
    options.modulate = 'true';
end

% Create limits if they were not provided
if isempty(options.limits)
    options.limits = [floor(min(overlayData)) ceil(max(overlayData))];
end

% if only a min or max was provided look at distance of provided value from
% min and from max. If closer to min, then set the provided value to the
% minimum limit and make get max of data, otherwise set value to max limit
% and get min from data
if length(options.limits) == 1
    limitTmp = [floor(min(overlayData)) ceil(max(overlayData))];
    optDist = pdist2(options.limits,limitTmp');
    if optDist(1) < optDist(2)
        options.limits = [options.limits optDist(2)];
    else
        options.limits = [optDist(1) options.limits];
    end
end

% Figure out which hemisphere the overlay should be plotted on...because
% contains was updated to work with cells in later versions of matlab,
% implement a backup solution
try
    if contains(lower(options.hemisphere),lower({'left', 'lh'})) == 1
        options.hemisphere = 'left';
    elseif contains(lower(options.hemisphere),lower({'right', 'rh'})) == 1
        options.hemisphere = 'right';
    elseif (contains(lower(options.hemisphere),lower({'left', 'lh'})) == 1) && (contains(lower(options.hemisphere),lower({'right', 'rh'})) == 1)
        options.hemisphere = inputdlg('It looks like your file contains reference to both hemispheres...which hemisphere should I associate with this file? (type left or right)' ,'Could not find hemisphere');
    elseif (contains(lower(options.hemisphere),lower({'left', 'lh'})) == 0) && (contains(lower(options.hemisphere),lower({'right', 'rh'})) == 0)
        options.hemisphere = inputdlg('It looks like your file does not contain reference to either hemisphere...which hemisphere should I associate with this file? (type left or right)' ,'Could not find hemisphere');
    end
catch
    ss = {'left', 'lh', 'rh', 'right'};
    fun = @(s)~cellfun('isempty',strfind(lower({options.hemisphere}),s));
    out = cellfun(fun,ss,'UniformOutput',false);
    
    if sum(horzcat(out{:})) > 1
        if sum(horzcat(out{1:2})) == 2 || sum(horzcat(out{3:4})) == 2
            if sum(horzcat(out{1:2})) == 2
                options.hemisphere = 'left';
            elseif sum(horzcat(out{3:4})) == 2
                options.hemisphere = 'right';
            end
        else
            options.hemisphere = questdlg(['Which hemisphere should this file be overlayed on?'], 'Your file name does not clearly reference one hemisphere','left','right','left');
        end
    elseif sum(horzcat(out{1:2})) == 1
        options.hemisphere = 'left';
    elseif sum(horzcat(out{3:4})) == 1
        options.hemisphere = 'right';
    end
end
%% 2.Setup colormap
% Setup colormap
% If you did not provide an overlay structure, then map all of the provided data onto the colorMap you have
% selected
switch options.colorMap
    case 'jet'
        cMap = jet(options.colorBins);
    case 'parula'
        cMap = parula(options.colorBins);
    case 'hsv'
        cMap = hsv(options.colorBins);
    case 'hot'
        cMap = hot(options.colorBins);
    case 'cool'
        cMap = cool(options.colorBins);
    case 'spring'
        cMap = spring(options.colorBins);
    case 'summer'
        cMap = summer(options.colorBins);
    case 'autumn'
        cMap = autumn(options.colorBins);
    case 'winter'
        cMap = winter(options.colorBins);
    case 'gray'
        cMap = gray(options.colorBins);
    case 'bone'
        cMap = bone(options.colorBins);
    case 'copper'
        cMap = copper(options.colorBins);
    case 'pink'
        cMap = pink(options.colorBins);
    case 'lines'
        cMap = lines(options.colorBins);
    case 'colorcube'
        cMap = colorcube(options.colorBins);
    case 'prism'
        cMap = prism(options.colorBins);
    case 'Spectral'
        cMap=cbrewer('div', options.colorMap, options.colorBins);
    case 'RdYlBu'
        cMap = cbrewer('div', options.colorMap, options.colorBins);
    case 'RdGy'
        cMap = cbrewer('div', options.colorMap, options.colorBins);
    case 'RdBu'
        cMap = cbrewer('div', options.colorMap, options.colorBins);
    case 'PuOr'
        cMap = cbrewer('div', options.colorMap, options.colorBins);
    case 'PRGn'
        cMap = cbrewer('div', options.colorMap, options.colorBins);
    case 'PiYG'
        cMap = cbrewer('div', options.colorMap, options.colorBins);
    case 'BrBG'
        cMap = cbrewer('div', options.colorMap, options.colorBins);
    case 'YlOrRd'
        cMap = cbrewer('seq', options.colorMap, options.colorBins);
    case 'YlOrBr'
        cMap = cbrewer('seq', options.colorMap, options.colorBins);
    case 'YlGnBu'
        cMap = cbrewer('seq', options.colorMap, options.colorBins);
    case 'YlGn'
        cMap = cbrewer('seq', options.colorMap, options.colorBins);
    case 'Reds'
        cMap = cbrewer('seq', options.colorMap, options.colorBins);
    case 'RdPu'
        cMap = cbrewer('seq', options.colorMap, options.colorBins);
    case 'Purples'
        cMap = cbrewer('seq', options.colorMap, options.colorBins);
    case 'PuRd'
        cMap = cbrewer('seq', options.colorMap, options.colorBins);
    case 'PuBuGn'
        cMap = cbrewer('seq', options.colorMap, options.colorBins);
    case 'PuBu'
        cMap = cbrewer('seq', options.colorMap, options.colorBins);
    case 'OrRd'
        cMap = cbrewer('seq', options.colorMap, options.colorBins);
    case 'Oranges'
        cMap = cbrewer('seq', options.colorMap, options.colorBins);
    case 'Greys'
        cMap = cbrewer('seq', options.colorMap, options.colorBins);
    case 'Greens'
        cMap = cbrewer('seq', options.colorMap, options.colorBins);
    case 'GnBu'
        cMap = cbrewer('seq', options.colorMap, options.colorBins);
    case 'BuPu'
        cMap = cbrewer('seq', options.colorMap, options.colorBins);
    case 'BuGn'
        cMap = cbrewer('seq', options.colorMap, options.colorBins);
    case 'Blues'
        cMap = cbrewer('seq', options.colorMap, options.colorBins);
    case 'Set3'
        cMap = cbrewer('qual', options.colorMap, options.colorBins);
    case 'Set2'
        cMap = cbrewer('qual', options.colorMap, options.colorBins);
    case 'Set1'
        cMap = cbrewer('qual', options.colorMap, options.colorBins);
    case 'Pastel2'
        cMap = cbrewer('qual', options.colorMap, options.colorBins);
    case 'Pastel1'
        cMap = cbrewer('qual', options.colorMap, options.colorBins);
    case 'Paired'
        cMap = cbrewer('qual', options.colorMap, options.colorBins);
    case 'Dark2'
        cMap = cbrewer('qual', options.colorMap, options.colorBins);
    case 'Accent'
        cMap = cbrewer('qual', options.colorMap, options.colorBins);
    case 'inferno'
        cMap = inferno(options.colorBins);
    case 'plasma'
        cMap = plasma(options.colorBins);
    case 'vega10'
        cMap = vega10(options.colorBins);
    case 'vega20b'
        cMap = vega20b(options.colorBins);
    case 'vega20c'
        cMap = vega20c(options.colorBins);
    case 'viridis'
        cMap = viridis(options.colorBins);
    case 'thermal'
        cMap = cmocean(options.colorMap, options.colorBins);
    case 'haline'
        cMap = cmocean(options.colorMap, options.colorBins);
    case 'solar'
        cMap = cmocean(options.colorMap, options.colorBins);
    case 'ice'
        cMap = cmocean(options.colorMap, options.colorBins);
    case 'oxy'
        cMap = cmocean(options.colorMap, options.colorBins);
    case 'deep'
        cMap = cmocean(options.colorMap, options.colorBins);
    case 'dense'
        cMap = cmocean(options.colorMap, options.colorBins);
    case 'algae'
        cMap = cmocean(options.colorMap, options.colorBins);
    case 'matter'
        cMap = cmocean(options.colorMap, options.colorBins);
    case 'turbid'
        cMap = cmocean(options.colorMap, options.colorBins);
    case 'speed'
        cMap = cmocean(options.colorMap, options.colorBins);
    case 'amp'
        cMap = cmocean(options.colorMap, options.colorBins);
    case 'tempo'
        cMap = cmocean(options.colorMap, options.colorBins);
    case 'balance'
        cMap = cmocean(options.colorMap, options.colorBins);
    case 'delta'
        cMap = cmocean(options.colorMap, options.colorBins);
    case 'curl'
        cMap = cmocean(options.colorMap, options.colorBins);
    case 'phase'
        cMap = cmocean(options.colorMap, options.colorBins);
    case 'perceptually distinct'
        cMap = distinguishable_colors(options.colorBins);
end

% load in custom map if it is being passed
if ~isempty(options.Odata)
    tmpMap = options.Odata;
    if size(tmpMap,1) < options.colorBins % only need to interpolate colors if there are more bins of data than there are colors
        cMap = customColorMapInterp(tmpMap,options.colorBins);
    else
        cMap = tmpMap;
    end
    % if # bins requested does not match provided colormap, downsample
    % or upsample colormap image
    if size(cMap,1) ~= options.colorBins
        cMapRe = ones([size(cMap,1),2,3]);
        cMapRe(:,1,:) = cMap;
        cMapRe(:,2,:) = cMap;
        
        F = griddedInterpolant(double(cMapRe));
        [sx,sy,sz] = size(cMapRe);
        imRat = size(cMapRe,1)/options.colorBins;
        
        xq = (1:imRat:sx)';
        yq = (1:imRat:sy)';
        zq = (1:sz)';
        vq = (F({xq,yq,zq}));
        
        cMap = squeeze(vq);
    end
end

% if you want to invert colors
switch options.invertColor
    case 'true'
        cMap = flipud(cMap);
end

%% 3. Apply thresholds
% Threshold data and remove all faces that include thresholded data
waitbar(.3,h,['Removing data between ' num2str(options.threshold(2)) ' and ' num2str(options.threshold(1))]);
% Copy faces since we will be removing them as we go through the thresholds

faces = underlay.(options.hemisphere).Faces;
vertList = (1:length(underlay.(options.hemisphere).Vertices))';
allThreshVert = [];

% prep thresholded data
switch options.inclZero
    case 'false'
        threshVert = find(overlayData >= options.threshold(1) & overlayData <= options.threshold(2));
    case 'true'
        threshVert = find(overlayData > options.threshold(1) & overlayData < options.threshold(2));
end
% we identified all vertices that do not pass the threshold. Now lets get
% the vertices that do pass threshold
[C,ia] = setdiff(vertList,threshVert);
threshVert = vertList(ia);
allThreshVert = vertcat(allThreshVert,threshVert);

% apply second p-value threshold that overwrites the value-based threshold
if isempty(options.pMap) ~= 1
    waitbar(.35,h,['Removing data that is p > ' num2str(options.pThresh)]);
    pThreshVert = find(options.pMap >= options.pThresh);
    [C, ia] = setdiff(allThreshVert,pThreshVert);
    allThreshVert = allThreshVert(ia);
    threshVert = threshVert(ia);
end

% now prep opacity data and get all vertices that fall under this threshold
if (~isempty(options.transparencyThresholds) || ~isempty(options.transparencyPThresh)) && ~isempty(options.transparencyLimits)
    if isempty(options.transparencyPThresh)
        opacityVert = find(options.transparencyData >= options.transparencyThresholds(1) & options.transparencyData <= options.transparencyThresholds(2));
        [C,ia] = setdiff(vertList,opacityVert);
        opacityVert = vertList(ia);
        allThreshVert = vertcat(allThreshVert,opacityVert);
    elseif ~isempty(options.pMap) && ~isempty(options.transparencyPThresh)
        opacityVert = find(options.pMap < options.transparencyPThresh);
        allThreshVert = vertcat(allThreshVert,opacityVert);
    end
end

% find unique vertices that survive all threshold
allThreshVert = unique(allThreshVert);
% remove everything from overlayData that does not survive
[C,ia] = setdiff(vertList,allThreshVert);
overlayData(vertList(ia)) = 0;

% trigger clusterization in case you want to grow or shrink your ROI, or if
% you are going to outline border of your ROI
if (options.growROI ~= 0 || strcmp(options.smoothThreshold,'border')) && (~strcmp(options.outline,'true') && ~strcmp(options.outlineROIs,'true'))
    if options.clusterThresh == 0
        options.clusterThresh = 0.05;
    end
    idx = find(overlayData == 0);% remove zeros in case it's an ROI IE repeat inclZero = 'false'
    [C,ia,ib] = intersect(idx,allThreshVert);
    allThreshVert(ib) = [];
end

% get min and max values based on the effective p-value threshold
% (excluding opacity vertices)
overlayDataPosIdx = find(overlayData(threshVert) > 0);
overlayDataNegIdx = find(overlayData(threshVert) < 0);
primaryThreshPos = min(overlayData(threshVert(overlayDataPosIdx)));
primaryThreshNeg = max(overlayData(threshVert(overlayDataNegIdx)));
minThreshPos = primaryThreshPos;
minThreshNeg = primaryThreshNeg;

% apply cluster thresholds to vertices that survive threshold
if strcmp(options.outline,'true') || strcmp(options.binarizeClusters,'true') || options.clusterThresh > 0
    waitbar(.4,h,['Removing clusters less than ' num2str(options.clusterThresh) ' in size. This may take some time if you have large clusters.' ]);
    
    % get clusters
    [dataClust, clusterLen] = getClusters(allThreshVert, faces);
    
    % remove clusters with cluster size less than threshold
    clustIdx = find(clusterLen < options.clusterThresh);
    dataClust(clustIdx) = [];
    
    % save maximum cluster size to options
    options.clusterLimit = max(clusterLen);
    options.clusters = dataClust;
elseif strcmp(options.outlineROIs,'true')
    inUn = unique(overlayData(allThreshVert));
    id = find(inUn == 0);
    inUn(id) = [];
    for roii = 1:length(inUn)
        dataClust{roii} = find(overlayData == inUn(roii));
    end
    clusterLen = cellfun('length',dataClust);
    %options.clusterLimit = max(clusterLen);
    %options.clusters = dataClust;
end
    
% now lets turn clusters into boundaries if you chose to do that
if strcmp(options.outlineROIs,'true') || strcmp(options.outline,'true')
        waitbar(.5,h,['Creating borders around clusters...this will take time']);
        % if we do want to make an outline, do so for each cluster
        dataClust_all = dataClust;
        dataClust = getClusterBoundary(dataClust, faces);
        
        % threshVert that maps onto empty overlayData needs to be removed
        allThreshVert = vertcat(dataClust{:});
        idx = find(overlayData(allThreshVert) == 0);
        allThreshVert(idx) = [];
        
        % we want to make the border an intensity that reflects the mean
        % intensity of the cluster. This way one side of a cluster can't be
        % substantially transparent than some other side. By using the mean we
        % preserve some information about clusters.
        overlayData2 = zeros(size(overlayData));
        for clusteri = 1:length(dataClust)
            switch growVal
                case 'mean'
                    oVals{clusteri} = mean(overlayData(dataClust{clusteri}));
                case 'edge'
                    oVals{clusteri} = unique(overlayData(dataClust_all{clusteri}));
            end
            
            if oVals{clusteri} <= 0 && oVals{clusteri} >= minThreshNeg
                oVals{clusteri} = minThreshNeg-0.0001;
            end
            if oVals{clusteri} >= 0 && oVals{clusteri} <= minThreshPos
                oVals{clusteri} = minThreshPos+0.00001;
            end
            overlayData2(dataClust{clusteri}) = oVals{clusteri}; % this means the border of your ROI will now be filled with mean intensity of its cluster
        end
        overlayData = overlayData2;
end
    
if strcmp(options.outlineROIs,'true') || strcmp(options.outline,'true') || strcmp(options.binarizeClusters,'true') || options.clusterThresh > 0
    allThreshVert = vertcat(dataClust{:});
end

% now smooth the data if you asked for some smoothing
if options.smoothArea > 0 && options.smoothSteps > 0
    
    waitbar(.6,h,'Smoothing data...this will take time');
    % make copy of vertices from underlay (we will use these)
    % and generate index for each vertex
    tmpVert = underlay.(options.hemisphere).Vertices;
    
    % get vertices below and above our thresholds
    aboveThreshVert = allThreshVert;
    
    % identify which vertices to smooth based on your argument
    switch options.smoothThreshold
        case 'above'
            % above means we will be smoothing only vertices that meet all
            % of the various thresholds we've gone through so far.
            % This means the border of the thresholded area will contract.
            % You will be smoothing vertices with some value greater than
            % zero, with thresholded values that are all zeros.
            toSmooth = aboveThreshVert;
            
        case 'border'
            % below means we will be smoothing vertices that do not meet
            % all of the various thresholds.This means the border of the
            % thresholded area will expand. You will be smoothing voxels on
            % the edge of thresholded values, which are all zeros. This
            waitbar(.7,h,'Still smoothing data...getting border so this will take more time');
            % will drive the mean of these edge voxels down.
            dataClust = getClusterBoundary(dataClust, faces);
            toSmooth = vertcat(dataClust{:});
            idx = find(overlayData(toSmooth) == 0);
            toSmooth(idx) = [];
    end
    
    %get nearest X vertices to each vertex to smooth (user selected area X)
    [~,neighborhood] = pdist2(tmpVert,tmpVert(toSmooth,:),'seuclidean','Smallest',options.smoothArea);
    neighborhoodUnique = unique(neighborhood);
    [C,ia] = setdiff(neighborhoodUnique,allThreshVert);
    allThreshVert = vertcat(allThreshVert,neighborhoodUnique(ia));
    
    switch options.smoothType
        case 'neighbors'
            % now smooth
            for smoothi = 1:options.smoothSteps
                overlayData(toSmooth) = mean(overlayData(neighborhood),1);
            end
            
        case 'neighborhood'
            for smoothi = 1:options.smoothSteps
                for verti = 1:length(neighborhood) %neighborhood for one vertex
                    oVal = mean(overlayData(neighborhood(:,verti))); % mean of neighborhood for vertex
                    overlayData(neighborhood(:,verti)) = oVal;
                end
            end
    end
end

% If you asked to binarize, lets do that now
if options.binarize ~= 0
    overlayData(allThreshVert) = options.binarize;
    [C, ia] = setdiff(vertList,allThreshVert);
    overlayData(ia) =  0;
end

% This will take all clusters and binarize them
switch options.binarizeClusters
    case 'true'
        % one problem is that smaller clusters will predominantly map onto
        % one end of the spectrum unless they are shuffled so lets do that
        % now
        switch options.clusterOrder
            case 'random'
                randi = randperm(length(dataClust));
                dataClust = dataClust(randi);
        end
        
        for clusteri = 1:length(dataClust)
            overlayData(dataClust{clusteri}) = clusteri;
        end
        options.limits = [min(overlayData) max(overlayData)];
        allThreshVert = vertcat(dataClust{:});
        [C, ia] = setdiff(vertList,allThreshVert);
        overlayData(ia) = 0;
        
end

% after getting cluster sizes, remove all vertices that don't survive
[C, ia, ib] = intersect(allThreshVert,threshVert);
threshVert = threshVert(ib);

% get min and max values based on the effective p-value threshold
% (excluding opacity vertices)
overlayDataPosIdx = find(overlayData(threshVert) > 0);
overlayDataNegIdx = find(overlayData(threshVert) < 0);
primaryThreshPos = min(overlayData(threshVert(overlayDataPosIdx)));
primaryThreshNeg = max(overlayData(threshVert(overlayDataNegIdx)));
minThreshPos = primaryThreshPos;
minThreshNeg = primaryThreshNeg;

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

if (~isempty(options.transparencyThresholds)|| ~isempty(options.transparencyPThresh)) && ~isempty(options.transparencyLimits)
    [C, ia, ib] = intersect(allThreshVert,opacityVert);
    opacityVert = opacityVert(ib);
    
    % get secondary opacity threshold
    overlayDataPosIdx = find(overlayData(opacityVert) > 0);
    overlayDataNegIdx = find(overlayData(opacityVert) < 0);
    secondaryThreshPos = min(overlayData(opacityVert(overlayDataPosIdx)));
    secondaryThreshNeg = max(overlayData(opacityVert(overlayDataNegIdx)));
    
    minThreshPos = min([minThreshPos secondaryThreshPos]);
    minThreshNeg = max([minThreshNeg secondaryThreshNeg]);
end

% if you want to grow your ROI, lets either get outline, or redo this process (this
% will be monentary if you've done it already)
if options.growROI ~= 0
    % do not get boundary again if you have already done it
    if ~strcmp(options.outline,'true') && ~strcmp(options.outlineROIs,'true')
        
        growVert = getClusterBoundary(dataClust, faces);
%         overlayData2 = zeros(size(overlayData));
        for clusteri = 1:length(growVert)
            switch growVal
                case 'mean'
                    oVals{clusteri} = mean(overlayData(dataClust{clusteri}));
                case 'edge'
                    oVals{clusteri} = unique(overlayData(dataClust_all{clusteri}));
            end
            
            if oVals{clusteri} <= 0 && oVals{clusteri} >= minThreshNeg
                oVals{clusteri} = minThreshNeg-0.0001;
            end
            if oVals{clusteri} >= 0 && oVals{clusteri} <= minThreshPos
                oVals{clusteri} = minThreshPos+0.00001;
            end
%             overlayData2(growVert{clusteri}) = oVals{clusteri}; % this means the border of your ROI will now be filled with mean intensity of its cluster
        end
%         overlayData = overlayData2;
    else
        growVert = dataClust;
    end
    growSteps = abs(options.growROI);
    growVertTracker = growVert;
    
    while growSteps > 0
        %overlayData2 = zeros(size(overlayData));
        for clusteri = 1:length(growVert)
            if options.growROI > 0
                %oVal = oVals{clusteri};
                waitbar(.8,h,['Growing clusters...on step ' num2str(growSteps) '. This may take some time if you have large clusters.' ]);
                % get everything that borders the cluster
                vertX = ismember(faces(:,1),growVert{clusteri});
                vertY = ismember(faces(:,2),growVert{clusteri});
                vertZ = ismember(faces(:,3),growVert{clusteri});
                vertXYZ = vertX+vertY+vertZ;
                vertXYZIdx = find(vertXYZ ~= 0);
                
                % edits
                growVertFaces = faces(vertXYZIdx,:);
                vertX2 = ismember(growVertFaces(:,1),allThreshVert);
                vertY2 = ismember(growVertFaces(:,2),allThreshVert);
                vertZ2 = ismember(growVertFaces(:,3),allThreshVert);
                vertXYZ2 = vertX2+vertY2+vertZ2;
                vertXYZ2Idx = find(vertXYZ2 >= 1);
                
                growVert{clusteri} = vertcat(growVert{clusteri},unique(faces(vertXYZIdx(vertXYZ2Idx),:)));
                growVert{clusteri} = unique(growVert{clusteri});
                [C,ia] = setdiff(growVert{clusteri},allThreshVert);
                growVert{clusteri} = growVert{clusteri}(ia);
                
                if ~strcmp(options.outline,'true') && ~strcmp(options.outlineROIs,'true')
                    overlayData(growVert{clusteri}) = oVals{clusteri};
                end
                
                growVertTracker{clusteri} = vertcat(growVertTracker{clusteri},growVert{clusteri});
                allThreshVert = vertcat(allThreshVert, growVert{clusteri});
                
                %vertInside = vertcat(vertInside, growVert{clusteri});
                %overlayData2(growVert{clusteri}) = oVal;
                
            else
                waitbar(.8,h,['Shrinking clusters...on step ' num2str(growSteps) '. This may take some time if you have large clusters.' ]);
                [C,ia,ib] = intersect(growVert{clusteri},allThreshVert);
                overlayData(allThreshVert(ib)) = 0;
                allThreshVert(ib) = [];
                
                % get everything that borders the cluster
                vertX = ismember(faces(:,1),growVert{clusteri}(ia));
                vertY = ismember(faces(:,2),growVert{clusteri}(ia));
                vertZ = ismember(faces(:,3),growVert{clusteri}(ia));
                vertXYZ = vertX+vertY+vertZ;
                vertXYZIdx = find(vertXYZ ~= 0);
                growVert{clusteri} = unique(faces(vertXYZIdx,:));
            end
            
        end
        %overlayData = overlayData2;
        growSteps = growSteps - 1;
    end
    if strcmp(options.outline,'true') || strcmp(options.outlineROIs,'true')
        overlayData2 = zeros(size(overlayData));
        for clusteri = 1:length(growVertTracker)
            overlayData2(growVertTracker{clusteri}) = oVals{clusteri};
        end
        overlayData = overlayData2;
    end
end

switch options.colorSampling
    % this is the default option. All values between limits will get a
    % color from your colormap.
    case 'even'
        cData = linspace(options.limits(1),options.limits(2),options.colorBins);
        % this will split your colormap into negative and positive values.
        % Negative stuff gets half the colormap. positive stuff gets the other
        % half.
        
    case 'center on zero'
        cMapPos = cMap((1:floor(length(cMap)/2)),:);
        cMapNeg = cMap(floor((length(cMap))/2):end,:);
        cMap = vertcat(cMapPos,cMapNeg);
        cDataNeg = linspace(options.limits(1),0,(options.colorBins/2)+1);
        cDataPos = linspace(0,options.limits(2),options.colorBins/2);
        cData = horzcat(cDataNeg,cDataPos);
        %cData(round((length(cMap)/2)+1)) = [];
        cData(round((length(cData)/2)+1)) = [];
        cMap(floor((length(cMap)/2)+1),:) = [];
        
        options.ticks = linspace(options.limits(1),options.limits(2),11);
        options.tickLabels = [linspace(options.limits(1),0,6) linspace(0,options.limits(2),6)];
        idx = find(options.tickLabels == 0);
        options.tickLabels(idx(end)) = [];
        
    case 'center on threshold'
        % find out if you have both positive and negative values
        posTest = find(options.limits > 0);
        negTest = find(options.limits < 0);
        
        if (isempty(posTest) && ~isempty(negTest)) || (~isempty(posTest) && isempty(negTest))
            if isempty(posTest) && ~isempty(negTest)
                cData = linspace(minThreshPos,options.limits(2),options.colorBins);
            end
            if ~isempty(posTest) && isempty(negTest)
                cData = linspace(options.limits(1),minThreshNeg,options.colorBins);
            end
        else
            cMapPos = cMap((1:floor(length(cMap)/2)),:);
            cMapNeg = cMap(floor((length(cMap))/2):end,:);
            cMap = vertcat(cMapPos,cMapNeg);
            cDataNeg = linspace(options.limits(1),minThreshNeg,(options.colorBins/2)+1);
            cDataPos = linspace(minThreshPos,options.limits(2),options.colorBins/2);
            cData = horzcat(cDataNeg,cDataPos);
            cData(round((length(cMap)/2)+1)) = [];
            cMap(floor((length(cMap)/2)+1),:) = [];
            
            options.ticks = linspace(options.limits(1),options.limits(2),12);
            options.ticks(6) = [];
            options.ticks(6) = [];
            options.tickLabels = [linspace(options.limits(1),minThreshNeg,6) linspace(minThreshPos,options.limits(2),6)];
            options.tickLabels(6) = [];
            options.tickLabels(6) = [];
            
        end
end

% update overlay data with any thresholds before matching it to colormap
[C,ia] = setdiff(vertList,allThreshVert);
overlayData(ia) = 0;

overlayDataPos = find(overlayData >= 0);
overlayDataNeg = find(overlayData < 0);
cDataPos = find(cData >= 0);
cDataNeg = find(cData < 0);
cDataNeg = fliplr(cDataNeg);

cDataMatchPos = abs(bsxfun(@gt,overlayData(overlayDataPos),cData(cDataPos)));
cDataMatchNeg = abs(bsxfun(@gt,abs(overlayData(overlayDataNeg)),abs(cData(cDataNeg))));

cDataIdxPos = sum( abs( cumprod( cDataMatchPos, 2 ) ) > 0, 2 ) + 1;
cDataIdxNeg = sum( abs( cumprod( cDataMatchNeg, 2 ) ) > 0, 2 ) + 1;

cDataIdx = zeros([size(overlayData,1),1]);

% it is possible that value is above the limits. In this case, because
% indexing starts at 1, the sum of bsxfun may be outside the range of data
% specified by the limits (i.e., by exactly one data bin because it fits
% the criteria for every bin). To avoid this, check for values outside
% limit and fix them to the max value on the colorbar.
outsidePosLimit = find(cDataIdxPos == (length(cDataPos) + 1));
if ~isempty(outsidePosLimit)
    cDataIdxPos(outsidePosLimit) = length(cDataPos);
end
cDataIdx(overlayDataPos) = cDataPos(cDataIdxPos);

outsideNegLimit = find(cDataIdxNeg == (length(cDataNeg) + 1));
if ~isempty(outsideNegLimit)
   cDataIdxNeg(outsideNegLimit) = length(cDataNeg); 
end
if isempty(cDataNeg) && ~isempty(cDataIdxNeg)
    cDataIdxNeg = cDataIdxNeg+1;
    cDataIdx(overlayDataNeg) = cDataPos(cDataIdxNeg);
else
    cDataIdx(overlayDataNeg) = cDataNeg(cDataIdxNeg);
end

ocData = cMap(cDataIdx,:);

% setup opacity bar
opacityColorbar = ones([size(cData,2), 1])*62;
opacityThreshIdx = find(cData > minThreshNeg & cData < minThreshPos);
opacityColorbar(opacityThreshIdx) = 0;

if (~isempty(options.transparencyThresholds) || ~isempty(options.transparencyPThresh)) && ~isempty(options.transparencyLimits)
    if options.transparencyThresholds(1) > options.threshold(1)
        transIdxNeg = find(cData > options.threshold(1) & cData < options.transparencyThresholds(1));
        transNeg = linspace(options.transparencyLimits(1),options.transparencyLimits(2),length(transIdxNeg));
        transNeg = fliplr(transNeg);
    else
        transIdxNeg = find(cData < options.transparencyThresholds(1));
        transNeg = linspace(options.transparencyLimits(1),options.transparencyLimits(2),length(transIdxNeg));
    end
    
    if options.transparencyThresholds(2) < options.threshold(2)
        transIdxPos = find(cData > options.transparencyThresholds(2) & cData < options.threshold(2));
        transPos = linspace(options.transparencyLimits(1),options.transparencyLimits(2),length(transIdxPos));
    else
        transIdxPos = find(cData > options.transparencyThresholds(2));
        transPos = linspace(options.transparencyLimits(1),options.transparencyLimits(2),length(transIdxPos));
        transPos = fliplr(transPos);
    end
    
    switch options.invertOpacity
        case 'true'
            transPos = fliplr(transPos);
            transNeg = fliplr(transNeg);
    end
    opacityColorbar(transIdxPos) = transPos * 62;
    opacityColorbar(transIdxNeg) = transNeg * 62;
end

% if we are just modulating the data by some other map, then just use that
% as the opacity, otherwise map the colorbar onto data
if isfield(options,'modulate')
    if isfield(options,'changeLim')
        xLim = options.limits(1);
        yLim = options.limits(2);
    else
        %xLim = min(options.transparencyData);
        %yLim = max(options.transparencyData);
        xLim = 0;
        yLim = 0.7;
    end
  
     if (min(options.transparencyData) < 0 && max(options.transparencyData) > 0) || (min(options.transparencyData) > 0 && max(options.transparencyData) < 0)
        dataModSpace1 = linspace(xLim,0,6);
        dataModSpace1(end) = [];
        dataModSpace2 = linspace(0,yLim,6);
        dataModSpace2(1) = [];
        dataModSpace = horzcat(dataModSpace1,dataModSpace2);
        dataModSpace1 = abs(dataModSpace1);
        rangePos = max(dataModSpace2) - 0;%min(dataModSpace2);
        rangeNeg = max(dataModSpace1) - 0;%min(dataModSpace1);
        idxPos = find(options.transparencyData > 0);
        idxNeg = find(options.transparencyData < 0);
        options.transparencyData(idxPos) = (options.transparencyData(idxPos) - 0) / rangePos;
        options.transparencyData(idxNeg) = abs(options.transparencyData(idxNeg));
        options.transparencyData(idxNeg) = (options.transparencyData(idxNeg) -0) / rangeNeg;
        
        % user-specified limits can be lower than actual range so check for
        % values greater than 1 (ie outside rangePos / rangeNeg) and
        % set them to max
        idx1 = find(options.transparencyData > 1);
        options.transparencyData(idx1) = 1;
        
    else
        dataModSpace = linspace(xLim,yLim,10);
        range = max(options.transparencyData) - min(options.transparencyData);
        options.transparencyData = (options.transparencyData - min(options.transparencyData)) / range;
    end
    
     switch options.invertOpacity
        case 'true'
           options.transparencyData = (options.transparencyData)*-1;
           options.transparencyData = options.transparencyData + 1;
     end
    
    % scale between gradient values
    range2 = options.transparencyLimits(2) - options.transparencyLimits(1);
    options.transparencyData = (options.transparencyData * range2) + options.transparencyLimits(1);
    options.transparencyData = options.transparencyData * 62;
    testInfIdx = find(options.transparencyData == Inf);
    options.transparencyData(testInfIdx) = max(options.transparencyData(~isinf(options.transparencyData)));
    
    if exist('dataModSpace1','var')
        dataModSpaceScaled1 = linspace(min(options.transparencyData(idxNeg)),max(options.transparencyData(idxNeg)),10);
        dataModSpaceScaled2 = linspace(min(options.transparencyData(idxPos)),max(options.transparencyData(idxPos)),10);
    else
        dataModSpaceScaled = linspace(min(options.transparencyData),max(options.transparencyData),10);
    end
    
    % fix colorbar now
    opacityColorbarBackup = opacityColorbar;
    meanT = [];
    for i2 = 1:length(cData)
        idx = find(cDataIdx == i2); % vertices that map onto colormap bin i
        meanT(i2,1) = mean(options.transparencyData(idx));
    end   
    
    opacityColorbar = meanT;
    
    A = reshape(cMap,[size(cMap,1),1,3]);
    B = repmat(A,1,10,1);

    cSpaceFig = figure;
    cSpaceImg = image(flipud(B));
    truesize(cSpaceFig,[1000 1000])

    alpha = repmat([linspace(options.transparencyLimits(1),options.transparencyLimits(2),10)],size(cMap,1),1,1);
    
    set(cSpaceImg, 'AlphaData', alpha);
    cSpaceImg.AlphaDataMapping = 'none';
    titlePos = title('Transparency modulated colorbar','FontSize',22);
    axis on
    cSpaceFig.CurrentAxes.TickLength = [0 0];
    cSpaceFig.CurrentAxes.XTick = 1:10;
    cSpaceFig.CurrentAxes.XTickLabelRotation = 60;    
    
    if length(cData) < 100
        cSpaceFig.CurrentAxes.YTick = 1:length(flipud(cData));
        cSpaceFig.CurrentAxes.YTickLabel = num2cell(flipud(cData));
    else
        cSpaceFig.CurrentAxes.YTick = 0:20:length(flipud(cData));
        cSpaceFig.CurrentAxes.YTickLabel = num2cell(fliplr([min(cData) cData(cSpaceFig.CurrentAxes.YTick(2:end))]));
    end
    ylabel('exact data bins from primary overlay (max of 100 displayed ticks)')

    % now draw boxes around the values for current cluster
    if exist('dataModSpace1','var')
        for i2 = 1:length(opacityColorbar)
            if i2 < (length(opacityColorbar)/2)+1
                if isnan(opacityColorbar(i2))
                    tMarks(i2,1) = 1;
                    isnanList(i2,1) = 1;
                else
                    idx = find(dataModSpaceScaled1 >= opacityColorbar(i2));
                    tMarks(i2,1) = idx(1);
                    isnanList(i2,1) = 0;
                end
            elseif i2 > (length(opacityColorbar)/2)+1
                if isnan(opacityColorbar(i2))
                    tMarks(i2,1) = 1;
                    isnanList(i2,1) = 1;
                else
                    idx = find(dataModSpaceScaled2 >= opacityColorbar(i2));
                    tMarks(i2,1) = idx(1);
                    isnanList(i2,1) = 0;
                end
            
            elseif i2 == (length(opacityColorbar)/2)+1
                tMarks(i2,1) = 0;
            end
        end
    else
        for i2 = 1:length(opacityColorbar)
            if isnan(opacityColorbar(i2))
                tMarks(i2,1) = 1;
                isnanList(i2,1) = 1;
            else
                idx = find(dataModSpaceScaled >= opacityColorbar(i2));
                if isempty(idx) % occassionally matlab returns bizzare bug here. identical items are not being treated as equal so the operator in the idx fails. Rounding fixes it. 
                    idx = find(round(dataModSpaceScaled) >= round(opacityColorbar(i2)));
                end
                tMarks(i2,1) = idx(1);
                isnanList(i2,1) = 0;
            end
        end
    end
    isnanList = logical(isnanList);
    tMarks = tMarks(~isnanList);
    tMarks = flipud(tMarks);
    isnanList = flipud(isnanList);
    % for real data 
    y = 1:length(cData);
    y = y(~isnanList);
    
    hold on
    p = plot((tMarks),y,'*k');
    set(gcf,'color','w');
    %hold off
    
    if exist('dataModSpace1','var')
        dataModSpace2 = linspace(0,abs(min(dataModSpace)),10);
        cSpaceFig.CurrentAxes.XTickLabel = num2cell(dataModSpace2*-1);
        xlabel('transparency bins for negative values')
        ax1 = gca; % current axes
        ax1_pos = ax1.Position; % position of first axes
        ax2 = axes('Position',ax1_pos,...
            'XAxisLocation','top',...
            'Color','none');
        ax2.XTick = linspace(0,1,10);
        dataModSpace2 = linspace(0,abs(max(dataModSpace)),10);
        ax2.XTickLabel = num2cell(dataModSpace2);
        ax2.XTickLabelRotation = 60;
        ax2.TickLength = [0 0];
        th = get(titlePos , 'position');
        th(2) = th(2) - 90;
        set( titlePos , 'position' , th);
        ax2.XLabel.String = 'transparency bins for positive values';
        ax2.YTickLabel = {};
    else
        cSpaceFig.CurrentAxes.XTickLabel = num2cell(dataModSpace);
        xlabel('approximate (average) value of data used to modulate transparency for vertices falling within each data bin from overlay')
    end
    FaceVertexAlphaData = options.transparencyData;
else
    FaceVertexAlphaData = opacityColorbar(cDataIdx);
end

%% 4. Patch data
% if you provided a figure to patch, use that, otherwise lets rebuild the
% underlay in a new figure
waitbar(.95,h,'Patching overlay');
if isempty(options.figHandle) && strcmp(options.plotSwitch,'on')
    options.figHandle = figure;
    for hemii = 1:length(fieldnames(underlay))
        hemiNames = fieldnames(underlay);
        underlay.(hemiNames{hemii}) = patch('Faces',hemiNames{hemii}.Faces,'Vertices',hemiNames{hemii}.Vertices,'FaceVertexCData',hemiNames{hemii}.FaceVertexCData,'facealpha',1,'CDataMapping','direct','facecolor','interp','edgecolor','none');
    end
    axis off vis3d equal tight;
    material dull
end

% if doing multioverlay interpolation of face alpha will be wonky unless we
% remove the faces we won't be plotting (i.e., lots of gross clipping)
% if strcmp(options.multiOverlay,'on') || strcmp(options.outline,'true')
% for multioverlay we need to manually specify which faces to plot
% if strcmp(options.multiOverlay,'on')

% if you don't do this, interpolation will assign the single outmost vertex
% at every cluster (i.e. border between 0 and something other than zero)
% the color data closest to the min. If you have even spacing this will
% produce a weird gradient

[C,ia] = setdiff(vertList,allThreshVert);
removeVert = vertList(ia); % all faces that don't have these verts
removeVertX = ismember(faces(:,1),removeVert);
removeVertY = ismember(faces(:,2),removeVert);
removeVertZ = ismember(faces(:,3),removeVert);
removeVertXYZ = removeVertX+removeVertY+removeVertZ;
removeVertXYZIdx = find(removeVertXYZ > 0);
faces(removeVertXYZIdx,:) = [];


% if you toggle including zeros, some circumstances will still leave you
% with visible zeros (though not the data does get updates), so manually
% trigger exclusion of zeros and remove opacity for vertices with 0s for
% data.
if options.binarize ~= 0 || strcmp(options.binarizeClusters, 'true') || strcmp(options.outline,'true') || strcmp(options.colorSampling,'center on threshold') || options.binarize ~= 0 || (options.smoothArea > 0 && options.smoothSteps > 0) || options.growROI ~= 0
    
    options.inclZero = 'false';
end
switch options.inclZero
    %case 'false'
    case 'true'
        idx = find(overlayData == 0);
        FaceVertexAlphaData(idx) = 0;
        [minc,minv] = min(abs(cData));
        
        ocData(idx,1) = 0;
        ocData(idx,2) = 0;
        ocData(idx,3) = 0;
end

% get current figure
switch options.plotSwitch
    case 'on'
        figure(options.figHandle)

        overlay = patch('Faces',faces,'Vertices',underlay.(options.hemisphere).Vertices,'FaceVertexCData',ocData,'FaceVertexAlphaData',(FaceVertexAlphaData)*options.opacity, 'AlphaDataMapping' ,'direct','CDataMapping','direct','facecolor','interp','edgecolor','none');
        
        if ~isfield(options,'modulate')
            overlay.FaceAlpha = options.opacity;
        else
            overlay.FaceAlpha = 'interp';
        end
        
        colormap(cMap);
        caxis(options.limits)
        
        % fix a few parameters for visualization
        waitbar(1,h,'Saving overlay and underlay');
        
        %overlay.SpecularStrength = 0;
        if strcmp(options.hemisphere,'left')
            view([-90 0]);
        elseif strcmp(options.hemisphere,'right')
            view([90 0]);
        end
        
        % save old overlay lighting properties
        if exist('overProps','var')
            overlay.SpecularStrength = overProps.specStren;
            overlay.SpecularExponent = overProps.spexExp;
            overlay.SpecularColorReflectance = overProps.specRef;
            overlay.DiffuseStrength = overProps.diff;
            overlay.AmbientStrength = overProps.amb;
        end
end
% setup outputs
% update overlayData just in case you haven't already
[C,ia] = setdiff(vertList,allThreshVert);
overlayData(ia) = 0;

options.verts = allThreshVert;
options.overlayData = overlayData;
options.transparencyData = (opacityColorbar) * options.opacity;
options.faces = faces;
options.vertCoords = underlay.(options.hemisphere).Vertices;

varargout{1} = underlay;
% The following is a hacky fix for 2nd output. Just switch options with
% overlay and remove options.figHandle (then update brainSurfer)
if exist('overlay','var')
    varargout{2} = overlay;
else
    varargout{2} = [];
end
varargout{3} = options.figHandle;
varargout{4} = options;
close(h)

