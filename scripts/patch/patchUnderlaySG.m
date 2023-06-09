function [varargout] = patchUnderlaySG(underlays,varargin)
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
options = struct('lh',[],'rh',[],'vls','raw','thresh',[0 0],'pos','on','neg','on','pMap',[],'pThresh',1,'operation','false','sclLims',[0 1],'compKeep',1,'smoothSteps', 0, 'smoothArea', 0, 'smoothThreshold', 'above', 'smoothType', 'neighbors','smoothToAssign','all','colormap','gray','colorSpacing','even','colorBins',1000,'colorSpecial','none','invertColors','false','limits',[],'binarize',[],'inclZero','on','surfC',[0.5 0.5 0.5],'sulci',[],'gyri',[],'surfOpacity',1,'sgOpacity',1,'UI',[]);
optionNames = fieldnames(options);

% Check inputs
if length(varargin) < 2
    error('You are missing an argument')
end
if length(varargin) > (length(fieldnames(options))*2)
    error('You have supplied too many arguments')
end  

% now parse the arguments
vleft = varargin(1:end);
for pair = reshape(vleft,2,[]) %pair is {propName;propValue}
    inpName = pair{1}; % make case insensitive by using lower() here but this can be buggy
    if any(strcmp(inpName,optionNames))
        options.(inpName) = pair{2};
    else
        error('%s is not a recognized parameter name',inpName)
    end
end

% sanity check that you passed in a lh or rh
if isempty(options.lh) && isempty(options.rh)
    error('You did not provide either lh or rh curvature data')
end

% setup outputs
ticksSG = struct('left', struct('ticks', '', 'labels', ''), 'right',struct('ticks', '', 'labels', ''));
colormapSG = struct('left', struct('map', '', 'dataMap', ''), 'right',struct('map', '', 'dataMap', ''));

% flip input data if necessary
if ~isempty(options.lh)
    if size(options.lh,1) < size(options.lh,2)
        options.lh = options.lh';
    end
end
if ~isempty(options.rh)
    if size(options.rh,1) < size(options.rh,2)
        options.rh = options.rh';
    end
end

% remove invalid data if necessary (inf, nan; these are un-patchable)
if ~isempty(options.lh)
    invIdx = find(isnan(options.lh));
    options.lh(invIdx) = 0;
end
if ~isempty(options.rh)
    invIdx = find(isnan(options.rh));
    options.rh(invIdx) = 0;
end
if ~isempty(options.lh)
    invIdx = find(isinf(options.lh));
    dm = max(options.lh);
    options.lh(invIdx) = dm;
end
if ~isempty(options.rh)
    invIdx = find(isinf(options.rh));
    dm = max(options.rh);
    options.rh(invIdx) = dm;
end

% if there is a UI passed in, start loading bar...
if ~isempty(options.UI)
    d = uiprogressdlg(options.UI,'Title','Patching underlay',...
        'Message','Thresholding values...');
end

% remove previous sg data if it exists 


% threshold values
if ~isempty(options.lh)
    [lo,vl] = dataThresh(options.lh,'pos',options.pos,'neg',options.neg,'vls',lower(options.vls),'sclLims',options.sclLims,'thresh',options.thresh);
end
if ~isempty(options.rh)
    [ro,vr] = dataThresh(options.rh,'pos',options.pos,'neg',options.neg,'vls',lower(options.vls),'sclLims',options.sclLims,'thresh',options.thresh);
end

if ~isempty(options.UI)
    d.Message = ['Binarizing...'];
    d.Value = 0.1;
end

% NOTE: we do not perform any kind of cluster-based thresholding or
% manipulations for sulci/gyri (which would go in this spot)
% in order to binarize, make everything one or zero
% if strcmp(options.binarize,'on')
%     if ~isempty(options.lh)
%        id1 = find(lo ~= 0);
%        id2 = find(lo == 0);
%        lo(id1) = 1;
%        lo(id2) = 0.01;
%     end
%     if ~isempty(options.rh)
%         id1 = find(ro ~= 0);
%         id2 = find(ro == 0);
%         ro(id1) = 1;
%         ro(id2) = 0.01;
%     end
% end

