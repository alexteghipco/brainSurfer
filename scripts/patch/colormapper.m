function [cMap,cData,cbData,ticks,tickLabels] = colormapper(data,varargin)
% This function generates a colormap using various specifications.
%
% Mandatory arguments------------------------------------------------------ 
%
% data: n x 1 data to be mapped onto 
%
% Output------------------------------------------------------------------- 
%
% cMap: b x 3 color associated with each bin
%
% cData: n x 3 color associated with each data point.1
%
% Optional (options.threshold) arguments-------------------------------------------
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
%       colormap can also be an l x 3 matrix of colors specifying a custom
%       colormap
%
% 'colorSpacing': determines how colors are spaced in between the limits. 
%       'even': evenly spaced between limits (default)
%       'center on zero': the midpoint of the colorbar is forced to be zero
%       'center on options.threshold': the midpoint of the colorbar is forced to be
%       the options.thresholds you've applied to your data
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
%
% Call: 
% [cMap,cData,cbData,ticks,tickLabels] = colormapGenerator(data)
% [cMap,cData,cbData,ticks,tickLabels] = colormapGenerator(data,'colormap','delta','colorSpacing','even','colorBins',1000,'colorSpecial','randomizeClusterColors','invertColors','false')

% Defaults
options = struct('colormap', 'jet','colorSpacing','even','colorBins',1000,'colorSpecial','none','invertColors','false','limits',[min(data) max(data)],'sulci',[],'gyri',[],'thresh',[]);
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

% create colormap if a string is passed in...otherwise interpolate colors
% in a custom colormap to fit the number of selected bins
if ischar(options.colormap)
    switch options.colormap
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
            cMap=cbrewer('div', options.colormap, options.colorBins);
        case 'RdYlBu'
            cMap = cbrewer('div', options.colormap, options.colorBins);
        case 'RdGy'
            cMap = cbrewer('div', options.colormap, options.colorBins);
        case 'RdBu'
            cMap = cbrewer('div', options.colormap, options.colorBins);
        case 'PuOr'
            cMap = cbrewer('div', options.colormap, options.colorBins);
        case 'PRGn'
            cMap = cbrewer('div', options.colormap, options.colorBins);
        case 'PiYG'
            cMap = cbrewer('div', options.colormap, options.colorBins);
        case 'BrBG'
            cMap = cbrewer('div', options.colormap, options.colorBins);
        case 'YlOrRd'
            cMap = cbrewer('seq', options.colormap, options.colorBins);
        case 'YlOrBr'
            cMap = cbrewer('seq', options.colormap, options.colorBins);
        case 'YlGnBu'
            cMap = cbrewer('seq', options.colormap, options.colorBins);
        case 'YlGn'
            cMap = cbrewer('seq', options.colormap, options.colorBins);
        case 'Reds'
            cMap = cbrewer('seq', options.colormap, options.colorBins);
        case 'RdPu'
            cMap = cbrewer('seq', options.colormap, options.colorBins);
        case 'Purples'
            cMap = cbrewer('seq', options.colormap, options.colorBins);
        case 'PuRd'
            cMap = cbrewer('seq', options.colormap, options.colorBins);
        case 'PuBuGn'
            cMap = cbrewer('seq', options.colormap, options.colorBins);
        case 'PuBu'
            cMap = cbrewer('seq', options.colormap, options.colorBins);
        case 'OrRd'
            cMap = cbrewer('seq', options.colormap, options.colorBins);
        case 'Oranges'
            cMap = cbrewer('seq', options.colormap, options.colorBins);
        case 'Greys'
            cMap = cbrewer('seq', options.colormap, options.colorBins);
        case 'Greens'
            cMap = cbrewer('seq', options.colormap, options.colorBins);
        case 'GnBu'
            cMap = cbrewer('seq', options.colormap, options.colorBins);
        case 'BuPu'
            cMap = cbrewer('seq', options.colormap, options.colorBins);
        case 'BuGn'
            cMap = cbrewer('seq', options.colormap, options.colorBins);
        case 'Blues'
            cMap = cbrewer('seq', options.colormap, options.colorBins);
        case 'Set3'
            cMap = cbrewer('qual', options.colormap, options.colorBins);
        case 'Set2'
            cMap = cbrewer('qual', options.colormap, options.colorBins);
        case 'Set1'
            cMap = cbrewer('qual', options.colormap, options.colorBins);
        case 'Pastel2'
            cMap = cbrewer('qual', options.colormap, options.colorBins);
        case 'Pastel1'
            cMap = cbrewer('qual', options.colormap, options.colorBins);
        case 'Paired'
            cMap = cbrewer('qual', options.colormap, options.colorBins);
        case 'Dark2'
            cMap = cbrewer('qual', options.colormap, options.colorBins);
        case 'Accent'
            cMap = cbrewer('qual', options.colormap, options.colorBins);
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
            cMap = cmocean(options.colormap, options.colorBins);
        case 'haline'
            cMap = cmocean(options.colormap, options.colorBins);
        case 'solar'
            cMap = cmocean(options.colormap, options.colorBins);
        case 'ice'
            cMap = cmocean(options.colormap, options.colorBins);
        case 'oxy'
            cMap = cmocean(options.colormap, options.colorBins);
        case 'deep'
            cMap = cmocean(options.colormap, options.colorBins);
        case 'dense'
            cMap = cmocean(options.colormap, options.colorBins);
        case 'algae'
            cMap = cmocean(options.colormap, options.colorBins);
        case 'matter'
            cMap = cmocean(options.colormap, options.colorBins);
        case 'turbid'
            cMap = cmocean(options.colormap, options.colorBins);
        case 'speed'
            cMap = cmocean(options.colormap, options.colorBins);
        case 'amp'
            cMap = cmocean(options.colormap, options.colorBins);
        case 'tempo'
            cMap = cmocean(options.colormap, options.colorBins);
        case 'balance'
            cMap = cmocean(options.colormap, options.colorBins);
        case 'delta'
            cMap = cmocean(options.colormap, options.colorBins);
        case 'curl'
            cMap = cmocean(options.colormap, options.colorBins);
        case 'phase'
            cMap = cmocean(options.colormap, options.colorBins);
        case 'perceptually distinct'
            cMap = distinguishable_colors(options.colorBins);
    end
