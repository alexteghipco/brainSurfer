function varargout = brainSurfer(varargin)
% Brainsurfer GUI
% Alex Teghipco // alex.teghipco@uci.edu // 12/6/18
%
% Fixed bug where certain GUI parameters were not being updated during overlay selection process
%
% Last Modified by GUIDE v2.5 08-Nov-2018 22:22:55

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


%hObject.UserData.paths.brainPath = [guiPath '/brains'];
%hObject.UserData.paths.scriptPath = [guiPath '/scripts'];
handles.paths.brainPath = [guiPath handles.paths.slash 'brains'];
handles.paths.scriptPath = [guiPath handles.paths.slash 'scripts'];
handles.paths.colormapsPath = [guiPath handles.paths.slash 'colormaps'];

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
set(handles.overlaySelection,'Max',50,'Min',0);
%guidata(hObject, handles);

guidata(hObject, handles);
% UIWAIT makes brainSurfer wait for user response (see UIRESUME)
% uiwait(handles.brainSurferGUI);

% --- Outputs from this function are returned to the command line.
function varargout = brainSurfer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.brainSurferGUI)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.brainSurferGUI,'Name') '?'],...
    ['Close ' get(handles.brainSurferGUI,'Name') '...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.brainSurferGUI)

% --- Executes on button press in overlayAdd.
function overlayAdd_Callback(hObject, eventdata, handles)
% hObject    handle to overlayAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);

if isfield(handles, 'underlay') == 1
    
    % get all overlay files
    overlayFiles = uipickfiles('REFilter','\.nii.gz$|\.nii$','Prompt','Select one or more overlays')';
    
    % Determine hemisphere of each file, get names, and set up structure for
    % overlays. Data from all overlays is stored as a backup in
    % handles.brainMap.Original.Data so that overlays can be reloaded. Data in
    % handles.brainMap.Current.Data is the data that gets manipulated. For each
    % overlay faces of the brain are stored. This is what gets visualized so
    % there is also a backup version of this in handles.brainMap.Original.Faces
    % and the version in handles.brainMap.Current.Faces will be the one that is
    % manipulated along with the data vectors. Filenames starting with 'l' are
    % assigned to the left hemisphere. Filenames starting with 'r' are assigned
    % to the right hemisphere (you need this info to understand which faces to
    % extract and which brain to plot the data on).
    
    % if you don't have an underlay, you can't add a file
    
    % figure out if there are any existing overlayFiles to add to
    if ischar(handles.overlaySelection.String) == 1 || isempty(handles.overlaySelection.String) == 1
        numSavedOverlays = 0;
    else
        numSavedOverlays = length(handles.overlaySelection.String) - 1;
    end
    
    % dont load in data or update handles if you hit the cancel button in
    % uipickfiles
    if isa(overlayFiles,'cell') == 1
        % if you did not hit the cancel button, loop through overlay files
        % and save the overlay's name in brainMap structure and data in
        % brainMap.Original.Data
        for filei = 1:length(overlayFiles)
            storedFileNum = numSavedOverlays+filei;
            [handles.brainMap.Path{storedFileNum, 1}, handles.brainMap.Name{storedFileNum,1}] = fileparts(overlayFiles{filei});
            hdr = load_nifti(overlayFiles{filei});
            handles.brainMap.Original.Data{storedFileNum,1} = hdr.vol;
            
            % Figure out which hemisphere the file belongs to
            if contains(lower(handles.brainMap.Name{storedFileNum,1}),lower({'left', 'lh'})) == 1
                handles.brainMap.hemi{storedFileNum,1} = 'left';
            elseif contains(lower(handles.brainMap.Name{storedFileNum,1}),lower({'right', 'rh'})) == 1
                handles.brainMap.hemi{storedFileNum,1} = 'right';
            elseif (contains(lower(handles.brainMap.Name{storedFileNum,1}),lower({'left', 'lh'})) == 1) && (contains(lower(handles.brainMap.Name{storedFileNum,1}),lower({'right', 'rh'})) == 1)
                handles.brainMap.hemi{storedFileNum,1} = inputdlg('It looks like your file contains reference to both hemispheres...which hemisphere should I associate with this file? (type left or right)' ,'Could not find hemisphere');
            elseif (contains(lower(handles.brainMap.Name{storedFileNum,1}),lower({'left', 'lh'})) == 0) && (contains(lower(handles.brainMap.Name{storedFileNum,1}),lower({'right', 'rh'})) == 0)
                handles.brainMap.hemi{storedFileNum,1} = inputdlg('It looks like your file does not contain reference to either hemisphere...which hemisphere should I associate with this file? (type left or right)' ,'Could not find hemisphere');
            end
            
            handles.brainMap.Current{storedFileNum} = handles.defaultOptions;
            handles.brainMap.Current{storedFileNum}.Data = handles.brainMap.Original.Data{storedFileNum};
            handles.brainMap.Current{storedFileNum}.hemi = handles.brainMap.hemi{storedFileNum};
            
        end
        
        % update available list of overlays to select from
        if numSavedOverlays == 0
            try % when only one overlay is left in selection box as a result of deleting overlays vertcat throws error because the selection string is no longer in cell (i.e., as the case when loading the very first overlay)
                handles.overlaySelection.String = vertcat({handles.overlaySelection.String},handles.brainMap.Name(numSavedOverlays+1:(numSavedOverlays+length(overlayFiles))));
            catch
                handles.overlaySelection.String = vertcat(handles.overlaySelection.String,handles.brainMap.Name(numSavedOverlays+1:(numSavedOverlays+length(overlayFiles))));
            end
        else
            handles.overlaySelection.String = vertcat(handles.overlaySelection.String(:),handles.brainMap.Name(numSavedOverlays+1:(numSavedOverlays+length(overlayFiles))));
        end
        
        guidata(hObject, handles);
    end
end

function smoothSteps_Callback(hObject, eventdata, handles)
% hObject    handle to smoothSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of smoothSteps as text
%        str2double(get(hObject,'String')) returns contents of smoothSteps as a double
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothSteps = str2double(get(hObject,'String'));
    guidata(hObject, handles);
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

function smoothRadius_Callback(hObject, eventdata, handles)
% hObject    handle to smoothRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of smoothRadius as text
%        str2double(get(hObject,'String')) returns contents of smoothRadius as a double
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    guidata(hObject, handles);
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

% --- Executes on button press in smoothButton.
function smoothButton_Callback(hObject, eventdata, handles)
% hObject    handle to smoothButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    if isfield(handles.opts,'colorbar')
        delete(handles.opts.colorbar)
    end
    
    [handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI,'smoothArea',str2double(handles.smoothArea.String),'smoothSteps',str2double(handles.smoothSteps.String),'smoothThreshold',handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothThreshold,'smoothType',handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothType);
    %[handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'smoothArea',str2double(handles.smoothArea.String),'smoothSteps',str2double(handles.smoothSteps.String),'smoothThreshold',handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothThreshold,'smoothType',handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothType,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh);
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothedData = handles.opts.overlayData;
    
    handles.opts.colorbar = cbar;
    handles.opts.colorbar.TickLength = [0 0];
    imh = handles.opts.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    %%handles.opts.colorbar.YTick = handles.opts.colorBarTicks;
    %%handles.opts.colorbar.YTickLabel = handles.opts.colorBarLabels;
    
    guidata(hObject, handles);
end

% --- Executes on button press in smoothBelowThresh.
function smoothBelowThresh_Callback(hObject, eventdata, handles)
% hObject    handle to smoothBelowThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of smoothBelowThresh
if handles.overlaySelection.Value ~= 1
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

% --- Executes on button press in smoothAboveThresh.
function smoothAboveThresh_Callback(hObject, eventdata, handles)
% hObject    handle to smoothAboveThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of smoothAboveThresh
if handles.overlaySelection.Value ~= 1
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

% --- Executes on button press in screenshotButton.
function screenshotButton_Callback(hObject, eventdata, handles)
% hObject    handle to screenshotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.overlaySelection.Value ~= 1
    try
        [~,file, ~] = fileparts(handles.brainMap.Name{handles.overlaySelection.Value - 1});
    catch
        % you selected more than 1 file...that's alright
        [~,file, ~] = fileparts(handles.brainMap.Name{handles.overlaySelection.Value(1) - 1});
        file = [file '_MultipleOverlays'];
    end
    [oFile, oPath] = uiputfile({'*.png'},'Screenshot of current overlay',file);
    saveas(handles.brainFig,[oPath oFile]);
end

% --- Executes on slider movement.
function clusterThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to clusterThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    guidata(hObject, handles);
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


function overlayClusterThresholdDynamic_Callback(hObject, eventdata, handles)
% hObject    handle to overlayClusterThresholdDynamic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of overlayClusterThresholdDynamic as text
%        str2double(get(hObject,'String')) returns contents of overlayClusterThresholdDynamic as a double
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    guidata(hObject, handles);
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


