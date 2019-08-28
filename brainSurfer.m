function varargout = brainSurfer(varargin)
% Brainsurfer GUI version 1
% Alex Teghipco // alex.teghipco@uci.edu // 04/08/19
%
% Too many updates to list!
%
% Last Modified by GUIDE v2.5 09-Apr-2019 15:09:56

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %% %% Setup and initialize %% %% %% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @brainSurfer_OpeningFcn, ...
    'gui_OutputFcn',  @brainSurfer_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before brainSurfer is made visible.
function brainSurfer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to brainSurfer (see VARARGIN)

% Choose default command line output for brainSurfer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% % This sets up the initial plot - only do when we are invisible
% % so window can get raised using brainSurfer.
% if strcmp(get(hObject,'Visible'),'off')
%     plot(rand(5));
% end

% get OS
if ispc == 0
    handles.paths.slash = '/';
else
    handles.paths.slash = '\';
end

% Setup paths for files we need
guiPath = which(mfilename);
[guiPath, ~] = fileparts(guiPath);

handles.paths.brainPath = [guiPath handles.paths.slash 'brains']; % contains lh and rh fsaveraged brains
handles.paths.scriptPath = [guiPath handles.paths.slash 'scripts']; % contains all the scripts
handles.paths.colormapsPath = [guiPath handles.paths.slash 'colormaps']; % contains all the colormaps

% if you need freesurfer path, this can work but freesurfer scripts come
% baked into brain surfer
% [~, bashProfile] = system('echo "$(<~/.bash_profile)"'); 
% bashProfile = splitlines(bashProfile);
% if any(contains(bashProfile,'FREESURFER_HOME='))
%     cIdx = find(contains(bashProfile,'FREESURFER_HOME='));
%     strIdx = strfind(bashProfile{cIdx},'FREESURFER_HOME=');
%     handles.paths.FS = bashProfile{cIdx}(strIdx(1)+16:end);
% else
%     handles.paths.FS = [handles.paths.scriptPath '/FS'];
% end
% addpath(handles.paths.FS);

% these are some settings that will help keep track of lighting options
% that are turned on (while switching overlays)
handles.cameras = cell(1);
handles.materials = cell(1);
handles.lightType = cell(1);

if exist(handles.paths.scriptPath,'dir') ~= 7
    error('It looks like the directory of scripts this gui draws on is missing (should be in ./scripts)')
else
    addpath(genpath(guiPath))
end

% Setup default parameters for any overlay loaded for the first time
handles.defaultOptions = struct('colormap',2,'overlayThresholdNeg',0,'overlayThresholdPos',0,'limitMin',[],'limitMax',[],'opacity',1,'colormapSpacing','even','colorBins',1000, 'clusterThresh',0,'binarize',0,'inclZero','true','outline','false','smoothSteps',0,'smoothArea',1,'smoothThreshold','above','customColor',[],'binarizeClusters','false','pThresh',0,'pVals',[],'transparencyLimits',[],'transparencyThresholds',[],'transparencyData',[],'transparencyPThresh',[],'invertColor','false','invertOpacity','false','growROI',0,'smoothType','neighbors');

% Load in colormaps
colormapDir = dir([handles.paths.colormapsPath handles.paths.slash '*.mat']);
colormaps = {colormapDir.name};
for colori = 1:length(colormaps)
    colormaps{colori} = colormaps{colori}(1:end-4);
end

