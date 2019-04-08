function varargout = multiOverlayGUI(varargin)
% GUI to control lighting of underlays and overlays
% Alex Teghipco // alex.teghipco@uci.edu // 11/28/18

% Last Modified by GUIDE v2.5 29-Mar-2019 17:10:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @multiOverlayGUI_OpeningFcn, ...
    'gui_OutputFcn',  @multiOverlayGUI_OutputFcn, ...
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


% --- Executes just before multiOverlayGUI is made visible.
function multiOverlayGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to multiOverlayGUI (see VARARGIN)

% Choose default command line output for multiOverlayGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

h = get(0,'Children');
% find brain surfer
for hi = 1:length(h)
    if strcmp(h(hi).Name,'Brain Surfer') == 1
        mainGuiNum = hi;
    end
end

% get data from brain surfer
mainGuiData = guidata(h(mainGuiNum));
handles.selectButton.String = vertcat({handles.selectButton.String},extractfield([mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}],'name')');

handles.mainSelections = mainGuiData.overlaySelection.Value - 1;

guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = multiOverlayGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in applyButton.
function applyButton_Callback(hObject, eventdata, handles)
% hObject    handle to applyButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.selectButton.Value ~= 1
    handles.output = hObject;
    handles = guidata(hObject);
    h = get(0,'Children');
    % find brain surfer
    for hi = 1:length(h)
        if strcmp(h(hi).Name,'Brain Surfer') == 1
            mainGuiNum = hi;
        end
    end
    
    % get data from brain surfer
    mainGuiData = guidata(h(mainGuiNum));
    
    % update variables that can be overwritten in the main GUI
    if handles.vertexTrans.Value == 1 % if you are interpolating data
        mainGuiData.brainMap.overlay{handles.mainSelections(handles.selectButton.Value - 1)}.FaceAlpha = 'interp';
        
        % now change opacity
        if str2double(handles.maxOpacity.String) == 0 % make sure you're not changing it to zero
            handles.maxOpacity.String = '0.00001';
        end
        
        % save opacity to mainGUI 
        mainGuiData.brainMap.Current{handles.mainSelections(handles.selectButton.Value - 1)}.opacity = str2double(handles.maxOpacity.String);

        % update overlay
        maxVal = max(mainGuiData.brainMap.overlay{handles.mainSelections(handles.selectButton.Value - 1)}.FaceVertexAlphaData);
        if maxVal < 62
            mulFac = 62/maxVal;
        else
            mulFac = 1;
        end
        
        mainGuiData.brainMap.overlay{handles.mainSelections(handles.selectButton.Value - 1)}.FaceVertexAlphaData = (mainGuiData.brainMap.overlay{handles.mainSelections(handles.selectButton.Value - 1)}.FaceVertexAlphaData) * (str2double(handles.maxOpacity.String) * mulFac);
    else % if you are not interpolating data
        mainGuiData.brainMap.Current{handles.mainSelections(handles.selectButton.Value - 1)}.opacity = str2double(handles.maxOpacity.String); % save to GUI
        mainGuiData.brainMap.overlay{handles.mainSelections(handles.selectButton.Value - 1)}.FaceAlpha = str2double(handles.maxOpacity.String); % update overlay
    end
        
    % update variables that can't be overwritten in the main GUI 
    if strcmp(handles.edgeAlpha.String,'interp') || strcmp(handles.edgeAlpha.String,'flat') || strcmp(handles.edgeAlpha.String,'none')
        mainGuiData.brainMap.overlay{handles.mainSelections(handles.selectButton.Value - 1)}.EdgeAlpha = handles.edgeAlpha.String;
    else
        try
            mainGuiData.brainMap.overlay{handles.mainSelections(handles.selectButton.Value - 1)}.EdgeAlpha = str2double(handles.edgeAlpha.String);
        catch
            warndlg('Edge alpha is not acceptable');
        end
    end
    
    if strcmp(handles.edgeColor.String,'interp') || strcmp(handles.edgeColor.String,'flat') || strcmp(handles.edgeColor.String,'none')
        mainGuiData.brainMap.overlay{handles.mainSelections(handles.selectButton.Value - 1)}.EdgeColor = handles.edgeColor.String;
    else
        try
            mainGuiData.brainMap.overlay{handles.mainSelections(handles.selectButton.Value - 1)}.EdgeColor = str2double(handles.edgeColor.String);
        catch
            warndlg('Edge color is not acceptable');
        end
    end
    
    try
        mainGuiData.brainMap.overlay{handles.mainSelections(handles.selectButton.Value - 1)}.LineWidth = str2double(handles.lineWidth.String);
    catch
        warndlg('Line width is not acceptable');
    end
    
    try
        mainGuiData.brainMap.overlay{handles.mainSelections(handles.selectButton.Value - 1)}.LineStyle = handles.lineStyle.String;
    catch
        warndlg('Line style is not acceptable');
    end
    
    guidata(h(mainGuiNum), mainGuiData);
    figure(mainGuiData.brainFig)

