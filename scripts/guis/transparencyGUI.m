function varargout = transparencyGUI(varargin)
% GUI for modulating transparency of a subset of data
% Alex Teghipco // alex.teghipco@uci.edu // 11/28/18
% Last Modified by GUIDE v2.5 10-Nov-2018 21:41:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @transparencyGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @transparencyGUI_OutputFcn, ...
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


% --- Executes just before transparencyGUI is made visible.
function transparencyGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to transparencyGUI (see VARARGIN)
% Choose default command line output for transparencyGUI
handles.output = hObject;

% get info from brainSurfer
% get children
h = get(0,'Children');
% find brain surfer
for hi = 1:length(h)
    if strcmp(h(hi).Name,'Brain Surfer') == 1
        mainGuiNum = hi;
    end
end

% get data from brain surfer
mainGuiData = guidata(h(mainGuiNum));

% get the selection from brain surfer that you are messing around with in
% transparencyGUI
currSelection = (get(mainGuiData.overlaySelection,'Value') - 1);

% now update sliders for opacity threshold
% change max and min for those sliders
handles.positiveThreshSlider.Max = max(mainGuiData.brainMap.Current{currSelection}.Data);
handles.negativeThreshSlider.Min = min(mainGuiData.brainMap.Current{currSelection}.Data);

% and change what they are set to
handles.positiveThreshSlider.Value = mainGuiData.overlayThresholdPos.Value;
handles.negativeThreshSlider.Value = mainGuiData.overlayThresholdNeg.Value;
handles.positiveThreshText.String = num2str(handles.positiveThreshSlider.Value);
handles.negativeThreshText.String = num2str(handles.negativeThreshSlider.Value);
handles.Current.transparencyThresholds = [mainGuiData.overlayThresholdPos.Value mainGuiData.overlayThresholdNeg.Value];

% save this gui
guidata(h(mainGuiNum), mainGuiData);

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = transparencyGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

% --- Executes on slider movement.
function minSlider_Callback(hObject, eventdata, handles)
% hObject    handle to minSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles = guidata(hObject);
handles.minText.String = num2str(hObject.Value);
handles.Current.transparencyMin = hObject.Value;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function minSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function maxSlider_Callback(hObject, eventdata, handles)
% hObject    handle to maxSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles = guidata(hObject);
handles.maxText.String = num2str(hObject.Value);
handles.Current.transparencyMax = hObject.Value;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function maxSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in alternativeButton.
function alternativeButton_Callback(hObject, eventdata, handles)
% hObject    handle to alternativeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);

[file, path]= uigetfile({'*.nii*'},'Select the data you would like to use to determine opacity','File Selector');

tmp = load_nifti([path file]);

handles.Current.transparencyData = tmp.vol;

% update min max threshold
% also update general stuff -- like the underlay and the figHandle
% now update sliders for opacity threshold
% change max and min for those sliders
handles.positiveThreshSlider.Max = max(handles.Current.transparencyData);
handles.negativeThreshSlider.Min = min(handles.Current.transparencyData);


% and change what they are set to
handles.positiveThreshSlider.Value = 0;
handles.negativeThreshSlider.Value = 0;
handles.positiveThreshText.String = '0';
handles.negativeThreshText.String = '0';

guidata(hObject, handles);

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function maxText_Callback(hObject, eventdata, handles)
% hObject    handle to maxText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxText as text
%        str2double(get(hObject,'String')) returns contents of maxText as a double
handles = guidata(hObject);
handles.maxSlider.Value = str2double(hObject.String);
handles.Current.transparencyMax = str2double(hObject.String);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function maxText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function minText_Callback(hObject, eventdata, handles)
% hObject    handle to minText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minText as text
%        str2double(get(hObject,'String')) returns contents of minText as a double
handles = guidata(hObject);
handles.minSlider.Value = str2double(hObject.String);
handles.Current.transparencyMin = str2double(hObject.String);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function minText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in closeButton.
function closeButton_Callback(hObject, eventdata, handles)
% hObject    handle to closeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if closing, then we will return modulating transparency data to default
% (but keep transparency data)
h = get(0,'Children');
% find brain surfer
for hi = 1:length(h)
    if strcmp(h(hi).Name,'Brain Surfer') == 1
        mainGuiNum = hi;
    end
