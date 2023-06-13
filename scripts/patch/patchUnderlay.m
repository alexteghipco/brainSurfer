function [varargout] = patchUnderlay(varargin)
% This script patches either left  and/or right hemisphere vertices and
% adds default lighting. It can also add a new surface onto an existing
% figure.
%
% Call: 
% [underlay, brain] = plotUnderlay(vert1, face1) % plots one hemisphere
% [underlay, brain] = plotUnderlay(vert1, face1, vert2, face2) % plots two
% hemispheres
% [underlay, brain] = plotUnderlay(vert1, face1, 'add', hemi, brainFig, underlay) % adds a
% hemisphere to an existing patch
% [underlay, brain] = plotUnderlay(vert1, face1, 'add', hemi, brainFig, underlay, 'lights', [-90 0; 90 0; 0 0; 180 0]) % adds a
% hemisphere to an existing patch and adds certain non-default lights
% (though note these are the defaults ;-]). lights can be set to: 'off',
% left out to generate default lights, or an n x 2 array of n lights can be
% passed with locatons of lights.
% [underlay, brain] = plotUnderlay(vert1, face1, 'add', hemi, brainFig, underlay, 'lights', [-90 0; 90 0; 0 0; 180 0],'surfC',[0.5 0.5 0.5])
% Alex Teghipco // alex.teghipco@uci.edu // 11/28/18

% Default settings:
vert2 = [];
face2 = [];
n = nargin;

% check to make sure at least 3 arguments are passed (i.e., hopefully
% all the data for 1 surface)
if length(varargin) < 2
    error('You need to at least pass vertices and faces to patch')
end
if length(varargin) > 9
    error('You have provided too many arguments')
end    

% load in data for first surface
vert1 = varargin{1};
face1 = varargin{2};

% check/remove argument for lights
if any(strcmp('lights',varargin))
    id = find(strcmp('lights',varargin));
    if strcmp(varargin{id+1},'off') 
        li = 'off';
    elseif isa(varargin{id+1},'double') 
        li = varargin{id+1};
    end
    varargin(id) = [];
    varargin(id) = [];
    n = n-2;
else
    li = [-90 0; 90 0; 0 0; 180 0];
end

% check/remove argument for surfC
if any(strcmp('surfC',varargin))
    id = find(strcmp('surfC',varargin));
    surfC = varargin{id+1};
    varargin(id) = [];
    varargin(id) = [];
    n = n-2;
else
    surfC = [0.5 0.5 0.5];
end

if find(strcmp('add', varargin))
    add = 'on';
    if isa(varargin{6},'struct') && isa(varargin{4},'char')
       underlay = varargin{6};
       hemi = varargin{4};
       brainFig = varargin{5};
    end
    
    if isfield(underlay,'left') && isfield(underlay,'right')
        if strcmp(hemi,'right')
            delete(underlay.right)
            underlay = rmfield(underlay,'right');
        elseif strcmp(hemi,'left')
            delete(underlay.left)
            underlay = rmfield(underlay,'left');
        end
    end
    
    if isfield(underlay,'left')
        brain.left.vert = underlay.left.Vertices;
        brain.left.face = underlay.left.Faces;
    elseif isfield(underlay,'right')
        brain.right.vert = underlay.right.Vertices;
        brain.right.face = underlay.right.Faces;
    end
    if strcmp(hemi,'left')
        brain.left.vert = vert1;
        brain.left.face = face1;
    elseif strcmp(hemi,'right')
        brain.right.vert = vert1;
        brain.right.face = face1;
    end
else
    add = 'off';
    fixedargn = 2;
    if n > (fixedargn + 0)
        if ~isempty(varargin{3})
            vert2 = varargin{3};
        end
    end
    if n > (fixedargn + 1)
        if ~isempty(varargin{4})
            face2 = varargin{4};
        end
    end
    
    % now lets figure out whether your surface(s) correspond to left or right
    % hemispheres
    if isempty(vert2) == 1
        if sum(vert1(:,3)) ~= 0
            if mean(vert1(:,1)) < 0
            %if mean(vert1(:,1)) > mean(vert2(:,1))
            %if mean(vert1(:,3)) < mean(vert2(:,3))
                brain.left.vert = vert1;
                brain.left.face = face1;
            else
                brain.right.vert = vert1;
                brain.right.face = face1;
            end
        else
            try
                if mean(vert1(:,3)) < mean(vert2(:,3))
                    %if mean(vert1(:,1)) > mean(vert2(:,1))
                    %             if mean(vert1(:,1)) < 0
                    brain.right.vert = vert1;
                    brain.right.face = face1;
                else
                    brain.left.vert = vert1;
                    brain.left.face = face1;
                end
            catch
                brain.left.vert = vert1;
                brain.left.face = face1;
            end
        end
    else
        if sum(vert1(:,3)) ~= 0
            %if mean(vert1(:,1)) > mean(vert2(:,1))
                %             if mean(vert1(:,1)) < 0
            if mean(vert1(:,3)) < mean(vert2(:,3))
                brain.left.vert = vert1;
                brain.left.face = face1;
                brain.right.vert = vert2;
                brain.right.face = face2;
            else
                brain.right.vert = vert1;
                brain.right.face = face1;
                brain.left.vert = vert2;
                brain.left.face = face2;
            end
        else
            %if mean(vert1(:,3)) < mean(vert2(:,3))
            %if mean(vert1(:,1)) > mean(vert2(:,1))
                %             if mean(vert1(:,1)) < 0
