function [varargout] = renderFSBrain2(varargin)
% Call:
% [brain, overlay] = renderFSBrain2(overlayFile, hemi, colorMapKind, limits, opacity, tails, threshold, smoothRadius, smoothSteps, smoothEmpty, clusterSizeTreshold, pictures)
% [brainLH, brainRH, overlayLH, overlayRH] = renderFSBrain2('/Users/ateghipc/Projects/PT/backups/package/experiment/test/finalTtests/testing/lh.MNI_poVSventralPT_UNEQUAL_FWE0.0001_SURFACE_MASKED_20_SMOOTHING_STEPS_WITH_1_REPS_RF_ANTs_MNI152_orig_to_fsaverage.nii.gz', 'both', 'jet', [-20 20], 0.7, 'two', [-0.01 0.01], 1, 1, 'true', 0,'true')
% [brainLH, brainRH, overlayLH, overlayRH] = renderFSBrain2('/Users/ateghipc/Projects/PT/backups/package/experiment/test/finalTtests/testing/lh.MNI_poVSventralPT_UNEQUAL_FWE0.0001_SURFACE_MASKED_20_SMOOTHING_STEPS_WITH_1_REPS_RF_ANTs_MNI152_orig_to_fsaverage.nii.gz', 'both', 'jet', [-20 20], 0.7, 'two', [-0.01 0.01], 0, 0, 'true', 0,'true')
% [brainLH, brainRH, overlayLH, overlayRH] = renderFSBrain2({'/Users/ateghipc/Projects/PT/backups/package/experiment/test/finalTtests/testing/lh.MNI_poVSventralPT_UNEQUAL_FWE0.0001_SURFACE_MASKED_20_SMOOTHING_STEPS_WITH_1_REPS_RF_ANTs_MNI152_orig_to_fsaverage.nii.gz'; '/Users/ateghipc/Projects/PT/ROI/PTClusters/LH/clusterSolutions/clusterOptimal/fsaverage/Kmeans_solution_2_CombinedClusters_FSSpace_LH.nii.gz'}, 'both', 'jet', [-20 20], 0.7, 'two', [-0.01 0.01], 0, 0, 'true', 0,'true','false',[-10 10])

% clusterSizeTreshold is not functional yet
%
%

% Adjustable defaults
overlayFile = [];
hemi = 'left';
colorMapKind = 'jet';
limits = [];
opacity = 0.8;
tails = 2;
threshold = 0;
smoothRadius = 0;
smoothSteps = 0;
smoothEmpty = 'true';
clusterSizeTreshold = 0;
pictures = 'false';
outline = 'false';
outlineThreshold = 0;

% Other defaults -- edit at your own peril
templateDir = '/Applications/freesurfer/subjects/fsaverage';
defaultC = [1.0000 0.7031 0.3906];
gyriC = [0.4 0.4 0.4];
sulciC = [0.8 0.8 0.8];
cameras = 'off';
smoothSteps = 1;
brightness = 'off';

% Check user inputs
fixedargn = 0;
if nargin > (fixedargn + 0)
    if ~isempty(varargin{1})
        overlayFile = varargin{1};
    end
end
if nargin > (fixedargn + 1)
    if ~isempty(varargin{2})
        hemi = varargin{2};
    end
end
if nargin > (fixedargn + 2)
    if ~isempty(varargin{3})
        colorMapKind = varargin{3};
    end
end
if nargin > (fixedargn + 3)
    if ~isempty(varargin{4})
        limits = varargin{4};
    end
end
if nargin > (fixedargn + 4)
    if ~isempty(varargin{5})
        opacity = varargin{5};
    end
end
if nargin > (fixedargn + 5)
    if ~isempty(varargin{6})
        tails = varargin{6};
    end
end
if nargin > (fixedargn + 6)
    if ~isempty(varargin{7})
        threshold = varargin{7};
    end
end

if nargin > (fixedargn + 7)
    if ~isempty(varargin{8})
        smoothRadius = varargin{8};
    end
end

if nargin > (fixedargn + 8)
    if ~isempty(varargin{9})
        smoothSteps = varargin{9};
    end
end