if isempty(colormaps) == 0
    handles.colormapCustom = vertcat(zeros([length(handles.colormap.String), 1]),ones([length(colormaps), 1]));
    handles.colormap.String = vertcat(handles.colormap.String,colormaps');
else
    handles.colormapCustom = vertcat(zeros([length(handles.colormap.String), 1]));
end
% Change some default settings for handles that are auto-generated with
% GUIDE
set(handles.overlaySelection,'Max',1000,'Min',0); % don't allow more than 50 overlays to be plotted in brainSurfer at once
set(handles.overlaySelection,'String',cellstr(handles.overlaySelection.String)); % change the string from overlaySelection to a cell

guidata(hObject, handles);
% UIWAIT makes brainSurfer wait for user response (see UIRESUME)
% uiwait(handles.brainSurferGUI);

% --- output for brainSurfer
function varargout = brainSurfer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Get default command line output from handles structure
% varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %% %% Open a surface %% %% %% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function surfaceSelection_Callback(hObject, eventdata, handles)
% get handles
handles = guidata(hObject);
if isfield(handles,'brainFig')
    handles.lastAct = 'new';
end

% if you selected both hemispheres of included fsaverage brain
if hObject.Value == 2
    % load in surface data
    [vert1,face1] = read_surf([handles.paths.brainPath handles.paths.slash 'lh.inflated']);
    [vert2,face2] = read_surf([handles.paths.brainPath handles.paths.slash 'rh.inflated']);
    % load in curvature data
    curv1 = read_curv([handles.paths.brainPath handles.paths.slash 'lh.curv']);
    curv2 = read_curv([handles.paths.brainPath handles.paths.slash 'rh.curv']);
    % patch underlay
    [handles.underlay, handles.brainFig] = plotUnderlay(vert1, face1, curv1, vert2, face2, curv2);
end

% if you selected just the left hemisphere of included fsaverage brain
if hObject.Value == 3
    [vert1,face1] = read_surf([handles.paths.brainPath handles.paths.slash 'lh.inflated']);
    curv1 = read_curv([handles.paths.brainPath handles.paths.slash 'lh.curv']);
    [handles.underlay, handles.brainFig] = plotUnderlay(vert1, face1, curv1);
end

% if you selected just the right hemisphere of included fsaverage brain
if hObject.Value == 4
    [vert1,face1] = read_surf([handles.paths.brainPath handles.paths.slash 'rh.inflated']);
    curv1 = read_curv([handles.paths.brainPath handles.paths.slash 'rh.curv']);
    [handles.underlay, handles.brainFig] = plotUnderlay(vert1, face1, curv1);
end

% if you've chosen to load in your own surface
if hObject.Value == 5 
    % load surface data and curv files
    brainFile = uipickfiles('FilterSpec','*.inflated','Prompt','Select one or two surface(s) to plot.');
    handles.w = warndlg('Please select your curvature files in the same order as the surfaces!');
    curvFile = uipickfiles('FilterSpec','*.curv','Prompt','Select curvatures for each of your surface(s)');
    
    % plot underlay automatically figures out which hemisphere is left vs
    % right using coordinates
    handles.w = warndlg('Assuming vertex positioning is in radiological convention (left is negative)');
    if length(brainFile) > 1 % if you selected two files lets load both in
        [vert1,face1] = read_surf(brainFile{1});
        [vert2,face2] = read_surf(brainFile{2});
        curv1 = read_curv(curvFile{1});
        curv2 = read_curv(curvFile{2});
        [handles.underlay, handles.brain] = plotUnderlay(vert1, face1, curv1, vert2, face2, curv2);
    else % if you selected one file just load that in and figure out which is negative
        [vert1,face1] = read_surf(brainFile{1});
        curv1 = read_curv(curvFile{1});
        [handles.underlay, handles.brain] = plotUnderlay(vert1, face1, curv1);
    end
end

% now setup some basic variables we'll need for visualizing multiple
% overlays or changing camera lighting
% handles.materials.flatButton = [];
% handles.materials.shinyButton = [];
% handles.materials.dullButton = 1;
% handles.multiOverlay = [];

% update handles
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %% %% Open an overlay %% %% %% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load overlay
function overlayAdd_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
if isfield(handles, 'underlay') % only allow for button to work if there's an underlay
    
    % get all overlay files
    overlayFiles = uipickfiles('REFilter','\.nii.gz$|\.nii$','Prompt','Select one or more overlays')';
    
    % uipickfiles returns an empty variable if user cancels. Ensure that hasn't happened before continuing
    if isa(overlayFiles,'cell')
        % find # of existing overlays
        numSavedOverlays = length(handles.overlaySelection.String) - 1; % we subtract one because index starts at no overlay
        
        % loop through loaded files and save each file's name in brainMap structure and data in
        % brainMap.Original.Data. We save the name so we can reload the
        % file if necessary.
        for filei = 1:length(overlayFiles)
            storedFileNum = numSavedOverlays+filei; % this is the index for this file in main data structure
            
            % populate brainMap.Current structure
            handles.brainMap.Current{storedFileNum} = handles.defaultOptions;
            [handles.brainMap.Current{storedFileNum}.path, handles.brainMap.Current{storedFileNum}.name, handles.brainMap.Current{storedFileNum}.ext] = fileparts(overlayFiles{filei}); % get file name and path so that data can be reloaded
            hdr = load_nifti(overlayFiles{filei}); % load in data
            handles.brainMap.Current{storedFileNum}.Data = hdr.vol;
            handles.brainMap.Current{storedFileNum}.limitMin = min(hdr.vol);
            handles.brainMap.Current{storedFileNum}.limitMax = max(hdr.vol);
            
            % Figure out which hemisphere the file belongs to...
            % it's a problem if the file either references both hemispheres
            % or neither hemisphere so lets check for that first

            % on older versions of matlab, contains function does not
            % search strings :( so we must implement a different approach
            % just in case
            try
                if (contains(lower(handles.brainMap.Current{storedFileNum}.name),lower({'left', 'lh'})) && contains(lower(handles.brainMap.Current{storedFileNum}.name),lower({'right', 'rh'}))) || (~contains(lower(handles.brainMap.Current{storedFileNum}.name),lower({'left', 'lh'})) && ~contains(lower(handles.brainMap.Current{storedFileNum}.name),lower({'right', 'rh'})))
                    % if the file is name is ambiguous ask user to confirm which hemisphere this
                    % overlay should be plotted over
                    handles.brainMap.Current{storedFileNum}.hemi = questdlg(['Which hemisphere should ' handles.brainMap.Current{storedFileNum}.name ' be overlayed on?'], 'Your file name does not clearly reference one hemisphere','left','right','left');
                    % otherwise check for right or left hemisphere
                elseif contains(lower(handles.brainMap.Current{storedFileNum}.name),lower({'left', 'lh'}))
                    handles.brainMap.Current{storedFileNum}.hemi = 'left';
                elseif contains(lower(handles.brainMap.Current{storedFileNum}.name),lower({'right', 'rh'}))
                    handles.brainMap.Current{storedFileNum}.hemi = 'right';
                end
                
            catch
                ss = {'left', 'lh', 'rh', 'right'};
                fun = @(s)~cellfun('isempty',strfind(lower({handles.brainMap.Current{storedFileNum}.name}),s));
                out = cellfun(fun,ss,'UniformOutput',false);
                
                if sum(horzcat(out{:})) > 1
                    if sum(horzcat(out{1:2})) == 2 || sum(horzcat(out{3:4})) == 2
                        if sum(horzcat(out{1:2})) == 2
                            handles.brainMap.Current{storedFileNum}.hemi = 'left';
                        elseif sum(horzcat(out{3:4})) == 2
                            handles.brainMap.Current{storedFileNum}.hemi = 'right';
                        end
                    else
                        handles.brainMap.Current{storedFileNum}.hemi = questdlg(['Which hemisphere should ' handles.brainMap.Current{storedFileNum}.name ' be overlayed on?'], 'Your file name does not clearly reference one hemisphere','left','right','left');
                    end
                elseif sum(horzcat(out{1:2})) == 1
                    handles.brainMap.Current{storedFileNum}.hemi = 'left';
                elseif sum(horzcat(out{3:4})) == 1
                    handles.brainMap.Current{storedFileNum}.hemi = 'right';
                end
            end
        end
        
        % now update visible overlays in GUI
        %handles.overlaySelection.String = vertcat(handles.overlaySelection.String(:),extractfield([handles.brainMap.Current{numSavedOverlays+1:(numSavedOverlays+length(overlayFiles))}],'name')');
        tmp = ([handles.brainMap.Current{numSavedOverlays+1:(numSavedOverlays+length(overlayFiles))}]);
        handles.overlaySelection.String = vertcat(handles.overlaySelection.String(:),tmp.name);
        
    end
    
    guidata(hObject, handles);
end


%% Import an overlay
function importOverlay_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
if isfield(handles, 'underlay') && (exist('convertMNI2FS.m','file') && exist('convertMNI2FSWithMask.m','file') && exist('convertROIForFS.m','file')) %only allow for button to work if there's an underlay and you have access to conversion files
    handles.w = warndlg('Only importing of 2mm MNI_152 files is currently possible.');
        overlayFiles = uipickfiles('REFilter','\.nii.gz$|\.nii$','Prompt','Select one or more overlays')';
        if iscell(overlayFiles)
            importOptions = questdlg('What kind of file(s) is(are) this?','Conversion options','Thresholded map','Contains one or more ROIs','Unthresholded map','Unthresholded map');
            switch importOptions
                case 'Thresholded map'
                    smoothing = inputdlg({'Smoothing area', 'Smoothing steps'});
                    if isempty(smoothing{1})
                        smoothing{1} = '0';
                    end
                    if isempty(smoothing{2})
                        smoothing{2} = '0';
                    end
                    outFiles = {};
                    for i = 1:length(overlayFiles)
                        tmpOut = convertMNI2FSWithMask(overlayFiles{i}, str2double(smoothing{1}), str2double(smoothing{2}),handles.paths.brainPath);
                        outFiles = vertcat(outFiles,tmpOut);
                    end
                case 'Contains one or more ROIs'
                    weight = inputdlg('Enter a weight vector for ROIs or leave blank for default no weighting option (1s given preference over 0s ; assuming 1s and 0s are in order of ROI values in map)','Define ROI weights');
                    if strcmp(weight{1},'[]') || isempty(weight)
                        weight = [];
                    else
                        weight = str2double(weight);
                    end
                    outFiles = {};
                    for i = 1:length(overlayFiles)
                        try
                            tmpOut = convertROIForFS(overlayFiles{i}, weight{1});
                        catch
                            tmpOut = convertROIForFS(overlayFiles{i}, []);
                        end
                        outFiles = vertcat(outFiles,tmpOut);
                    end
                case 'Unthresholded map'
                    outFiles = {};
                    for i = 1:length(overlayFiles)
                        tmpOut = convertMNI2FS(overlayFiles{i},[]);
                        outFiles = vertcat(outFiles,tmpOut);
                    end
            end
            % remove confidence maps
            cellCon = find(contains(outFiles,'Confidence'));
            outFiles(cellCon) = [];
            overlayFiles = outFiles;
            
            % find # of existing overlays
            numSavedOverlays = length(handles.overlaySelection.String) - 1; % we subtract one because index starts at no overlay
            
            % loop through loaded files and save each file's name in brainMap structure and data in
            % brainMap.Original.Data. We save the name so we can reload the
            % file if necessary.
            for filei = 1:length(overlayFiles)
                storedFileNum = numSavedOverlays+filei; % this is the index for this file in main data structure
                handles.brainMap.Current{storedFileNum} = handles.defaultOptions; % load in some default settings for the current overlay
                
                [handles.brainMap.Current{storedFileNum}.path, handles.brainMap.Current{storedFileNum}.name] = fileparts(overlayFiles{filei}); % get file name and path so that data can be reloaded
                hdr = load_nifti(overlayFiles{filei}); % load in data
                
                % populate brainMap.Current structure
                handles.brainMap.Current{storedFileNum}.Data = hdr.vol;
                handles.brainMap.Current{storedFileNum}.limitMin = min(hdr.vol);
                handles.brainMap.Current{storedFileNum}.limitMax = max(hdr.vol);
                
                % Figure out which hemisphere the file belongs to...
                % it's a problem if the file either references both hemispheres
                % or neither hemisphere so lets check for that first
                try
                    if (contains(lower(handles.brainMap.Current{storedFileNum}.name),lower({'left', 'lh'})) && contains(lower(handles.brainMap.Current{storedFileNum}.name),lower({'right', 'rh'}))) || (~contains(lower(handles.brainMap.Current{storedFileNum}.name),lower({'left', 'lh'})) && ~contains(lower(handles.brainMap.Current{storedFileNum}.name),lower({'right', 'rh'})))
                        % if the file is name is ambiguous ask user to confirm which hemisphere this
                        % overlay should be plotted over
                        handles.brainMap.Current{storedFileNum}.hemi = questdlg(['Which hemisphere should ' handles.brainMap.Current{storedFileNum}.name ' be overlayed on?'], 'Your file name does not clearly reference one hemisphere','left','right','left');
                        % otherwise check for right or left hemisphere
                    elseif contains(lower(handles.brainMap.Current{storedFileNum}.name),lower({'left', 'lh'}))
                        handles.brainMap.Current{storedFileNum}.hemi = 'left';
                    elseif contains(lower(handles.brainMap.Current{storedFileNum}.name),lower({'right', 'rh'}))
                        handles.brainMap.Current{storedFileNum}.hemi = 'right';
                    end
                catch
                    ss = {'left', 'lh', 'rh', 'right'};
                    fun = @(s)~cellfun('isempty',strfind(lower({handles.brainMap.Current{storedFileNum}.name}),s));
                    out = cellfun(fun,ss,'UniformOutput',false);
                    
                    if sum(horzcat(out{:})) > 1
                        if sum(horzcat(out{1:2})) == 2 || sum(horzcat(out{3:4})) == 2
                            if sum(horzcat(out{1:2})) == 2
                                handles.brainMap.Current{storedFileNum}.hemi = 'left';
                            elseif sum(horzcat(out{3:4})) == 2
                                handles.brainMap.Current{storedFileNum}.hemi = 'right';
                            end
                        else
                            handles.brainMap.Current{storedFileNum}.hemi = questdlg(['Which hemisphere should ' handles.brainMap.Current{storedFileNum}.name ' be overlayed on?'], 'Your file name does not clearly reference one hemisphere','left','right','left');
                        end
                    elseif sum(horzcat(out{1:2})) == 1
                        handles.brainMap.Current{storedFileNum}.hemi = 'left';
                    elseif sum(horzcat(out{3:4})) == 1
                        handles.brainMap.Current{storedFileNum}.hemi = 'right';
                    end
                end
            end
            
            % now update visible overlays in GUI
            %handles.overlaySelection.String = vertcat(handles.overlaySelection.String(:),extractfield([handles.brainMap.Current{numSavedOverlays+1:(numSavedOverlays+length(overlayFiles))}],'name')');
            tmp = ([handles.brainMap.Current{numSavedOverlays+1:(numSavedOverlays+length(overlayFiles))}]);
            handles.overlaySelection.String = vertcat(handles.overlaySelection.String(:),tmp.name);
            
            guidata(hObject, handles);
        end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %% %% Select an overlay %% %% %% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on selection change in overlaySelection.
function overlaySelection_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
% remove any warnings that may have been thrown 
if isfield(handles,'w') % if the warning field exists
    if isvalid(handles.w) % check if it's a valid handle
        close(handles.w) % close it
        handles = rmfield(handles,'w');
    else
        handles = rmfield(handles,'w');
    end
end

if isfield(handles,'brainMap')
    % remove colorbar if it exists
    if isfield(handles.brainMap,'colorbar')
        delete(handles.brainMap.colorbar)
        handles.brainMap = rmfield(handles.brainMap,'colorbar');
    end
    
    % now turn off any overlays that might exist and delete them
    % multioverlays are in a cell
    if isfield(handles,'lastAct')
        if ~strcmp(handles.lastAct,'new')
            if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
                if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
                    for celli = 1:length(handles.brainMap.overlay)
                        try
                             handles.brainMap.overlay{celli}.FaceAlpha = 0;
                        catch
                            delete(handles.brainMap.overlay{celli});
                        end
                    end
                    handles.brainMap = rmfield(handles.brainMap,'overlay');
                elseif isvalid(handles.brainMap.overlay)
                    handles.overlayCopy = handles.brainMap.overlay;
                    handles.brainMap.overlay.FaceAlpha = 0;
                    handles.brainMap = rmfield(handles.brainMap,'overlay');
                end
            end
            handles.lastAct = 'not new';
        end
    else
        if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
            if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
                for celli = 1:length(handles.brainMap.overlay)
                    try
                        handles.brainMap.overlay{celli}.FaceAlpha = 0;
                    catch
                        delete(handles.brainMap.overlay{celli});
                    end
                end
                handles.brainMap = rmfield(handles.brainMap,'overlay');
            elseif isvalid(handles.brainMap.overlay)
                handles.overlayCopy = handles.brainMap.overlay;
                handles.brainMap.overlay.FaceAlpha = 0;
                handles.brainMap = rmfield(handles.brainMap,'overlay');
            end
        end
    end
    
    % if you have selected one overlay
    if length(handles.overlaySelection.Value) == 1
        if handles.overlaySelection.Value == 1 % if you selected no overlay load defaults
            
            handles.overlayThresholdPos.Value = 0;
            handles.overlayThresholdNeg.Value = 0;
            handles.overlayThresholdPosDynamic.String = '0';
            handles.overlayThresholdNegDynamic.String = '0';
            handles.pSlider.Value = 1;
            handles.pText.String = '1';
            handles.clusterThreshSlider.Value = 0;
            handles.clusterThreshText.String = '0';
            
            handles.colormap.Value = 1;
            handles.invertColorButton.Value = 0;
            handles.colormapSpacing.Value = 1;
            handles.colorBins.String = '1000';
            handles.opacity.String = '1';
            
            handles.limitMin.String = '0';
            handles.limitMax.String = '0';
            handles.growROI.String = '0';
            handles.outlineButton.Value = 0;
            handles.zeroButton.Value = 1;
            handles.binarizeSwitch.Value = 0;
            
            handles.smoothAboveThresh.Value = 1;
            handles.smoothBelowThresh.Value = 0;
            handles.valuesButton.Value = 1;
            handles.neighborhoodButton.Value = 0;
            handles.smoothArea.String = '0';
            handles.smoothSteps.String = '0';
            
        else % otherwise load all settings saved for this overlay into the GUI
            handles.limitMin.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin);
            handles.limitMax.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax);
            handles.overlayThresholdPos.Value = handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos;
            handles.overlayThresholdNeg.Value = handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg;
            handles.colormap.Value = handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap;
            handles.opacity.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity);
            handles.binarizeSwitch.Value = handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize;
            
            handles.clusterThreshSlider.Value = handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh;
            handles.clusterThreshText.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh);
            
            if strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'true')
                handles.zeroButton.Value = 1;
            else
                handles.zeroButton.Value = 0;
            end
            
            if strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'false')
                handles.outlineButton.Value = 0;
            elseif strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'true')
                handles.outlineButton.Value = 1;
            end
            
            if strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'false')
                handles.invertColorButton.Value = 0;
            elseif strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'true')
                handles.invertColorButton.Value = 1;
            end
            
            handles.growROI.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
            
            if strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'even')
                handles.colormapSpacing.Value = 2;
            elseif strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'center on zero')
                handles.colormapSpacing.Value = 3;
            elseif strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'center on threshold')
                handles.colormapSpacing.Value = 4;
            end
            
            handles.overlayThresholdPosDynamic.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos);
            handles.overlayThresholdNegDynamic.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg);
            handles.colorBins.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins);
            
            % also update how far the sliders should be capable of moving based on
            % the data for this map
            handles.overlayThresholdPos.Max = max(max(max(handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data)));
            handles.overlayThresholdNeg.Min = min(min(min(handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data)));
            
            if strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothThreshold,'above')
                handles.smoothAboveThresh.Value = 1;
                handles.smoothBelowThresh.Value = 0;
            elseif strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothThreshold,'below')
                handles.smoothAboveThresh.Value = 0;
                handles.smoothBelowThresh.Value = 1;
            end
            
            if strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothType,'neighborhood')
                handles.neighborhoodButton.Value = 1;
                handles.valuesButton.Value = 0;
            elseif strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothThreshold,'neighbors')
                handles.neighborhoodButton.Value = 0;
                handles.valuesButton.Value = 1;
            end
            
            handles.smoothArea.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothArea);
            handles.smoothSteps.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothSteps);
            figure(handles.brainFig)
            [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
            
            handles.brainMap.colorbar = cbar;
            handles.brainMap.colorbar.TickLength = [0 0];
            imh = handles.brainMap.colorbar.Children(1);
            imh.AlphaData = handles.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
            
            if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
                handles.brainMap.colorbar.YTick = handles.opts.ticks;
                handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
            end
            
            if isfield(handles,'overlayCopy')
                if isvalid(handles.overlayCopy)
                    handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
                    handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
                    handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
                    handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
                    handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
                end
            end

        end
        
%        % copy in overlay settings from previous overlay
%        %handles.overlayCopy;
%        if isfield(handles,'overlayCopy')
%            if isvalid(handles.overlayCopy)
%                handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
%                handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
%                handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
%                handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
%                handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
%            end
%        end
       
    elseif length(handles.overlaySelection.Value) > 1
        
        for filei = handles.overlaySelection.Value
            figure(handles.brainFig)
            [handles.underlay, handles.brainMap.overlay{filei - 1}, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{filei - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{filei - 1}.overlayThresholdNeg, handles.brainMap.Current{filei - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{filei - 1}.hemi, 'opacity', handles.brainMap.Current{filei - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{filei - 1}.colormap}, 'colorSampling',handles.brainMap.Current{filei - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{filei - 1}.colorBins,'limits', [handles.brainMap.Current{filei - 1}.limitMin handles.brainMap.Current{filei - 1}.limitMax],'inclZero',handles.brainMap.Current{filei - 1}.inclZero,'clusterThresh',handles.brainMap.Current{filei - 1}.clusterThresh,'binarize',handles.brainMap.Current{filei - 1}.binarize,'outline',handles.brainMap.Current{filei - 1}.outline,'binarizeClusters',handles.brainMap.Current{filei - 1}.binarizeClusters,'customColor',handles.brainMap.Current{filei - 1}.customColor,'pMap',handles.brainMap.Current{filei - 1}.pVals,'pThresh',handles.brainMap.Current{filei - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{filei - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{filei - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{filei - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{filei - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{filei - 1}.invertColor,'invertOpacity',handles.brainMap.Current{filei - 1}.invertOpacity,'growROI',handles.brainMap.Current{filei - 1}.growROI);
            if isfield(handles,'overlayCopy')
                if isvalid(handles.overlayCopy)
                    handles.brainMap.overlay{filei - 1}.SpecularStrength = handles.overlayCopy.SpecularStrength;
                    handles.brainMap.overlay{filei - 1}.SpecularExponent = handles.overlayCopy.SpecularExponent;
                    handles.brainMap.overlay{filei - 1}.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
                    handles.brainMap.overlay{filei - 1}.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
                    handles.brainMap.overlay{filei - 1}.AmbientStrength =  handles.overlayCopy.AmbientStrength;
                end
            end
            
        end
        
    end
end
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %% %% Overlay selection buttons %% %% %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% move overlay up
function upButtonFinal_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 % make sure no overlay is not being moved
    if length(handles.overlaySelection.Value) == 1 % make sure there is not multiple selections
        handles = guidata(hObject);
        currVal = handles.overlaySelection.Value - 1;
        
        if currVal ~= 1 % can't move item 2 up because item 1 is no overlay
            toData = handles.brainMap.Current{currVal-1};
            fromData = handles.brainMap.Current{currVal};
            handles.brainMap.Current{currVal} = toData;
            handles.brainMap.Current{currVal-1} = fromData;
            
            toName = handles.overlaySelection.String{handles.overlaySelection.Value - 1};
            fromName = handles.overlaySelection.String{handles.overlaySelection.Value};
            
            handles.overlaySelection.String{handles.overlaySelection.Value} = toName;
            handles.overlaySelection.String{handles.overlaySelection.Value - 1} = fromName;
            
            handles.overlaySelection.Value = handles.overlaySelection.Value - 1; 
            guidata(hObject, handles);
        end
    end
end

%% move overlay down
function downButton_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1
    if length(handles.overlaySelection.Value) == 1 % make sure there is not multiple selections
        handles = guidata(hObject);
        currVal = handles.overlaySelection.Value - 1;
        
        if currVal ~= (length(handles.brainMap.Current)) % can't move item 2 up because item 1 is no overlay
            fromData = handles.brainMap.Current{currVal};
            toData = handles.brainMap.Current{currVal+1};
            handles.brainMap.Current{currVal} = toData;
            handles.brainMap.Current{currVal+1} = fromData;
            
            fromName = handles.overlaySelection.String{handles.overlaySelection.Value};
            toName = handles.overlaySelection.String{handles.overlaySelection.Value + 1};
            
            handles.overlaySelection.String{handles.overlaySelection.Value} = toName;
            handles.overlaySelection.String{handles.overlaySelection.Value + 1} = fromName;
            
            handles.overlaySelection.Value = handles.overlaySelection.Value + 1; % change selection to 'no overlay'
            guidata(hObject, handles);
        end
    end
end

%% duplicate overlay
function duplicateButton_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 % make sure you are not duplicating 'no overlay'
    if length(handles.overlaySelection.Value) == 1
        handles = guidata(hObject);
        
        fileNum = length(handles.brainMap.Current) + 1;
        handles.brainMap.Current{fileNum} = handles.brainMap.Current{handles.overlaySelection.Value - 1};
        %handles.overlaySelection.String = vertcat(handles.overlaySelection.String(:),extractfield([handles.brainMap.Current{handles.overlaySelection.Value - 1}],'name')');
        tmp = ([handles.brainMap.Current{handles.overlaySelection.Value - 1}]);
        handles.overlaySelection.String = vertcat(handles.overlaySelection.String(:),tmp.name);
        
        handles.overlaySelection.Value = length(handles.overlaySelection.String);
        
        % remove colorbar if it exists
        if isfield(handles.brainMap,'colorbar')
            delete(handles.brainMap.colorbar)
            handles.brainMap = rmfield(handles.brainMap,'colorbar');
        end
        
        % now turn off any overlays that might exist and delete them
        % multioverlays are in a cell
        if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
            if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
                for celli = 1:length(handles.brainMap.overlay)
                    handles.brainMap.overlay{celli}.FaceAlpha = 0;
                end
                handles.brainMap = rmfield(handles.brainMap,'overlay');
            elseif isvalid(handles.brainMap.overlay)
                handles.overlayCopy = handles.brainMap.overlay;
                handles.brainMap.overlay.FaceAlpha = 0;
                handles.brainMap = rmfield(handles.brainMap,'overlay');
            end
        end
        figure(handles.brainFig)
        [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
        
        handles.brainMap.colorbar = cbar;
        handles.brainMap.colorbar.TickLength = [0 0];
        imh = handles.brainMap.colorbar.Children(1);
        imh.AlphaData = handles.opts.transparencyData;
        imh.AlphaDataMapping = 'direct';
        
        if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
            handles.brainMap.colorbar.YTick = handles.opts.ticks;
            handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
        end
        
        if isfield(handles,'overlayCopy')
            handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
            handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
            handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
            handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
            handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
        end
        
        guidata(hObject, handles);
    end
end

%% save overlays
function saveOverlay_Callback(hObject, eventdata, handles)
if length(handles.overlaySelection.Value) == 1 % saving only works if you don't select multiple items
    if handles.overlaySelection.Value ~= 1
        handles = guidata(hObject);
        
        % load in the original overlay file for your selection. Try .gz if it
        % fails because load_nifti automatically gunzips
        fullfile = [handles.brainMap.Current{handles.overlaySelection.Value - 1}.path handles.paths.slash handles.brainMap.Current{handles.overlaySelection.Value - 1}.name handles.brainMap.Current{handles.overlaySelection.Value - 1}.ext];
        
        if exist(fullfile,'file')
            template = load_nifti(fullfile);
        else
            error('Could not load your original file...check to make sure you have not moved it')
        end
        
        % now save
        template.vol = handles.opts.overlayData;
        [oFile, oPath] = uiputfile({'*.nii';'*.nii.gz'},'Save current overlay',handles.brainMap.Current{handles.overlaySelection.Value - 1}.name);
        if isa(oFile,'double') == 0
            save_nifti(template,[oPath oFile])
        end
    end
end

%% reload overlays
function reloadOverlay_Callback(hObject, eventdata, handles)
if length(handles.overlaySelection.Value) == 1 % reloading only works if you don't select multiple items
    if handles.overlaySelection.Value ~= 1
        handles = guidata(hObject);
        
        % remove colorbar if it exists
        if isfield(handles.brainMap,'colorbar')
            delete(handles.brainMap.colorbar)
            handles.brainMap = rmfield(handles.brainMap,'colorbar');
        end
        
        % now turn off any overlays that might exist and delete them
        % multioverlays are in a cell
        if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
            if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
                for celli = 1:length(handles.brainMap.overlay)
                    handles.brainMap.overlay{celli}.FaceAlpha = 0;
                end
                handles.brainMap = rmfield(handles.brainMap,'overlay');
            elseif isvalid(handles.brainMap.overlay)
                handles.overlayCopy = handles.brainMap.overlay;
                handles.brainMap.overlay.FaceAlpha = 0;
                handles.brainMap = rmfield(handles.brainMap,'overlay');
            end
        end
        
        % return current selection to original state
        tmpPath = handles.brainMap.Current{handles.overlaySelection.Value - 1}.path;
        tmpName = handles.brainMap.Current{handles.overlaySelection.Value - 1}.name;
        try
            tmpExt = handles.brainMap.Current{handles.overlaySelection.Value - 1}.ext;
        catch
            warndlg('No extension in brainmap, probably import error')
        end
        tmpHemi = handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi;
        
        handles.brainMap.Current{handles.overlaySelection.Value - 1} = handles.defaultOptions;
        try
            hdr = load_nifti([tmpPath handles.paths.slash tmpName tmpExt]); % load in data
        catch
            hdr = load_nifti([tmpPath handles.paths.slash tmpName '.gz']);
        end
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data = hdr.vol;
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin = min(hdr.vol);
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax = max(hdr.vol);
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.path = tmpPath;
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.name = tmpName;
        try
            handles.brainMap.Current{handles.overlaySelection.Value - 1}.ext = tmpExt;
        catch
        end
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi = tmpHemi;
        
        % load all settings saved for this overlay into the GUI
        handles.limitMin.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin);
        handles.limitMax.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax);
        handles.overlayThresholdPos.Value = handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos;
        handles.overlayThresholdNeg.Value = handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg;
        handles.colormap.Value = handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap;
        handles.opacity.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity);
        handles.binarizeSwitch.Value = handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize;
        
        if strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'true')
            handles.zeroButton.Value = 1;
        else
            handles.zeroButton.Value = 0;
        end
        
        if strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'false')
            handles.outlineButton.Value = 0;
        elseif strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'true')
            handles.outlineButton.Value = 1;
        end
        
        if strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'false')
            handles.invertColorButton.Value = 0;
        elseif strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'true')
            handles.invertColorButton.Value = 1;
        end
        
        handles.growROI.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
        
        if strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'even')
            handles.colormapSpacing.Value = 2;
        elseif strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'center on zero')
            handles.colormapSpacing.Value = 3;
        elseif strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'center on threshold')
            handles.colormapSpacing.Value = 4;
        end
        
        handles.overlayThresholdPosDynamic.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos);
        handles.overlayThresholdNegDynamic.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg);
        handles.colorBins.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins);
        
        % also update how far the sliders should be capable of moving based on
        % the data for this map
        handles.overlayThresholdPos.Max = max(max(max(handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data)));
        handles.overlayThresholdNeg.Min = min(min(min(handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data)));
        
        figure(handles.brainFig)
        [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
        
        handles.brainMap.colorbar = cbar;
        handles.brainMap.colorbar.TickLength = [0 0];
        imh = handles.brainMap.colorbar.Children(1);
        imh.AlphaData = handles.opts.transparencyData;
        imh.AlphaDataMapping = 'direct';
        
        if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
            handles.brainMap.colorbar.YTick = handles.opts.ticks;
            handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
        end
        
        if isfield(handles,'overlayCopy')
            handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
            handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
            handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
            handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
            handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
        end
        
        % update handles
        guidata(hObject, handles);
    end
end

%% delete selected overlay
function deleteOverlay_Callback(hObject, eventdata, handles)
if length(handles.overlaySelection.Value) == 1 % deleting only works if you don't select multiple items
    if handles.overlaySelection.Value ~= 1
        handles = guidata(hObject);
        
        % remove colorbar if it exists
        if isfield(handles.brainMap,'colorbar')
            delete(handles.brainMap.colorbar)
            handles.brainMap = rmfield(handles.brainMap,'colorbar');
        end
        
        % now turn off any overlays that might exist and delete them
        % multioverlays are in a cell
        if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
            if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
                for celli = 1:length(handles.brainMap.overlay)
                    handles.brainMap.overlay{celli}.FaceAlpha = 0;
                end
                handles.brainMap = rmfield(handles.brainMap,'overlay');
            elseif isvalid(handles.brainMap.overlay)
                handles.overlayCopy = handles.brainMap.overlay;
                handles.brainMap.overlay.FaceAlpha = 0;
                handles.brainMap = rmfield(handles.brainMap,'overlay');
            else
                handles.brainMap = rmfield(handles.brainMap,'overlay');
            end
        end
        
        % delete data for this overlay
        handles.brainMap.Current(handles.overlaySelection.Value - 1) = [];
        
        % update GUI by switching to no overlay and deleting remaining string
        handles.overlaySelection.String(handles.overlaySelection.Value) = [];
        handles.overlaySelection.Value = 1; % change selection to 'no overlay'
        
        % load defaults
        handles.overlayThresholdPos.Value = 0;
        handles.overlayThresholdNeg.Value = 0;
        handles.overlayThresholdPosDynamic.String = '0';
        handles.overlayThresholdNegDynamic.String = '0';
        handles.overlayThresholdNegDynamic.String = '0';
        handles.pSlider.Value = 1;
        handles.pText.String = '1';
        handles.clusterThreshSlider.Value = 0;
        handles.clusterThreshText.String = '0';
        
        handles.colormap.Value = 1;
        handles.invertColorButton.Value = 0;
        handles.colormapSpacing.Value = 1;
        handles.colorBins.String = '1000';
        handles.opacity.String = '1';
        
        handles.limitMin.String = '0';
        handles.limitMax.String = '0';
        handles.growROI.String = '0';
        handles.outlineButton.Value = 0;
        handles.zeroButton.Value = 1;
        handles.binarizeSwitch.Value = 0;
        
        handles.smoothAboveThresh.Value = 1;
        handles.smoothBelowThresh.Value = 0;
        handles.valuesButton.Value = 1;
        handles.neighborhoodButton.Value = 0;
        handles.smoothArea.String = '0';
        handles.smoothSteps.String = '0';
        
        % update handles
        guidata(hObject, handles);
    end
end

%% delete all overlays
function deleteAllButton_Callback(hObject, eventdata, handles)
handles = guidata(hObject);

% remove colorbar if it exists
if isfield(handles.brainMap,'colorbar')
    delete(handles.brainMap.colorbar)
    handles.brainMap = rmfield(handles.brainMap,'colorbar');
end

% now turn off any overlays that might exist and delete them
% multioverlays are in a cell
if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
    if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
        for celli = 1:length(handles.brainMap.overlay)
            try
                handles.brainMap.overlay{celli}.FaceAlpha = 0;
            catch
            end
        end
        handles.brainMap = rmfield(handles.brainMap,'overlay');
    elseif isvalid(handles.brainMap.overlay)
        handles.overlayCopy = handles.brainMap.overlay;
        handles.brainMap.overlay.FaceAlpha = 0;
        handles.brainMap = rmfield(handles.brainMap,'overlay');
    else
        handles.brainMap = rmfield(handles.brainMap,'overlay');
    end
end

% delete data for all overlays
handles.brainMap = rmfield(handles.brainMap,'Current');

% update GUI by switching to no overlay and deleting remaining string
handles.overlaySelection.String(2:end) = [];
handles.overlaySelection.Value = 1; % change selection to 'no overlay'

% load defaults
handles.overlayThresholdPos.Value = 0;
handles.overlayThresholdNeg.Value = 0;
handles.overlayThresholdPosDynamic.String = '0';
handles.overlayThresholdNegDynamic.String = '0';
handles.overlayThresholdNegDynamic.String = '0';
handles.pSlider.Value = 1;
handles.pText.String = '1';
handles.clusterThreshSlider.Value = 0;
handles.clusterThreshText.String = '0';

handles.colormap.Value = 1;
handles.invertColorButton.Value = 0;
handles.colormapSpacing.Value = 1;
handles.colorBins.String = '1000';
handles.opacity.String = '1';

handles.limitMin.String = '0';
handles.limitMax.String = '0';
handles.growROI.String = '0';
handles.outlineButton.Value = 0;
handles.zeroButton.Value = 1;
handles.binarizeSwitch.Value = 0;

handles.smoothAboveThresh.Value = 1;
handles.smoothBelowThresh.Value = 0;
handles.valuesButton.Value = 1;
handles.neighborhoodButton.Value = 0;
handles.smoothArea.String = '0';
handles.smoothSteps.String = '0';

% update handles
guidata(hObject, handles);

%% button for copying overlay settings to other overlays
function copyButton_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    copySettingsGUI
    guidata(hObject, handles);
end

%% lighting button
function lightingButton_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
handles.lg = lightingGUI;
guidata(hObject, handles);

%% multioverlay transparency settings button
function multiOverlayTrans_Callback(hObject, eventdata, handles)
if length(handles.overlaySelection.Value) > 1
    multiOverlayGUI
end

%% screenshot button
function screenshotButton_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1
    if length(handles.overlaySelection.Value) == 1
        [~,file, ~] = fileparts(handles.brainMap.Current{handles.overlaySelection.Value - 1}.name);
    else
        % you selected more than 1 file...that's alright we'll use the
        % first file as the template
        [~,file, ~] = fileparts(handles.brainMap.Current{handles.overlaySelection.Value(1) - 1}.name);
        file = [file '_MultipleOverlays'];
    end
    [oFile, oPath] = uiputfile({'*.png'},'Screenshot of current overlay',file);
    saveas(handles.brainFig,[oPath oFile]);
end

%% screenshots button
function screenshotsButton_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 
    handles = guidata(hObject);
    
    for j = 1:length(handles.brainFig.Children)
        if ~strcmp(handles.brainFig.Children(j).Tag,'cbar')
            cNum = j;
        end
    end
    
    if length(handles.overlaySelection.Value) == 1 % if you only have one overlay turned on...
        [~,file, ~] = fileparts(handles.brainMap.Current{handles.overlaySelection.Value - 1}.name);
        [oFile, oPath] = uiputfile({'*'},'Pick a base name for all screenshots',file);
        
        if strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi,'left')
            handles.underlay.right.FaceAlpha = 0;
            
            figure(handles.brainFig)
            % inferior view
            view(handles.brainFig.Children(cNum),90, -90);
            saveas(handles.brainFig,[oPath oFile '_inferior.png']);
            % superior view
            view(handles.brainFig.Children(cNum),-90, 90);
            saveas(handles.brainFig,[oPath oFile '_superior.png']);
            % lateral from left
            view(handles.brainFig.Children(cNum),-90, 0);
            saveas(handles.brainFig,[oPath oFile '_lateral.png']);
            % lateral from right
            view(handles.brainFig.Children(cNum),90, 0);
            saveas(handles.brainFig,[oPath oFile '_medial.png']);
            
            handles.underlay.right.FaceAlpha = 1;
            
        elseif strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi,'right')
            handles.underlay.left.FaceAlpha = 0;
            
            figure(handles.brainFig)
            % inferior view
            view(handles.brainFig.Children(cNum),90, -90);
            saveas(handles.brainFig,[oPath oFile '_inferior.png']);
            % superior view
            view(handles.brainFig.Children(cNum),-90, 90);
            saveas(handles.brainFig,[oPath oFile '_superior.png']);
            % lateral from left
            view(handles.brainFig.Children(cNum),-90, 0);
            saveas(handles.brainFig,[oPath oFile '_medial.png']);
            % lateral from right
            view(handles.brainFig.Children(cNum),90, 0);
            saveas(handles.brainFig,[oPath oFile '_lateral.png']);
        
            handles.underlay.left.FaceAlpha = 1;
        end
    else
        [~,file, ~] = fileparts(handles.brainMap.Current{1}.name);
        [oFile, oPath] = uiputfile({'*'},'Pick a base name for all screenshots',file);
        
        % this is temporary -- for outlines if necessary (i.e., to trace
        % which hemisphere was first, etc)
        %hemis = extractfield([handles.brainMap.Current{handles.overlaySelection.Value - 1}],'hemi');
        %op = extractfield([handles.brainMap.Current{handles.overlaySelection.Value - 1}],'opacity');
        
        tmp = ([handles.brainMap.Current{handles.overlaySelection.Value - 1}]);
        %handles.overlaySelection.String = vertcat(handles.overlaySelection.String(:),tmp.name);
        hemis = {tmp.hemi};
        op = {tmp.opacity};
        
        lIdx = find(contains(hemis,'left'));
        rIdx = find(contains(hemis,'right'));
        
        figure(handles.brainFig)
        % start with inferior/superior
        % inferior view
        view(handles.brainFig.Children(cNum),90, -90);
        saveas(handles.brainFig,[oPath oFile '_inferior.png']);
        % superior view
        view(handles.brainFig.Children(cNum),-90, 90);
        saveas(handles.brainFig,[oPath oFile '_superior.png']);

        % now get lateral left and right
        % lateral from left
        view(handles.brainFig.Children(cNum),-90, 0);
        saveas(handles.brainFig,[oPath oFile '_leftlateral.png']);
        % lateral from right
        view(handles.brainFig.Children(cNum),90, 0);
        saveas(handles.brainFig,[oPath oFile '_rightlateral.png']);
        
        % now medial
        view(handles.brainFig.Children(cNum),-90, 0);
        handles.underlay.left.FaceAlpha = 0;
        for i = 1:length(lIdx)
            handles.brainMap.overlay{lIdx(i)}.FaceAlpha = 0;
        end
        saveas(handles.brainFig,[oPath oFile '_rightmedial.png']);
        
        handles.underlay.left.FaceAlpha = 1;
        for i = 1:length(lIdx)
            handles.brainMap.overlay{lIdx(i)}.FaceAlpha = op(lIdx(i));
        end
        
        view(handles.brainFig.Children(cNum),90, 0);
        handles.underlay.right.FaceAlpha = 0;
        for i = 1:length(rIdx)
            handles.brainMap.overlay{rIdx(i)}.FaceAlpha = 0;
        end
        saveas(handles.brainFig,[oPath oFile '_leftmedial.png']);
        
        handles.underlay.right.FaceAlpha = 1;
        for i = 1:length(rIdx)
            handles.brainMap.overlay{rIdx(i)}.FaceAlpha = op(rIdx(i));
        end
        
    end
    % update handles
    guidata(hObject, handles);