%                 brain.right.vert = vert1;
%                 brain.right.face = face1;
%                 brain.left.vert = vert2;
%                 brain.left.face = face2;
%             else
                brain.left.vert = vert1;
                brain.left.face = face1;
                brain.right.vert = vert2;
                brain.right.face = face2;
            %end
        end
    end
end

if isfield(brain, 'left')
    cdata1(:,1) = repmat(surfC(1),size(brain.left.vert,1),1);
    cdata1(:,2) = repmat(surfC(2),size(brain.left.vert,1),1);
    cdata1(:,3) = repmat(surfC(3),size(brain.left.vert,1),1);
end
if isfield(brain, 'right')
    cdata2(:,1) = repmat(surfC(1),size(brain.right.vert,1),1);
    cdata2(:,2) = repmat(surfC(2),size(brain.right.vert,1),1);
    cdata2(:,3) = repmat(surfC(3),size(brain.right.vert,1),1);
end

if isfield(brain, 'left') && isfield(brain, 'right')
    % move RH such that the 
    m2 = min(brain.right.vert(:,1));
    m1 = min(brain.left.vert(:,1));
    m3 = max(brain.right.vert(:,1));
    m4 = max(brain.left.vert(:,1));
    
    rh_offset = round((m4 + 7.6) - m2);
else
    rh_offset = 0;
end

switch add
    case 'off'
        brainFig = figure;
        newFig = 'true';
        addedHemi = [];

        if isfield(brain, 'left') && isfield(brain, 'right')
            if min(min(brain.left.face)) <= 0
                brain.left.face = 1+brain.left.face;
            end
            if min(min(brain.right.face)) <= 0
                brain.right.face = 1+brain.right.face;
            end
            brain.right.vert(:,1) = brain.right.vert(:,1)+rh_offset;
            
            tmp = patch('Faces',brain.left.face,'Vertices',brain.left.vert,'FaceVertexCData',[cdata1],'facealpha',1,'CDataMapping','direct','facecolor','interp','edgecolor','none','FaceLighting','gouraud');
            hold on
            tmp2 = patch('Faces',brain.right.face,'Vertices',brain.right.vert,'FaceVertexCData',[cdata2],'facealpha',1,'CDataMapping','direct','facecolor','interp','edgecolor','none','FaceLighting','gouraud');
            
            underlay.left = tmp;
            underlay.right = tmp2;
            
        elseif isfield(brain, 'left') && ~isfield(brain, 'right')
            if min(min(brain.left.face)) <= 0
                min(min(brain.left.face))
                brain.left.face = -1*(min(min(brain.left.face)))+1+brain.left.face;
            end
            
            tmp = patch('Faces',brain.left.face,'Vertices',brain.left.vert,'FaceVertexCData',[cdata1],'facealpha',1,'CDataMapping','direct','facecolor','interp','edgecolor','none','FaceLighting','gouraud');
            underlay.left = tmp;
            
        elseif isfield(brain, 'right') && ~isfield(brain, 'left')
            if min(min(brain.right.face)) <= 0
                brain.right.face = -1*(min(min(brain.left.face)))+1+brain.right.face;
            end
            brain.right.vert(:,1) = brain.right.vert(:,1)+rh_offset;
            
            tmp2 = patch('Faces',brain.right.face,'Vertices',brain.right.vert,'FaceVertexCData',[cdata2],'facealpha',1,'CDataMapping','direct','facecolor','interp','edgecolor','none','FaceLighting','gouraud');
            underlay.right = tmp2;
        end
        
        % some default settings
        axis off vis3d equal tight;
        material dull
    case 'on'
        addedHemi = [];
        newFig = 'false';
        
        figure(brainFig)
        tm = findall(brainFig.Children,'Type','Axes');
        if length(tm) > 1
            tm = tm(end);
        end
        
        if strcmp(hemi, 'left')
            addedHemi = [addedHemi 'left'];
            if min(min(brain.left.face)) <= 0
                brain.left.face = 1+brain.left.face;
            end
            underlay.right.Vertices(:,1) = underlay.right.Vertices(:,1)+rh_offset;
            hold on
            
            tmp = patch(tm,'Faces',brain.left.face,'Vertices',brain.left.vert,'FaceVertexCData',[cdata1],'facealpha',1,'CDataMapping','direct','facecolor','interp','edgecolor','none','FaceLighting','gouraud');
            hold off
            underlay.left = tmp;
        elseif strcmp(hemi,'right')
            addedHemi = [addedHemi '_right'];
            if min(min(brain.right.face)) <= 0
                brain.right.face = 1+brain.right.face;
            end
            brain.right.vert(:,1) = brain.right.vert(:,1)+rh_offset;
            hold on
            
            tmp2 = patch(tm,'Faces',brain.right.face,'Vertices',brain.right.vert,'FaceVertexCData',[cdata2],'facealpha',1,'CDataMapping','direct','facecolor','interp','edgecolor','none','FaceLighting','gouraud');
            hold off
            underlay.right = tmp2;
        end