if nargin > (fixedargn + 9)
    if ~isempty(varargin{10})
        smoothEmpty = varargin{10};
    end
end

if nargin > (fixedargn + 10)
    if ~isempty(varargin{11})
        clusterSizeTreshold = varargin{11};
    end
end

if nargin > (fixedargn + 11)
    if ~isempty(varargin{12})
        pictures = varargin{12};
    end
end

if nargin > (fixedargn + 12)
    if ~isempty(varargin{13})
        outline = varargin{13};
    end
end

if nargin > (fixedargn + 13)
    if ~isempty(varargin{14})
        outlineThreshold = varargin{14};
    end
end

% load up a surface and set up the number of times you will have to repeat
% the process (i.e., twice if you want to do both hemispheres).
switch hemi
    case 'both'
        reps = 2;
        [hemiVert, hemiFace] = read_surf([templateDir '/surf/lh.inflated']);
        [hemiCurv] = read_curv([templateDir '/surf/lh.curv']);
        view_angle=[-90 0]; %lateral view for left hemisphere;
    case 'left'
        reps = 1;
        [hemiVert, hemiFace] = read_surf([templateDir '/surf/lh.inflated']);
        [hemiCurv] = read_curv([templateDir '/surf/lh.curv']);
        view_angle=[-90 0]; %lateral view for left hemisphere;
    case 'right'
        reps = 1;
        [hemiVert, hemiFace] = read_surf([templateDir '/surf/rh.inflated']);
        [hemiCurv] = read_curv([templateDir '/surf/rh.curv']);
        view_angle=[90 0]; %lateral view for left hemisphere;
end