if ~isempty(options.binarize)
    if ~isempty(options.lh)
       id1 = find(lo >= options.binarize);
       id2 = find(lo < options.binarize);
       lo(id1) = 1;
       lo(id2) = 0.01;
       options.colorBins = 2;
       [~,mi] = min(options.limits);
       options.limits(mi) = 0;
    end
    if ~isempty(options.rh)
        id1 = find(ro >= options.binarize);
        id2 = find(ro < options.binarize);
        ro(id1) = 1;
        ro(id2) = 0.01;
        options.colorBins = 2;
        [~,mi] = min(options.limits);
        options.limits(mi) = 0;
    end
end

if ~isempty(options.UI)
    d.Message = ['Smoothing...This can take some time depending on your settings'];
    d.Value = 0.3;
end

% smooth data
if ~isempty(options.lh)
    if sum(underlays.left.Vertices(:,3)) ~= 0
        los = smoothVertData(lo, underlays.left.Vertices, underlays.left.Faces, 'smoothSteps', options.smoothSteps, 'smoothArea', options.smoothArea,'toAssign',options.smoothToAssign);
    else
        los = lo;
    end
end
if ~isempty(options.rh)
    if sum(underlays.right.Vertices(:,3)) ~= 0
        ros = smoothVertData(ro, underlays.right.Vertices, underlays.right.Faces, 'smoothSteps', options.smoothSteps, 'smoothArea', options.smoothArea,'toAssign',options.smoothToAssign);
    else
        ros = ro;
    end
end

% NOTE: we do not perform any kind of cluster-based thresholding or
% manipulations for sulci/gyri.

if ~isempty(options.UI)
    d.Message = ['Mapping colors...'];
    d.Value = 0.5;
end