end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function selectButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function maxOpacity_Callback(hObject, eventdata, handles)
% hObject    handle to maxOpacity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxOpacity as text
%        str2double(get(hObject,'String')) returns contents of maxOpacity as a double


% --- Executes during object creation, after setting all properties.
function maxOpacity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxOpacity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edgeAlpha_Callback(hObject, eventdata, handles)
% hObject    handle to edgeAlpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edgeAlpha as text
%        str2double(get(hObject,'String')) returns contents of edgeAlpha as a double

% --- Executes during object creation, after setting all properties.
function edgeAlpha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edgeAlpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edgeColor_Callback(hObject, eventdata, handles)
% hObject    handle to edgeColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edgeColor as text
%        str2double(get(hObject,'String')) returns contents of edgeColor as a double

% --- Executes during object creation, after setting all properties.
function edgeColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edgeColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function lineWidth_Callback(hObject, eventdata, handles)
% hObject    handle to lineWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lineWidth as text
%        str2double(get(hObject,'String')) returns contents of lineWidth as a double

% --- Executes during object creation, after setting all properties.
function lineWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lineWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in selectButton.
function selectButton_Callback(hObject, eventdata, handles)
% hObject    handle to selectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns selectButton contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectButton
if handles.selectButton.Value ~= 1
    handles.output = hObject;
    handles = guidata(hObject);
    h = get(0,'Children');
    % find brain surfer
    for hi = 1:length(h)
        if strcmp(h(hi).Name,'Brain Surfer') == 1
            mainGuiNum = hi;
        end
    end
    
    % get data from brain surfer
    mainGuiData = guidata(h(mainGuiNum));
    
    % write it into this gui
    fa = mainGuiData.brainMap.overlay{handles.mainSelections(handles.selectButton.Value - 1)}.FaceAlpha;
    if ischar(fa)
        handles.maxOpacity.String = num2str(mainGuiData.brainMap.Current{handles.mainSelections(handles.selectButton.Value - 1)}.opacity);
        handles.vertexTrans.Value = 1;
    else
        handles.maxOpacity.String = num2str(fa);
        handles.singleTrans.Value = 1;
    end
    
    ea = mainGuiData.brainMap.overlay{handles.mainSelections(handles.selectButton.Value - 1)}.EdgeAlpha;
    if ischar(ea)
        handles.edgeAlpha.String = ea;
    else
        handles.edgeAlpha.String = num2str(ea);
    end
    
    ec = mainGuiData.brainMap.overlay{handles.mainSelections(handles.selectButton.Value - 1)}.EdgeColor;
    if ischar(ec)
        handles.edgeColor.String = ec;
    else
        handles.edgeColor.String = num2str(ec);
    end

    lw = mainGuiData.brainMap.overlay{handles.mainSelections(handles.selectButton.Value - 1)}.LineWidth;
    if ischar(lw)
        handles.lineWidth.String = lw;
    else
        handles.lineWidth.String = num2str(lw);
    end

     ls = mainGuiData.brainMap.overlay{handles.mainSelections(handles.selectButton.Value - 1)}.LineStyle;
    if ischar(lw)
        handles.lineStyle.String = ls;
    end
end
guidata(hObject, handles);

function lineStyle_Callback(hObject, eventdata, handles)
% hObject    handle to lineStyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lineStyle as text
%        str2double(get(hObject,'String')) returns contents of lineStyle as a double


% --- Executes during object creation, after setting all properties.
function lineStyle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lineStyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