% --- Executes on slider movement.
function overlayThresholdPos_Callback(hObject, eventdata, handles)
% hObject    handle to overlayThresholdPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    % update the dynamic text box
    handles.overlayThresholdPosDynamic.String = num2str(hObject.Value);
    
    % update saved settings for overlay
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos = hObject.Value;
    
    delete(handles.opts.colorbar)
    
    % update overlay
    %[handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh);
    [handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.opts.colorbar = cbar;
    handles.opts.colorbar.TickLength = [0 0];
    imh = handles.opts.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    %%handles.opts.colorbar.YTick = handles.opts.colorBarTicks;
    %%handles.opts.colorbar.YTickLabel = handles.opts.colorBarLabels;
    
    guidata(hObject, handles);
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


function overlayThresholdPosDynamic_Callback(hObject, eventdata, handles)
% hObject    handle to overlayThresholdPosDynamic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of overlayThresholdPosDynamic as text
%        str2double(get(hObject,'String')) returns contents of overlayThresholdPosDynamic as a double

% if a threshold is set in the text box, adjust the slider
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    % update the slider
    handles.overlayThresholdPos.Value = str2double(hObject.String);
    
    % update saved settings for overlay
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos = str2double(hObject.String);
    
    delete(handles.opts.colorbar)
    
    % update overlay
    %[handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh);
    [handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.opts.colorbar = cbar;
    handles.opts.colorbar.TickLength = [0 0];
    imh = handles.opts.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    %%handles.opts.colorbar.YTick = handles.opts.colorBarTicks;
    %%handles.opts.colorbar.YTickLabel = handles.opts.colorBarLabels;
    
    guidata(hObject, handles);
end

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

% --- Executes on slider movement.
function overlayThresholdNeg_Callback(hObject, eventdata, handles)
% hObject    handle to overlayThresholdNeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    % update the dynamic text box
    handles.overlayThresholdNegDynamic.String = num2str(hObject.Value);
    
    % update saved settings for overlay
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg = hObject.Value;
    
    delete(handles.opts.colorbar)
    
    % update overlay
    %[handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh);
    [handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.opts.colorbar = cbar;
    handles.opts.colorbar.TickLength = [0 0];
    imh = handles.opts.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    %handles.opts.colorbar.YTick = handles.opts.colorBarTicks;
    %handles.opts.colorbar.YTickLabel = handles.opts.colorBarLabels;
    
    guidata(hObject, handles);
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

function overlayThresholdNegDynamic_Callback(hObject, eventdata, handles)
% hObject    handle to overlayThresholdNegDynamic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of overlayThresholdNegDynamic as text
%        str2double(get(hObject,'String')) returns contents of overlayThresholdNegDynamic as a double

% if a threshold is set in the text box, adjust the slider
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    % update the slider
    handles.overlayThresholdNeg.Value = str2double(hObject.String);
    
    % update saved settings for overlay
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg = str2double(hObject.String);
    
    delete(handles.opts.colorbar)
    
    % update overlay
    %[handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh);
    [handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.opts.colorbar = cbar;
    handles.opts.colorbar.TickLength = [0 0];
    imh = handles.opts.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    %    %handles.opts.colorbar.YTick = handles.opts.colorBarTicks;
    %    %handles.opts.colorbar.YTickLabel = handles.opts.colorBarLabels;
    
    guidata(hObject, handles);
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

% --- Executes on button press in saveOverlay.
function saveOverlay_Callback(hObject, eventdata, handles)
% hObject    handle to saveOverlay (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    structure with handles
% and user data (see GUIDATA)
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    % load in the original overlay file for your selection. Try .gz if it
    % fails because load_nifti automatically gunzips
    if exist([handles.brainMap.Path{handles.overlaySelection.Value - 1} handles.paths.slash handles.brainMap.Name{handles.overlaySelection.Value - 1}],'file') ~= 0
        template = load_nifti([handles.brainMap.Path{handles.overlaySelection.Value - 1} handles.paths.slash handles.brainMap.Name{handles.overlaySelection.Value - 1}]);
    else
        try
            template = load_nifti([handles.brainMap.Path{handles.overlaySelection.Value - 1} handles.paths.slash handles.brainMap.Name{handles.overlaySelection.Value - 1} '.gz']);
        catch
            error('Could not load your original file...check to make sure you have not moved it')
        end
    end
    
    % now save
    template.vol = handles.opts.overlayData;
    [oFile, oPath] = uiputfile({'*.nii';'*.nii.gz'},'Save current overlay',handles.brainMap.Name{handles.overlaySelection.Value - 1});
    if isa(oFile,'double') == 0
        save_nifti(template,[oPath oFile])
    end
end

% --- Executes on selection change in overlaySelection.
function overlaySelection_Callback(hObject, eventdata, handles)
% hObject    handle to overlaySelection (see GCBO) eventdata  reserved - to
% be defined in a future version of MATLAB handles    structure with
% handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns overlaySelection
% contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        overlaySelection
handles = guidata(hObject);
% set(handles.overlaySelection,'Max',10,'Min',0);
% guidata(hObject, handles);

% check if you have selected more than one overlay
if length(handles.overlaySelection.Value) > 1
    % if multioverlay exists in handle and it has a current structure,
    % delete it to make room for this new multioverlay that you have
    % selected
    if isfield(handles,'multiOverlay') == 1
        if isfield(handles.multiOverlay,'Current') == 1
            for overlayi = 1:length(handles.multiOverlay.Current)
                delete(handles.multiOverlay.Current{overlayi}.overlay);
            end
            handles = rmfield(handles,'multiOverlay');
        end
    end
    
    % also turn off any other available overlays
    for overlayi = 1:length(handles.brainMap.Current)
        if isempty(handles.brainMap.Current{overlayi}) == 0
            try
                if isvalid(handles.brainMap.Current{overlayi}.overlay)
                    handles.brainMap.Current{overlayi}.overlay.FaceAlpha = 0;
                end
            catch
                warning('brainSurfer may have generated an extra overlay by accident...')
            end
        end
    end
    
    % find all overlays that you have selected (excluding 1 which is no
    % overlay) * REDUNDANT FIX
    handles.multiOverlay.Slections = handles.overlaySelection.Value(handles.overlaySelection.Value ~= 1);
    handles.multiOverlay.SlectionsAdjusted = handles.multiOverlay.Slections-1; % adjust for no overlap option
    
    % loop over selections and extract their current data. ignore any
    % overlay that is undefined (i.e., that you have not selected
    % previously)
    for overlayi = 1:length(handles.multiOverlay.SlectionsAdjusted)
        if overlayi <= length(handles.brainMap.Current) && isempty(handles.brainMap.Current{handles.multiOverlay.SlectionsAdjusted(overlayi)}) == 0 % if there is data for that overlay
            handles.multiOverlay.Current{overlayi} = handles.brainMap.Current{handles.multiOverlay.SlectionsAdjusted(overlayi)};
            handles.multiOverlay.Name{overlayi} = handles.overlaySelection.String{handles.multiOverlay.Slections(overlayi)};
        end
    end
    
    if isfield(handles.opts,'colorbar')
        delete(handles.opts.colorbar)
    end
    
    % that's all! now plot all of the overlays at once
    for overlayi = 1:length(handles.multiOverlay.Slections)
        [handles.underlay, handles.multiOverlay.Current{overlayi}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.multiOverlay.Current{overlayi}.Data,'figHandle', handles.brainFig, 'threshold',[handles.multiOverlay.Current{overlayi}.overlayThresholdNeg, handles.multiOverlay.Current{overlayi}.overlayThresholdPos], 'hemisphere', handles.multiOverlay.Current{overlayi}.hemi, 'opacity', handles.multiOverlay.Current{overlayi}.opacity, 'colorMap', handles.colormap.String{handles.multiOverlay.Current{overlayi}.colormap}, 'colorSampling',handles.multiOverlay.Current{overlayi}.colormapSpacing,'colorBins',handles.multiOverlay.Current{overlayi}.colorBins,'limits', [handles.multiOverlay.Current{overlayi}.limitMin handles.multiOverlay.Current{overlayi}.limitMax],'inclZero',handles.multiOverlay.Current{overlayi}.inclZero,'clusterThresh',handles.multiOverlay.Current{overlayi}.clusterThresh,'binarize',handles.multiOverlay.Current{overlayi}.binarize,'outline',handles.multiOverlay.Current{overlayi}.outline,'binarizeClusters',handles.multiOverlay.Current{overlayi}.binarizeClusters,'customColor',handles.multiOverlay.Current{overlayi}.customColor,'pMap',handles.multiOverlay.Current{overlayi}.pVals,'pThresh',handles.multiOverlay.Current{overlayi}.pThresh,'transparencyLimits',handles.multiOverlay.Current{overlayi}.transparencyLimits,'transparencyThresholds',handles.multiOverlay.Current{overlayi}.transparencyThresholds,'transparencyData',handles.multiOverlay.Current{overlayi}.transparencyData,'transparencyPThresh',handles.multiOverlay.Current{overlayi}.transparencyPThresh,'invertColor',handles.brainMap.Current{overlayi}.invertColor,'invertOpacity',handles.brainMap.Current{overlayi}.invertOpacity,'growROI',handles.brainMap.Current{overlayi}.growROI,'multiOverlay','on');
        %[handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    end
else
    % if you selected one item, we need to make sure your last selection
    % wasn't multiple overlays. Just in case, if there is any multiple
    % overlay structure in the handles, turn off all of those maps (i.e.,
    % set opacity to zero)
    if isfield(handles,'multiOverlay') == 1
        if isfield(handles.multiOverlay,'Current') == 1
            for overlayi = 1:length(handles.multiOverlay.Current)
                if isvalid(handles.multiOverlay.Current{overlayi}.overlay)
                    handles.multiOverlay.Current{overlayi}.overlay.FaceAlpha = 0;
                end
            end
        end
    end
    
    % if you have selected 'no overlay', loop through all overlays and turn
    % them off
    if handles.overlaySelection.Value == 1
        if isfield(handles.brainMap, 'Current') == 1
            for overlayii = 1:length(handles.brainMap.Current)
                handles.brainMap.Current{overlayii}.overlay.FaceAlpha = 0;
            end
        end
        
        % and colorbar if necessary
        if isfield(handles,'opts')
            if isfield(handles.opts,'colorbar')
                delete(handles.opts.colorbar)
            end
        end
    else
        
        % Populate GUI options with saved settings for this selection stored in 'Current' structure
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
        
        % turn off any overlays on the same hemisphere as current overlay
        % (excluding current file's overlay which might be passed on in
        % next argument)
        currHemi = handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi;
        for overlayi = [1:(handles.overlaySelection.Value - 1)-1 (handles.overlaySelection.Value - 1)+1:length(handles.brainMap.Current)]
            if isfield(handles.brainMap.Current{overlayi},'overlay') == 1
                if strcmp(handles.brainMap.Current{overlayi}.hemi,currHemi) == 1
                    if isvalid(handles.brainMap.Current{overlayi}.overlay)
                        handles.brainMap.Current{overlayi}.overlay.FaceAlpha = 0;
                    end
                end
            end
        end
        
        % Now plot the data. In the case that there is no overlay generated, we
        % won't pass an overlay argument into plotOverlay
        if isfield(handles.brainMap.Current{handles.overlaySelection.Value - 1}, 'overlay') == 0
            if isfield(handles,'opts')
                if isfield(handles.opts,'colorbar')
                    delete(handles.opts.colorbar)
                end
            end
            %[handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh);
            [handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
            
            handles.opts.colorbar = cbar;
            handles.opts.colorbar.TickLength = [0 0];
            imh = handles.opts.colorbar.Children(1);
            imh.AlphaData = handles.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
            %%handles.opts.colorbar.YTick = handles.opts.colorBarTicks;
            %%handles.opts.colorbar.YTickLabel = handles.opts.colorBarLabels;
            
            % If your saved limits were empty (e.g., default settings)
            % update the GUI
            handles.limitMin.String = num2str(handles.opts.limits(1));
            handles.limitMax.String = num2str(handles.opts.limits(2));
            handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin = handles.opts.limits(1);
            handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax = handles.opts.limits(2);
        else
            if isfield(handles.opts,'colorbar')
                delete(handles.opts.colorbar)
            end
            %[handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh);
            [handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
            
            handles.opts.colorbar = cbar;
            handles.opts.colorbar.TickLength = [0 0];
            imh = handles.opts.colorbar.Children(1);
            imh.AlphaData = handles.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
            %%handles.opts.colorbar.YTick = handles.opts.colorBarTicks;
            %%handles.opts.colorbar.YTickLabel = handles.opts.colorBarLabels;
        end
    end
end

guidata(hObject, handles);


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

function surfaceSelection_Callback(hObject, eventdata, handles)
% get handles
handles = guidata(hObject);

% if you selected both hemispheres:
if hObject.Value == 2
    [vert1,face1] = read_surf([handles.paths.brainPath handles.paths.slash 'lh.inflated']);
    [vert2,face2] = read_surf([handles.paths.brainPath handles.paths.slash 'rh.inflated']);
    curv1 = read_curv([handles.paths.brainPath handles.paths.slash 'lh.curv']);
    curv2 = read_curv([handles.paths.brainPath handles.paths.slash 'rh.curv']);
    [handles.underlay, handles.brainFig] = plotUnderlay(vert1, face1, curv1, vert2, face2, curv2);
    hold on
end

if hObject.Value == 3
    [vert1,face1] = read_surf([handles.paths.brainPath handles.paths.slash 'lh.inflated']);
    curv1 = read_curv([handles.paths.brainPath handles.paths.slash 'lh.curv']);
    [handles.underlay, handles.brainFig] = plotUnderlay(vert1, face1, curv1);
end

if hObject.Value == 4
    [vert1,face1] = read_surf([handles.paths.brainPath handles.paths.slash 'rh.inflated']);
    curv1 = read_curv([handles.paths.brainPath handles.paths.slash 'rh.curv']);
    [handles.underlay, handles.brainFig] = plotUnderlay(vert1, face1, curv1);
end

if hObject.Value == 5 % custom surface
    % load surface data
    brainFile = uipickfiles('FilterSpec','*.inflated','Prompt','Select one or two surface(s) to plot.');
    warndlg('Please select your curvature files in the same order as the surfaces!');
    curvFile = uipickfiles('FilterSpec','*.curv','Prompt','Select curvatures for each of your surface(s)');
    
    % figure out which hemisphere is which from the selections
    warndlg('Assuming vertex positioning is in radiological convention (left is negative)');
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


handles.materials.flatButton = [];
handles.materials.shinyButton = [];
handles.materials.dullButton = 1;

% update handles
guidata(hObject, handles);

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

% --- Executes on selection change in curvSelection.
function curvSelection_Callback(hObject, eventdata, handles)
% hObject    handle to curvSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns curvSelection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from curvSelection
if isfield(handles,'underlay') == 1
    handles = guidata(hObject);
    
    if get(hObject,'Value') == 2
        % get new values
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
    end
    
    if get(hObject,'Value') == 3
        % plot raw sulci/gyri data. Check if you have 2,3,4 selected
        % for surface because that means we can find them ourselves
        if handles.surfaceSelection.Value == 2
            delete(handles.underlay.left)
            delete(handles.underlay.right)
            
            [vert1,face1] = read_surf([handles.paths.brainPath handles.paths.slash 'lh.inflated']);
            [vert2,face2] = read_surf([handles.paths.brainPath handles.paths.slash 'rh.inflated']);
            curv1 = read_curv([handles.paths.brainPath handles.paths.slash 'lh.curv']);
            curv2 = read_curv([handles.paths.brainPath handles.paths.slash 'rh.curv']);
            [handles.underlay, handles.brainFig] = plotUnderlay(vert1, face1, curv1, vert2, face2, curv2,'true');
            hold on
        end
        
        if handles.surfaceSelection.Value == 3
            delete(handles.underlay.left)
            [vert1,face1] = read_surf([handles.paths.brainPath handles.paths.slash 'lh.inflated']);
            curv1 = read_curv([handles.paths.brainPath handles.paths.slash 'lh.curv']);
            [handles.underlay, handles.brainFig] = plotUnderlay(vert1, face1, curv1,'true');
        end
        
        if handles.surfaceSelection.Value == 4
            delete(handles.underlay.right)
            [vert1,face1] = read_surf([handles.paths.brainPath handles.paths.slash 'rh.inflated']);
            curv1 = read_curv([handles.paths.brainPath handles.paths.slash 'rh.curv']);
            [handles.underlay, handles.brainFig] = plotUnderlay(vert1, face1, curv1,'true');
        end
        
        if handles.surfaceSelection.Value == 5
            % load surface data
            brainFile = uipickfiles('FilterSpec','*.inflated','Prompt','Select one or two surface(s) to plot.');
            warndlg('Please select your curvature files in the same order as the surfaces!');
            curvFile = uipickfiles('FilterSpec','*.curv','Prompt','Select curvatures for each of your surface(s)');
            
            % figure out which hemisphere is which from the selections
            warndlg('Assuming vertex positioning is in radiological convention (left is negative)');
            if length(brainFile) > 1 % if you selected two files lets load both in
                [vert1,face1] = read_surf(brainFile{1});
                [vert2,face2] = read_surf(brainFile{2});
                curv1 = read_curv(curvFile{1});
                curv2 = read_curv(curvFile{2});
                delete(handles.underlay)
                [handles.underlay, handles.brain] = plotUnderlay(vert1, face1, curv1, vert2, face2, curv2,'true');
            else % if you selected one file just load that in and figure out which is negative
                [vert1,face1] = read_surf(brainFile{1});
                curv1 = read_curv(curvFile{1});
                delete(handles.underlay)
                [handles.underlay, handles.brain] = plotUnderlay(vert1, face1, curv1,'true');
            end
        end
    end
    
    if get(hObject,'Value') == 4
        if handles.surfaceSelection.Value == 2
            delete(handles.underlay.left)
            delete(handles.underlay.right)
            
            [vert1,face1] = read_surf([handles.paths.brainPath handles.paths.slash 'lh.inflated']);
            [vert2,face2] = read_surf([handles.paths.brainPath handles.paths.slash 'rh.inflated']);
            curv1 = read_curv([handles.paths.brainPath handles.paths.slash 'lh.curv']);
            curv2 = read_curv([handles.paths.brainPath handles.paths.slash 'rh.curv']);
            
            thresh = inputdlg(['Choose a threshold boundary for what we will call sulci (smaller and negative values will increase gyri size...min is ' num2str(min(curv1)) ' and max is ' num2str(max(curv1))],'Sulci-gyri Boundary');
            [handles.underlay, handles.brainFig] = plotUnderlay(vert1, face1, curv1, vert2, face2, curv2,'false',str2double(thresh));
            hold on
        end
        
        if handles.surfaceSelection.Value == 3
            delete(handles.underlay.left)
            [vert1,face1] = read_surf([handles.paths.brainPath handles.paths.slash 'lh.inflated']);
            curv1 = read_curv([handles.paths.brainPath handles.paths.slash 'lh.curv']);
            thresh = inputdlg(['Choose a threshold boundary for what we will call sulci (smaller and negative values will increase gyri size...min is ' num2str(min(curv1)) ' and max is ' num2str(max(curv1))],'Sulci-gyri Boundary');
            
            [handles.underlay, handles.brainFig] = plotUnderlay(vert1, face1, curv1,'false',str2double(thresh));
        end
        
        if handles.surfaceSelection.Value == 4
            delete(handles.underlay.right)
            [vert1,face1] = read_surf([handles.paths.brainPath handles.paths.slash 'rh.inflated']);
            curv1 = read_curv([handles.paths.brainPath handles.paths.slash 'rh.curv']);
            thresh = inputdlg(['Choose a threshold boundary for what we will call sulci (smaller and negative values will increase gyri size...min is ' num2str(min(curv1)) ' and max is ' num2str(max(curv1))],'Sulci-gyri Boundary');
            
            [handles.underlay, handles.brainFig] = plotUnderlay(vert1, face1, curv1,'false',str2double(thresh));
        end
        
        if handles.surfaceSelection.Value == 5
            % load surface data
            brainFile = uipickfiles('FilterSpec','*.inflated','Prompt','Select one or two surface(s) to plot.');
            warndlg('Please select your curvature files in the same order as the surfaces!');
            curvFile = uipickfiles('FilterSpec','*.curv','Prompt','Select curvatures for each of your surface(s)');
            
            % figure out which hemisphere is which from the selections
            warndlg('Assuming vertex positioning is in radiological convention (left is negative)');
            if length(brainFile) > 1 % if you selected two files lets load both in
                [vert1,face1] = read_surf(brainFile{1});
                [vert2,face2] = read_surf(brainFile{2});
                curv1 = read_curv(curvFile{1});
                curv2 = read_curv(curvFile{2});
                delete(handles.underlay)
                [handles.underlay, handles.brain] = plotUnderlay(vert1, face1, curv1, vert2, face2, curv2,'false',thresh);
            else % if you selected one file just load that in and figure out which is negative
                [vert1,face1] = read_surf(brainFile{1});
                curv1 = read_curv(curvFile{1});
                delete(handles.underlay)
                [handles.underlay, handles.brain] = plotUnderlay(vert1, face1, curv1,'false',thresh);
            end
        end
        
    end
    
    guidata(hObject, handles);
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

% --- Executes on button press in reloadOverlay.
function reloadOverlay_Callback(hObject, eventdata, handles)
% hObject    handle to reloadOverlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get handles
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    % delete the current overlay
    delete(handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay)
    
    % copy original data into current structure
    handles.brainMap.Current{handles.overlaySelection.Value - 1} = handles.defaultOptions;
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data = handles.brainMap.Original.Data{handles.overlaySelection.Value - 1};
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.hemi = handles.brainMap.hemi{handles.overlaySelection.Value - 1};
    
    % update GUI with defaults
    % Load all the saved data from 'Current'
    handles.limitMin.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin);
    handles.limitMax.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax);
    handles.overlayThresholdPos.Value = handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos;
    handles.overlayThresholdNeg.Value = handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg;
    handles.colormap.Value = handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap;
    handles.opacity.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity);
    
    if strcmp(handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing,'even')
        handles.colormapSpacing.Value = 2;
    else
        handles.colormapSpacing.Value = 3;
    end
    handles.overlayThresholdPosDynamic.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdPos);
    handles.overlayThresholdNegDynamic.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlayThresholdNeg);
    handles.colorBins.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins);
    
    if isfield(handles.opts,'colorbar')
        delete(handles.opts.colorbar)
    end
    
    % now plot the original data
    %[handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.Name{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh);
    [handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.opts.colorbar = cbar;
    handles.opts.colorbar.TickLength = [0 0];
    imh = handles.opts.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    %%handles.opts.colorbar.YTick = handles.opts.colorBarTicks;
    %%handles.opts.colorbar.YTickLabel = handles.opts.colorBarLabels;
    
    handles.limitMin.String = num2str(handles.opts.limits(1));
    handles.limitMax.String = num2str(handles.opts.limits(2));
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin = handles.opts.limits(1);
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax = handles.opts.limits(2);
    
    % also update how far the sliders should be capable of moving based on
    % the data for this map
    handles.overlayThresholdPos.Max = max(handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data);
    handles.overlayThresholdNeg.Min = min(handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data);
    
    % update handles
    guidata(hObject, handles);
end

% --- Executes on button press in deleteOverlay.
function deleteOverlay_Callback(hObject, eventdata, handles)
% hObject    handle to deleteOverlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get handles
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    % delete the current overlay
    delete(handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay)
    
    % delete current and original data for this overlay
    handles.brainMap.Name(handles.overlaySelection.Value - 1) = [];
    handles.brainMap.Original.Data(handles.overlaySelection.Value - 1) = [];
    handles.brainMap.Current(handles.overlaySelection.Value - 1) = [];
    handles.brainMap.hemi(handles.overlaySelection.Value - 1) = [];
    
    % update GUI by switching to no overlay and deleting remaining string
    toDelete = handles.overlaySelection.Value;
    handles.overlaySelection.Value = 1; % if you delete first you will throw an error
    handles.overlaySelection.String(toDelete) = [];
    
    % turn off any overlays -- default behavior for no overlay
    if isfield(handles.brainMap, 'Current') == 1
        for overlayii = 1:length(handles.brainMap.Current)
            if isvalid(handles.brainMap.Current{overlayii}.overlay)
                handles.brainMap.Current{overlayii}.overlay.FaceVertexAlphaData = (handles.brainMap.Current{overlayii}.overlay.FaceVertexAlphaData) * 0.00001;
                if isfield(handles.opts,'colorbar')
                    delete(handles.opts.colorbar)
                end
            end
        end
    end
end

% update handles
guidata(hObject, handles);

% --- Executes on button press in importOverlay.
function importOverlay_Callback(hObject, eventdata, handles)
% hObject    handle to importOverlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);
if isfield(handles, 'underlay') == 1
    if exist('convertMNI2FS.m','file') && exist('convertMNI2FSWithMask.m','file') && exist('convertROIForFS.m','file')
        warndlg('Only importing of 2mm MNI_152 files is currently possible.')
        
        overlayFiles = uipickfiles('REFilter','\.nii.gz$|\.nii$','Prompt','Select one or more overlays','NumFiles',[1 1])';
        if iscell(overlayFiles) == 1
            importOptions = questdlg('What kind of file is this?','Conversion options','Thresholded map','Contains one or more ROIs','Unthresholded map','Unthresholded map');
            switch importOptions
                case 'Thresholded map'
                    smoothing = inputdlg({'Smoothing area', 'Smoothing steps'});
                    outFiles = convertMNI2FSWithMask(overlayFiles{1}, str2double(smoothing{1}), str2double(smoothing{2}));
                case 'Contains one or more ROIs'
                    weight = inputdlg('Enter a weight vector for ROIs (1s given preference over 0s; leave [ ] for default; assuming 1s and 0s are in order of ROI values in map)','Define ROI weights');
                    if strcmp(weight{1},'[]')
                        weight = [];
                    else
                        weight = str2double(weight);
                    end
                    try
                        outFiles = convertROIForFS(overlayFiles{1}, weight{1});
                    catch
                        outFiles = convertROIForFS(overlayFiles{1}, []);
                    end
                case 'Unthresholded map'
                    outFiles = convertMNI2FS(overlayFiles{1},[]);
            end
            
            % populate the list now in overlaySelection and save relevant data
            % figure out if there are any existing overlayFiles to add to
            if ischar(handles.overlaySelection.String) == 1 || isempty(handles.overlaySelection.String) == 1
                numSavedOverlays = 0;
            else
                numSavedOverlays = length(handles.overlaySelection.String) - 1;
            end
            
            % save the overlays name in brainMap structure and data in
            % brainMap.Original.Data
            for filei = 1:length(outFiles)
                storedFileNum = numSavedOverlays+filei;
                [handles.brainMap.Path{storedFileNum, 1}, handles.brainMap.Name{storedFileNum,1}] = fileparts(outFiles{filei});
                hdr = load_nifti(outFiles{filei});
                handles.brainMap.Original.Data{storedFileNum,1} = hdr.vol;
                
                % Figure out which hemisphere the file belongs to
                if contains(lower(handles.brainMap.Name{storedFileNum,1}),lower({'left', 'lh'})) == 1
                    handles.brainMap.hemi{storedFileNum,1} = 'left';
                elseif contains(lower(handles.brainMap.Name{storedFileNum,1}),lower({'right', 'rh'})) == 1
                    handles.brainMap.hemi{storedFileNum,1} = 'right';
                elseif (contains(lower(handles.brainMap.Name{storedFileNum,1}),lower({'left', 'lh'})) == 1) && (contains(lower(handles.brainMap.Name{storedFileNum,1}),lower({'right', 'rh'})) == 1)
                    handles.brainMap.hemi{storedFileNum,1} = inputdlg('It looks like your file contains reference to both hemispheres...which hemisphere should I associate with this file? (type left or right)' ,'Could not find hemisphere');
                elseif (contains(lower(handles.brainMap.Name{storedFileNum,1}),lower({'left', 'lh'})) == 0) && (contains(lower(handles.brainMap.Name{storedFileNum,1}),lower({'right', 'rh'})) == 0)
                    handles.brainMap.hemi{storedFileNum,1} = inputdlg('It looks like your file does not contain reference to either hemisphere...which hemisphere should I associate with this file? (type left or right)' ,'Could not find hemisphere');
                end
                
                handles.brainMap.Current{storedFileNum} = handles.defaultOptions;
                handles.brainMap.Current{storedFileNum}.Data = handles.brainMap.Original.Data{storedFileNum};
                handles.brainMap.Current{storedFileNum}.hemi = handles.brainMap.hemi{storedFileNum};
                
            end
            
            % update available list of overlays to select from
            if numSavedOverlays == 0
                handles.overlaySelection.String = vertcat({handles.overlaySelection.String},handles.brainMap.Name(numSavedOverlays+1:(numSavedOverlays+length(overlayFiles))));
            else
                handles.overlaySelection.String = vertcat(handles.overlaySelection.String(:),handles.brainMap.Name(numSavedOverlays+1:(numSavedOverlays+length(overlayFiles))));
            end
            
        end
        % save data to handle
        guidata(hObject, handles);
    end
end

function opacity_Callback(hObject, eventdata, handles)
% hObject    handle to opacity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of opacity as text
%        str2double(get(hObject,'String')) returns contents of opacity as a double
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    % if you make opacity 0 we will never be able to recover original data
    % without replotting everything from scratch
    if str2double(handles.opacity.String) == 0
        handles.opacity.String = 0.00001;
    end
    
    % saveOverlay input opacity into settings for this overlay map
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity = str2double(handles.opacity.String);
    
    % update overlay
    % return overlay to original state
    maxVal = max(handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay.FaceVertexAlphaData);
    if maxVal < 62
        mulFac = 62/maxVal;
    else
        mulFac = 1;
    end
    
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay.FaceVertexAlphaData = (handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay.FaceVertexAlphaData) * (str2double(handles.opacity.String) * mulFac);
    imh = handles.opts.colorbar.Children(1);
    imh.AlphaData = (handles.opts.transparencyData) * (str2double(handles.opacity.String) * mulFac);
    imh.AlphaDataMapping = 'direct';
    
    guidata(hObject, handles);
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

function smoothArea_Callback(hObject, eventdata, handles)
% hObject    handle to smoothArea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of smoothArea as text
%        str2double(get(hObject,'String')) returns contents of smoothArea as a double
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothArea = str2double(get(hObject,'String'));
    guidata(hObject, handles);
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


% --- Executes on selection change in colormap.
function colormap_Callback(hObject, eventdata, handles)
% hObject    handle to colormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns colormap contents as cell array
%        contents{get(hObject,'Value')} returns selected item from colormap
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    % if you didn't choose the empty colormap
    if hObject.Value > 1
        % if colormap is custom and already loaded in GUI or if you
        % selected to create a custom map
        if isfield(handles,'colormapCustom') == 1
            if handles.colormapCustom(hObject.Value) == 1 || hObject.Value == 52 || hObject.Value == 53
                % load in the colormap if it's an already created colormap
                if handles.colormapCustom(hObject.Value) == 1
                    customColor = load([handles.paths.colormapsPath handles.paths.slash handles.colormap.String{hObject.Value} '.mat']);
                    if isa(customColor,'struct') == 1
                        field = fieldnames(customColor);
                        handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor = customColor.(field{1});
                        handles.colorBins.String = num2str(length(handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor));
                        handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins = length(customColor);
                    end
                end
                % or if you asked to make a custom colormap, do that now
                if hObject.Value == 75
                    customChoice = questdlg('Do you want to create a colormap?','Custom colormap','Yes','No','Yes');
                    switch customChoice
                        case 'Yes'
                            colormapeditor
                            %pause;
                            ax = gca;
                            f = msgbox('When you are done selecting your colormap press any key on your computer','Unideal scenario');
                            pause;
                            customColor = colormap(ax);
                            handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor = customColor;
                            [oFile, oPath] = uiputfile({'*.mat'},'Pick a name for your colormap',[handles.paths.colormapsPath handles.paths.slash 'colormap']);
                            save([oPath oFile]','customColor')
                            
                            handles.colormapCustom = vertcat(handles.colormapCustom,[1]);
                            handles.colormap.String = vertcat(handles.colormap.String,{oFile});
                    end
                end
                
                % if you chose a single color lets ask you which one to use
                % now
                if hObject.Value == 76
                    handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor = uisetcolor;
                    handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor = repmat(singleColor,[handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins,1]);
                end
                
                if isfield(handles.opts,'colorbar')
                    delete(handles.opts.colorbar)
                end
                
                % now update the figure
                %[handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh);
                [handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
                
                handles.opts.colorbar = cbar;
                handles.opts.colorbar.TickLength = [0 0];
                imh = handles.opts.colorbar.Children(1);
                imh.AlphaData = handles.opts.transparencyData;
                imh.AlphaDataMapping = 'direct';
                %handles.opts.colorbar.YTick = handles.opts.colorBarTicks;
                %handles.opts.colorbar.YTickLabel = handles.opts.colorBarLabels;
                
            else % update overlay and clear custom color
                handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor = [];
                
                if isfield(handles.opts,'colorbar')
                    delete(handles.opts.colorbar)
                end
                
                %[handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh);
                [handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
                
                handles.opts.colorbar = cbar;
                handles.opts.colorbar.TickLength = [0 0];
                imh = handles.opts.colorbar.Children(1);
                imh.AlphaData = handles.opts.transparencyData;
                imh.AlphaDataMapping = 'direct';
                %handles.opts.colorbar.YTick = handles.opts.colorBarTicks;
                %handles.opts.colorbar.YTickLabel = handles.opts.colorBarLabels;
                
            end
        end
        
        % saveOverlay colormap into overlay settings
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap = hObject.Value;
    else
        handles.opacity.String = '0';
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.opacity = str2double(handles.opacity.String);
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay.FaceAlpha = str2double(handles.opacity.String);
    end
    
    guidata(hObject, handles);
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

function limitMin_Callback(hObject, eventdata, handles)
% hObject    handle to limitMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of limitMin as text
%        str2double(get(hObject,'String')) returns contents of limitMin as a double

if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    % saveOverlay input limit into overlay settings
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin = str2double(get(hObject,'String'));
    
    if isfield(handles.opts,'colorbar')
        delete(handles.opts.colorbar)
    end
    
    % update overlay
    %[handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh);
    [handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.opts.colorbar = cbar;
    handles.opts.colorbar.TickLength = [0 0];
    imh = handles.opts.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    
    guidata(hObject, handles);
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

function limitMax_Callback(hObject, eventdata, handles)
% hObject    handle to limitMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of limitMax as text
%        str2double(get(hObject,'String')) returns contents of limitMax as a double
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    % saveOverlay input limit into overlay settings
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax = str2double(get(hObject,'String'));
    
    if isfield(handles.opts,'colorbar')
        delete(handles.opts.colorbar)
    end
    
    % update overlay
    %[handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh);
    [handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.opts.colorbar = cbar;
    handles.opts.colorbar.TickLength = [0 0];
    imh = handles.opts.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    
    guidata(hObject, handles);
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


function limitNegMin_Callback(hObject, eventdata, handles)
% hObject    handle to limitNegMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of limitNegMin as text
%        str2double(get(hObject,'String')) returns contents of limitNegMin as a double
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    guidata(hObject, handles);
end

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


function limitNegMax_Callback(hObject, eventdata, handles)
% hObject    handle to limitNegMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of limitNegMax as text
%        str2double(get(hObject,'String')) returns contents of limitNegMax as a double
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    guidata(hObject, handles);
end

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


% --- Executes on selection change in colormapSpacing.
function colormapSpacing_Callback(hObject, eventdata, handles)
% hObject    handle to colormapSpacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns colormapSpacing contents as cell array
%        contents{get(hObject,'Value')} returns selected item from colormapSpacing
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    % saveOverlay input colormap spacing setting into overlay settings
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing = handles.colormapSpacing.String{get(hObject,'Value')};
    
    if isfield(handles.opts,'colorbar')
        delete(handles.opts.colorbar)
    end
    
    % update overlay
    %[handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh);
    [handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.opts.colorbar = cbar;
    handles.opts.colorbar.TickLength = [0 0];
    imh = handles.opts.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    
    if get(hObject,'Value') == 4 || get(hObject,'Value') == 3
        handles.opts.colorbar.YTick = handles.opts.ticks;
        handles.opts.colorbar.YTickLabel = handles.opts.tickLabels;
    end
    
    guidata(hObject, handles);
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

function colorBins_Callback(hObject, eventdata, handles)
% hObject    handle to colorBins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of colorBins as text
%        str2double(get(hObject,'String')) returns contents of colorBins as a double
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    % saveOverlay input colormap spacing setting into overlay settings
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins = str2double(handles.colorBins.String);
    
    if isfield(handles.opts,'colorbar')
        delete(handles.opts.colorbar)
    end
    
    % update overlay
    %[handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh);
    [handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.opts.colorbar = cbar;
    handles.opts.colorbar.TickLength = [0 0];
    imh = handles.opts.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    %handles.opts.colorbar.YTick = handles.opts.colorBarTicks;
    %handles.opts.colorbar.YTickLabel = handles.opts.colorBarLabels;
    
    guidata(hObject, handles);
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

% --- Executes on button press in binarizeSwitch.
function binarizeSwitch_Callback(hObject, eventdata, handles)
% hObject    handle to binarizeSwitch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of binarizeSwitch
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize = handles.binarizeSwitch.Value;
    
    if isfield(handles.opts,'colorbar')
        delete(handles.opts.colorbar)
    end
    
    % update GUI
    %[handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh);
    [handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.opts.colorbar = cbar;
    handles.opts.colorbar.TickLength = [0 0];
    imh = handles.opts.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    %handles.opts.colorbar.YTick = handles.opts.colorBarTicks;
    %handles.opts.colorbar.YTickLabel = handles.opts.colorBarLabels;
    
    guidata(hObject, handles);
end

% --- Executes on button press in outlineButton.
function outlineButton_Callback(hObject, eventdata, handles)
% hObject    handle to outlineButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of outlineButton
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    if get(hObject,'Value') == 0
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline = 'false';
    else
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline = 'true';
    end
    
    if isfield(handles.opts,'colorbar')
        delete(handles.opts.colorbar)
    end
    
    % update GUI
    %[handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh);
    [handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.opts.colorbar = cbar;
    handles.opts.colorbar.TickLength = [0 0];
    %     imh = handles.opts.colorbar.Children(1);
    %     imh.AlphaData = handles.opts.transparencyData;
    %     imh.AlphaDataMapping = 'direct';
    %     %handles.opts.colorbar.YTick = handles.opts.colorBarTicks;
    %     %handles.opts.colorbar.YTickLabel = handles.opts.colorBarLabels;
    
    guidata(hObject, handles);
end

% --- Executes on button press in editClusterButton.
function editClusterButton_Callback(hObject, eventdata, handles)
% hObject    handle to editClusterButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    clusterGUI
    
    guidata(hObject, handles);
end

% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    guidata(hObject, handles);
end

% --- Executes on button press in addP.
function addP_Callback(hObject, eventdata, handles)
% hObject    handle to addP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    [file, path]= uigetfile({'*.nii*'},'Select the file with your p-values','File Selector');
    tmp = load_nifti([path file]);
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals = tmp.vol;
    guidata(hObject, handles);
end

% --- Executes on slider movement.
function pSlider_Callback(hObject, eventdata, handles)
% hObject    handle to pSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    % update the dynamic text box
    handles.pText.String = num2str(hObject.Value);
    
    % update saved settings for overlay
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh = hObject.Value;
    
    if isfield(handles.opts,'colorbar')
        delete(handles.opts.colorbar)
    end
    
    % update overlay
    %[handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh);
    [handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.opts.colorbar = cbar;
    handles.opts.colorbar.TickLength = [0 0];
    imh = handles.opts.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    %handles.opts.colorbar.YTick = handles.opts.colorBarTicks;
    %handles.opts.colorbar.YTickLabel = handles.opts.colorBarLabels;
    
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


function pText_Callback(hObject, eventdata, handles)
% hObject    handle to pText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pText as text
%        str2double(get(hObject,'String')) returns contents of pText as a double
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    % update the dynamic text box
    handles.pSlider.Value = str2double(handles.pText.String);
    
    % update saved settings for overlay
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh = str2double(handles.pText.String);
    
    if isfield(handles.opts,'colorbar')
        delete(handles.opts.colorbar)
    end
    
    % update overlay
    %[handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh);
    [handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.opts.colorbar = cbar;
    handles.opts.colorbar.TickLength = [0 0];
    imh = handles.opts.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    %handles.opts.colorbar.YTick = handles.opts.colorBarTicks;
    %handles.opts.colorbar.YTickLabel = handles.opts.colorBarLabels;
    
    guidata(hObject, handles);
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

% --- Executes on slider movement.
function clusterThreshSlider_Callback(hObject, eventdata, handles)
% hObject    handle to clusterThreshSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    % update the dynamic text box
    handles.clusterThreshText.String = num2str(hObject.Value);
    
    % update saved settings for overlay
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh = hObject.Value;
    
    if isfield(handles.opts,'colorbar')
        delete(handles.opts.colorbar)
    end
    
    % update overlay
    %[handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh);
    [handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.opts.colorbar = cbar;
    handles.opts.colorbar.TickLength = [0 0];
    imh = handles.opts.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    %handles.opts.colorbar.YTick = handles.opts.colorBarTicks;
    %handles.opts.colorbar.YTickLabel = handles.opts.colorBarLabels;
    
    guidata(hObject, handles);
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


function clusterThreshText_Callback(hObject, eventdata, handles)
% hObject    handle to clusterThreshText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of clusterThreshText as text
%        str2double(get(hObject,'String')) returns contents of clusterThreshText as a double
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    % update the slider
    handles.clusterThreshSlider.Value = str2double(hObject.String);
    
    % update saved settings for overlay
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh = str2double(hObject.String);
    
    if isfield(handles.opts,'colorbar')
        delete(handles.opts.colorbar)
    end
    
    % update overlay
    %[handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh);
    [handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.opts.colorbar = cbar;
    handles.opts.colorbar.TickLength = [0 0];
    imh = handles.opts.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    %handles.opts.colorbar.YTick = handles.opts.colorBarTicks;
    %handles.opts.colorbar.YTickLabel = handles.opts.colorBarLabels;
    
    guidata(hObject, handles);
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

% --- Executes on button press in screenshotsButton.
function screenshotsButton_Callback(hObject, eventdata, handles)
% hObject    handle to screenshotsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    [~,file, ~] = fileparts(handles.brainMap.Name{handles.overlaySelection.Value - 1});
    [oFile, oPath] = uiputfile({'*'},'Pick a base name for all screenshots',file);
    h = waitbar(0.5,'Taking photos...');
    if length(fieldnames(handles.underlay)) == 2
        % inferior view
        figure(handles.brainFig)
        
        if isfield(handles.opts,'colorbar')
            delete(handles.opts.colorbar)
            redo = 1;
        else
            redo = 0;
        end
        view(90, -90);
        if redo == 1
            handles.opts.colorbar = cbar;
            handles.opts.colorbar.TickLength = [0 0];
            imh = handles.opts.colorbar.Children(1);
            imh.AlphaData = handles.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        saveas(handles.brainFig,[oPath oFile '_inferiorView.png']);
        
        % superior
        if isfield(handles.opts,'colorbar')
            delete(handles.opts.colorbar)
            redo = 1;
        else
            redo = 0;
        end
        view(-90, 90);
        if redo == 1
            handles.opts.colorbar = cbar;
            handles.opts.colorbar.TickLength = [0 0];
            imh = handles.opts.colorbar.Children(1);
            imh.AlphaData = handles.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        saveas(handles.brainFig,[oPath oFile '_superiorView.png']);
        
        % lateral from left
        if isfield(handles.opts,'colorbar')
            delete(handles.opts.colorbar)
            redo = 1;
        else
            redo = 0;
        end
        view(-90, 0);
        if redo == 1
            handles.opts.colorbar = cbar;
            handles.opts.colorbar.TickLength = [0 0];
            imh = handles.opts.colorbar.Children(1);
            imh.AlphaData = handles.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        saveas(handles.brainFig,[oPath oFile '_leftLateralView.png']);
        
        % lateral from right
        if isfield(handles.opts,'colorbar')
            delete(handles.opts.colorbar)
            redo = 1;
        else
            redo = 0;
        end
        view(90, 0);
        if redo == 1
            handles.opts.colorbar = cbar;
            handles.opts.colorbar.TickLength = [0 0];
            imh = handles.opts.colorbar.Children(1);
            imh.AlphaData = handles.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        saveas(handles.brainFig,[oPath oFile '_rightLateralView.png']);
        
        % right medial
        if isfield(handles.opts,'colorbar')
            delete(handles.opts.colorbar)
            redo = 1;
        else
            redo = 0;
        end
        view(-90, 0);
        if redo == 1
            handles.opts.colorbar = cbar;
            handles.opts.colorbar.TickLength = [0 0];
            imh = handles.opts.colorbar.Children(1);
            imh.AlphaData = handles.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        % turn off left brain
        handles.underlay.left.FaceAlpha = 0;
        % turn off all left hemisphere overlays
        trace = [];
        for overlayi = 1:length(handles.brainMap.Current)
            if strcmp(handles.brainMap.Current{overlayi}.hemi,'left')
                if isfield(handles.brainMap.Current{overlayi},'overlay')
                    if isvalid(handles.brainMap.Current{overlayi}.overlay)
                        handles.brainMap.Current{overlayi}.overlay.FaceVertexAlphaData = (handles.brainMap.Current{overlayi}.overlay.FaceVertexAlphaData * 0.000001);
                        handles.brainMap.Current{overlayi}.overlay.FaceVertexAlphaData = (handles.brainMap.Current{overlayi}.overlay.FaceVertexAlphaData * 0.000001);
                        % handles.brainMap.Current{overlayi}.overlay.FaceAlpha = 0.00001;
                        trace = [trace overlayi];
                    end
                end
            end
        end
        saveas(handles.brainFig,[oPath oFile '_rightMedialView.png']);
        % turn them back on for next step
        handles.underlay.left.FaceAlpha = 1;
        for overlayi = 1:length(trace)
            mulFac = 62/0.000001;
            handles.brainMap.Current{trace(overlayi)}.overlay.FaceVertexAlphaData = (handles.brainMap.Current{trace(overlayi)}.overlay.FaceVertexAlphaData * mulFac);
        end
        
        % left medial
        if isfield(handles.opts,'colorbar')
            delete(handles.opts.colorbar)
            redo = 1;
        else
            redo = 0;
        end
        view(90, 0);
        if redo == 1
            handles.opts.colorbar = cbar;
            handles.opts.colorbar.TickLength = [0 0];
            imh = handles.opts.colorbar.Children(1);
            imh.AlphaData = handles.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        % turn off right brain
        handles.underlay.right.FaceAlpha = 0;
        % turn off all right hemisphere overlays
        trace = [];
        for overlayi = 1:length(handles.brainMap.Current)
            if strcmp(handles.brainMap.Current{overlayi}.hemi,'right')
                if isfield(handles.brainMap.Current{overlayi},'overlay')
                    if isvalid(handles.brainMap.Current{overlayi}.overlay)
                        handles.brainMap.Current{overlayi}.overlay.FaceVertexAlphaData = (handles.brainMap.Current{overlayi}.overlay.FaceVertexAlphaData * 0.000001);
                        handles.brainMap.Current{overlayi}.overlay.FaceVertexAlphaData = (handles.brainMap.Current{overlayi}.overlay.FaceVertexAlphaData * 0.000001);
                        trace = [trace overlayi];
                    end
                end
            end
        end
        saveas(handles.brainFig,[oPath oFile '_leftMedialView.png']);
        % turn them back on
        handles.underlay.right.FaceAlpha = 1;
        for overlayi = 1:length(trace)
            mulFac = 62/0.000001;
            handles.brainMap.Current{trace(overlayi)}.overlay.FaceVertexAlphaData = (handles.brainMap.Current{trace(overlayi)}.overlay.FaceVertexAlphaData * mulFac);
        end
    else
        figure(handles.brainFig)
        % inferior view
        if isfield(handles.opts,'colorbar')
            delete(handles.opts.colorbar)
            redo = 1;
        else
            redo = 0;
        end
        view(90, -90);
        if redo == 1
            handles.opts.colorbar = cbar;
            handles.opts.colorbar.TickLength = [0 0];
            imh = handles.opts.colorbar.Children(1);
            imh.AlphaData = handles.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        saveas(handles.brainFig,[oPath oFile '_inferiorView.png']);
        
        % superior
        if isfield(handles.opts,'colorbar')
            delete(handles.opts.colorbar)
            redo = 1;
        else
            redo = 0;
        end
        view(-90, 90);
        if redo == 1
            handles.opts.colorbar = cbar;
            handles.opts.colorbar.TickLength = [0 0];
            imh = handles.opts.colorbar.Children(1);
            imh.AlphaData = handles.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        saveas(handles.brainFig,[oPath oFile '_superiorView.png']);
        
        % lateral from left
        if isfield(handles.opts,'colorbar')
            delete(handles.opts.colorbar)
            redo = 1;
        else
            redo = 0;
        end
        view(-90, 0);
        if redo == 1
            handles.opts.colorbar = cbar;
            handles.opts.colorbar.TickLength = [0 0];
            imh = handles.opts.colorbar.Children(1);
            imh.AlphaData = handles.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        saveas(handles.brainFig,[oPath oFile '_leftLateralView.png']);
        
        % lateral from right
        if isfield(handles.opts,'colorbar')
            delete(handles.opts.colorbar)
            redo = 1;
        else
            redo = 0;
        end
        view(90, 0);
        if redo == 1
            handles.opts.colorbar = cbar;
            handles.opts.colorbar.TickLength = [0 0];
            imh = handles.opts.colorbar.Children(1);
            imh.AlphaData = handles.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        saveas(handles.brainFig,[oPath oFile '_rightLateralView.png']);
    end
    
    close(h)
    guidata(hObject, handles);
end
% --- Executes on button press in zeroButton.
function zeroButton_Callback(hObject, eventdata, handles)
% hObject    handle to zeroButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of zeroButton
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    if hObject.Value == 1
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero = 'true';
    else
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero = 'false';
    end
    if isfield(handles.opts,'colorbar')
        delete(handles.opts.colorbar)
    end
    
    %[handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh);
    [handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.opts.colorbar = cbar;
    handles.opts.colorbar.TickLength = [0 0];
    imh = handles.opts.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    %handles.opts.colorbar.YTick = handles.opts.colorBarTicks;
    %handles.opts.colorbar.YTickLabel = handles.opts.colorBarLabels;
    
    guidata(hObject, handles);
end

% --- Executes on button press in 3.
function roiButton_Callback(hObject, eventdata, handles)
% hObject    handle to roiButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    if isfield(handles.opts,'colorbar')
        delete(handles.opts.colorbar)
    end
    
    %[handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters','true','customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh);
    [handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters','true','customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.opts.colorbar = cbar;
    handles.opts.colorbar.TickLength = [0 0];
    %     imh = handles.opts.colorbar.Children(1);
    %     imh.AlphaData = handles.opts.transparencyData;
    %     imh.AlphaDataMapping = 'direct';
    %     %handles.opts.colorbar.YTick = handles.opts.colorBarTicks;
    %     %handles.opts.colorbar.YTickLabel = handles.opts.colorBarLabels;
    
    % write cluster data into main data structure and update GUI based on
    % this data's range
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data = handles.opts.overlayData;
    
    % change limits
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin = min(handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data);
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax = max(handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data);
    handles.limitMin.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin);
    handles.limitMax.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax);
    
    % set binarize to zero
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize = 0;
    handles.binarizeSwitch.Value = 0;
    
    % set outline to zero
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline = 0;
    handles.outlineButton.Value = 0;
    
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
    
    % set colorSampling to zero
    handles.colormapSpacing.Value = 2;
    handles.colormapSpacing.Value = 2;
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing = 2;
    
    % also update how far the sliders should be capable of moving based on
    % the data for this map
    handles.overlayThresholdPos.Max = max(handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data);
    handles.overlayThresholdNeg.Min = min(handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data);
    
    guidata(hObject, handles);
end

% --- Executes on button press in setButton.
function setButton_Callback(hObject, eventdata, handles)
% hObject    handle to setButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    if isfield(handles.brainMap.Current{handles.overlaySelection.Value - 1},'smoothedData') == 1
        
        % save smoothed data and info about smoothing
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data = handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothedData;
        %         smoothSteps = handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothSteps;
        %         smoothArea = handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothArea;
        %         smoothThreshold = handles.brainMap.Current{handles.overlaySelection.Value - 1}.smoothThreshold;
        %
        % change limits
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin = min(handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data);
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax = max(handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data);
        handles.limitMin.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMin);
        handles.limitMax.String = num2str(handles.brainMap.Current{handles.overlaySelection.Value - 1}.limitMax);
        
        % set binarize to zero
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize = 0;
        handles.binarizeSwitch.Value = 0;
        
        % set outline to zero
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline = 0;
        handles.outlineButton.Value = 0;
        
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
        
        % set colorSampling to zero
        handles.colormapSpacing.Value = 2;
        handles.colormapSpacing.Value = 2;
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormapSpacing = 2;
        
        % also update how far the sliders should be capable of moving based on
        % the data for this map
        handles.overlayThresholdPos.Max = max(handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data);
        handles.overlayThresholdNeg.Min = min(handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data);
    end
    
    guidata(hObject, handles);
end

% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in duplicateButton.
function duplicateButton_Callback(hObject, eventdata, handles)
% hObject    handle to duplicateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    fileNum = length(handles.brainMap.Current) + 1;
    
    handles.brainMap.Current{fileNum} = handles.brainMap.Current{handles.overlaySelection.Value - 1};
    handles.overlaySelection.String = vertcat(handles.overlaySelection.String,handles.brainMap.Name{handles.overlaySelection.Value - 1});
    handles.brainMap.hemi{fileNum} = handles.brainMap.hemi{handles.overlaySelection.Value - 1};
    handles.brainMap.Name{fileNum} = handles.brainMap.Name{handles.overlaySelection.Value - 1};
    handles.brainMap.Original.Data{fileNum} = handles.brainMap.Original.Data{handles.overlaySelection.Value - 1};
    
    handles.overlaySelection.Value = length(handles.overlaySelection.String);
    if isfield(handles.opts,'colorbar')
        delete(handles.opts.colorbar)
    end
    
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay.FaceAlpha = 0;
    
    %[handles.underlay, handles.brainMap.Current{fileNum}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{fileNum}.Data,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{fileNum}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{fileNum}.inclZero,'clusterThresh',handles.brainMap.Current{fileNum}.clusterThresh,'binarize',handles.brainMap.Current{fileNum}.binarize,'outline',handles.brainMap.Current{fileNum}.outline,'binarizeClusters',handles.brainMap.Current{fileNum}.binarizeClusters,'customColor',handles.brainMap.Current{fileNum}.customColor,'pMap',handles.brainMap.Current{fileNum}.pVals,'pThresh',handles.brainMap.Current{fileNum}.pThresh,'transparencyLimits',handles.brainMap.Current{fileNum}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{fileNum}.transparencyThresholds,'transparencyData',handles.brainMap.Current{fileNum}.transparencyData,'transparencyPThresh',handles.brainMap.Current{fileNum}.transparencyPThresh);
    [handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.opts.colorbar = cbar;
    handles.opts.colorbar.TickLength = [0 0];
    imh = handles.opts.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    
    guidata(hObject, handles);
end

% --- Executes on button press in duplicateButton.
function pushbutton23_Callback(hObject, eventdata, handles)
% hObject    handle to duplicateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in transparencyButton.
function transparencyButton_Callback(hObject, eventdata, handles)
% hObject    handle to transparencyButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    % fix colormap
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap = handles.colormap.String{handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap};
    
    transparencyGUI
    
    % unfix for this GUI
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.colormap = handles.colormap.Value;
    
    guidata(hObject, handles);
end


% --- Executes on button press in upButton.
function upButton_Callback(hObject, eventdata, handles)
% hObject    handle to upButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    guidata(hObject, handles);
end

% --- Executes on button press in upButton.
function downButton_Callback(hObject, eventdata, handles)
% hObject    handle to upButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    currVal = handles.overlaySelection.Value;
    
    if currVal < length(handles.overlaySelection.String)
        currSelection = handles.overlaySelection.String{handles.overlaySelection.Value};
        backupBelow = handles.overlaySelection.String{currVal+1};
        handles.overlaySelection.String{currVal+1} = currSelection;
        handles.overlaySelection.String{currVal} = backupBelow;
        handles.overlaySelection.Value = handles.overlaySelection.Value+1;
        
        % now move all data
        currVal = currVal-1;
        
        % name
        backupBelow = handles.brainMap.Name{currVal+1};
        currSelection = handles.brainMap.Name{currVal};
        handles.brainMap.Name{currVal} = backupBelow;
        handles.brainMap.Name{currVal+1} = currSelection;
        
        % original data
        backupBelow = handles.brainMap.Original.Data{currVal+1};
        currSelection = handles.brainMap.Original.Data{currVal};
        handles.brainMap.Original.Data{currVal} = backupBelow;
        handles.brainMap.Original.Data{currVal+1} = currSelection;
        
        % hemi
        backupBelow = handles.brainMap.hemi{currVal+1};
        currSelection = handles.brainMap.hemi{currVal};
        handles.brainMap.hemi{currVal} = backupBelow;
        handles.brainMap.hemi{currVal+1} = currSelection;
        
        % current (the try-catch statements are there in case you have not
        % yet selected the second overlay, in which case it will have no
        % current field
        try
            backupBelow = handles.brainMap.Current{currVal+1};
        catch
            backupBelow = [];
        end
        try
            currSelection = handles.brainMap.Current{currVal};
        catch
            currSelection = [];
        end
        handles.brainMap.Current{currVal} = backupBelow;
        handles.brainMap.Current{currVal+1} = currSelection;
    end
    
    guidata(hObject, handles);
end

function growROI_Callback(hObject, eventdata, handles)
% hObject    handle to growROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of growROI as text
%        str2double(get(hObject,'String')) returns contents of growROI as a double
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI = str2double(get(hObject,'String'));
    
    if isfield(handles.opts,'colorbar')
        delete(handles.opts.colorbar)
    end
    
    %[handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    [handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.opts.colorbar = cbar;
    handles.opts.colorbar.TickLength = [0 0];
    imh = handles.opts.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    
    guidata(hObject, handles);
end

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

% --- Executes on button press in invertColorButton.
function invertColorButton_Callback(hObject, eventdata, handles)
% hObject    handle to invertColorButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of invertColorButton

if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    
    % update structure
    if get(hObject,'Value') == 1
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor = 'true';
    else
        handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor = 'false';
    end
    
    if isfield(handles.opts,'colorbar')
        delete(handles.opts.colorbar)
    end
    
    %[handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    [handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay, handles.brainFig, handles.opts] = plotOverlay(handles.underlay, handles.brainMap.Current{handles.overlaySelection.Value - 1}.Data, 'overlay', handles.brainMap.Current{handles.overlaySelection.Value - 1}.overlay,'figHandle', handles.brainFig, 'threshold',[handles.overlayThresholdNeg.Value, handles.overlayThresholdPos.Value], 'hemisphere', handles.brainMap.hemi{handles.overlaySelection.Value - 1}, 'opacity', str2double(handles.opacity.String), 'colorMap', handles.colormap.String{handles.colormap.Value}, 'colorSampling',handles.colormapSpacing.String{handles.colormapSpacing.Value},'colorBins',str2double(handles.colorBins.String),'limits', [str2double(handles.limitMin.String) str2double(handles.limitMax.String)],'inclZero',handles.brainMap.Current{handles.overlaySelection.Value - 1}.inclZero,'clusterThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.clusterThresh,'binarize',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarize,'outline',handles.brainMap.Current{handles.overlaySelection.Value - 1}.outline,'binarizeClusters',handles.brainMap.Current{handles.overlaySelection.Value - 1}.binarizeClusters,'customColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor,'pMap',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pVals,'pThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.pThresh,'transparencyLimits',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',handles.brainMap.Current{handles.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.brainMap.Current{handles.overlaySelection.Value - 1}.invertOpacity,'growROI',handles.brainMap.Current{handles.overlaySelection.Value - 1}.growROI);
    
    handles.opts.colorbar = cbar;
    handles.opts.colorbar.TickLength = [0 0];
    imh = handles.opts.colorbar.Children(1);
    imh.AlphaData = handles.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    
    guidata(hObject, handles);
end

% --- Executes on button press in maskButton.
function maskButton_Callback(hObject, eventdata, handles)
% hObject    handle to maskButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    maskGUI
    guidata(hObject, handles);
end

% --- Executes on button press in upButtonFinal.
function upButtonFinal_Callback(hObject, eventdata, handles)
% hObject    handle to upButtonFinal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.overlaySelection.Value ~= 1
    handles = guidata(hObject);
    currVal = handles.overlaySelection.Value;
    
    if currVal ~= 2
        currSelection = handles.overlaySelection.String{handles.overlaySelection.Value};
        backupAbove = handles.overlaySelection.String{currVal-1};
        handles.overlaySelection.String{currVal-1} = currSelection;
        handles.overlaySelection.String{currVal} = backupAbove;
        handles.overlaySelection.Value = handles.overlaySelection.Value-1;
        
        % now move all data
        currVal = currVal-1;
        
        % name
        backupAbove = handles.brainMap.Name{currVal-1};
        currSelection = handles.brainMap.Name{currVal};
        handles.brainMap.Name{currVal} = backupAbove;
        handles.brainMap.Name{currVal-1} = currSelection;
        
        % original data
        backupAbove = handles.brainMap.Original.Data{currVal-1};
        currSelection = handles.brainMap.Original.Data{currVal};
        handles.brainMap.Original.Data{currVal} = backupAbove;
        handles.brainMap.Original.Data{currVal-1} = currSelection;
        
        % hemi
        backupAbove = handles.brainMap.hemi{currVal-1};
        currSelection = handles.brainMap.hemi{currVal};
        handles.brainMap.hemi{currVal} = backupAbove;
        handles.brainMap.hemi{currVal-1} = currSelection;
        
        % current (the try-catch statements are there in case you have not
        % yet selected the second overlay, in which case it will have no
        % current field
        try
            backupAbove = handles.brainMap.Current{currVal-1};
        catch
            backupAbove = [];
        end
        try
            currSelection = handles.brainMap.Current{currVal};
        catch
            currSelection = [];
        end
        handles.brainMap.Current{currVal} = backupAbove;
        handles.brainMap.Current{currVal-1} = currSelection;
    end
    
    guidata(hObject, handles);
end

% --- Executes on button press in lightingButton.
function lightingButton_Callback(hObject, eventdata, handles)
% hObject    handle to lightingButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lightingGUI

% --- Executes on button press in valuesButton.
function valuesButton_Callback(hObject, eventdata, handles)
% hObject    handle to valuesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of valuesButton
if handles.overlaySelection.Value ~= 1
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

% --- Executes on button press in neighborhoodButton.
function neighborhoodButton_Callback(hObject, eventdata, handles)
% hObject    handle to neighborhoodButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of neighborhoodButton
if handles.overlaySelection.Value ~= 1
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
