function varargout = maskGUI(varargin)
% MASKGUI MATLAB code for maskGUI.fig
%      MASKGUI, by itself, creates a new MASKGUI or raises the existing
%      singleton*.
%
%      H = MASKGUI returns the handle to a new MASKGUI or the handle to
%      the existing singleton*.
%
%      MASKGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MASKGUI.M with the given input arguments.
%
%      MASKGUI('Property','Value',...) creates a new MASKGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before maskGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to maskGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help maskGUI

% Last Modified by GUIDE v2.5 08-Nov-2018 21:00:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @maskGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @maskGUI_OutputFcn, ...
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

% --- Executes just before maskGUI is made visible.
function maskGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to maskGUI (see VARARGIN)

% Choose default command line output for maskGUI
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
handles.listbox2.String = vertcat({handles.listbox2.String},mainGuiData.overlaySelection.String{2:end});

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes maskGUI wait for user response (see UIRESUME)
% uiwait(handles.maskGUI);

% --- Outputs from this function are returned to the command line.
function varargout = maskGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in maskButton.
function maskButton_Callback(hObject, eventdata, handles)
% hObject    handle to maskButton (see GCBO)
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
toMask = handles.listbox2.Value - 1;
mask = mainGuiData.overlaySelection.Value - 1;
%currSelection = (get(mainGuiData.overlaySelection,'Value') - 1);

if isfield(mainGuiData.opts,'colorbar')
    delete(mainGuiData.opts.colorbar)
end

[mainGuiData.underlay, ~, ~, mainGuiData.opts] = plotOverlay(mainGuiData.underlay, mainGuiData.brainMap.Current{mask}.Data,'plotSwitch','off', 'threshold',[mainGuiData.overlayThresholdNeg.Value, mainGuiData.overlayThresholdPos.Value], 'hemisphere', mainGuiData.brainMap.hemi{mask}, 'colorMap', mainGuiData.colormap.String{mainGuiData.colormap.Value}, 'colorSampling',mainGuiData.colormapSpacing.String{mainGuiData.colormapSpacing.Value},'colorBins',str2double(mainGuiData.colorBins.String),'limits', [str2double(mainGuiData.limitMin.String) str2double(mainGuiData.limitMax.String)],'inclZero','false','clusterThresh',mainGuiData.brainMap.Current{mask}.clusterThresh,'binarize',mainGuiData.brainMap.Current{mask}.binarize,'outline',mainGuiData.brainMap.Current{mask}.outline,'binarizeClusters',mainGuiData.brainMap.Current{mask}.binarizeClusters,'customColor',mainGuiData.brainMap.Current{mask}.customColor,'pMap',mainGuiData.brainMap.Current{mask}.pVals,'pThresh',mainGuiData.brainMap.Current{mask}.pThresh,'transparencyLimits',mainGuiData.brainMap.Current{mask}.transparencyLimits,'transparencyThresholds',mainGuiData.brainMap.Current{mask}.transparencyThresholds,'transparencyData',mainGuiData.brainMap.Current{mask}.transparencyData,'transparencyPThresh',mainGuiData.brainMap.Current{mask}.transparencyPThresh,'growROI',mainGuiData.brainMap.Current{mask}.growROI);

idx = find(mainGuiData.opts.overlayData ~= 0);
mainGuiData.brainMap.Current{toMask}.Data(idx) = 0;

% save GUI
guidata(h(mainGuiNum), mainGuiData);

% close everything
% close figure
h = get(0,'Children');
% find transparencyFig
for hi = 1:length(h)
    if strcmp(h(hi).Name,'maskGUI') == 1
        close(h(hi))
    end
end

% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2

% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