% map colors onto data
% but first, make sure the limits you define are consistent across both
% hemispheres (and redefine limits if we've thresholded).
if isempty(options.limits) || ~isempty(options.binarize)
    if ~isempty(options.lh) && ~isempty(options.rh)
        tmp = [los; ros];
        if isempty(options.binarize)
            options.limits(1,1) = min(tmp);
        end
        options.limits(1,2) = max(tmp);
    elseif ~isempty(options.lh) && isempty(options.rh)
        if isempty(options.binarize)
            options.limits(1,1) = min(options.lh);
        end
        options.limits(1,2) = max(options.lh);
    elseif isempty(options.lh) && ~isempty(options.rh)
        if isempty(options.binarize)
            options.limits(1,1) = min(options.rh);
        end
        options.limits(1,2) = max(options.rh);
    end
end

if ~isempty(options.lh) 
    [colormapSG.left.map,lcData,colormapSG.left.dataMap,ticksSG.left.ticks,ticksSG.left.labels] = colormapper(los,'colormap',options.colormap,'colorSpacing',options.colorSpacing,'colorBins',options.colorBins,'colorSpecial',options.colorSpecial,'invertColors',options.invertColors,'limits',[min(options.limits) max(options.limits)],'sulci',options.sulci,'gyri',options.gyri,'thresh',options.thresh);
end
if ~isempty(options.rh)
    [colormapSG.right.map,rcData,colormapSG.right.dataMap,ticksSG.right.ticks,ticksSG.right.labels] = colormapper(ros,'colormap',options.colormap,'colorSpacing',options.colorSpacing,'colorBins',options.colorBins,'colorSpecial',options.colorSpecial,'invertColors',options.invertColors,'limits',[min(options.limits) max(options.limits)],'sulci',options.sulci,'gyri',options.gyri,'thresh',options.thresh);
end

% This is where we would set up alpha data but that doesn't make sense to
% do with sulci/gyri information

if ~isempty(options.UI)
    d.Message = ['Replacing zeros and making intial patch...'];
    d.Value = 0.6;
end

% Now map things onto the surface
if ~isempty(options.lh)
    underlays.left.CDataMapping = 'scaled';
    underlays.left.FaceVertexCData = lcData;
    
    switch options.inclZero
        case 'off'
            id = find(los == 0);
            underlays.left.FaceVertexCData(id,1) = options.surfC(1);
            underlays.left.FaceVertexCData(id,2) = options.surfC(2);
            underlays.left.FaceVertexCData(id,3) = options.surfC(3);
        case 'on'
            
    end
    %underlays.left.FaceAlpha = 'interp';
    %id = find(los == 0);
    %underlays.left.FaceVertexAlphaData = ones(size(lcData,1),1);
end

if ~isempty(options.rh)
    underlays.right.CDataMapping = 'scaled';
    underlays.right.FaceVertexCData = rcData;
    
     switch options.inclZero
        case 'off'
            id = find(ros == 0);
            underlays.right.FaceVertexCData(id,1) = options.surfC(1);
            underlays.right.FaceVertexCData(id,2) = options.surfC(2);
            underlays.right.FaceVertexCData(id,3) = options.surfC(3);           
    end
end

if ~isempty(options.UI)
    d.Message = ['Interpolating colormap to fix sulcal/gyral opacity...'];
    d.Value = 0.8;
end

% now make a colormap interp between each unique color in FaceVertexCData
% and the background color (options.surfC). Have 100 bins 
if options.sgOpacity ~= 1
    if ~isempty(options.lh)
        un = unique(underlays.left.FaceVertexCData,'rows');
        for i = 1:size(un,1)
            %tmp = customColorMapInterp([un(i,:); options.surfC],100);
            tmp = customColorMapInterp([options.surfC; un(i,:)],100);
            out(i,:) = tmp(round(options.sgOpacity*100),:);
        end
        for i = 1:size(underlays.left.FaceVertexCData,1)
            [~,id] = ismember(underlays.left.FaceVertexCData(i,:),un,'rows');
            out2(i,:) = out(id,:);
        end
        underlays.left.FaceVertexCData = out2;
    end
    if ~isempty(options.rh)
        un = unique(underlays.right.FaceVertexCData,'rows');
        for i = 1:size(un,1)
            %tmp = customColorMapInterp([un(i,:); options.surfC],100);
            tmp = customColorMapInterp([options.surfC; un(i,:)],100);
            out(i,:) = tmp(round(options.sgOpacity*100),:);
        end
        for i = 1:size(underlays.right.FaceVertexCData,1)
            [~,id] = ismember(underlays.right.FaceVertexCData(i,:),un,'rows');
            out2(i,:) = out(id,:);
        end
        underlays.right.FaceVertexCData = out2;
    end
end

if ~isempty(options.UI)
    d.Message = ['Finishing up with surface opacity and cleanup...'];
    d.Value = 1;
    close(d)
end

% also address surface opacity (last)
if ~isempty(options.lh)
    underlays.left.FaceVertexAlphaData = ones([size(underlays.left.Vertices,1),1])*options.surfOpacity;
    underlays.left.AlphaDataMapping = 'scaled';
    underlays.left.FaceAlpha = 'interp';
    underlays.left.AlphaDataMapping = 'none';
end
if ~isempty(options.rh)
    underlays.right.FaceVertexAlphaData = ones([size(underlays.right.Vertices,1),1])*options.surfOpacity;
    underlays.right.AlphaDataMapping = 'scaled';
    underlays.right.FaceAlpha = 'interp';
    underlays.right.AlphaDataMapping = 'none';
end

if ~isempty(options.lh)
    v.left = vl;
    o.left = los;
end
if ~isempty(options.rh)
    v.right = vr;
    o.right = ros;
end

varargout{1} = underlays;
varargout{2} = colormapSG;
varargout{3} = ticksSG;
varargout{4} = v;
varargout{5} = o;