% go through the number of times you need to plot a surface
for rep = 1:reps
    if rep == 2 % load in the remaining hemisphere (always RH)
        [hemiVert, hemiFace] = read_surf([templateDir '/surf/rh.inflated']);
        [hemiCurv] = read_curv([templateDir '/surf/rh.curv']);
        hemiVert(:,1) = hemiVert(:,1)+90;
    end
    
    % find sucli & gyri & create patches of color for each vertex
    gyriVert=find(hemiCurv>0);
    hemiData(gyriVert,:) = repmat(gyriC,[size(gyriVert),1]);
    sulcVert=find(hemiCurv<0);
    hemiData(sulcVert,:) = repmat(sulciC,[size(sulcVert),1]);
    
    % plot the patches
    if rep == 1
        brain = patch('Faces',hemiFace+1,'Vertices',hemiVert,'FaceVertexCData',hemiData,'facealpha',1,'CDataMapping','direct','facecolor','interp','edgecolor','none');
    else
        brain2 = patch('Faces',hemiFace+1,'Vertices',hemiVert,'FaceVertexCData',hemiData,'facealpha',1,'CDataMapping','direct','facecolor','interp','edgecolor','none');
    end
    set(gca,'xlim',[min(hemiVert(:,1)) max(hemiVert(:,1))],'ylim',[min(hemiVert(:,2)) max(hemiVert(:,2))],'zlim',[min(hemiVert(:,3)) max(hemiVert(:,3))]);
    
    if rep == 1
        varargout{1} = brain;
    end
    
    if rep == 2
        varargout{2} = brain2;
    end
    
    % set the camera defaults now in case there is no overlay
    disp('Turning on cameras and updating figure properties...')
    axis off vis3d equal tight;
    view(view_angle(1), view_angle(2));
    material dull
    
    switch cameras
        case 'on'
            camlight(-90,0);
            camlight(90,0);
            camlight(0,0);
            camlight(180,0);
            %camlight(180,90); % this will make it REALLY bright
    end
    
    % check if you need to overlay a map
    if isempty(overlayFile) ~= 1
        
        % if you do need to overlay a map, setup overlay properties
        bins = 1000;
        disp('Setting up colormap properties for overlay...')
        switch colorMapKind
            case 'jet'
                cMap = jet(bins);
            case 'parula'
                cMap = parula(bins);
            case 'hsv'
                cMap = hsv(bins);
            case 'hot'
                cMap = hot(bins);
            case 'cool'
                cMap = cool(bins);
            case 'spring'
                cMap = spring(bins);
            case 'summer'
                cMap = summer(bins);
            case 'autumn'
                cMap = autumn(bins);
            case 'winter'
                cMap = winter(bins);
            case 'gray'
                cMap = gray(bins);
            case 'bone'
                cMap = bone(bins);
            case 'copper'
                cMap = copper(bins);
            case 'pink'
                cMap = pink(bins);
            case 'lines'
                cMap = lines(bins);
            case 'colorcube'
                cMap = colorcube(bins);
            case 'prism'
                cMap = prism(bins);
        end
        
        % check if you want to plot multiple overlays...
        if isa(overlayFile,'cell') == 1
            secondary = overlayFile;
            secondary(1) = [];
            overlayFile = overlayFile{1};
        end
        
        % now load in the actual data
        overlayHDR = load_nifti(overlayFile);
        [path, fileName] = fileparts(overlayFile);
        
        % if you are on rep 2, look for rh overlay to load in
        if rep == 2 % load in the remaining hemisphere (always RH)
            overlayHDR = load_nifti([path '/rh' fileName(3:end) '.gz']);
            %             if strfind(fileName(1:2),'lh') == 1
            %                 overlayHDR = load_nifti([path '/rh' fileName(3:end) '.gz']);
            %             end
            %
            %             if strfind(fileName(1:2),'rh') == 1
            %                 overlayHDR = load_nifti([path '/lh' fileName(3:end) '.gz']);
            %             end
        end
        data = overlayHDR.vol;
        
        % smooth the data if necessary
        if smoothRadius > 0 && smoothSteps > 0
            switch smoothEmpty
                case 'true'
                    disp('Smoothing zeros in your map...empty space should look slighlty larger')
                    disp(['Using a radius of ' num2str(smoothRadius)])
                    disp(['Using ' num2str(smoothSteps) ' step(s)'])
                    smoothVert = find(data == 0); % identify vertices to smooth
                    [~,I] = pdist2(hemiVert,hemiVert(smoothVert,:),'euclidean','Smallest',smoothRadius); % get smoothSteps nearest vertices to each vertex to smooth (x is smoothing steps)
                    for i = 1:smoothSteps % repeat smoothing process smoothSteps # of times
                        data(smoothVert) = mean(data(I),1);
                    end
                case 'false'
                    disp('Smoothing non-zero values in your map...empty space should look slightly smaller')
                    disp(['Using a radius of ' num2str(smoothRadius)])
                    disp(['Using ' num2str(smoothSteps) ' step(s)'])
                    smoothVert = find(data ~= 0); % identify vertices to smooth
                    [~,I] = pdist2(hemiVert,hemiVert(smoothVert,:),'euclidean','Smallest',smoothRadius); % get smoothSteps nearest vertices to each vertex to smooth (x is smoothing steps)
                    for i = 1:smoothSteps % repeat smoothing process smoothSteps # of times
                        data(smoothVert) = mean(data(I),1);
                    end
            end
        end
        
        % find any vertices matching threshold condition in data and remove their associated faces
        oFace = hemiFace+1;
        if isempty(threshold) ~= 1
            if length(threshold) == 1
                warning(['Removing all values lower than ' num2str(threshold)])
                emptyVert = find(data < threshold);
                emptyVertFaceX = ismember(oFace(:,1),emptyVert);
                emptyVertFaceY = ismember(oFace(:,2),emptyVert);
                emptyVertFaceZ = ismember(oFace(:,3),emptyVert);
                emptyVertFaceXYZ = (emptyVertFaceX+emptyVertFaceY+emptyVertFaceZ);
                emptyVertFaceXYZIdx = find(emptyVertFaceXYZ > 0);
                
                oFace(emptyVertFaceXYZIdx,:) = [];
            else
                emptyVert = find(data < threshold(2) & data > threshold(1));
                warning(['Removing all values between ' num2str(threshold(1)) ' and ' num2str(threshold(2))])
                emptyVertFaceX = ismember(oFace(:,1),emptyVert);
                emptyVertFaceY = ismember(oFace(:,2),emptyVert);
                emptyVertFaceZ = ismember(oFace(:,3),emptyVert);
                emptyVertFaceXYZ = emptyVertFaceX+emptyVertFaceY+emptyVertFaceZ;
                emptyVertFaceXYZIdx = find(emptyVertFaceXYZ ~= 0);
                
                oFace(emptyVertFaceXYZIdx,:) = [];
            end
        else
            warning('Your map is not thresholded so every vertex will have an assigned color')
        end
        
        % map all of your data onto the heatmap
        if isempty(limits) == 1 % if not provided get limits
            limits = [ceil(min(data)) ceil(max(data))];
        end
        
        switch tails
            case 'one'
                warning('One tail option was selected so all spaces between limits will be even in colorscale')
                binSpace = linspace(limits(1),limits(2),bins);
            case 'two'
                warning('Two tail option was selected so positive values up to max will take up half the colorscale and negative values up to min will take up the other half')
                cMapPos = cMap((1:length(cMap)/2),:);
                cMapNeg = cMap((length(cMap)+1)/2:end,:);
                binSpaceNeg = linspace(limits(1),0,bins/2);
                binSpacePos = linspace(0,limits(2),bins/2);
                cMap = vertcat(cMapPos,cMapNeg);
                binSpace = horzcat(binSpaceNeg,binSpacePos);
        end
        
        for i = 1:size(data,1)
            emptyVert = find(binSpace >= data(i));
            if isempty(emptyVert) == 1
                emptyVert = size(binSpace,2);
            end
            cData(i,:) = cMap(emptyVert(1),:);
        end
        
        disp('Plotting overlay...')
        if rep == 1
            overlay = patch('Faces',oFace,'Vertices',hemiVert,'FaceVertexCData',cData,'facealpha',opacity,'CDataMapping','direct','facecolor','interp','edgecolor','none');
            overlay.SpecularStrength = 0;
        else
            overlay2 = patch('Faces',oFace,'Vertices',hemiVert,'FaceVertexCData',cData,'facealpha',opacity,'CDataMapping','direct','facecolor','interp','edgecolor','none');
            overlay2.SpecularStrength = 0;
        end
        
        colorbar;
        colormap(cMap);
        caxis(limits);
        set(gcf,'color','w');
        
        % if you want the overlay to be brighter...
        switch brightness
            case 'on'
                if rep == 1
                    overlay.EdgeColor = 'interp';
                    overlay.EdgeAlpha = 0.8;
                    overlay.FaceAlpha = 0.6;
                    overlay.LineWidth = 0.2;
                    overlay.DiffuseStrength = 0.8;
                else
                    overlay2.EdgeColor = 'interp';
                    overlay2.EdgeAlpha = 0.8;
                    overlay2.FaceAlpha = 0.6;
                    overlay2.LineWidth = 0.2;
                    overlay2.DiffuseStrength = 0.8;
                end
            case 'off'
                % overlay.EdgeColor = 'none';
                % overlay.FaceAlpha = 0.8;
                % overlay.DiffuseStrength = 0.4;
                %                 overlay.SpecularColorReflectance = 0.2;
                %                 overlay.SpecularStrength = 0.2;
                %                 overlay.SpecularExponent = 5;
                %                 overlay.DiffuseStrength = 0.9;
                
        end
        
        if rep == 1
            if reps == 2
                varargout{3} = overlay;
                
            end
            if reps == 1
                varargout{2} = overlay;
                
            end
        end
        
        if rep == 2
            varargout{4} = overlay2;
            %             brain.DiffuseStrength = 0.4;
            %             brain2.DiffuseStrength = 0.4;
        end
    end