end

%% batch photos
function batchPhotos_Callback(hObject, eventdata, handles)
handles = guidata(hObject);

for i = 1:length(handles.brainMap.Current)
    % remove colorbar if it exists
    if isfield(handles.brainMap,'colorbar')
        delete(handles.brainMap.colorbar)
        handles.brainMap = rmfield(handles.brainMap,'colorbar');
    end
    
    % now turn off any overlays that might exist and delete them
    % multioverlays are in a cell
    if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
        if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
            for celli = 1:length(handles.brainMap.overlay)
                try
                    handles.brainMap.overlay{celli}.FaceAlpha = 0;
                catch
                    delete(handles.brainMap.overlay{celli});
                end
            end
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        elseif isvalid(handles.brainMap.overlay)
            handles.overlayCopy = handles.brainMap.overlay;
            handles.brainMap.overlay.FaceAlpha = 0;
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        end
    end
    
    % get file name
    [~,file, ~] = fileparts(handles.brainMap.Current{i}.name);
    path = handles.brainMap.Current{i}.path;
    oName = [path handles.paths.slash file];
    
    % check if repatch will produce a new figure...
    figPre = findobj('type','figure');
    
    % repatch
    figure(handles.brainFig)
    %[handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{i}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{i}.overlayThresholdNeg, handles.brainMap.Current{i}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{i}.hemi, 'opacity', handles.brainMap.Current{i}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{i}.colormap}, 'colorSampling',handles.brainMap.Current{i}.colormapSpacing,'colorBins',handles.brainMap.Current{i}.colorBins,'limits', [handles.brainMap.Current{i}.limitMin handles.brainMap.Current{i}.limitMax],'inclZero',handles.brainMap.Current{i}.inclZero,'clusterThresh',handles.brainMap.Current{i}.clusterThresh,'binarize',handles.brainMap.Current{i}.binarize,'outline',handles.brainMap.Current{i}.outline,'binarizeClusters',handles.brainMap.Current{i}.binarizeClusters,'customColor',handles.brainMap.Current{i}.customColor,'pMap',handles.brainMap.Current{i}.pVals,'pThresh',handles.brainMap.Current{i}.pThresh,'transparencyLimits',handles.brainMap.Current{i}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{i}.transparencyThresholds,'transparencyData',handles.brainMap.Current{i}.transparencyData,'transparencyPThresh',handles.brainMap.Current{i}.transparencyPThresh,'invertColor',handles.brainMap.Current{i}.invertColor,'invertOpacity',handles.brainMap.Current{i}.invertOpacity,'growROI',handles.brainMap.Current{i}.growROI);
    
    %bar = figure;
    handles.brainMap.colorbar = cbar;
    handles.brainMap.colorbar.TickLength = [0 0];
    imh = handles.brainMap.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    
    if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
        handles.brainMap.colorbar.YTick = handles.opts.ticks;
        handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
    end
    
    if isfield(handles,'overlayCopy')
        handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
        handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
        handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
        handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
        handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
    end
    
    % check for transparency modulation
    figPost = findobj('type','figure');
    if length(figPost) > length(figPre)
        [C,ia] = setdiff([figPost(:).Number],[figPre(:).Number]);
        for i = 1:length(figPost)
            if figPost(i).Number == C
                % take photo of it...
                saveas(figPost(i),[oName '_transparencyModulatedColorbar.png']);
                deleteFig = i;
            end
        end
    end
    
    if exist('deleteFig','var')
        delete(figPost(deleteFig))
    end
    
    % so that we don't rotate the colorbar find it in children of brainFig
    for j = 1:length(handles.brainFig.Children)
        if ~strcmp(handles.brainFig.Children(j).Tag,'cbar')
            cNum = j;
        end
    end
    
    % take screenshots
    if strcmp(handles.brainMap.Current{i}.hemi,'left')
        handles.underlay.right.FaceAlpha = 0;
        
        figure(handles.brainFig)
        % inferior view
        view(handles.brainFig.Children(cNum),90, -90);
        saveas(handles.brainFig,[oName '_inferior.png']);
        % superior view
        view(handles.brainFig.Children(cNum),-90, 90);
        saveas(handles.brainFig,[oName '_superior.png']);
        % lateral from left
        view(handles.brainFig.Children(cNum),-90, 0);
        saveas(handles.brainFig,[oName '_lateral.png']);
        % lateral from right
        view(handles.brainFig.Children(cNum),90, 0);
        saveas(handles.brainFig,[oName '_medial.png']);
        
        handles.underlay.right.FaceAlpha = 1;
        
    elseif strcmp(handles.brainMap.Current{i}.hemi,'right')
        handles.underlay.left.FaceAlpha = 0;
        
        figure(handles.brainFig)
        % inferior view
        view(handles.brainFig.Children(cNum),90, -90);
        saveas(handles.brainFig,[oName '_inferior.png']);
        % superior view
        view(handles.brainFig.Children(cNum),-90, 90);
        saveas(handles.brainFig,[oName '_superior.png']);
        % lateral from left
        view(handles.brainFig.Children(cNum),-90, 0);
        saveas(handles.brainFig,[oName '_medial.png']);
        % lateral from right
        view(handles.brainFig.Children(cNum),90, 0);
        saveas(handles.brainFig,[oName '_lateral.png']);
        
        handles.underlay.left.FaceAlpha = 1;
    end
