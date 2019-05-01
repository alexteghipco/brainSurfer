function varargout = colormapEditor3D(varargin)
% COLORMAPEDITOR3D MATLAB code for colormapEditor3D.fig
%      COLORMAPEDITOR3D, by itself, creates a new COLORMAPEDITOR3D or raises the existing
%      singleton*.
%
%      H = COLORMAPEDITOR3D returns the handle to a new COLORMAPEDITOR3D or the handle to
%      the existing singleton*.
%
%      COLORMAPEDITOR3D('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COLORMAPEDITOR3D.M with the given input arguments.
%
%      COLORMAPEDITOR3D('Property','Value',...) creates a new COLORMAPEDITOR3D or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before colormapEditor3D_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to colormapEditor3D_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help colormapEditor3D

% Last Modified by GUIDE v2.5 27-Apr-2019 18:52:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @colormapEditor3D_OpeningFcn, ...
                   'gui_OutputFcn',  @colormapEditor3D_OutputFcn, ...
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


% --- Executes just before colormapEditor3D is made visible.
function colormapEditor3D_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to colormapEditor3D (see VARARGIN)

% Choose default command line output for colormapEditor3D
handles.output = hObject;
handles = guidata(hObject);

% get data from mainGUI
handles.output = hObject;
h = get(0,'Children');
% find brain surfer
for hi = 1:length(h)
    if strcmp(h(hi).Name,'Brain Surfer') == 1
        mainGuiNum = hi;
    end
end
mainGuiData = guidata(h(mainGuiNum));

% update colormap options in this gui
handles.selectButton.String = mainGuiData.colormap.String;
handles.selectButton.Value = mainGuiData.colormap.Value;

handles.listbox.String = vertcat({handles.listbox.String},mainGuiData.overlaySelection.String{2:end});
set(handles.listbox,'Max',3,'Min',0);

% Update handles structure
guidata(h(mainGuiNum), mainGuiData);
guidata(hObject, handles);
% UIWAIT makes colormapEditor3D wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = colormapEditor3D_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in patchButton.
function patchButton_Callback(hObject, eventdata, handles)
% hObject    handle to patchButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
if length(handles.listbox.Value) == 3
    h = get(0,'Children');
    % find brain surfer
    for hi = 1:length(h)
        if strcmp(h(hi).Name,'Brain Surfer') == 1
            mainGuiNum = hi;
        end
    end
    mainGuiData = guidata(h(mainGuiNum));
    
    lims(1,1) = str2num(handles.dim1Min.String);
    lims(1,2) = str2num(handles.dim2Min.String);
    lims(1,3) = str2num(handles.dim3Min.String);
    
    lims(2,1) = str2num(handles.dim1Max.String);
    lims(2,2) = str2num(handles.dim2Max.String);
    lims(2,3) = str2num(handles.dim3Max.String);
    
    allData(:,1) = mainGuiData.brainMap.Current{handles.listbox.Value(1) - 1}.Data;
    allData(:,2) = mainGuiData.brainMap.Current{handles.listbox.Value(2) - 1}.Data;
    allData(:,3) = mainGuiData.brainMap.Current{handles.listbox.Value(3) - 1}.Data;
    
    if handles.checkbox7.Value == 1
        backup = allData(:,1);
        allData(:,1) = allData(:,2);
        allData(:,2) = backup;
    end
    
    if handles.checkbox8.Value == 1
        backup = allData(:,1);
        allData(:,1) = allData(:,3);
        allData(:,3) = backup;
    end
    
    if handles.checkbox9.Value == 1
        backup = allData(:,2);
        allData(:,2) = allData(:,3);
        allData(:,3) = backup;
    end
    
    if handles.patchCube.Value == 1
        plotSwitch = 'true';
    else
        plotSwitch = 'false';
    end
       
    %figure
    [handles.underlay, handles.overlay] = plot3dOverlay(allData, str2double(handles.cBins.String), str2double(handles.cubeSz.String), lims, plotSwitch);    
    handles.overlay.FaceAlpha = str2double(handles.opacity.String);
    
    guidata(h(mainGuiNum), mainGuiData);
end
guidata(hObject, handles);

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in listbox.
function listbox_Callback(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox
handles = guidata(hObject);
handles.output = hObject;
h = get(0,'Children');
% find brain surfer
for hi = 1:length(h)
    if strcmp(h(hi).Name,'Brain Surfer') == 1
        mainGuiNum = hi;
    end
end
mainGuiData = guidata(h(mainGuiNum));

if length(handles.listbox.Value) == 1 && sum(handles.listbox.Value ~= 1) == 1
    handles.dim1Min.String = num2str(min(mainGuiData.brainMap.Current{handles.listbox.Value - 1}.Data));
    handles.dim1Max.String = num2str(max(mainGuiData.brainMap.Current{handles.listbox.Value - 1}.Data));
    handles.dim2Min.String = 'NaN';
    handles.dim2Max.String = 'NaN';
    handles.dim3Min.String = 'NaN';
    handles.dim3Max.String = 'NaN';
elseif length(handles.listbox.Value) == 2 && sum(handles.listbox.Value ~= 1) == 2
    handles.dim1Min.String = num2str(min(mainGuiData.brainMap.Current{handles.listbox.Value(1) - 1}.Data));
    handles.dim2Min.String = num2str(min(mainGuiData.brainMap.Current{handles.listbox.Value(2) - 1}.Data));
    handles.dim1Max.String = num2str(max(mainGuiData.brainMap.Current{handles.listbox.Value(1) - 1}.Data));
    handles.dim2Max.String = num2str(max(mainGuiData.brainMap.Current{handles.listbox.Value(2) - 1}.Data));
    handles.dim3Min.String = 'NaN';
    handles.dim3Max.String = 'NaN';
elseif length(handles.listbox.Value) == 3 && sum(handles.listbox.Value ~= 1) == 3
    handles.dim1Min.String = num2str(min(mainGuiData.brainMap.Current{handles.listbox.Value(1) - 1}.Data));
    handles.dim2Min.String = num2str(min(mainGuiData.brainMap.Current{handles.listbox.Value(2) - 1}.Data));
    handles.dim3Min.String = num2str(min(mainGuiData.brainMap.Current{handles.listbox.Value(3) - 1}.Data));
    handles.dim1Max.String = num2str(max(mainGuiData.brainMap.Current{handles.listbox.Value(1) - 1}.Data));
    handles.dim2Max.String = num2str(max(mainGuiData.brainMap.Current{handles.listbox.Value(2) - 1}.Data));
    handles.dim3Max.String = num2str(max(mainGuiData.brainMap.Current{handles.listbox.Value(3) - 1}.Data));
end
        
guidata(h(mainGuiNum), mainGuiData);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function dim1Min_Callback(hObject, eventdata, handles)
% hObject    handle to dim1Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dim1Min as text
%        str2double(get(hObject,'String')) returns contents of dim1Min as a double
handles = guidata(hObject);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function dim1Min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dim1Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function dim1Max_Callback(hObject, eventdata, handles)
% hObject    handle to dim1Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dim1Max as text
%        str2double(get(hObject,'String')) returns contents of dim1Max as a double
handles = guidata(hObject);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function dim1Max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dim1Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function dim2Min_Callback(hObject, eventdata, handles)
% hObject    handle to dim2Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dim2Min as text
%        str2double(get(hObject,'String')) returns contents of dim2Min as a double
handles = guidata(hObject);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function dim2Min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dim2Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function dim2Max_Callback(hObject, eventdata, handles)
% hObject    handle to dim2Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dim2Max as text
%        str2double(get(hObject,'String')) returns contents of dim2Max as a double
handles = guidata(hObject);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function dim2Max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dim2Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function cBins_Callback(hObject, eventdata, handles)
% hObject    handle to cBins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cBins as text
%        str2double(get(hObject,'String')) returns contents of cBins as a double
handles = guidata(hObject);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function cBins_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cBins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function opacity_Callback(hObject, eventdata, handles)
% hObject    handle to opacity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of opacity as text
%        str2double(get(hObject,'String')) returns contents of opacity as a double
handles = guidata(hObject);
try 
    handles.overlay.FaceAlpha = str2double(handles.opacity.String);
catch
    
end
guidata(hObject, handles);

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


function dim3Min_Callback(hObject, eventdata, handles)
% hObject    handle to dim3Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dim3Min as text
%        str2double(get(hObject,'String')) returns contents of dim3Min as a double


% --- Executes during object creation, after setting all properties.
function dim3Min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dim3Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function dim3Max_Callback(hObject, eventdata, handles)
% hObject    handle to dim3Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dim3Max as text
%        str2double(get(hObject,'String')) returns contents of dim3Max as a double


% --- Executes during object creation, after setting all properties.
function dim3Max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dim3Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cubeSide.
function cubeSide_Callback(hObject, eventdata, handles)
% hObject    handle to cubeSide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cubeSide contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cubeSide


% --- Executes during object creation, after setting all properties.
function cubeSide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cubeSide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in patchCube.
function patchCube_Callback(hObject, eventdata, handles)
% hObject    handle to patchCube (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of patchCube

function cubeSz_Callback(hObject, eventdata, handles)
% hObject    handle to cubeSz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cubeSz as text
%        str2double(get(hObject,'String')) returns contents of cubeSz as a double

% --- Executes during object creation, after setting all properties.
function cubeSz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cubeSz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox7
handles = guidata(hObject);

backup = handles.dim1Min.String;
backup2 = handles.dim1Max.String;
handles.dim1Min.String = handles.dim2Min.String;
handles.dim1Max.String = handles.dim2Max.String;
handles.dim2Min.String = backup;
handles.dim2Max.String = backup2;

guidata(hObject, handles);

% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox8
handles = guidata(hObject);

backup = handles.dim1Min.String;
backup2 = handles.dim1Max.String;
handles.dim1Min.String = handles.dim3Min.String;
handles.dim1Max.String = handles.dim3Max.String;
handles.dim3Min.String = backup;
handles.dim3Max.String = backup2;

guidata(hObject, handles);

% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox9
handles = guidata(hObject);

backup = handles.dim2Min.String;
backup2 = handles.dim2Max.String;
handles.dim2Min.String = handles.dim3Min.String;
handles.dim2Max.String = handles.dim3Max.String;
handles.dim3Min.String = backup;
handles.dim3Max.String = backup2;

guidata(hObject, handles);
