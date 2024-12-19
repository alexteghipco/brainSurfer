function [underlay, brainFig, newFig, addedHemi] = patchUnderlay(varargin)
% Patches hemisphere vertices, manages lighting, and handles surface overlays.
%
% This function creates 3D patches for left and/or right brain hemispheres,
% adds default or specified lighting, and can overlay a new surface onto an
% existing figure. It is versatile for plotting single or dual hemispheres
% and for adding additional hemispheres to existing plots with customizable
% lighting and surface colors.
%
% **Mandatory Arguments**
% -----------------------
%   vert1   - (n x 3) Matrix of vertex coordinates for the first hemisphere, where
%             each row represents a vertex with x, y, z positions.
%
%   face1   - (m x 3 or m x 4) Matrix defining the mesh faces for the first hemisphere,
%             where each row contains indices into vert1 that form a triangular or
%             quadrilateral face.
%
% **Output**
% ----------
%   underlay - (Structure) Contains handles to the created patch objects:
%               - underlay.left  : Handle to the left hemisphere patch (if plotted).
%               - underlay.right : Handle to the right hemisphere patch (if plotted).
%
%   brainFig - (Figure Handle) Handle to the figure containing the brain plot.
%
%   newFig   - (Logical) Flag indicating whether a new figure was created (`true`) or
%              an existing one was used (`false`).
%
%   addedHemi - (String) Indicates which hemisphere was added ('left' or 'right') when
%               using the 'add' option. Empty if a new figure is created.
%
% **Optional Parameters**
% -----------------------
%   vert2, face2 - (n x 3, m x 3 or m x 4) Second set of vertices and faces for the
%                  second hemisphere. Required if plotting two hemispheres.
%
%   'add'        - (Flag) Indicates that a hemisphere should be added to an existing plot.
%
%   hemi         - (String) Specifies which hemisphere to add. Options: 'left' | 'right'.
%
%   brainFig     - (Figure Handle) Handle to the existing brain figure where the hemisphere
%                  will be added.
%
%   underlay     - (Structure) Existing underlay structure containing patch handles to which
%                  the new hemisphere will be added.
%
%   'lights'     - (String | n x 2 Array) Lighting configuration:
%                  - 'off'       : Disables lighting.
%                  - Omitted      : Uses default lighting angles.
%                  - n x 2 array  : Specifies n lighting angles, where each row contains azimuth and elevation in degrees.
%
%   'surfC'      - (1 x 3) RGB triplet specifying the surface color. Defaults to [0.5 0.5 0.5].
%
% **Function Call Examples**
% --------------------------
%   % Example 1: Plotting a Single Hemisphere
%   [underlay, brainFig] = patchUnderlay(vertices1, faces1);
%
%   % Example 2: Plotting Two Hemispheres
%   [underlay, brainFig] = patchUnderlay(vertices1, faces1, vertices2, faces2);
%
%   % Example 3: Adding a Right Hemisphere to an Existing Plot with Default Lighting
%   [underlay, brainFig] = patchUnderlay(newVerts, newFaces, 'add', 'right', brainFigureHandle, existingUnderlay);
%
%   % Example 4: Adding a Left Hemisphere with Custom Lighting and Surface Color
%   customLights = [-90 0; 90 0; 0 0; 180 0];
%   customColor = [0.7 0.7 0.7];
%   [underlay, brainFig] = patchUnderlay(newVerts, newFaces, 'add', 'left', brainFigureHandle, existingUnderlay, 'lights', customLights, 'surfC', customColor);
%
% **Notes**
% ----------
%   - The function automatically determines hemisphere orientation based on vertex coordinates unless specified otherwise.
%   - Ensure that vertices (`vert1`, `vert2`) are n x 3 matrices and faces (`face1`, `face2`) are m x 3 or m x 4 matrices.
%   - Lighting angles are specified in degrees when using the 'lights' parameter.
%   - The function supports adding hemispheres to existing figures, which is useful for incremental plotting.
%   - If adding a hemisphere, ensure that the existing `underlay` structure contains the necessary fields (`left`, `right`) as applicable.
%   - The function handles the alignment of hemispheres by calculating and applying necessary offsets to the vertex coordinates.
%   - When plotting two hemispheres, the function adjusts face indices if they contain non-positive values to ensure proper rendering.
%
% **Author:**
% Alex Teghipco // alex.teghipco@uci.edu // 11/28/18

    % Default settings:
    vert2 = [];
    face2 = [];
    n = nargin;
    
    % check to make sure at least 2 arguments are passed (i.e., vertices and faces)
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
                
                tmp = patch('Faces',brain.left.face,'Vertices',brain.left.vert,'FaceVertexCData',cdata1,'facealpha',1,'CDataMapping','direct','facecolor','interp','edgecolor','none','FaceLighting','gouraud');
                hold on
                tmp2 = patch('Faces',brain.right.face,'Vertices',brain.right.vert,'FaceVertexCData',cdata2,'facealpha',1,'CDataMapping','direct','facecolor','interp','edgecolor','none','FaceLighting','gouraud');
                
                underlay.left = tmp;
                underlay.right = tmp2;
                
            elseif isfield(brain, 'left') && ~isfield(brain, 'right')
                if min(min(brain.left.face)) <= 0
                    brain.left.face = -1*(min(min(brain.left.face)))+1+brain.left.face;
                end
                
                tmp = patch('Faces',brain.left.face,'Vertices',brain.left.vert,'FaceVertexCData',cdata1,'facealpha',1,'CDataMapping','direct','facecolor','interp','edgecolor','none','FaceLighting','gouraud');
                underlay.left = tmp;
                
            elseif isfield(brain, 'right') && ~isfield(brain, 'left')
                if min(min(brain.right.face)) <= 0
                    brain.right.face = -1*(min(min(brain.right.face)))+1+brain.right.face;
                end
                brain.right.vert(:,1) = brain.right.vert(:,1)+rh_offset;
                
                tmp2 = patch('Faces',brain.right.face,'Vertices',brain.right.vert,'FaceVertexCData',cdata2,'facealpha',1,'CDataMapping','direct','facecolor','interp','edgecolor','none','FaceLighting','gouraud');
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
                
                tmp = patch(tm,'Faces',brain.left.face,'Vertices',brain.left.vert,'FaceVertexCData',cdata1,'facealpha',1,'CDataMapping','direct','facecolor','interp','edgecolor','none','FaceLighting','gouraud');
                hold off
                underlay.left = tmp;
            elseif strcmp(hemi,'right')
                addedHemi = [addedHemi '_right'];
                if min(min(brain.right.face)) <= 0
                    brain.right.face = 1+brain.right.face;
                end
                brain.right.vert(:,1) = brain.right.vert(:,1)+rh_offset;
                hold on
                
                tmp2 = patch(tm,'Faces',brain.right.face,'Vertices',brain.right.vert,'FaceVertexCData',cdata2,'facealpha',1,'CDataMapping','direct','facecolor','interp','edgecolor','none','FaceLighting','gouraud');
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
            set(gcf,'units','normalized','outerposition',[0 0 wSz(1) wSz(2)]);
    end
    
    if isfield(underlay,'right') && ~isfield(underlay,'left') && strcmp(v,'on')
        view([90 0]);
    end
    
    varargout{1} = underlay;
    varargout{2} = brainFig;
    varargout{3} = newFig;
    varargout{4} = addedHemi;
end