end

% repatch original overlay
% remove colorbar if it exists
if isfield(handles.brainMap,'colorbar')
    delete(handles.brainMap.colorbar)
    handles.brainMap = rmfield(handles.brainMap,'colorbar');
end

% now turn off any overlays that might exist and delete them
% multioverlays are in a cell
if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
    if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
        for celli = 1:length(handles.brainMap.overlay)
            try
                handles.brainMap.overlay{celli}.FaceAlpha = 0;
            catch
                delete(handles.brainMap.overlay{celli});
            end
        end
        handles.brainMap = rmfield(handles.brainMap,'overlay');
    elseif isvalid(handles.brainMap.overlay)
        handles.overlayCopy = handles.brainMap.overlay;
        handles.brainMap.overlay.FaceAlpha = 0;
        handles.brainMap = rmfield(handles.brainMap,'overlay');
    end
end

figure(handles.brainFig)
[handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);

handles.brainMap.colorbar = cbar;
handles.brainMap.colorbar.TickLength = [0 0];
imh = handles.brainMap.colorbar.Children(1);
imh.AlphaData = handles.opts.transparencyData;
imh.AlphaDataMapping = 'direct';
    
if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
    handles.brainMap.colorbar.YTick = handles.opts.ticks;
    handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
end

if isfield(handles,'overlayCopy')
    if isvalid(handles.overlayCopy)
        handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
        handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
        handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
        handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
        handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
    end
end