end
                            
% set bounds
if isfield(underlay,'left') && isfield(underlay,'right')
    xlims = [min([underlay.left.Vertices(:,1);underlay.right.Vertices(:,1)]) max([underlay.left.Vertices(:,1);underlay.right.Vertices(:,1)])];
    ylims = [min([underlay.left.Vertices(:,2);underlay.right.Vertices(:,2)]) max([underlay.left.Vertices(:,2);underlay.right.Vertices(:,2)])];
    zlims = [min([underlay.left.Vertices(:,3);underlay.right.Vertices(:,3)]) max([underlay.left.Vertices(:,3);underlay.right.Vertices(:,3)])];
elseif isfield(underlay,'left') && ~isfield(underlay,'right')
    xlims = [min(min(underlay.left.Vertices(:,1))) max(max(underlay.left.Vertices(:,1)))];
    ylims = [min(min(underlay.left.Vertices(:,2))) max(max(underlay.left.Vertices(:,2)))];
    zlims = [min(min(underlay.left.Vertices(:,3))) max(max(underlay.left.Vertices(:,3)))];
elseif ~isfield(underlay,'left') && isfield(underlay,'right')
    xlims = [min(min(underlay.right.Vertices(:,1))) max(max(underlay.right.Vertices(:,1)))];
    ylims = [min(min(underlay.right.Vertices(:,2))) max(max(underlay.right.Vertices(:,2)))];
    zlims = [min(min(underlay.right.Vertices(:,3))) max(max(underlay.right.Vertices(:,3)))];
end

if zlims(1) == 0 && zlims(2) == 0
    zlims = [0 0.01];
    v = 'off';
else
    v = 'on';
end
%set(gca,'xlim',xlims,'ylim',ylims,'zlim',zlims)
figure(brainFig)
tm = findall(brainFig.Children,'Type','Axes');
if length(tm) > 1
    tm = tm(end);
end
set(tm,'xlim',xlims,'ylim',ylims,'zlim',zlims)

% some default settings
brain.view_angle = [-90 0];
switch v
    case 'on'
        view(brain.view_angle(1), brain.view_angle(2));
end

switch add
    case 'on'
        delete(findall(gcf,'Type','light'))
end

if ~strcmp(li,'off')
    for i = 1:size(li,1)
        camlight(tm,li(i,1),li(i,2));
    end
end

switch add
    case 'on'
        if strcmp(hemi,'right')
            underlay.right.SpecularStrength = underlay.left.SpecularStrength;
            underlay.right.SpecularExponent = underlay.left.SpecularExponent;
            underlay.right.SpecularColorReflectance = underlay.left.SpecularColorReflectance;
            underlay.right.DiffuseStrength = underlay.left.DiffuseStrength;
            underlay.right.AmbientStrength = underlay.left.AmbientStrength;
            underlay.right.AlphaDataMapping = underlay.left.AlphaDataMapping;
            underlay.right.FaceLighting = underlay.left.FaceLighting;
            underlay.right.FaceColor = underlay.left.FaceColor;
        elseif strcmp(hemi,'left')
            underlay.left.SpecularStrength = underlay.right.SpecularStrength;
            underlay.left.SpecularExponent = underlay.right.SpecularExponent;
            underlay.left.SpecularColorReflectance = underlay.right.SpecularColorReflectance;
            underlay.left.DiffuseStrength = underlay.right.DiffuseStrength;
            underlay.left.AmbientStrength = underlay.right.AmbientStrength;
            underlay.left.AlphaDataMapping = underlay.right.AlphaDataMapping;
            underlay.left.FaceLighting = underlay.right.FaceLighting;
            underlay.left.FaceColor = underlay.right.FaceColor;
        end
    case 'off'
            
        try
            res = get(0,'ScreenSize');
            if res(3)/res(4) > 3
                wSz(1) = 0.18;
                wSz(2) = 0.4;
            else
                wSz(1) = 0.5;
                wSz(2) = 0.5;
            end
        catch
            wSz(1) = 0.5;
            wSz(2) = 0.5;
        end
        
        set(gcf,'color','w');
        set(gcf,'units','normalized','outerposition',[0 0 wSz(1) wSz(2)])
end

if isfield(underlay,'right') && ~isfield(underlay,'left') && strcmp(v,'on')
    view([90 0]);
end

varargout{1} = underlay;
varargout{2} = brainFig;
varargout{3} = newFig;
varargout{4} = addedHemi;