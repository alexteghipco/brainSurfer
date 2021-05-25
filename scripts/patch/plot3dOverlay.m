function [underlay, overlay] = plot3dOverlay(inData, hemi, n, w, limits, plotSwitch, brainFile, brainCurvFile)
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

% defaultBrain = 'left';
% 
% if ~isempty(hemi)
%     defaultBrain = hemi;
% end

% get OS
if ispc == 0
    sl = '/';
else
    sl = '\';
end

% Setup paths for files we need
guiPath = which(mfilename);
[guiPath, ~] = fileparts(guiPath);
id = strfind(guiPath,sl);
guiPath = guiPath(1:id(end-1)); % this assumes script is nested within two subfolders of main brainSurfer directory
brainPaths = [guiPath 'brains']; % contains lh and rh fsaveraged brains

if nargin < 2
    hemi = 'left';
end
if nargin < 3
    n = 8;
end

if nargin < 4
    w = 0.3;
end

if nargin < 5
    limits = [];
end

if nargin < 6
    plotSwitch = 'true';
end

if nargin < 8
    try
        if strcmp(hemi,'left')
            brainFile = [brainPaths sl 'lh.inflated'];
            [vert1,face1] = read_surf(brainFile);
            brainCurvFile = [brainPaths '/lh.curv'];
            curv1 = read_curv(brainCurvFile);
        else
            brainFile = [brainPaths sl 'rh.inflated'];
            [vert1,face1] = read_surf(brainFile);
            brainCurvFile = [brainPaths sl 'rh.curv'];
            curv1 = read_curv(brainCurvFile);
        end
    catch
        errordlg('Could not find brainSurfer to load LH default brain from. Provide path to files manually')
    end
else
    [vert1,face1] = read_surf(brainFile);
    curv1 = read_curv(brainCurvFile);
end

% plot colorcube
if isempty(limits)
    [rgb_out, data_out, data_rgb_out] = colorcubes(n, w, inData, plotSwitch);
else
    [rgb_out, data_out, data_rgb_out] = colorcubes(n, w, inData, plotSwitch, limits);
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
if strcmp(hemi,'left')
    view(-90, 0);
    light1 = camlight(180,180);
    light2 = camlight(0,180);
elseif strcmp(hemi,'right')
    view(90,0)
    %light1 = camlight(0,0);
    light1 = camlight(180,180);
    %light2 = camlight(0,-180);
    %light2 = camlight(90,90);
    light2 = camlight(85,0);
end
        
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

