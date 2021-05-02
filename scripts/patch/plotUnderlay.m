function [varargout] = plotUnderlay(varargin)
% Call: 
% [underlay, brain] = plotUnderlay(vert1, face1, curv1)
% [underlay, brain] = plotUnderlay(vert1, face1, curv1, vert2, face2, curv2, sulciC, gyriC, lights)
% [underlay, brain] = plotUnderlay(vert1, face1, curv1, vert2, face2, curv2, [0.4 0.4 0.4], [0.8 0.8 0.8], 'off')
% [underlay, brain, brainFig] = plotUnderlay(vert1, face1, curv1, vert2, face2, curv2, [0.4 0.4 0.4], [0.8 0.8 0.8], 'off')
%
% This script will plot an underlay based on some vertices, faces, and
% sulci/gyri patterns that you pass. It will use the mean value of the
% x-coordinate to determine which file corresponds to the left
% hemisphere, and which to the right (i.e., < 0 means left hemisphere). 
%
% Alex Teghipco // alex.teghipco@uci.edu // 11/28/18
% Default settings:
vert2 = [];
face2 = [];
curv2 = [];
sulciC = [0.4 0.4 0.4];
gyriC = [0.8 0.8 0.8];
lights = 'off';
options.colorSampling = 'even';
raw = 'false';
thresh = 0.1;

% check to make sure at least 3 arguments are passed (i.e., hopefully
% all the data for 1 surface)
if length(varargin) < 3
    error('You need to at least pass vertices, faces, and curvature data for your surface')
end
    
% load in data for first surface
vert1 = varargin{1};
face1 = varargin{2};
curv1 = varargin{3};

% load in data for second surface if provided, and overwrite any sulci/gyri
% colors if provided
fixedargn = 3;
if nargin > (fixedargn + 0)
    if ~isempty(varargin{4})
        vert2 = varargin{4};
    end
end

if nargin > (fixedargn + 1)
    if ~isempty(varargin{5})
        face2 = varargin{5};
    end
end

if nargin > (fixedargn + 2)
    if ~isempty(varargin{6})
        curv2 = varargin{6};
    end
end

if nargin > (fixedargn + 3)
    if ~isempty(varargin{7})
        raw = varargin{7};
    end
end

if nargin > (fixedargn + 4)
    if ~isempty(varargin{8})
        thresh = varargin{8};
    end
end

if nargin > (fixedargn + 5)
    if ~isempty(varargin{9})
        sulciC = varargin{9};
    end
end

if nargin > (fixedargn + 6)
    if ~isempty(varargin{10})
        gyriC = varargin{10};
    end
end

if nargin > (fixedargn + 7)
    if ~isempty(varargin{11})
        lights = varargin{11};
    end
end

% now lets figure out whether your surface(s) correspond to left or right
% hemispheres
if isempty(vert2) == 1
    if mean(vert1(:,1)) < 0
        brain.left.vert = vert1;
        brain.left.face = face1;
        brain.left.curv = curv1;
    else
        brain.right.vert = vert1;
        brain.right.face = face1;
        brain.right.curv = curv1;
    end
else
    if mean(vert1(:,1)) < 0
        brain.left.vert = vert1;
        brain.left.face = face1;
        brain.left.curv = curv1;
        brain.right.vert = vert2;
        brain.right.face = face2;
        brain.right.curv = curv2;
    else
        brain.right.vert = vert1;
        brain.right.face = face1;
        brain.right.curv = curv1;
        brain.left.vert = vert2;
        brain.left.face = face2;
        brain.left.curv = curv2;
    end
end

% gather patches 
if isfield(brain, 'left') == 1
    gyriVert = find(brain.left.curv > thresh);
    brain.left.curvData(gyriVert,:) = repmat(sulciC,[size(gyriVert),1]);
    sulcVert = find(brain.left.curv < thresh);
    brain.left.curvData(sulcVert,:) = repmat(gyriC,[size(sulcVert),1]);
    brain.left.face = brain.left.face+1;
    
    switch raw
        case 'true'
            cMap = gray(1000);
            switch options.colorSampling
                case 'center on zero'
                    cMapPos = cMap((1:floor(length(cMap)/2)),:);
                    cMapNeg = cMap(floor((length(cMap)+1)/2):end,:);
                    cMap = vertcat(cMapPos,cMapNeg);
                    cDataNeg = linspace(min(curv1),0,1000/2);
                    cDataPos = linspace(0,max(curv2),1000/2);
                    cData = horzcat(cDataNeg,cDataPos);
                case 'even'
                    cData = linspace(min(curv1),max(curv1),1000);
            end
            
            cDataMatch = abs(bsxfun(@gt,curv1,cData));
            cDataIdx = sum( abs( cumprod( cDataMatch, 2 ) ) > 0, 2 ) + 1;
            ocData1 = cMap(cDataIdx,:);
    end
end
    