% update handles
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %% %% Thresholds %% %% %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% positive value threshold
function overlayThresholdPos_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    
    % update the dynamic text box
    handles.overlayThresholdPosDynamic.String = num2str(hObject.Value);
    
    % update saved settings for overlay
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos = hObject.Value;
    
    % remove colorbar if it exists
    if isfield(handles.brainMap,'colorbar')
        delete(handles.brainMap.colorbar)
        handles.brainMap = rmfield(handles.brainMap,'colorbar');
    end
    
    % now turn off any overlays that might exist and delete them
    % multioverlays are in a cell
    if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
        if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
            for celli = 1:length(handles.brainMap.overlay)
                handles.brainMap.overlay{celli}.FaceAlpha = 0;
            end
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        elseif isvalid(handles.brainMap.overlay)
            handles.overlayCopy = handles.brainMap.overlay;
            handles.brainMap.overlay.FaceAlpha = 0;
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        else
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        end
    end
    figure(handles.brainFig)
    [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.brainMap.colorbar = cbar;
    handles.brainMap.colorbar.TickLength = [0 0];
    imh = handles.brainMap.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    
    if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
        handles.brainMap.colorbar.YTick = handles.opts.ticks;
        handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
    end
    
    if isfield(handles,'overlayCopy')
        handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
        handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
        handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
        handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
        handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
    end
    
    guidata(hObject, handles);
end

function overlayThresholdPosDynamic_Callback(hObject, eventdata, handles)
% if a threshold is set in the text box, adjust the slider
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    
    % update the slider
    handles.overlayThresholdPos.Value = str2double(hObject.String);
    
    % update saved settings for overlay
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos = str2double(hObject.String);
    
    % remove colorbar if it exists
    if isfield(handles.brainMap,'colorbar')
        delete(handles.brainMap.colorbar)
        handles.brainMap = rmfield(handles.brainMap,'colorbar');
    end
    
    % now turn off any overlays that might exist and delete them
    % multioverlays are in a cell
    if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
        if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
            for celli = 1:length(handles.brainMap.overlay)
                handles.brainMap.overlay{celli}.FaceAlpha = 0;
            end
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        elseif isvalid(handles.brainMap.overlay)
            handles.overlayCopy = handles.brainMap.overlay;
            handles.brainMap.overlay.FaceAlpha = 0;
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        else
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        end
    end
    figure(handles.brainFig)
    [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.brainMap.colorbar = cbar;
    handles.brainMap.colorbar.TickLength = [0 0];
    imh = handles.brainMap.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
        
    if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
        handles.brainMap.colorbar.YTick = handles.opts.ticks;
        handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
    end
    
    if isfield(handles,'overlayCopy')
        handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
        handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
        handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
        handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
        handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
    end
    
    guidata(hObject, handles);
end

%% negative value threshold
function overlayThresholdNeg_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    
    % update the dynamic text box
    handles.overlayThresholdNegDynamic.String = num2str(hObject.Value);
    
    % update saved settings for overlay
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg = hObject.Value;
    
    % remove colorbar if it exists
    if isfield(handles.brainMap,'colorbar')
        delete(handles.brainMap.colorbar)
        handles.brainMap = rmfield(handles.brainMap,'colorbar');
    end
    
  % now turn off any overlays that might exist and delete them
    % multioverlays are in a cell
    if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
        if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
            for celli = 1:length(handles.brainMap.overlay)
                handles.brainMap.overlay{celli}.FaceAlpha = 0;
            end
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        elseif isvalid(handles.brainMap.overlay)
            handles.overlayCopy = handles.brainMap.overlay;
            handles.brainMap.overlay.FaceAlpha = 0;
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        else
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        end
    end
    figure(handles.brainFig)
    [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.brainMap.colorbar = cbar;
    handles.brainMap.colorbar.TickLength = [0 0];
    imh = handles.brainMap.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    
    if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
        handles.brainMap.colorbar.YTick = handles.opts.ticks;
        handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
    end
    
    if isfield(handles,'overlayCopy')
        handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
        handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
        handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
        handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
        handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
    end
    
    guidata(hObject, handles);
end

function overlayThresholdNegDynamic_Callback(hObject, eventdata, handles)
% if a threshold is set in the text box, adjust the slider
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    
    % update the slider
    handles.overlayThresholdNeg.Value = str2double(hObject.String);
    
    % update saved settings for overlay
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg = str2double(hObject.String);
    
    % remove colorbar if it exists
    if isfield(handles.brainMap,'colorbar')
        delete(handles.brainMap.colorbar)
        handles.brainMap = rmfield(handles.brainMap,'colorbar');
    end
    
  % now turn off any overlays that might exist and delete them
    % multioverlays are in a cell
    if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
        if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
            for celli = 1:length(handles.brainMap.overlay)
                handles.brainMap.overlay{celli}.FaceAlpha = 0;
            end
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        elseif isvalid(handles.brainMap.overlay)
            handles.overlayCopy = handles.brainMap.overlay;
            handles.brainMap.overlay.FaceAlpha = 0;
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        else
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        end
    end
    figure(handles.brainFig)
    [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.brainMap.colorbar = cbar;
    handles.brainMap.colorbar.TickLength = [0 0];
    imh = handles.brainMap.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    
    if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
        handles.brainMap.colorbar.YTick = handles.opts.ticks;
        handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
    end
    
    if isfield(handles,'overlayCopy')
        handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
        handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
        handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
        handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
        handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
    end
    
    guidata(hObject, handles);
end

%% adds p-values to the currently selected overlay
function addP_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    [file, path]= uigetfile({'*.nii*'},'Select the file with your p-values','File Selector');
    tmp = load_nifti([path file]);
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals = tmp.vol;
    guidata(hObject, handles);
end

function pSlider_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    
    % update the dynamic text box
    handles.pText.String = num2str(hObject.Value);
    
    % update saved settings for overlay
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh = hObject.Value;
    
    % remove colorbar if it exists
    if isfield(handles.brainMap,'colorbar')
        delete(handles.brainMap.colorbar)
        handles.brainMap = rmfield(handles.brainMap,'colorbar');
    end
    
  % now turn off any overlays that might exist and delete them
    % multioverlays are in a cell
    if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
        if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
            for celli = 1:length(handles.brainMap.overlay)
                handles.brainMap.overlay{celli}.FaceAlpha = 0;
            end
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        elseif isvalid(handles.brainMap.overlay)
            handles.overlayCopy = handles.brainMap.overlay;
            handles.brainMap.overlay.FaceAlpha = 0;
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        else
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        end
    end
    figure(handles.brainFig)
    [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.brainMap.colorbar = cbar;
    handles.brainMap.colorbar.TickLength = [0 0];
    imh = handles.brainMap.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    
    if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
        handles.brainMap.colorbar.YTick = handles.opts.ticks;
        handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
    end
    
    if isfield(handles,'overlayCopy')
        handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
        handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
        handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
        handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
        handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
    end
    
    guidata(hObject, handles);
end

function pText_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    
    % update the dynamic text box
    handles.pSlider.Value = str2double(handles.pText.String);
    
    % update saved settings for overlay
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh = str2double(handles.pText.String);
    
    % remove colorbar if it exists
    if isfield(handles.brainMap,'colorbar')
        delete(handles.brainMap.colorbar)
        handles.brainMap = rmfield(handles.brainMap,'colorbar');
    end
    
  % now turn off any overlays that might exist and delete them
    % multioverlays are in a cell
    if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
        if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
            for celli = 1:length(handles.brainMap.overlay)
                handles.brainMap.overlay{celli}.FaceAlpha = 0;
            end
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        elseif isvalid(handles.brainMap.overlay)
            handles.overlayCopy = handles.brainMap.overlay;
            handles.brainMap.overlay.FaceAlpha = 0;
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        else
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        end
    end
    figure(handles.brainFig)
    [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.brainMap.colorbar = cbar;
    handles.brainMap.colorbar.TickLength = [0 0];
    imh = handles.brainMap.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
        
    if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
        handles.brainMap.colorbar.YTick = handles.opts.ticks;
        handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
    end
    
    if isfield(handles,'overlayCopy')
        handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
        handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
        handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
        handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
        handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
    end
    
    guidata(hObject, handles);
end

%% cluster thresholds
function clusterThreshSlider_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    % update the dynamic text box
    handles.clusterThreshText.String = num2str(hObject.Value);
    
    % update saved settings for overlay
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh = hObject.Value;
    
    % remove colorbar if it exists
    if isfield(handles.brainMap,'colorbar')
        delete(handles.brainMap.colorbar)
        handles.brainMap = rmfield(handles.brainMap,'colorbar');
    end
    
  % now turn off any overlays that might exist and delete them
    % multioverlays are in a cell
    if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
        if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
            for celli = 1:length(handles.brainMap.overlay)
                handles.brainMap.overlay{celli}.FaceAlpha = 0;
            end
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        elseif isvalid(handles.brainMap.overlay)
            handles.overlayCopy = handles.brainMap.overlay;
            handles.brainMap.overlay.FaceAlpha = 0;
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        else
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        end
    end
    figure(handles.brainFig)
    [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.brainMap.colorbar = cbar;
    handles.brainMap.colorbar.TickLength = [0 0];
    imh = handles.brainMap.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    
    if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
        handles.brainMap.colorbar.YTick = handles.opts.ticks;
        handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
    end
    
    if isfield(handles,'overlayCopy')
        handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
        handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
        handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
        handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
        handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
    end
    
    guidata(hObject, handles);
end

function clusterThreshText_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    
    % update the slider
    handles.clusterThreshSlider.Value = str2double(hObject.String);
    
    % update saved settings for overlay
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh = str2double(hObject.String);
    
    % remove colorbar if it exists
    if isfield(handles.brainMap,'colorbar')
        delete(handles.brainMap.colorbar)
        handles.brainMap = rmfield(handles.brainMap,'colorbar');
    end
    
  % now turn off any overlays that might exist and delete them
    % multioverlays are in a cell
    if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
        if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
            for celli = 1:length(handles.brainMap.overlay)
                handles.brainMap.overlay{celli}.FaceAlpha = 0;
            end
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        elseif isvalid(handles.brainMap.overlay)
            handles.overlayCopy = handles.brainMap.overlay;
            handles.brainMap.overlay.FaceAlpha = 0;
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        else
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        end
    end
    figure(handles.brainFig)
    [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.brainMap.colorbar = cbar;
    handles.brainMap.colorbar.TickLength = [0 0];
    imh = handles.brainMap.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
        
    if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
        handles.brainMap.colorbar.YTick = handles.opts.ticks;
        handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
    end
    
    if isfield(handles,'overlayCopy')
        handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
        handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
        handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
        handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
        handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
    end
    
    guidata(hObject, handles);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %% %% Colormap %% %% %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function opacity_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    if length(handles.overlaySelection.Value) == 1
        handles = guidata(hObject);
        
        if ischar(handles.brainMap.overlay.FaceAlpha) % if it's a string then facevertexalpha is being used
            % if you make opacity 0 we will never be able to recover original data
            % without replotting everything from scratch
            if str2double(handles.opacity.String) == 0
                handles.opacity.String = 0.00001;
            end
            
            % saveOverlay input opacity into settings for this overlay map
            handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity = str2double(handles.opacity.String);
            
            % update overlay
            % return overlay to original state
            maxVal = max(handles.brainMap.overlay.FaceVertexAlphaData);
            if maxVal < 62
                mulFac = 62/maxVal;
            else
                mulFac = 1;
            end
            
            handles.brainMap.overlay.FaceVertexAlphaData = (handles.brainMap.overlay.FaceVertexAlphaData) * (str2double(handles.opacity.String) * mulFac);
            imh = handles.brainMap.colorbar.Children(1);
            imh.AlphaData = (handles.opts.transparencyData) * (str2double(handles.opacity.String) * mulFac);
            imh.AlphaDataMapping = 'direct';
            
        else
            handles.brainMap.overlay.FaceAlpha = str2double(handles.opacity.String);
            handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity = str2double(handles.opacity.String);
            
            imh = handles.brainMap.colorbar.Children(1);
            maxVal = max(handles.brainMap.overlay.FaceVertexAlphaData);
            if maxVal < 62
                mulFac = 62/maxVal;
            else
                mulFac = 1;
            end
            
            imh.AlphaData = (handles.opts.transparencyData) * (str2double(handles.opacity.String) * mulFac);
            imh.AlphaDataMapping = 'direct';
        end
        
        guidata(hObject, handles);
    end
end

%% change the spacing of bins
function colormapSpacing_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    
    % saveOverlay input colormap spacing setting into overlay settings
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing = handles.colormapSpacing.String{get(hObject,'Value')};
    
    % remove colorbar if it exists
    if isfield(handles.brainMap,'colorbar')
        delete(handles.brainMap.colorbar)
        handles.brainMap = rmfield(handles.brainMap,'colorbar');
    end
    
    % now turn off any overlays that might exist and delete them
    % multioverlays are in a cell
    if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
        if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
            for celli = 1:length(handles.brainMap.overlay)
                handles.brainMap.overlay{celli}.FaceAlpha = 0;
            end
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        elseif isvalid(handles.brainMap.overlay)
            handles.overlayCopy = handles.brainMap.overlay;
            handles.brainMap.overlay.FaceAlpha = 0;
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        end
    end
    figure(handles.brainFig)
    [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.brainMap.colorbar = cbar;
    handles.brainMap.colorbar.TickLength = [0 0];
    imh = handles.brainMap.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    
    if get(hObject,'Value') == 4 || get(hObject,'Value') == 3
        handles.brainMap.colorbar.YTick = handles.opts.ticks;
        handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
    end
    
    if isfield(handles,'overlayCopy')
        handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
        handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
        handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
        handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
        handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
    end
    
    guidata(hObject, handles);
end

%% change the colormap 
function colormap_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    
    % if you didn't choose the empty colormap
    if hObject.Value > 1
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap = handles.colormap.Value;
        % if colormap is custom and already loaded in GUI or if you
        % selected to create a custom map
        if isfield(handles,'colormapCustom') == 1
            % load in the colormap if it's an already created colormap
            if handles.colormapCustom(hObject.Value) == 1
                customColor = load([handles.paths.colormapsPath handles.paths.slash handles.colormap.String{hObject.Value} '.mat']);
                if isa(customColor,'struct') == 1
                    field = fieldnames(customColor);
                    handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor = customColor.(field{1});
                    handles.colorBins.String = num2str(length(handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor));
                    handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins = length(handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor);
                end
            
                % remove colorbar if it exists
                if isfield(handles.brainMap,'colorbar')
                    delete(handles.brainMap.colorbar)
                    handles.brainMap = rmfield(handles.brainMap,'colorbar');
                end
                
                % now turn off any overlays that might exist and delete them
                % multioverlays are in a cell
                if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
                    if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
                        for celli = 1:length(handles.brainMap.overlay)
                            handles.brainMap.overlay{celli}.FaceAlpha = 0;
                        end
                        handles.brainMap = rmfield(handles.brainMap,'overlay');
                    elseif isvalid(handles.brainMap.overlay)
                        handles.overlayCopy = handles.brainMap.overlay;
                        handles.brainMap.overlay.FaceAlpha = 0;
                        handles.brainMap = rmfield(handles.brainMap,'overlay');
                    end
                end
                figure(handles.brainFig)
                [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
                
                handles.brainMap.colorbar = cbar;
                handles.brainMap.colorbar.TickLength = [0 0];
                imh = handles.brainMap.colorbar.Children(1);
                imh.AlphaData = handles.opts.transparencyData;
                imh.AlphaDataMapping = 'direct';
                
                if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
                    handles.brainMap.colorbar.YTick = handles.opts.ticks;
                    handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
                end
                
                if isfield(handles,'overlayCopy')
                    handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
                    handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
                    handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
                    handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
                    handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
                end
                
            else % update overlay and clear custom color
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor = [];
                
                % remove colorbar if it exists
                if isfield(handles.brainMap,'colorbar')
                    delete(handles.brainMap.colorbar)
                    handles.brainMap = rmfield(handles.brainMap,'colorbar');
                end
                
                % now turn off any overlays that might exist and delete them
                % multioverlays are in a cell
                if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
                    if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
                        for celli = 1:length(handles.brainMap.overlay)
                            handles.brainMap.overlay{celli}.FaceAlpha = 0;
                        end
                        handles.brainMap = rmfield(handles.brainMap,'overlay');
                    elseif isvalid(handles.brainMap.overlay)
                        handles.overlayCopy = handles.brainMap.overlay;
                        handles.brainMap.overlay.FaceAlpha = 0;
                        handles.brainMap = rmfield(handles.brainMap,'overlay');
                    end
                end
                figure(handles.brainFig)
                [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
                
                handles.brainMap.colorbar = cbar;
                handles.brainMap.colorbar.TickLength = [0 0];
                imh = handles.brainMap.colorbar.Children(1);
                imh.AlphaData = handles.opts.transparencyData;
                imh.AlphaDataMapping = 'direct';
                
                if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
                    handles.brainMap.colorbar.YTick = handles.opts.ticks;
                    handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
                end
                
                if isfield(handles,'overlayCopy')
                    handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
                    handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
                    handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
                    handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
                    handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
                end
                
            end
        end
    end
end

guidata(hObject, handles);

%% button to adjust number of colors in colormap
function colorBins_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    
    % saveOverlay input colormap spacing setting into overlay settings
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins = str2double(handles.colorBins.String);
    
    % remove colorbar if it exists
    if isfield(handles.brainMap,'colorbar')
        delete(handles.brainMap.colorbar)
        handles.brainMap = rmfield(handles.brainMap,'colorbar');
    end
    
    % now turn off any overlays that might exist and delete them
    % multioverlays are in a cell
    if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
        if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
            for celli = 1:length(handles.brainMap.overlay)
                handles.brainMap.overlay{celli}.FaceAlpha = 0;
            end
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        elseif isvalid(handles.brainMap.overlay)
            handles.overlayCopy = handles.brainMap.overlay;
            handles.brainMap.overlay.FaceAlpha = 0;
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        end
    end
    
    figure(handles.brainFig)
    [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.brainMap.colorbar = cbar;
    handles.brainMap.colorbar.TickLength = [0 0];
    imh = handles.brainMap.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    
    if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
        handles.brainMap.colorbar.YTick = handles.opts.ticks;
        handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
    end
    
    if isfield(handles,'overlayCopy')
        handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
        handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
        handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
        handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
        handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
    end
    
    guidata(hObject, handles);
end

%% button for editing/creating colormaps
function colormapCreate_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    colormapEditorfig
    guidata(hObject, handles);
end

%% button for inverting the colormap
function invertColorButton_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    
    % update structure
    if get(hObject,'Value') == 1
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor = 'true';
    else
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor = 'false';
    end
    
    % remove colorbar if it exists
    if isfield(handles.brainMap,'colorbar')
        delete(handles.brainMap.colorbar)
        handles.brainMap = rmfield(handles.brainMap,'colorbar');
    end
    
    % now turn off any overlays that might exist and delete them
    % multioverlays are in a cell
    if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
        if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
            for celli = 1:length(handles.brainMap.overlay)
                handles.brainMap.overlay{celli}.FaceAlpha = 0;
            end
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        elseif isvalid(handles.brainMap.overlay)
            handles.overlayCopy = handles.brainMap.overlay;
            handles.brainMap.overlay.FaceAlpha = 0;
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        end
    end
    figure(handles.brainFig)
    [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.brainMap.colorbar = cbar;
    handles.brainMap.colorbar.TickLength = [0 0];
    imh = handles.brainMap.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    
    if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
        handles.brainMap.colorbar.YTick = handles.opts.ticks;
        handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
    end
    
    if isfield(handles,'overlayCopy')
        handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
        handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
        handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
        handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
        handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
    end
    
    guidata(hObject, handles);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %% %% Adjustments %% %% %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% button for binarizing map
function binarizeSwitch_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize = handles.binarizeSwitch.Value;
    
    % remove colorbar if it exists
    if isfield(handles.brainMap,'colorbar')
        delete(handles.brainMap.colorbar)
        handles.brainMap = rmfield(handles.brainMap,'colorbar');
    end
    
    % now turn off any overlays that might exist and delete them
    % multioverlays are in a cell
    if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
        if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
            for celli = 1:length(handles.brainMap.overlay)
                handles.brainMap.overlay{celli}.FaceAlpha = 0;
            end
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        elseif isvalid(handles.brainMap.overlay)
            handles.overlayCopy = handles.brainMap.overlay;
            handles.brainMap.overlay.FaceAlpha = 0;
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        end
    end
    figure(handles.brainFig)
    [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.brainMap.colorbar = cbar;
    handles.brainMap.colorbar.TickLength = [0 0];
    imh = handles.brainMap.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
        
    if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
        handles.brainMap.colorbar.YTick = handles.opts.ticks;
        handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
    end
    
    if isfield(handles,'overlayCopy')
        handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
        handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
        handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
        handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
        handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
    end
    
    guidata(hObject, handles);
end

%% button for creating an outline of each cluster in map
function outlineButton_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    
    if get(hObject,'Value') == 0
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline = 'false';
    else
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline = 'true';
    end
    
    % remove colorbar if it exists
    if isfield(handles.brainMap,'colorbar')
        delete(handles.brainMap.colorbar)
        handles.brainMap = rmfield(handles.brainMap,'colorbar');
    end
    
    % now turn off any overlays that might exist and delete them
    % multioverlays are in a cell
    if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
        if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
            for celli = 1:length(handles.brainMap.overlay)
                handles.brainMap.overlay{celli}.FaceAlpha = 0;
            end
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        elseif isvalid(handles.brainMap.overlay)
            handles.overlayCopy = handles.brainMap.overlay;
            handles.brainMap.overlay.FaceAlpha = 0;
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        end
    end
    figure(handles.brainFig)
    [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.brainMap.colorbar = cbar;
    handles.brainMap.colorbar.TickLength = [0 0];
    imh = handles.brainMap.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    
    if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
        handles.brainMap.colorbar.YTick = handles.opts.ticks;
        handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
    end
    
    if isfield(handles,'overlayCopy')
        handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
        handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
        handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
        handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
        handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
    end
    
    guidata(hObject, handles);
end

%% button for adjusting the minimum value represented in colormap 
function limitMin_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    
    % saveOverlay input limit into overlay settings
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin = str2double(get(hObject,'String'));
    
    % remove colorbar if it exists
    if isfield(handles.brainMap,'colorbar')
        delete(handles.brainMap.colorbar)
        handles.brainMap = rmfield(handles.brainMap,'colorbar');
    end
    
    % now turn off any overlays that might exist and delete them
    % multioverlays are in a cell
    if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
        if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
            for celli = 1:length(handles.brainMap.overlay)
                handles.brainMap.overlay{celli}.FaceAlpha = 0;
            end
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        elseif isvalid(handles.brainMap.overlay)
            handles.overlayCopy = handles.brainMap.overlay;
            handles.brainMap.overlay.FaceAlpha = 0;
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        end
    end
    figure(handles.brainFig)
    [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.brainMap.colorbar = cbar;
    handles.brainMap.colorbar.TickLength = [0 0];
    imh = handles.brainMap.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    
    if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
        handles.brainMap.colorbar.YTick = handles.opts.ticks;
        handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
    end
    
    if isfield(handles,'overlayCopy')
        handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
        handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
        handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
        handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
        handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
    end
    
    guidata(hObject, handles);
end

%% button for adjusting the maximum value represented in colormap 
function limitMax_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    
    % saveOverlay input limit into overlay settings
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax = str2double(get(hObject,'String'));
    
        % remove colorbar if it exists
    if isfield(handles.brainMap,'colorbar')
        delete(handles.brainMap.colorbar)
        handles.brainMap = rmfield(handles.brainMap,'colorbar');
    end
    
    % now turn off any overlays that might exist and delete them
    % multioverlays are in a cell
    if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
        if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
            for celli = 1:length(handles.brainMap.overlay)
                handles.brainMap.overlay{celli}.FaceAlpha = 0;
            end
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        elseif isvalid(handles.brainMap.overlay)
            handles.overlayCopy = handles.brainMap.overlay;
            handles.brainMap.overlay.FaceAlpha = 0;
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        end
    end
    figure(handles.brainFig)
    [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.brainMap.colorbar = cbar;
    handles.brainMap.colorbar.TickLength = [0 0];
    imh = handles.brainMap.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    
    if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
        handles.brainMap.colorbar.YTick = handles.opts.ticks;
        handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
    end
    
    if isfield(handles,'overlayCopy')
        handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
        handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
        handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
        handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
        handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
    end
    
    guidata(hObject, handles);
end

%% button for summoning the transparency GUI
function transparencyButton_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    
    % fix colormap
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap = handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap};
    
    transparencyGUI
    
    % unfix for this GUI
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap = handles.colormap.Value;
    
    guidata(hObject, handles);
end

%% button for visualizing zeros on map
function zeroButton_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    
    if hObject.Value == 1
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero = 'true';
    else
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero = 'false';
    end
    
    % remove colorbar if it exists
    if isfield(handles.brainMap,'colorbar')
        delete(handles.brainMap.colorbar)
        handles.brainMap = rmfield(handles.brainMap,'colorbar');
    end
    
    % now turn off any overlays that might exist and delete them
    % multioverlays are in a cell
    if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
        if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
            for celli = 1:length(handles.brainMap.overlay)
                handles.brainMap.overlay{celli}.FaceAlpha = 0;
            end
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        elseif isvalid(handles.brainMap.overlay)
            handles.overlayCopy = handles.brainMap.overlay;
            handles.brainMap.overlay.FaceAlpha = 0;
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        end
    end
    figure(handles.brainFig)
    [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.brainMap.colorbar = cbar;
    handles.brainMap.colorbar.TickLength = [0 0];
    imh = handles.brainMap.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
        
    if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
        handles.brainMap.colorbar.YTick = handles.opts.ticks;
        handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
    end
    
    if isfield(handles,'overlayCopy')
        handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
        handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
        handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
        handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
        handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
    end
    
    guidata(hObject, handles);
end

%% button for growing the map
function growROI_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI = str2double(get(hObject,'String'));
    
        % remove colorbar if it exists
    if isfield(handles.brainMap,'colorbar')
        delete(handles.brainMap.colorbar)
        handles.brainMap = rmfield(handles.brainMap,'colorbar');
    end
    
    % now turn off any overlays that might exist and delete them
    % multioverlays are in a cell
    if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
        if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
            for celli = 1:length(handles.brainMap.overlay)
                handles.brainMap.overlay{celli}.FaceAlpha = 0;
            end
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        elseif isvalid(handles.brainMap.overlay)
            handles.overlayCopy = handles.brainMap.overlay;
            handles.brainMap.overlay.FaceAlpha = 0;
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        end
    end
    figure(handles.brainFig)
    [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.brainMap.colorbar = cbar;
    handles.brainMap.colorbar.TickLength = [0 0];
    imh = handles.brainMap.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    
    if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
        handles.brainMap.colorbar.YTick = handles.opts.ticks;
        handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
    end
    
    if isfield(handles,'overlayCopy')
        handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
        handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
        handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
        handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
        handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
    end
    
    guidata(hObject, handles);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %% %% Smoothing %% %% %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Change the number of times you will apply smoothing
function smoothSteps_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothSteps = str2double(get(hObject,'String'));
    guidata(hObject, handles);
end

function smoothArea_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothArea = str2double(get(hObject,'String'));
    guidata(hObject, handles);
end

%% change the area you will be smoothing
function smoothBelowThresh_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    if get(hObject,'Value') == 1
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothThreshold = 'border';
        handles.smoothAboveThresh.Value = 0;
    else
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothThreshold = 'above';
        handles.smoothAboveThresh.Value = 1;
    end
    guidata(hObject, handles);
end

function smoothAboveThresh_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    
    if get(hObject,'Value') == 1
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothThreshold = 'above';
        handles.smoothBelowThresh.Value = 0;
    else
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothThreshold = 'below';
        handles.smoothBelowThresh.Value = 1;
    end
    
    guidata(hObject, handles);
end

function valuesButton_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    if get(hObject,'Value') == 1
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothType = 'neighbors';
        handles.neighborhoodButton.Value = 0;
    else
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothType = 'neighborhood';
        handles.neighborhoodButton.Value = 1;
    end
    guidata(hObject, handles);
end

function neighborhoodButton_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    if get(hObject,'Value') == 1
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothType = 'neighborhood';
        handles.valuesButton.Value = 0;
    else
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothType = 'neighbors';
        handles.valuesButton.Value = 1;
    end
    guidata(hObject, handles);
end

%% Button to apply smoothing
function smoothButton_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    
 % remove colorbar if it exists
    if isfield(handles.brainMap,'colorbar')
        delete(handles.brainMap.colorbar)
        handles.brainMap = rmfield(handles.brainMap,'colorbar');
    end
    
    % now turn off any overlays that might exist and delete them
    % multioverlays are in a cell
    if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
        if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
            for celli = 1:length(handles.brainMap.overlay)
                handles.brainMap.overlay{celli}.FaceAlpha = 0;
            end
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        elseif isvalid(handles.brainMap.overlay)
            handles.overlayCopy = handles.brainMap.overlay;
            handles.brainMap.overlay.FaceAlpha = 0;
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        end
    end
    
    if handles.valuesButton.Value == 1 && handles.neighborhoodButton.Value == 0
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothType = 'neighbors';
    elseif handles.valuesButton.Value == 0 && handles.neighborhoodButton.Value == 1
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothType = 'neighborhood';
    end
        
    if handles.smoothBelowThresh.Value == 1 && handles.smoothAboveThresh.Value == 0
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothThreshold = 'border';
    elseif handles.smoothBelowThresh.Value == 0 && handles.smoothAboveThresh.Value == 1
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothThreshold = 'above';
    end
    figure(handles.brainFig)
    [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI,'smoothSteps',str2double(handles.smoothSteps.String),'smoothArea',str2double(handles.smoothArea.String),'smoothThreshold',handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothThreshold,'smoothType',handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothType);
    
    handles.brainMap.colorbar = cbar;
    handles.brainMap.colorbar.TickLength = [0 0];
    imh = handles.brainMap.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
        
    if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
        handles.brainMap.colorbar.YTick = handles.opts.ticks;
        handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
    end
    
    if isfield(handles,'overlayCopy')
        handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
        handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
        handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
        handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
        handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
    end
    
    guidata(hObject, handles);
end

%% button to save smoothing to this overlay's settings
function setButton_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data = handles.opts.overlayData;    
    
    handles.smoothAboveThresh.Value = 1;
    handles.smoothBelowThresh.Value = 0;
    handles.valuesButton.Value = 1;
    handles.neighborhoodButton.Value = 0;
    handles.smoothArea.String = '0';
    handles.smoothSteps.String = '0';
    
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothThreshold = 'border';
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothType = 'neighbors';
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothArea = 0;
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothSteps = 0;
    
    guidata(hObject, handles);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %% %% Menu options %% %% %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% button for summoning cluster editing GUI
function editClusterButton_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    clusterGUI
    guidata(hObject, handles);
end

%% roi-ification of map
function roiButton_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    % remove colorbar if it exists
    if isfield(handles.brainMap,'colorbar')
        delete(handles.brainMap.colorbar)
        handles.brainMap = rmfield(handles.brainMap,'colorbar');
    end
    
    % now turn off any overlays that might exist and delete them
    % multioverlays are in a cell
    if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
        if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
            for celli = 1:length(handles.brainMap.overlay)
                handles.brainMap.overlay{celli}.FaceAlpha = 0;
            end
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        elseif isvalid(handles.brainMap.overlay)
            handles.overlayCopy = handles.brainMap.overlay;
            handles.brainMap.overlay.FaceAlpha = 0;
            handles.brainMap = rmfield(handles.brainMap,'overlay');
        end
    end
    
    % this is the switch for roi-ification
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters = 'true';
    figure(handles.brainFig)
    % get new data without patching...
    [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI,'plotSwitch','off');
    
    if isfield(handles,'overlayCopy')
        handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
        handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
        handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
        handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
        handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
    end
    
    % now using the roi data update GUI settings and settings for current
    % map
    % change limits
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin = min(handles.opts.overlayData);
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax = max(handles.opts.overlayData);
    handles.limitMin.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin);
    handles.limitMax.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax);
    
    % set binarize to zero
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize = 0;
    handles.binarizeSwitch.Value = 0;
    
    % set thresholds to zero
    handles.overlayThresholdPos.Value = 0;
    handles.overlayThresholdNeg.Value = 0;
    handles.overlayThresholdNegDynamic.String = '0';
    handles.overlayThresholdPosDynamic.String = '0';
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos = 0;
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg = 0;
    
    handles.pSlider.Value = 0;
    handles.pText.String = '0';
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh = 0;
    
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins = length(unique(handles.opts.overlayData));
    
    % set colorSampling to zero
    handles.colormapSpacing.Value = 2;
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing = handles.colormapSpacing.String{handles.colormapSpacing.Value};
    
    % also update how far the sliders should be capable of moving based on
    % the data for this map
    handles.overlayThresholdPos.Max = max(handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data);
    handles.overlayThresholdNeg.Min = min(handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data);
    
    % write cluster data into main data structure and update GUI based on
    % this data's range
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data = handles.opts.overlayData;
    
    % changing to true triggers roi-ification but we are going to write
    % this data into the main structure so that we don't have to redo the
    % analysis (which takes time because you need to trigger delineation of
    % clusters). So, we should turn it of for future patching.
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters = 'false';
    figure(handles.brainFig)
    [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.brainMap.colorbar = cbar;
    handles.brainMap.colorbar.TickLength = [0 0];
    imh = handles.brainMap.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
            
    if isfield(handles,'overlayCopy')
        handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
        handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
        handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
        handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
        handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
    end
    
    guidata(hObject, handles);
end

%% buttons for editing sulici/gyri
function editSGC_Callback(hObject, eventdata, handles)
if isfield(handles,'underlay') == 1
    handles = guidata(hObject);
    gyriC = uisetcolor([0.8 0.8 0.8],'Select a color for gyri (shown is default)');
    sulciC = uisetcolor([0.4 0.4 0.4],'Select a color for sulci (shown is default)');
    
    % only two colors in underlay -- sulci and gyri
    hemis = fieldnames(handles.underlay);
    unCs = unique(handles.underlay.(hemis{1}).FaceVertexCData,'rows');
    
    % if first unique color is higher, it's the sulci color so replace it
    % with your new color
    for hemii = 1:length(hemis)
        
        if mean(unCs(1,:)) < mean(unCs(2,:))
            sulciFace = find(ismember(handles.underlay.(hemis{hemii}).FaceVertexCData,unCs(1,:),'rows'));
            gyriFace = find(ismember(handles.underlay.(hemis{hemii}).FaceVertexCData,unCs(2,:),'rows'));
        else
            sulciFace = find(ismember(handles.underlay.(hemis{hemii}).FaceVertexCData,unCs(2,:),'rows'));
            gyriFace = find(ismember(handles.underlay.(hemis{hemii}).FaceVertexCData,unCs(1,:),'rows'));
        end
        
        handles.underlay.(hemis{hemii}).FaceVertexCData(sulciFace,1) = sulciC(1);
        handles.underlay.(hemis{hemii}).FaceVertexCData(sulciFace,2) = sulciC(2);
        handles.underlay.(hemis{hemii}).FaceVertexCData(sulciFace,3) = sulciC(3);
        
        handles.underlay.(hemis{hemii}).FaceVertexCData(gyriFace,1) = gyriC(1);
        handles.underlay.(hemis{hemii}).FaceVertexCData(gyriFace,2) = gyriC(2);
        handles.underlay.(hemis{hemii}).FaceVertexCData(gyriFace,3) = gyriC(3);
        
    end
    guidata(hObject, handles);
end

function editSGT_Callback(hObject, eventdata, handles)
if isfield(handles,'underlay') == 1
    handles = guidata(hObject);
    if handles.surfaceSelection.Value == 2
        %delete(handles.underlay.left)
        %delete(handles.underlay.right)
        
        [vert1,face1] = read_surf([handles.paths.brainPath handles.paths.slash 'lh.inflated']);
        [vert2,face2] = read_surf([handles.paths.brainPath handles.paths.slash 'rh.inflated']);
        curv1 = read_curv([handles.paths.brainPath handles.paths.slash 'lh.curv']);
        curv2 = read_curv([handles.paths.brainPath handles.paths.slash 'rh.curv']);
        
        thresh = inputdlg(['Choose a threshold boundary for what we will call sulci (smaller and negative values will increase gyri size...min is ' num2str(min(curv1)) ' and max is ' num2str(max(curv1))],'Sulci-gyri Boundary');
        [handles.underlay, handles.brainFig] = plotUnderlay(vert1, face1, curv1, vert2, face2, curv2,'false',str2double(thresh));
        hold on
    end
    
    if handles.surfaceSelection.Value == 3
        %delete(handles.underlay.left)
        [vert1,face1] = read_surf([handles.paths.brainPath handles.paths.slash 'lh.inflated']);
        curv1 = read_curv([handles.paths.brainPath handles.paths.slash 'lh.curv']);
        thresh = inputdlg(['Choose a threshold boundary for what we will call sulci (smaller and negative values will increase gyri size...min is ' num2str(min(curv1)) ' and max is ' num2str(max(curv1))],'Sulci-gyri Boundary');
        
        [handles.underlay, handles.brainFig] = plotUnderlay(vert1, face1, curv1,'false',str2double(thresh));
    end
    
    if handles.surfaceSelection.Value == 4
        %delete(handles.underlay.right)
        [vert1,face1] = read_surf([handles.paths.brainPath handles.paths.slash 'rh.inflated']);
        curv1 = read_curv([handles.paths.brainPath handles.paths.slash 'rh.curv']);
        thresh = inputdlg(['Choose a threshold boundary for what we will call sulci (smaller and negative values will increase gyri size...min is ' num2str(min(curv1)) ' and max is ' num2str(max(curv1))],'Sulci-gyri Boundary');
        
        [handles.underlay, handles.brainFig] = plotUnderlay(vert1, face1, curv1,'false',str2double(thresh));
    end
    
    if handles.surfaceSelection.Value == 5
        % load surface data
        brainFile = uipickfiles('FilterSpec','*.inflated','Prompt','Select one or two surface(s) to plot.');
        handles.w = warndlg('Please select your curvature files in the same order as the surfaces!');
        curvFile = uipickfiles('FilterSpec','*.curv','Prompt','Select curvatures for each of your surface(s)');
        
        % figure out which hemisphere is which from the selections
        handles.w = warndlg('Assuming vertex positioning is in radiological convention (left is negative)');
        if length(brainFile) > 1 % if you selected two files lets load both in
            [vert1,face1] = read_surf(brainFile{1});
            [vert2,face2] = read_surf(brainFile{2});
            curv1 = read_curv(curvFile{1});
            curv2 = read_curv(curvFile{2});
            %delete(handles.underlay)
            [handles.underlay, handles.brain] = plotUnderlay(vert1, face1, curv1, vert2, face2, curv2,'false',thresh);
        else % if you selected one file just load that in and figure out which is negative
            [vert1,face1] = read_surf(brainFile{1});
            curv1 = read_curv(curvFile{1});
            %delete(handles.underlay)
            [handles.underlay, handles.brain] = plotUnderlay(vert1, face1, curv1,'false',thresh);
        end
    end
    guidata(hObject, handles);
end

function rawSGC_Callback(hObject, eventdata, handles)
if isfield(handles,'underlay') == 1
    handles = guidata(hObject);
    % plot raw sulci/gyri data. Check if you have 2,3,4 selected
    % for surface because that means we can find them ourselves
    if handles.surfaceSelection.Value == 2
        %delete(handles.underlay.left)
        %delete(handles.underlay.right)
        
        [vert1,face1] = read_surf([handles.paths.brainPath handles.paths.slash 'lh.inflated']);
        [vert2,face2] = read_surf([handles.paths.brainPath handles.paths.slash 'rh.inflated']);
        curv1 = read_curv([handles.paths.brainPath handles.paths.slash 'lh.curv']);
        curv2 = read_curv([handles.paths.brainPath handles.paths.slash 'rh.curv']);
        [handles.underlay, handles.brainFig] = plotUnderlay(vert1, face1, curv1, vert2, face2, curv2,'true');
        hold on
    end
    
    if handles.surfaceSelection.Value == 3
        %delete(handles.underlay.left)
        [vert1,face1] = read_surf([handles.paths.brainPath handles.paths.slash 'lh.inflated']);
        curv1 = read_curv([handles.paths.brainPath handles.paths.slash 'lh.curv']);
        [handles.underlay, handles.brainFig] = plotUnderlay(vert1, face1, curv1,'true');
    end
    
    if handles.surfaceSelection.Value == 4
        %delete(handles.underlay.right)
        [vert1,face1] = read_surf([handles.paths.brainPath handles.paths.slash 'rh.inflated']);
        curv1 = read_curv([handles.paths.brainPath handles.paths.slash 'rh.curv']);
        [handles.underlay, handles.brainFig] = plotUnderlay(vert1, face1, curv1,'true');
    end
    
    if handles.surfaceSelection.Value == 5
        % load surface data
        brainFile = uipickfiles('FilterSpec','*.inflated','Prompt','Select one or two surface(s) to plot.');
        handles.w = warndlg('Please select your curvature files in the same order as the surfaces!');
        curvFile = uipickfiles('FilterSpec','*.curv','Prompt','Select curvatures for each of your surface(s)');
        
        % figure out which hemisphere is which from the selections
        handles.w = warndlg('Assuming vertex positioning is in radiological convention (left is negative)');
        if length(brainFile) > 1 % if you selected two files lets load both in
            [vert1,face1] = read_surf(brainFile{1});
            [vert2,face2] = read_surf(brainFile{2});
            curv1 = read_curv(curvFile{1});
            curv2 = read_curv(curvFile{2});
            %delete(handles.underlay)
            [handles.underlay, handles.brain] = plotUnderlay(vert1, face1, curv1, vert2, face2, curv2,'true');
        else % if you selected one file just load that in and figure out which is negative
            [vert1,face1] = read_surf(brainFile{1});
            curv1 = read_curv(curvFile{1});
            %delete(handles.underlay)
            [handles.underlay, handles.brain] = plotUnderlay(vert1, face1, curv1,'true');
        end
    end
    guidata(hObject, handles);
end

%% mask button
function maskButton_Callback(hObject, eventdata, handles)
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    maskGUI
    guidata(hObject, handles);
end

%% show the entire color bar button
function wholeColorbar_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
if isfield(handles,'brainMap')
    if isfield(handles.brainMap,'overlay')
        if length(handles.overlaySelection.Value) == 1
            % remove colorbar if it exists
            if isfield(handles.brainMap,'colorbar')
                delete(handles.brainMap.colorbar)
                handles.brainMap = rmfield(handles.brainMap,'colorbar');
            end
            
            figure(handles.brainFig)
            handles.brainMap.colorbar = cbar;
            handles.brainMap.colorbar.TickLength = [0 0];
            
            if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
                handles.brainMap.colorbar.YTick = handles.opts.ticks;
                handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
            end
        end
    end
end
guidata(hObject, handles);

%% save overlay settings
function saveOSet_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    % save GUI settings
    settings.colormap = handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap;
    settings.overlayThresholdNeg = handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg;
    settings.overlayThresholdPos = handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos;
    settings.limitMin = handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin;
    settings.limitMax = handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax;
    settings.opacity = handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity;
    settings.colormapSpacing = handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing;
    settings.colorBins = handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins;
    settings.clusterThresh = handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh;
    settings.binarize = handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize;
    settings.inclZero = handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero;
    settings.outline = handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline;
    settings.smoothSteps = handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothSteps;
    settings.smoothArea = handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothArea;
    settings.smoothThreshold = handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothThreshold;
    settings.customColor = handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor;
    settings.binarizeClusters = handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters;
    settings.pThresh = handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh;
    settings.pVals = handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals;
    settings.transparencyLimits = handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits;
    settings.transparencyThresholds = handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds;
    settings.transparencyData = handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData;
    settings.transparencyPThresh = handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh;
    settings.invertColor = handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor;
    settings.invertOpacity = handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity;
    settings.growROI = handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI;
    settings.smoothType = handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothType;
    settings.path = handles.brainMap.Current{handles.overlaySelection.Value - 1}.path;
    settings.name = handles.brainMap.Current{handles.overlaySelection.Value - 1}.name;
    settings.ext = handles.brainMap.Current{handles.overlaySelection.Value - 1}.ext;
    settings.hemi = handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi;
    
    [~,file, ~] = fileparts(handles.brainMap.Current{handles.overlaySelection.Value - 1}.name);
    [oFile, oPath] = uiputfile({'*.mat'},'Save overlay settings',file);
    save([oPath oFile],'settings')
end
guidata(hObject, handles);

%% load overlay settings 
function loadOSet_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    [file,path] = uigetfile('*.mat','Select overlay settings to load');
    load([path file])
    
    uIn = questdlg('Would you like to load the brain map associated with these settings too?', ...
        'Optional', ...
        'Yes','No','No');
    
    switch uIn
        case 'Yes'
            if length(handles.overlaySelection.Value) == 1
                
                fileNum = length(handles.brainMap.Current) + 1;
                handles.brainMap.Current{fileNum} = handles.brainMap.Current{handles.overlaySelection.Value - 1};
                
                handles.brainMap.Current{fileNum}.colormap = settings.colormap;
                handles.brainMap.Current{fileNum}.overlayThresholdNeg = settings.overlayThresholdNeg;
                handles.brainMap.Current{fileNum}.overlayThresholdPos = settings.overlayThresholdPos;
                handles.brainMap.Current{fileNum}.limitMin = settings.limitMin;
                handles.brainMap.Current{fileNum}.limitMax = settings.limitMax;
                handles.brainMap.Current{fileNum}.opacity = settings.opacity;
                handles.brainMap.Current{fileNum}.colormapSpacing = settings.colormapSpacing;
                handles.brainMap.Current{fileNum}.colorBins = settings.colorBins;
                handles.brainMap.Current{fileNum}.clusterThresh = settings.clusterThresh;
                handles.brainMap.Current{fileNum}.binarize = settings.binarize;
                handles.brainMap.Current{fileNum}.inclZero = settings.inclZero;
                handles.brainMap.Current{fileNum}.outline = settings.outline;
                handles.brainMap.Current{fileNum}.smoothSteps = settings.smoothSteps;
                handles.brainMap.Current{fileNum}.smoothArea = settings.smoothArea;
                handles.brainMap.Current{fileNum}.smoothThreshold = settings.smoothThreshold;
                handles.brainMap.Current{fileNum}.customColor = settings.customColor;
                handles.brainMap.Current{fileNum}.binarizeClusters = settings.binarizeClusters;
                handles.brainMap.Current{fileNum}.pThresh = settings.pThresh;
                
                handles.brainMap.Current{fileNum}.pVals = settings.pVals;
                handles.brainMap.Current{fileNum}.transparencyLimits = settings.transparencyLimits;
                handles.brainMap.Current{fileNum}.transparencyThresholds = settings.transparencyThresholds;
                handles.brainMap.Current{fileNum}.transparencyData = settings.transparencyData;
                handles.brainMap.Current{fileNum}.transparencyPThresh = settings.transparencyPThresh;
                handles.brainMap.Current{fileNum}.invertColor = settings.invertColor;
                handles.brainMap.Current{fileNum}.invertOpacity = settings.invertOpacity;
                handles.brainMap.Current{fileNum}.growROI = settings.growROI;
                handles.brainMap.Current{fileNum}.smoothType = settings.smoothType;
                handles.brainMap.Current{fileNum}.path = settings.path;
                handles.brainMap.Current{fileNum}.name = settings.name;
                handles.brainMap.Current{fileNum}.ext = settings.ext;
                handles.brainMap.Current{fileNum}.hemi = settings.hemi;
                hdr = load_nifti([handles.brainMap.Current{fileNum}.path handles.paths.slash handles.brainMap.Current{fileNum}.name handles.brainMap.Current{fileNum}.ext]); % load in data
                handles.brainMap.Current{fileNum}.Data = hdr.vol;
                
                handles.overlaySelection.String = vertcat(handles.overlaySelection.String(:),handles.brainMap.Current{fileNum}.name);
                handles.overlaySelection.Value = length(handles.overlaySelection.String);
                
                % remove colorbar if it exists
                if isfield(handles.brainMap,'colorbar')
                    delete(handles.brainMap.colorbar)
                    handles.brainMap = rmfield(handles.brainMap,'colorbar');
                end
                
                % now turn off any overlays that might exist and delete them
                % multioverlays are in a cell
                if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
                    if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
                        for celli = 1:length(handles.brainMap.overlay)
                            handles.brainMap.overlay{celli}.FaceAlpha = 0;
                        end
                        handles.brainMap = rmfield(handles.brainMap,'overlay');
                    elseif isvalid(handles.brainMap.overlay)
                        handles.overlayCopy = handles.brainMap.overlay;
                        handles.brainMap.overlay.FaceAlpha = 0;
                        handles.brainMap = rmfield(handles.brainMap,'overlay');
                    end
                end
                figure(handles.brainFig)
                [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
                
                handles.brainMap.colorbar = cbar;
                handles.brainMap.colorbar.TickLength = [0 0];
                imh = handles.brainMap.colorbar.Children(1);
                imh.AlphaData = handles.opts.transparencyData;
                imh.AlphaDataMapping = 'direct';
                
                if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
                    handles.brainMap.colorbar.YTick = handles.opts.ticks;
                    handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
                end
                
                if isfield(handles,'overlayCopy')
                    handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
                    handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
                    handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
                    handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
                    handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
                end
                
            end
            
        case 'No'
            
            if handles.overlaySelection.Value > 1
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap = settings.colormap;
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg = settings.overlayThresholdNeg;
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos = settings.overlayThresholdPos;
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin = settings.limitMin;
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax = settings.limitMax;
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity = settings.opacity;
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing = settings.colormapSpacing;
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins = settings.colorBins;
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh = settings.clusterThresh;
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize = settings.binarize;
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero = settings.inclZero;
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline = settings.outline;
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothSteps = settings.smoothSteps;
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothArea = settings.smoothArea;
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothThreshold = settings.smoothThreshold;
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor = settings.customColor;
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters = settings.binarizeClusters;
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh = settings.pThresh;
                
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals = settings.pVals;
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits = settings.transparencyLimits;
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds = settings.transparencyThresholds;
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData = settings.transparencyData;
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh = settings.transparencyPThresh;
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor = settings.invertColor;
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity = settings.invertOpacity;
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI = settings.growROI;
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothType = settings.smoothType;
                
                handles.limitMin.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin);
                handles.limitMax.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax);
                handles.overlayThresholdPos.Value = handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos;
                handles.overlayThresholdNeg.Value = handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg;
                handles.colormap.Value = handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap;
                handles.opacity.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity);
                handles.binarizeSwitch.Value = handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize;
                
                if strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'true')
                    handles.zeroButton.Value = 1;
                else
                    handles.zeroButton.Value = 0;
                end
                
                if strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'false')
                    handles.outlineButton.Value = 0;
                elseif strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'true')
                    handles.outlineButton.Value = 1;
                end
                
                if strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'false')
                    handles.invertColorButton.Value = 0;
                elseif strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'true')
                    handles.invertColorButton.Value = 1;
                end
                
                handles.growROI.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
                
                if strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'even')
                    handles.colormapSpacing.Value = 2;
                elseif strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'center on zero')
                    handles.colormapSpacing.Value = 3;
                elseif strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'center on threshold')
                    handles.colormapSpacing.Value = 4;
                end
                
                handles.overlayThresholdPosDynamic.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos);
                handles.overlayThresholdNegDynamic.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg);
                handles.colorBins.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins);
                
                % also update how far the sliders should be capable of moving based on
                % the data for this map
                handles.overlayThresholdPos.Max = max(max(max(handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data)));
                handles.overlayThresholdNeg.Min = min(min(min(handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data)));
                
                % remove colorbar if it exists
                if isfield(handles.brainMap,'colorbar')
                    delete(handles.brainMap.colorbar)
                    handles.brainMap = rmfield(handles.brainMap,'colorbar');
                end
                
                % now turn off any overlays that might exist and delete them
                % multioverlays are in a cell
                if isfield(handles.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
                    if iscell(handles.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
                        for celli = 1:length(handles.brainMap.overlay)
                            handles.brainMap.overlay{celli}.FaceAlpha = 0;
                        end
                        handles.brainMap = rmfield(handles.brainMap,'overlay');
                    elseif isvalid(handles.brainMap.overlay)
                        handles.overlayCopy = handles.brainMap.overlay;
                        handles.brainMap.overlay.FaceAlpha = 0;
                        handles.brainMap = rmfield(handles.brainMap,'overlay');
                    end
                end
                figure(handles.brainFig)
                [handles.underlay, handles.brainMap.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi, 'opacity', handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity, 'colorMap', handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap}, 'colorSampling',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'colorBins',handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,'limits', [handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
                
                handles.brainMap.colorbar = cbar;
                handles.brainMap.colorbar.TickLength = [0 0];
                imh = handles.brainMap.colorbar.Children(1);
                imh.AlphaData = handles.opts.transparencyData;
                imh.AlphaDataMapping = 'direct';
                
                if handles.colormapSpacing.Value == 4 || handles.colormapSpacing.Value == 3
                    handles.brainMap.colorbar.YTick = handles.opts.ticks;
                    handles.brainMap.colorbar.YTickLabel = handles.opts.tickLabels;
                end
                
                if isfield(handles,'overlayCopy')
                    handles.brainMap.overlay.SpecularStrength = handles.overlayCopy.SpecularStrength;
                    handles.brainMap.overlay.SpecularExponent = handles.overlayCopy.SpecularExponent;
                    handles.brainMap.overlay.SpecularColorReflectance =  handles.overlayCopy.SpecularColorReflectance;
                    handles.brainMap.overlay.DiffuseStrength = handles.overlayCopy.DiffuseStrength;
                    handles.brainMap.overlay.AmbientStrength =  handles.overlayCopy.AmbientStrength;
                end
                
            else
                handles.w = warndlg('You do not have an overlay selected for which to load settings into','Error');
            end
    end
    
end

guidata(hObject, handles);

%% convert a tal image to mni space
function convTal2MNI_Callback(hObject, eventdata, handles)
handles = guidata(hObject);

[inFiles, inPaths] = uigetfile({'*.nii*'},'Select some files to convert','MultiSelect','on');

if ~iscell(inFiles)
    inFiles = {[inPaths inFiles]};
else
    for i = 1:length(inFiles)
       inFiles{i} = [inPaths{i} inFiles{i}]; 
    end
end

idx = find(contains(inFiles,'.gz'));
for i = 1:length(idx)
    gunzip(inFiles{idx(i)})
    inFiles{idx(i)} = inFiles{idx(i)}(1:end-3);
end

convertTAL2MNIImage(inFiles,[],0)

for i = 1:length(idx)
    delete(inFiles{idx(i)})
end

handles.w = warndlg('MNI file is in the same directory as original file (appended ''''_MNI'''')');

guidata(hObject, handles);

%% convert an MNI image to TAL space
function convMNI2Tal_Callback(hObject, eventdata, handles)
handles = guidata(hObject);

[inFiles, inPaths] = uigetfile({'*.nii*'},'Select some files to convert','MultiSelect','on');

if ~iscell(inFiles)
    inFiles = {[inPaths inFiles]};
else
    for i = 1:length(inFiles)
       inFiles{i} = [inPaths{i} inFiles{i}]; 
    end
end

idx = find(contains(inFiles,'.gz'));
for i = 1:length(idx)
    gunzip(inFiles{idx(i)})
    inFiles{idx(i)} = inFiles{idx(i)}(1:end-3);
end

convertMNI2TALImage(inFiles,[],0)

for i = 1:length(idx)
    delete(inFiles{idx(i)})
end

handles.w = warndlg('Talairached file is in the same directory as original file (appended ''''_TAL'''')');

guidata(hObject, handles);

%% get information about currently selected map
function mapInfo_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    h = figure;
    h = histogram(handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data);
    if length(handles.brainMap.Current{handles.overlaySelection.Value - 1}.name) > 45
        nTmp = handles.brainMap.Current{handles.overlaySelection.Value - 1}.name(1:45);
    else
        nTmp = handles.brainMap.Current{handles.overlaySelection.Value - 1}.name;
    end
    idx = strfind(nTmp,'_');
    nTmp(idx) = ' ';
    title(['Histogram of values in ' nTmp])
    xlabel(['Value in map (falling between ' num2str(min(handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data)) ' and ' num2str(max(handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data)) ' with a mean of ' num2str(mean(handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data)) ' and stdev of ' num2str(std(handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data)) ')']);
    ylabel(['Number of vertices (of ' num2str(length(handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data)) ')']);
    set(gcf,'color','w');
end
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %% %% Creation functions %% %% %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes during object creation, after setting all properties.
function overlayThresholdPosDynamic_CreateFcn(hObject, eventdata, handles)
% hObject    handle to overlayThresholdPosDynamic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function overlayClusterThresholdDynamic_CreateFcn(hObject, eventdata, handles)
% hObject    handle to overlayClusterThresholdDynamic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function clusterThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clusterThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function smoothRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smoothRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function smoothSteps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smoothSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function overlayThresholdPos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to overlayThresholdPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function overlayThresholdNeg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to overlayThresholdNeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function overlayThresholdNegDynamic_CreateFcn(hObject, eventdata, handles)
% hObject    handle to overlayThresholdNegDynamic (see GCBO) eventdata
% reserved - to be defined in a future version of MATLAB handles    empty -
% handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function overlaySelection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to overlaySelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function surfaceSelection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to surfaceSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function curvSelection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to curvSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function opacity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to opacity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to smoothSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of smoothSteps as text
%        str2double(get(hObject,'String')) returns contents of smoothSteps as a double
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smoothSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function smoothArea_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smoothArea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function colormap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function limitMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to limitMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function limitMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to limitMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% function limitNegMin_Callback(hObject, eventdata, handles)
% % hObject    handle to limitNegMin (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'String') returns contents of limitNegMin as text
% %        str2double(get(hObject,'String')) returns contents of limitNegMin as a double
% if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
%     handles = guidata(hObject);
%     guidata(hObject, handles);
% end

% --- Executes during object creation, after setting all properties.
function limitNegMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to limitNegMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% function limitNegMax_Callback(hObject, eventdata, handles)
% % hObject    handle to limitNegMax (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'String') returns contents of limitNegMax as text
% %        str2double(get(hObject,'String')) returns contents of limitNegMax as a double
% if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
%     handles = guidata(hObject);
%     guidata(hObject, handles);
% end

% --- Executes during object creation, after setting all properties.
function limitNegMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to limitNegMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function colormapSpacing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colormapSpacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function colorBins_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colorBins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function pSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function pText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function clusterThreshSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clusterThreshSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function clusterThreshText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clusterThreshText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in duplicateButton.
function pushbutton23_Callback(hObject, eventdata, handles)
% hObject    handle to duplicateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in upButton.
% function upButton_Callback(hObject, eventdata, handles)
% % hObject    handle to upButton (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
%     handles = guidata(hObject);
%     
%     guidata(hObject, handles);
% end

% --- Executes during object creation, after setting all properties.
function growROI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to growROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function combMaps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to growROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in reloadOverlay.
function pushbutton41_Callback(hObject, eventdata, handles)
% hObject    handle to reloadOverlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in duplicateButton.
function pushbutton42_Callback(hObject, eventdata, handles)
% hObject    handle to duplicateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in deleteOverlay.
function pushbutton43_Callback(hObject, eventdata, handles)
% hObject    handle to deleteOverlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in saveOverlay.
function pushbutton45_Callback(hObject, eventdata, handles)
% hObject    handle to saveOverlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton37.
function pushbutton37_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Settings_Callback(hObject, eventdata, handles)
% hObject    handle to Settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in pushbutton48.
function pushbutton48_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton48 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in screenshotsButton.
function pushbutton50_Callback(hObject, eventdata, handles)
% hObject    handle to screenshotsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in screenshotButton.
function pushbutton51_Callback(hObject, eventdata, handles)
% hObject    handle to screenshotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in lightingButton.
function pushbutton52_Callback(hObject, eventdata, handles)
% hObject    handle to lightingButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function multidimOverlay_Callback(hObject, eventdata, handles)
% hObject    handle to multidimOverlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function combMaps_Callback(hObject, eventdata, handles)
% hObject    handle to multidimOverlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function patch2d_Callback(hObject, eventdata, handles)
% hObject    handle to patch2d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    colormapEditor2D
    guidata(hObject, handles);
end

% --------------------------------------------------------------------
function patch3d_Callback(hObject, eventdata, handles)
% hObject    handle to patch3d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if length(handles.overlaySelection.Value) == 1
    handles = guidata(hObject);
    colormapEditor3D
    guidata(hObject, handles);
end

% --------------------------------------------------------------------
function Untitled_16_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function statsButton_Callback(hObject, eventdata, handles)
% hObject    handle to statsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
% handles = guidata(hObject);
% mathsGUI
% guidata(hObject, handles);
%end
handles.w = warndlg('Sorry! This is not currently supported');

% --------------------------------------------------------------------
function clustCorr_Callback(hObject, eventdata, handles)
% hObject    handle to clustCorr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.w = warndlg('Sorry! This is not currently supported');
% --------------------------------------------------------------------
% function copyOSet_Callback(hObject, eventdata, handles)
% % hObject    handle to copyOSet (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% if handles.overlaySelection.Value ~= 1 && length(handles.overlaySelection.Value) == 1
%     handles = guidata(hObject);
%     copySettingsGUI
%     guidata(hObject, handles);
% end

% --------------------------------------------------------------------
function Untitled_20_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_22_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_23_Callback(hObject, eventdata, handles)
% hObject    handle to roiButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Untitled_26_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_27_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function volumeViewer_Callback(hObject, eventdata, handles)
% hObject    handle to volumeViewer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.w = warndlg('Sorry! This is not currently supported');