end

% now overlay any secondary files
if exist('secondary','var') == 1
    switch outline
        case 'true'
            disp('test')
            
        case 'false'
            if length(secondary) <= 5  
                % load in surfaces again...
                if reps == 1
                    oFace = brain.Faces;
                else
                    oFaceL = brain.Faces;
                    oFaceR = brain2.Faces;
                end
                
                if length(secondary) > 0 && length(secondary) < 2
                    overlay1HDR = load_nifti(secondary{1});
                    %[path, fileName] = fileparts(overlay1HDR);
                    data1 = overlay1HDR.vol;
                    
                    
                    
                    
                    oFace1 = 
                    
                end
                if length(secondary) > 1 && length(secondary) < 3
                    overlay1HDR = load_nifti(secondary{1});
                    data1 = overlay1HDR.vol;
                    overlay2HDR = load_nifti(secondary{2});
                    data2 = overlay2HDR.vol;
                end
                if length(secondary) > 2 && length(secondary) < 4
                    overlay1HDR = load_nifti(secondary{1});
                    data1 = overlay1HDR.vol;
                    overlay2HDR = load_nifti(secondary{2});
                    data2 = overlay2HDR.vol;
                    overlay3HDR = load_nifti(secondary{3});
                    data3 = overlay3HDR.vol;
                end
                if length(secondary) > 3 && length(secondary) < 5
                    overlay1HDR = load_nifti(secondary{1});
                    data1 = overlay1HDR.vol;
                    overlay2HDR = load_nifti(secondary{2});
                    data2 = overlay2HDR.vol;
                    overlay3HDR = load_nifti(secondary{3});
                    data3 = overlay3HDR.vol;
                    overlay4HDR = load_nifti(secondary{4});
                    data4 = overlay4HDR.vol;
                end
                if length(secondary) > 4 && length(secondary) < 6
                    overlay1HDR = load_nifti(secondary{1});
                    data1 = overlay1HDR.vol;
                    overlay2HDR = load_nifti(secondary{2});
                    data2 = overlay2HDR.vol;
                    overlay3HDR = load_nifti(secondary{3});
                    data3 = overlay3HDR.vol;
                    overlay4HDR = load_nifti(secondary{4});
                    data4 = overlay4HDR.vol;
                    overlay5HDR = load_nifti(secondary{5});
                    data5 = overlay5HDR.vol;
                end
                
            else
                warning('You can only overlay up to 5 files...overlaying only the first 5 files')
                
            end
    end