if isfield(brain, 'right') == 1
    gyriVert = find(brain.right.curv > thresh);
    brain.right.curvData(gyriVert,:) = repmat(sulciC,[size(gyriVert),1]);
    sulcVert = find(brain.right.curv < thresh);
    brain.right.curvData(sulcVert,:) = repmat(gyriC,[size(sulcVert),1]);
    brain.right.face = brain.right.face+1;
    brain.right.vert(:,1) = brain.right.vert(:,1)+90;
    
    switch raw
        case 'true'
            cMap = gray(1000);
            switch options.colorSampling
                case 'center on zero'
                    cMapPos = cMap((1:floor(length(cMap)/2)),:);
                    cMapNeg = cMap(floor((length(cMap)+1)/2):end,:);
                    cMap = vertcat(cMapPos,cMapNeg);
                    cDataNeg = linspace(min(curv2),0,1000/2);
                    cDataPos = linspace(0,max(curv2),1000/2);
                    cData = horzcat(cDataNeg,cDataPos);
                case 'even'
                    cData = linspace(min(curv2),max(curv2),1000);
            end
            
            cDataMatch = abs(bsxfun(@gt,curv2,cData));
            cDataIdx = sum( abs( cumprod( cDataMatch, 2 ) ) > 0, 2 ) + 1;
            ocData2 = cMap(cDataIdx,:);
    end
end

% now plot    
if isfield(brain, 'left') == 1 && isfield(brain, 'right') == 1
   brainFig = figure;
   
   switch raw
       case 'true'
           tmp = patch('Faces',brain.left.face,'Vertices',brain.left.vert,'FaceVertexCData',ocData1,'facealpha',1,'CDataMapping','direct','facecolor','interp','edgecolor','none');
           hold on
           tmp2 = patch('Faces',brain.right.face,'Vertices',brain.right.vert,'FaceVertexCData',ocData2,'facealpha',1,'CDataMapping','direct','facecolor','interp','edgecolor','none');
           
       case 'false'
           tmp = patch('Faces',brain.left.face,'Vertices',brain.left.vert,'FaceVertexCData',brain.left.curvData,'facealpha',1,'CDataMapping','direct','facecolor','interp','edgecolor','none');
           hold on
           tmp2 = patch('Faces',brain.right.face,'Vertices',brain.right.vert,'FaceVertexCData',brain.right.curvData,'facealpha',1,'CDataMapping','direct','facecolor','interp','edgecolor','none');
   end
   
   underlay.left = tmp;
   underlay.right = tmp2;
   
   xlims = [min(min([brain.left.vert(:,1),brain.right.vert(:,1)])) max(max([brain.left.vert(:,1),brain.right.vert(:,1)]))];
   ylims = [min(min([brain.left.vert(:,2),brain.right.vert(:,2)])) max(max([brain.left.vert(:,2),brain.right.vert(:,2)]))];
   zlims = [min(min([brain.left.vert(:,3),brain.right.vert(:,3)])) max(max([brain.left.vert(:,3),brain.right.vert(:,3)]))];
   set(gca,'xlim',xlims,'ylim',ylims,'zlim',zlims)
   brain.view_angle = [-90 0]; 
end

if isfield(brain, 'left') == 1 && isfield(brain, 'right') == 0
   brainFig = figure;
   
   switch raw
       case 'true'
           underlay.left = patch('Faces',brain.left.face,'Vertices',brain.left.vert,'FaceVertexCData',ocData1,'facealpha',1,'CDataMapping','direct','facecolor','interp','edgecolor','none');

       case 'false'
           underlay.left = patch('Faces',brain.left.face,'Vertices',brain.left.vert,'FaceVertexCData',brain.left.curvData,'facealpha',1,'CDataMapping','direct','facecolor','interp','edgecolor','none');
   end
   
   xlims = [min(min(brain.left.vert(:,1))) max(max(brain.left.vert(:,1)))];
   ylims = [min(min(brain.left.vert(:,2))) max(max(brain.left.vert(:,2)))];
   zlims = [min(min(brain.left.vert(:,3))) max(max(brain.left.vert(:,3)))];
   set(gca,'xlim',xlims,'ylim',ylims,'zlim',zlims)
   brain.view_angle = [-90 0];
end

if isfield(brain, 'left') == 0 && isfield(brain, 'right') == 1
   brainFig = figure;
   
   switch raw
       case 'true'
           underlay.right = patch('Faces',brain.right.face,'Vertices',brain.right.vert,'FaceVertexCData',ocData2,'facealpha',1,'CDataMapping','direct','facecolor','interp','edgecolor','none');
       case 'false'
           underlay.right = patch('Faces',brain.right.face,'Vertices',brain.right.vert,'FaceVertexCData',brain.right.curvData,'facealpha',1,'CDataMapping','direct','facecolor','interp','edgecolor','none');
   end
   
   xlims = [min(min(brain.right.vert(:,1))) max(max(brain.right.vert(:,1)))];
   ylims = [min(min(brain.right.vert(:,2))) max(max(brain.right.vert(:,2)))];
   zlims = [min(min(brain.right.vert(:,3))) max(max(brain.right.vert(:,3)))];
   set(gca,'xlim',xlims,'ylim',ylims,'zlim',zlims)
   brain.view_angle = [90 0];
end

axis off vis3d equal tight;
view(brain.view_angle(1), brain.view_angle(2));
material dull

switch lights
    case 'on'
        camlight(-90,0);
        camlight(90,0);
        camlight(0,0);
        camlight(180,0);
        camlight(180,90); % this will make it REALLY bright
end

set(gcf,'color','w');
set(gcf,'units','normalized','outerposition',[0 0 0.5 0.5])

varargout{1} = underlay;
varargout{2} = brainFig;
