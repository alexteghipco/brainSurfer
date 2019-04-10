function varargout = copySettingsGUI(varargin)
% GUI for masking an overlay with another overlay
% Alex Teghipco // alex.teghipco@uci.edu // 11/28/18
% Last Modified by GUIDE v2.5 01-Apr-2019 12:51:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @copySettingsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @copySettingsGUI_OutputFcn, ...
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

% --- Executes just before copySettingsGUI is made visible.
function copySettingsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to copySettingsGUI (see VARARGIN)

% Choose default command line output for copySettingsGUI
handles.output = hObject;
set(handles.selectionList,'Max',50,'Min',0);

h = get(0,'Children');
% find brain surfer
for hi = 1:length(h)
    if strcmp(h(hi).Name,'Brain Surfer') == 1
        mainGuiNum = hi;
    end
end
 
% get data from brain surfer
mainGuiData = guidata(h(mainGuiNum));
handles.selectionList.String = vertcat({handles.selectionList.String},mainGuiData.overlaySelection.String{2:end});

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes copySettingsGUI wait for user response (see UIRESUME)
% uiwait(handles.copySettingsGUI);

% --- Outputs from this function are returned to the command line.
function varargout = copySettingsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in selectButton.
function selectButton_Callback(hObject, eventdata, handles)
% hObject    handle to selectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;

h = get(0,'Children');
% find brain surfer
for hi = 1:length(h)
    if strcmp(h(hi).Name,'Brain Surfer') == 1
        mainGuiNum = hi;
    end
end
 
% get data from brain surfer
mainGuiData = guidata(h(mainGuiNum));

% make all settings the same as overlay selection
for i = 1:length(handles.selectionList.Value)
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.colormap = mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.colormap;
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.overlayThresholdNeg =  mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.overlayThresholdNeg;
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.overlayThresholdPos = mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.overlayThresholdPos;
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.limitMin =  mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.limitMin;
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.limitMax = mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.limitMax;
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.opacity = mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.opacity;
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.colormapSpacing = mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.colormapSpacing;
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.colorBins = mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.colorBins;
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.clusterThresh = mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.clusterThresh;
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.binarize = mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.binarize;
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.inclZero = mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.inclZero;
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.outline = mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.outline;
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.smoothSteps = mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.smoothSteps;
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.smoothArea = mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.smoothArea;
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.smoothThreshold = mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.smoothThreshold;
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.customColor = mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.customColor;
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.binarizeClusters = mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.binarizeClusters;
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.pThresh = mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.pThresh;
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.pVals = mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.pVals;
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.transparencyLimits = mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.transparencyLimits;
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.transparencyThresholds = mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.transparencyThresholds;
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.transparencyData = mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.transparencyData;
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.transparencyPThresh = mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.transparencyPThresh;
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.invertColor = mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.invertColor;
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.invertOpacity = mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.invertOpacity;
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.growROI = mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.growROI;
   mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.smoothType = mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.smoothType;
end

% save GUI
guidata(h(mainGuiNum), mainGuiData);

% close everything
% close figure
h = get(0,'Children');
% find transparencyFig
for hi = 1:length(h)
    if strcmp(h(hi).Name,'copySettingsGUI') == 1
        close(h(hi))
    end
end

% --- Executes on selection change in selectionList.
function selectionList_Callback(hObject, eventdata, handles)
% hObject    handle to selectionList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns selectionList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectionList

% --- Executes during object creation, after setting all properties.
function selectionList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectionList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    set(h_list,'Max',2,'Min',0);
end