else
    tmpMap = options.colormap';
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

% invert colors if necessary
switch options.invertColors
    case 'on'
        cMap = flipud(cMap);
end

% tackle any special cases
switch options.colorSpecial
    case 'randomizeColors'
        cMap = cMap(randperm(size(cMap,1)),:);
end

% stretch colorbar based on data limits
switch options.colorSpacing
    % this is the default option. All values between limits will get a
    % color from your colormap.
    case 'even'
        cbData = linspace(min(options.limits),max(options.limits),options.colorBins);
        % this will split your colormap into negative and positive values.
        % Negative stuff gets half the colormap. positive stuff gets the other
        % half.
        ticks = linspace(min(options.limits),max(options.limits),11);
        tickLabels = ticks;
        %tickLabels = [min(options.limits):(max(options.limits)-min(options.limits))/11:max(options.limits)]; % tick labels
        
    case 'center on zero'
        cbMapPos = cMap((1:floor(length(cMap)/2)),:);
        cbMapNeg = cMap(floor((length(cMap))/2):end,:);
        cMap = vertcat(cbMapPos,cbMapNeg);
        cbDataNeg = linspace(min(options.limits),0,(options.colorBins/2)+1);
        cbDataPos = linspace(0,max(options.limits),options.colorBins/2);
        cbData = horzcat(cbDataNeg,cbDataPos);
        %cData(round((length(cMap)/2)+1)) = [];
        cbData(round((length(cbData)/2)+1)) = [];
        cMap(floor((length(cMap)/2)+1),:) = [];
        
        ticks = linspace(min(options.limits),max(options.limits),11);
        tickLabels = [linspace(min(options.limits),0,6) linspace(0,max(options.limits),6)];
        idx = find(tickLabels == 0);
        tickLabels(idx(end)) = [];
        
    case 'center on threshold'
        % find out if you have both positive and negative values
        posTest = find(options.limits > 0);
        negTest = find(options.limits < 0);
        
        %         if (isempty(posTest) && ~isempty(negTest)) || (~isempty(posTest) && isempty(negTest))
        %             if options.thresh(1) == 0 && options.thresh(2) == 0
        %                 options.thresh = [mean(options.limits) mean(options.limits)];
        %             end
        %             if ~isempty(posTest) && isempty(negTest)
        %                 cbData = linspace(max(options.thresh),max(options.limits),options.colorBins);
        %                 ticks = linspace(max(options.thresh),max(options.limits),10);
        %             end
        %             if isempty(posTest) && ~isempty(negTest)
        %                 cbData = linspace(min(options.limits),min(options.thresh),options.colorBins);
        %                 ticks = linspace(min(options.limits),min(options.thresh),10);
        %             end
        %         else
        cbMapPos = cMap((1:floor(length(cMap)/2)),:);
        cbMapNeg = cMap(floor((length(cMap))/2):end,:);
        cMap = vertcat(cbMapPos,cbMapNeg);
        cbDataNeg = linspace(min(options.limits),min(options.thresh),(options.colorBins/2)+1);
        cbDataPos = linspace(max(options.thresh),max(options.limits),options.colorBins/2);
        cbData = horzcat(cbDataNeg,cbDataPos);
        cbData(round((length(cMap)/2)+1)) = [];
        cMap(floor((length(cMap)/2)+1),:) = [];
        
        if (isempty(posTest) && ~isempty(negTest)) || (~isempty(posTest) && isempty(negTest))
            ticks = linspace(min(options.limits),max(options.limits),10);
            tickLabels = [linspace(min(options.limits),min(options.thresh),5) linspace(max(options.thresh),max(options.limits),5)];
        else
            ticks = linspace(min(options.limits),max(options.limits),12);
            ticks(6) = [];
            ticks(6) = [];
            tickLabels = [linspace(min(options.limits),min(options.thresh),6) linspace(max(options.thresh),max(options.limits),6)];
            tickLabels(6) = [];
            tickLabels(6) = [];
        end
end


 dec = floor(log10(max(abs(options.limits)))); % decade of largest abs value
 if dec<1
     tickLabels = round(tickLabels*100^(1-dec))*100^(dec-1);
 elseif dec == 1
     tickLabels = round(tickLabels*100^(2-dec))*100^(dec-2);
 else
     tickLabels = round(tickLabels);
 end

% map values onto colorbar
tf = cbData >= data;
[~,m] = max(tf,[],2);
cData = cMap(m,:);
id = find(data > max(options.limits));
cData(id,1) = cMap(end,1);
cData(id,2) = cMap(end,2);
cData(id,3) = cMap(end,3);
id = find(data < min(options.limits));
cData(id,1) = cMap(1,1);
cData(id,2) = cMap(1,2);
cData(id,3) = cMap(1,3);