end
 
% get data from brain surfer
mainGuiData = guidata(h(mainGuiNum));
currSelection = (get(mainGuiData.overlaySelection,'Value') - 1);

mainGuiData.brainMap.Current{currSelection}.transparencyLimits = [];
mainGuiData.brainMap.Current{currSelection}.transparencyThresholds = [];
mainGuiData.brainMap.Current{currSelection}.transparencyPThresh = [];
mainGuiData.brainMap.Current{currSelection}.invertOpacity = 'false';

% update figure to make it clear that modulation is no longer available
% remove colorbar if it exists
if isfield(mainGuiData.brainMap,'colorbar')
    delete(mainGuiData.brainMap.colorbar)
    mainGuiData.brainMap = rmfield(mainGuiData.brainMap,'colorbar');
end

% now turn off any overlays that might exist and delete them
% multioverlays are in a cell
if isfield(mainGuiData.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
    if iscell(mainGuiData.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
        for celli = 1:length(mainGuiData.brainMap.overlay)
            mainGuiData.brainMap.overlay{celli}.FaceAlpha = 0;
        end
        mainGuiData.brainMap = rmfield(mainGuiData.brainMap,'overlay');
    elseif isvalid(mainGuiData.brainMap.overlay)
        mainGuiData.overlayCopy = mainGuiData.brainMap.overlay;
        mainGuiData.brainMap.overlay.FaceAlpha = 0;
        mainGuiData.brainMap = rmfield(mainGuiData.brainMap,'overlay');
    end
end


figure(mainGuiData.brainFig)
[mainGuiData.underlay, mainGuiData.brainMap.overlay, mainGuiData.brainFig, mainGuiData.opts] = plotOverlay(mainGuiData.underlay, mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.Data,'figHandle', mainGuiData.brainFig, 'threshold',[mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.overlayThresholdNeg, mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.hemi, 'opacity', mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.opacity, 'colorMap', mainGuiData.colormap.String{mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.colormap}, 'colorSampling',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.colormapSpacing,'colorBins',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.colorBins,'limits', [mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.limitMin mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.limitMax],'inclZero',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.inclZero,'clusterThresh',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.clusterThresh,'binarize',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.binarize,'outline',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.outline,'binarizeClusters',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.binarizeClusters,'customColor',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.customColor,'pMap',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.pVals,'pThresh',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.pThresh,'transparencyLimits',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.transparencyThresholds,'transparencyData',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.transparencyData,'transparencyPThresh',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.transparencyPThresh,'invertColor',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.invertColor,'invertOpacity',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.invertOpacity,'growROI',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.growROI);

mainGuiData.brainMap.colorbar = cbar;
mainGuiData.brainMap.colorbar.TickLength = [0 0];
imh = mainGuiData.brainMap.colorbar.Children(1);
imh.AlphaData = mainGuiData.opts.transparencyData;
imh.AlphaDataMapping = 'direct';

if mainGuiData.colormapSpacing.Value == 4 || mainGuiData.colormapSpacing.Value == 3
    mainGuiData.brainMap.colorbar.YTick = mainGuiData.opts.ticks;
    mainGuiData.brainMap.colorbar.YTickLabel = mainGuiData.opts.tickLabels;
end

if isfield(mainGuiData.overlayCopy,'overlayCopy')
    mainGuiData.overlayCopy.brainMap.overlay.SpecularStrength = mainGuiData.overlayCopy.overlayCopy.SpecularStrength;
    mainGuiData.overlayCopy.brainMap.overlay.SpecularExponent = mainGuiData.overlayCopy.overlayCopy.SpecularExponent;
    mainGuiData.overlayCopy.brainMap.overlay.SpecularColorReflectance =  mainGuiData.overlayCopy.overlayCopy.SpecularColorReflectance;
    mainGuiData.overlayCopy.brainMap.overlay.DiffuseStrength = mainGuiData.overlayCopy.overlayCopy.DiffuseStrength;
    mainGuiData.overlayCopy.brainMap.overlay.AmbientStrength =  mainGuiData.overlayCopy.overlayCopy.AmbientStrength;
end

% close figure
h = get(0,'Children');
% find transparencyFig
for hi = 1:length(h)
    if strcmp(h(hi).Name,'transparencyFIG') == 1
        close(h(hi))
    end
end

guidata(h(mainGuiNum), mainGuiData);


function positiveThreshText_Callback(hObject, eventdata, handles)
% hObject    handle to positiveThreshText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of positiveThreshText as text
%        str2double(get(hObject,'String')) returns contents of positiveThreshText as a double
handles = guidata(hObject);      
handles.positiveThreshSlider.Value = str2double(hObject.String);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function positiveThreshText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to positiveThreshText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function negativeThreshText_Callback(hObject, eventdata, handles)
% hObject    handle to negativeThreshText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of negativeThreshText as text
%        str2double(get(hObject,'String')) returns contents of negativeThreshText as a double
handles = guidata(hObject);
handles.negativeThreshSlider.Value = str2double(hObject.String);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function negativeThreshText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to negativeThreshText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function positiveThreshSlider_Callback(hObject, eventdata, handles)
% hObject    handle to positiveThreshSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles = guidata(hObject);
handles.positiveThreshText.String = num2str(hObject.Value);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function positiveThreshSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to positiveThreshSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function negativeThreshSlider_Callback(hObject, eventdata, handles)
% hObject    handle to negativeThreshSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles = guidata(hObject);
handles.negativeThreshText.String = num2str(hObject.Value);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function negativeThreshSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to negativeThreshSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in goButton.
function goButton_Callback(hObject, eventdata, handles)
% hObject    handle to goButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% update overlay

h = get(0,'Children');
% find brain surfer
for hi = 1:length(h)
    if strcmp(h(hi).Name,'Brain Surfer') == 1
        mainGuiNum = hi;
    end
end

% get data from brain surfer
mainGuiData = guidata(h(mainGuiNum));
currSelection = (get(mainGuiData.overlaySelection,'Value') - 1);

% remove colorbar if it exists
if isfield(mainGuiData.brainMap,'colorbar')
    delete(mainGuiData.brainMap.colorbar)
    mainGuiData.brainMap = rmfield(mainGuiData.brainMap,'colorbar');
end

% now turn off any overlays that might exist and delete them
% multioverlays are in a cell
if isfield(mainGuiData.brainMap,'overlay') %if there is an overlay field (i.e., not your first click)
    if iscell(mainGuiData.brainMap.overlay) % check if overlay is a cell (i.e., multioverlay)
        for celli = 1:length(mainGuiData.brainMap.overlay)
            mainGuiData.brainMap.overlay{celli}.FaceAlpha = 0;
        end
        mainGuiData.brainMap = rmfield(mainGuiData.brainMap,'overlay');
    elseif isvalid(mainGuiData.brainMap.overlay)
        mainGuiData.overlayCopy = mainGuiData.brainMap.overlay;
        mainGuiData.brainMap.overlay.FaceAlpha = 0;
        mainGuiData.brainMap = rmfield(mainGuiData.brainMap,'overlay');
    end
end

if isfield(handles.Current,'transparencyPThresh') == 0
    handles.Current.transparencyPThresh = [];
end

if isfield(handles.Current,'transparencyData') == 0
    handles.Current.transparencyData = [];
end

if isfield(handles.Current,'invertOpacity') == 0
    handles.Current.invertOpacity = 'false';
end

% patch brain
% if you did not provide p-values but you did provide an opacity
% p-threshold, use the value thresholds instead
if isempty(mainGuiData.brainMap.Current{currSelection}.pVals) == 1 && isempty(handles.Current.transparencyPThresh) ~= 1
    warning('You did not provide p-values but you want to use a p-value based opacity threshold. This is impossible. Using the value thresholds you supplied in the transparency GUI')
    figure(mainGuiData.brainFig)
    %[mainGuiData.underlay, mainGuiData.brainMap.Current{currSelection}.overlay, mainGuiData.brainFig, mainGuiData.opts] = plotOverlay(mainGuiData.underlay, mainGuiData.brainMap.Current{currSelection}.Data, 'overlay', mainGuiData.brainMap.Current{currSelection}.overlay,'figHandle', mainGuiData.brainFig, 'threshold',[mainGuiData.overlayThresholdNeg.Value, mainGuiData.overlayThresholdPos.Value], 'hemisphere', mainGuiData.brainMap.hemi{currSelection}, 'opacity', str2double(mainGuiData.opacity.String), 'colorMap', mainGuiData.colormap.String{mainGuiData.colormap.Value}, 'colorSampling',mainGuiData.colormapSpacing.String{mainGuiData.colormapSpacing.Value},'colorBins',str2double(mainGuiData.colorBins.String),'limits', [str2double(mainGuiData.limitMin.String) str2double(mainGuiData.limitMax.String)],'inclZero',mainGuiData.brainMap.Current{currSelection}.inclZero,'clusterThresh',mainGuiData.brainMap.Current{currSelection}.clusterThresh,'binarize',mainGuiData.brainMap.Current{currSelection}.binarize,'outline',mainGuiData.brainMap.Current{currSelection}.outline,'binarizeClusters',mainGuiData.brainMap.Current{currSelection}.binarizeClusters,'customColor',mainGuiData.brainMap.Current{currSelection}.customColor,'pMap',mainGuiData.brainMap.Current{currSelection}.pVals,'pThresh',mainGuiData.brainMap.Current{currSelection}.pThresh,'transparencyLimits',[handles.minSlider.Value handles.maxSlider.Value],'transparencyThresholds',[handles.negativeThreshSlider.Value handles.positiveThreshSlider.Value],'transparencyData',handles.Current.transparencyData,'transparencyPThresh',[],'invertColor',mainGuiData.brainMap.Current{currSelection}.invertColor,'invertOpacity',handles.Current.invertOpacity,'growROI',mainGuiData.brainMap.Current{currSelection}.growROI,'smoothType',mainGuiData.brainMap.Current{currSelection}.smoothType);
    [mainGuiData.underlay, mainGuiData.brainMap.overlay, mainGuiData.brainFig, mainGuiData.opts] = plotOverlay(mainGuiData.underlay, mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.Data,'figHandle', mainGuiData.brainFig, 'threshold',[mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.overlayThresholdNeg, mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.hemi, 'opacity', mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.opacity, 'colorMap', mainGuiData.colormap.String{mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.colormap}, 'colorSampling',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.colormapSpacing,'colorBins',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.colorBins,'limits', [mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.limitMin mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.limitMax],'inclZero',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.inclZero,'clusterThresh',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.clusterThresh,'binarize',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.binarize,'outline',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.outline,'binarizeClusters',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.binarizeClusters,'customColor',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.customColor,'pMap',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.pVals,'pThresh',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.pThresh,'transparencyLimits',[handles.minSlider.Value handles.maxSlider.Value],'transparencyThresholds',[handles.negativeThreshSlider.Value handles.positiveThreshSlider.Value],'transparencyData',handles.Current.transparencyData,'transparencyPThresh',[],'invertColor',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.invertColor,'invertOpacity',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.invertOpacity,'growROI',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.growROI);

    % else, if you provided both a p-threshold (or one that isn't p > 1) and
    % also a value-based threshold, then use the p-threshold over the value
    % thresholds
elseif (isempty(handles.Current.transparencyPThresh) ~= 1 && handles.Current.transparencyPThresh ~= 1) && isempty(handles.Current.transparencyThresholds) == 0
    %[mainGuiData.underlay, mainGuiData.brainMap.Current{currSelection}.overlay, mainGuiData.brainFig, mainGuiData.opts] = plotOverlay(mainGuiData.underlay, mainGuiData.brainMap.Current{currSelection}.Data, 'overlay', mainGuiData.brainMap.Current{currSelection}.overlay,'figHandle', mainGuiData.brainFig, 'threshold',[mainGuiData.overlayThresholdNeg.Value, mainGuiData.overlayThresholdPos.Value], 'hemisphere', mainGuiData.brainMap.hemi{currSelection}, 'opacity', str2double(mainGuiData.opacity.String), 'colorMap', mainGuiData.colormap.String{mainGuiData.colormap.Value}, 'colorSampling',mainGuiData.colormapSpacing.String{mainGuiData.colormapSpacing.Value},'colorBins',str2double(mainGuiData.colorBins.String),'limits', [str2double(mainGuiData.limitMin.String) str2double(mainGuiData.limitMax.String)],'inclZero',mainGuiData.brainMap.Current{currSelection}.inclZero,'clusterThresh',mainGuiData.brainMap.Current{currSelection}.clusterThresh,'binarize',mainGuiData.brainMap.Current{currSelection}.binarize,'outline',mainGuiData.brainMap.Current{currSelection}.outline,'binarizeClusters',mainGuiData.brainMap.Current{currSelection}.binarizeClusters,'customColor',mainGuiData.brainMap.Current{currSelection}.customColor,'pMap',mainGuiData.brainMap.Current{currSelection}.pVals,'pThresh',mainGuiData.brainMap.Current{currSelection}.pThresh,'transparencyLimits',[handles.minSlider.Value handles.maxSlider.Value],'transparencyThresholds',[],'transparencyData',handles.Current.transparencyData,'transparencyPThresh',handles.Current.transparencyPThresh,'invertColor',mainGuiData.brainMap.Current{currSelection}.invertColor,'invertOpacity',handles.Current.invertOpacity,'growROI',mainGuiData.brainMap.Current{currSelection}.growROI,'smoothType',mainGuiData.brainMap.Current{currSelection}.smoothType);
    figure(mainGuiData.brainFig)
    [mainGuiData.underlay, mainGuiData.brainMap.overlay, mainGuiData.brainFig, mainGuiData.opts] = plotOverlay(mainGuiData.underlay, mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.Data,'figHandle', mainGuiData.brainFig, 'threshold',[mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.overlayThresholdNeg, mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.hemi, 'opacity', mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.opacity, 'colorMap', mainGuiData.colormap.String{mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.colormap}, 'colorSampling',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.colormapSpacing,'colorBins',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.colorBins,'limits', [mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.limitMin mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.limitMax],'inclZero',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.inclZero,'clusterThresh',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.clusterThresh,'binarize',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.binarize,'outline',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.outline,'binarizeClusters',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.binarizeClusters,'customColor',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.customColor,'pMap',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.pVals,'pThresh',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.pThresh,'transparencyLimits',[handles.minSlider.Value handles.maxSlider.Value],'transparencyThresholds',[],'transparencyData',handles.Current.transparencyData,'transparencyPThresh',handles.Current.transparencyPThresh,'invertColor',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.invertColor,'invertOpacity',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.invertOpacity,'growROI',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.growROI);
    
    % else, use just value based thresholds
else
    %[mainGuiData.underlay, mainGuiData.brainMap.Current{currSelection}.overlay, mainGuiData.brainFig, mainGuiData.opts] = plotOverlay(mainGuiData.underlay, mainGuiData.brainMap.Current{currSelection}.Data, 'overlay', mainGuiData.brainMap.Current{currSelection}.overlay,'figHandle', mainGuiData.brainFig, 'threshold',[mainGuiData.overlayThresholdNeg.Value, mainGuiData.overlayThresholdPos.Value], 'hemisphere', mainGuiData.brainMap.hemi{currSelection}, 'opacity', str2double(mainGuiData.opacity.String), 'colorMap', mainGuiData.colormap.String{mainGuiData.colormap.Value}, 'colorSampling',mainGuiData.colormapSpacing.String{mainGuiData.colormapSpacing.Value},'colorBins',str2double(mainGuiData.colorBins.String),'limits', [str2double(mainGuiData.limitMin.String) str2double(mainGuiData.limitMax.String)],'inclZero',mainGuiData.brainMap.Current{currSelection}.inclZero,'clusterThresh',mainGuiData.brainMap.Current{currSelection}.clusterThresh,'binarize',mainGuiData.brainMap.Current{currSelection}.binarize,'outline',mainGuiData.brainMap.Current{currSelection}.outline,'binarizeClusters',mainGuiData.brainMap.Current{currSelection}.binarizeClusters,'customColor',mainGuiData.brainMap.Current{currSelection}.customColor,'pMap',mainGuiData.brainMap.Current{currSelection}.pVals,'pThresh',mainGuiData.brainMap.Current{currSelection}.pThresh,'transparencyLimits',[handles.minSlider.Value handles.maxSlider.Value],'transparencyThresholds',[handles.negativeThreshSlider.Value handles.positiveThreshSlider.Value],'transparencyData',handles.Current.transparencyData,'transparencyPThresh',[],'invertColor',mainGuiData.brainMap.Current{currSelection}.invertColor,'invertOpacity',handles.Current.invertOpacity,'growROI',mainGuiData.brainMap.Current{currSelection}.growROI,'smoothType',mainGuiData.brainMap.Current{currSelection}.smoothType);
    figure(mainGuiData.brainFig)
    %[mainGuiData.underlay, mainGuiData.brainMap.overlay, mainGuiData.brainFig, mainGuiData.opts] = plotOverlay(mainGuiData.underlay, mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.Data,'figHandle', mainGuiData.brainFig, 'threshold',[mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.overlayThresholdNeg, mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.hemi, 'opacity', mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.opacity, 'colorMap', mainGuiData.colormap.String{mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.colormap}, 'colorSampling',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.colormapSpacing,'colorBins',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.colorBins,'limits', [mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.limitMin mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.limitMax],'inclZero',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.inclZero,'clusterThresh',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.clusterThresh,'binarize',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.binarize,'outline',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.outline,'binarizeClusters',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.binarizeClusters,'customColor',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.customColor,'pMap',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.pVals,'pThresh',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.pThresh,'transparencyLimits',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.transparencyLimits,'transparencyThresholds',[handles.negativeThreshSlider.Value handles.positiveThreshSlider.Value],'transparencyData',handles.Current.transparencyData,'transparencyPThresh',[],'invertColor',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.invertColor,'invertOpacity',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.invertOpacity,'growROI',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.growROI);
    [mainGuiData.underlay, mainGuiData.brainMap.overlay, mainGuiData.brainFig, mainGuiData.opts] = plotOverlay(mainGuiData.underlay, mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.Data,'figHandle', mainGuiData.brainFig, 'threshold',[mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.overlayThresholdNeg, mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.overlayThresholdPos], 'hemisphere', mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.hemi, 'opacity', mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.opacity, 'colorMap', mainGuiData.colormap.String{mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.colormap}, 'colorSampling',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.colormapSpacing,'colorBins',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.colorBins,'limits', [mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.limitMin mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.limitMax],'inclZero',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.inclZero,'clusterThresh',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.clusterThresh,'binarize',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.binarize,'outline',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.outline,'binarizeClusters',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.binarizeClusters,'customColor',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.customColor,'pMap',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.pVals,'pThresh',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.pThresh,'transparencyLimits',[handles.minSlider.Value handles.maxSlider.Value],'transparencyThresholds',[handles.negativeThreshSlider.Value handles.positiveThreshSlider.Value],'transparencyData',handles.Current.transparencyData,'transparencyPThresh',handles.Current.transparencyPThresh,'invertColor',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.invertColor,'invertOpacity',handles.Current.invertOpacity,'growROI',mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.growROI);
end

% plot cbar
   
mainGuiData.brainMap.colorbar = cbar;
mainGuiData.brainMap.colorbar.TickLength = [0 0];
imh = mainGuiData.brainMap.colorbar.Children(1);
imh.AlphaData = mainGuiData.opts.transparencyData;
imh.AlphaDataMapping = 'direct';

if mainGuiData.colormapSpacing.Value == 4 || mainGuiData.colormapSpacing.Value == 3
    mainGuiData.brainMap.colorbar.YTick = mainGuiData.opts.ticks;
    mainGuiData.brainMap.colorbar.YTickLabel = mainGuiData.opts.tickLabels;
end

if isfield(mainGuiData.overlayCopy,'overlayCopy')
    mainGuiData.overlayCopy.brainMap.overlay.SpecularStrength = mainGuiData.overlayCopy.overlayCopy.SpecularStrength;
    mainGuiData.overlayCopy.brainMap.overlay.SpecularExponent = mainGuiData.overlayCopy.overlayCopy.SpecularExponent;
    mainGuiData.overlayCopy.brainMap.overlay.SpecularColorReflectance =  mainGuiData.overlayCopy.overlayCopy.SpecularColorReflectance;
    mainGuiData.overlayCopy.brainMap.overlay.DiffuseStrength = mainGuiData.overlayCopy.overlayCopy.DiffuseStrength;
    mainGuiData.overlayCopy.brainMap.overlay.AmbientStrength =  mainGuiData.overlayCopy.overlayCopy.AmbientStrength;
end


% save 
mainGuiData.brainMap.Current{currSelection}.transparencyLimits = [handles.minSlider.Value handles.maxSlider.Value];
mainGuiData.brainMap.Current{currSelection}.transparencyThresholds = [handles.negativeThreshSlider.Value handles.positiveThreshSlider.Value];
mainGuiData.brainMap.Current{currSelection}.transparencyData = handles.Current.transparencyData;
mainGuiData.brainMap.Current{currSelection}.transparencyPThresh = handles.Current.transparencyPThresh;
mainGuiData.brainMap.Current{currSelection}.invertOpacity = handles.Current.invertOpacity;

% save this gui
guidata(h(mainGuiNum), mainGuiData);
guidata(hObject, handles);

function pText_Callback(hObject, eventdata, handles)
% hObject    handle to pText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pText as text
%        str2double(get(hObject,'String')) returns contents of pText as a double
handles = guidata(hObject);
handles.pSlider.Value = str2double(hObject.String);
handles.Current.transparencyPThresh = handles.pSlider.Value;
guidata(hObject, handles);

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
function pSlider_Callback(hObject, eventdata, handles)
% hObject    handle to pSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles = guidata(hObject);
handles.pText.String = num2str(hObject.Value);
handles.Current.transparencyPThresh = hObject.Value;

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in invertButton.
function invertButton_Callback(hObject, eventdata, handles)
% hObject    handle to invertButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of invertButton
handles = guidata(hObject);

% update saved settings for overlay
if hObject.Value == 1
    handles.Current.invertOpacity = 'true';
else
    handles.Current.invertOpacity = 'false';
end

guidata(hObject, handles);


% --- Executes on button press in overwrite.
function overwrite_Callback(hObject, eventdata, handles)
% hObject    handle to overwrite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h = get(0,'Children');
% find brain surfer
for hi = 1:length(h)
    if strcmp(h(hi).Name,'Brain Surfer') == 1
        mainGuiNum = hi;
    end
end

% get data from brain surfer
mainGuiData = guidata(h(mainGuiNum));
currSelection = (get(mainGuiData.overlaySelection,'Value') - 1);

% save 
mainGuiData.brainMap.Current{currSelection}.transparencyLimits = [handles.minSlider.Value handles.maxSlider.Value];
mainGuiData.brainMap.Current{currSelection}.transparencyThresholds = [handles.negativeThreshSlider.Value handles.positiveThreshSlider.Value];
mainGuiData.brainMap.Current{currSelection}.transparencyData = handles.Current.transparencyData;
mainGuiData.brainMap.Current{currSelection}.transparencyPThresh = handles.Current.transparencyPThresh;
mainGuiData.brainMap.Current{currSelection}.invertOpacity = handles.Current.invertOpacity;

% save this gui
guidata(h(mainGuiNum), mainGuiData);

% close figure
h = get(0,'Children');
% find transparencyFig
for hi = 1:length(h)
    if strcmp(h(hi).Name,'transparencyFIG') == 1
        close(h(hi))
    end
end
%guidata(hObject, handles);