end

switch pictures
    case 'true'
        oDir = [path '/' fileName(1:end-4) '_screenshots'];
        mkdir(oDir)
        % set up the figure
        set(gcf,'units','normalized','outerposition',[0 0 1 1])
        if reps == 1
            % inferior view
            view(90, -90);
            saveas(gcf,[path '/' fileName(1:end-4) '_screenshots/' fileName(1:end-4) '_inferior.png']);
            % superior
            view(-90,90);
            saveas(gcf,[path '/' fileName(1:end-4) '_screenshots/' fileName(1:end-4) '_superior.png']);
            % lateral
            view(-90, 0);
            saveas(gcf,[path '/' fileName(1:end-4) '_screenshots/' fileName(1:end-4) '_left.png']);
            % medial
            view(90, 0);
            saveas(gcf,[path '/' fileName(1:end-4) '_screenshots/' fileName(1:end-4) '_right.png']);
        else
            % inferior view
            view(90, -90);
            saveas(gcf,[path '/' fileName(1:end-4) '_screenshots/' fileName(1:end-4) '_inferior.png']);
            % superior
            view(-90,90);
            saveas(gcf,[path '/' fileName(1:end-4) '_screenshots/' fileName(1:end-4) '_superior.png']);
            % lateral from left
            view(-90, 0);
            saveas(gcf,[path '/' fileName(1:end-4) '_screenshots/' fileName(1:end-4) '_left_lateral.png']);
            % lateral from right
            view(90, 0);
            saveas(gcf,[path '/' fileName(1:end-4) '_screenshots/' fileName(1:end-4) '_right_lateral.png']);
            % right medial
            view(-90, 0);
            brain.FaceAlpha = 0;
            overlay.FaceAlpha = 0;
            saveas(gcf,[path '/' fileName(1:end-4) '_screenshots/' fileName(1:end-4) '_right_medial.png']);
            % left medial
            view(90, 0);
            brain.FaceAlpha = 1;
            overlay.FaceAlpha = opacity;
            brain2.FaceAlpha = 0;
            overlay2.FaceAlpha = 0;
            saveas(gcf,[path '/' fileName(1:end-4) '_screenshots/' fileName(1:end-4) '_left_medial.png']);
        end
        brain2.FaceAlpha = 1;
        overlay2.FaceAlpha = opacity;
end


