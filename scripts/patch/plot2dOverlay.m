function [underlay, overlay] = plot2dOverlay(inData, cMap, limits, cBins, brainFile, brainCurvFile)
% it is assumed that cMap is 4 colors. The leftmost colormap will blend
% cMap(1:2,:) and the rightmost colormap will blend cMap(3:4,:)


% plot3dOverlay(inData) : pass inData, which must have as
% many rows as vertices in brain you are plotting, and exactly 3 columns. A
% colorcube will be constructed based on your data, providing 3d color
% information mapping onto ea. of the dimensions in inData.
%
% plot3dOverlay(inData, n, w, plotSwitch, limits) : n represents the length of each
% face on the 3d colorcube. w represents the width of each colorcube.
% limits is a 2 x 3 matrix where each col corresponds to the cols of
% inData. The first row for ea. col represents the min limit for that
% dimension, and the second row for ea. col represents the max limit for
% that dimension. If plotSwitch is 'true' then a figure with the colorcubes
% will be drawn (note this can take a very long time for large n)
%
% plot3dOverlay(inData, n, w, limits, brainFile, brainCurvFile) : pass
% specific brain and curvature file paths to use as underlay. Otherwise LH
% from brainSurfer will be loaded.

if nargin < 5
    try
        brainFile = '/Users/ateghipc/MATLAB-Drive/brainSurfer-master/brains/lh.inflated';
        [vert1,face1] = read_surf(brainFile);
        brainCurvFile = '/Users/ateghipc/MATLAB-Drive/brainSurfer-master/brains/lh.curv';
        curv1 = read_curv(brainCurvFile);
    catch
        errordlg('Could not find brainSurfer to load LH default brain from. Provide path to files manually')
    end
else
    [vert1,face1] = read_surf(brainFile);
    curv1 = read_curv(brainCurvFile);
end

if nargin < 4
    cBins = 10;
end

if nargin < 3
    limits(1,1) = min(inData(:,1));
    limits(2,1) = max(inData(:,1));
    limits(1,2) = min(inData(:,2));
    limits(2,2) = max(inData(:,2));
end

% interpolate between supplied colors
colorMap = zeros(cBins,cBins,3);
if size(cMap,1) == 4
    colorMap(:,1,:) = customColorMapInterp(cMap(1:2,:),cBins);
    colorMap(:,end,:) = customColorMapInterp(cMap(3:4,:),cBins);
    for i = 1:size(colorMap,2)
        mixMat = vertcat(squeeze(colorMap(i,1,:))',squeeze(colorMap(i,end,:))');
        colorMap(i,:,:) = customColorMapInterp(mixMat,cBins);
    end
else
    colorMap = cMap;
end

% plot 2d colormap
% cSpaceFig = figure;
% cSpaceImg = image(flipud(colorMap));
% truesize(cSpaceFig,[1000 1000])

% for each data point in overlay, find closest 2d bin
xLinSpace = linspace(limits(1,1), limits(2,1), cBins);
yLinSpace = linspace(limits(1,2), limits(2,2), cBins);
for i = 1:length(inData)
    disp(['Mapping data onto colormap...' num2str((i/length(inData))* 100) '%'])
    % get closest bin in the x dim
    idx1 = find(xLinSpace <= inData(i,1));
    if isempty(idx1) % if idx is empty, check if it is equal to max
       idx1 = find(round(xLinSpace,1) <= round(inData(i,1),1));
    end
    
    % Bins need to be adjusted if closest value is negative
    xbin = idx1(end);
    if xLinSpace(xbin) < 0
        xbin = xbin+1;
    end
    
    % Repeat for y dim
    idx2 = find(yLinSpace <= inData(i,2));
    if isempty(idx2) % if idx is empty, check if it is equal to max
        idx2 = find(round(yLinSpace,1) <= round(inData(i,2),1));
    end
    
    ybin = idx2(end);
    if yLinSpace(ybin) < 0
        ybin = ybin+1;
    end
    %idx2 = find(ceil(yLinSpace) <= ceil(inData(i,2)));
    %ybin = idx2(1);
    
    % get coordinate on colorcube
    data_out(i,1) = xbin;
    data_out(i,2) = ybin;
    
    % get color directly
    data_rgb_out(i,:) = colorMap(xbin,ybin,:);
end
    
[underlay, brainFig] = plotUnderlay(vert1, face1, curv1);
hold on
fields = fieldnames(underlay);
test = all(inData == 0,2);
idx = find(test == 1);
faces = underlay.(fields{1}).Faces;

% remove all faces that are zeros
removeVert = idx; % all faces that don't have these verts
removeVertX = ismember(faces(:,1),removeVert);
removeVertY = ismember(faces(:,2),removeVert);
removeVertZ = ismember(faces(:,3),removeVert);
removeVertXYZ = removeVertX+removeVertY+removeVertZ;
removeVertXYZIdx = find(removeVertXYZ > 0);
faces(removeVertXYZIdx,:) = [];

overlay = patch('Faces',faces,'Vertices',underlay.(fields{1}).Vertices,'FaceVertexCData',data_rgb_out,'FaceAlpha',1,'AlphaDataMapping' ,'none','CDataMapping','direct','facecolor','interp','edgecolor','none');

figure(brainFig)
material dull
view(-90, 0);
light1 = camlight(180,180);
light2 = camlight(0,180);
        
underlay.left.SpecularStrength = 0;
underlay.left.SpecularExponent = 10;
underlay.left.SpecularColorReflectance = 1;
underlay.left.DiffuseStrength = 0.85;
underlay.left.AmbientStrength = 0.5;
        
overlay.SpecularStrength = 0;
overlay.SpecularExponent = 1;
overlay.SpecularColorReflectance = 0;
overlay.DiffuseStrength = 0.3;
overlay.AmbientStrength = 0.8;

end

