function varargout = lightingGUI(varargin)
% GUI to control lighting of underlays and overlays
% Alex Teghipco // alex.teghipco@uci.edu // 11/28/18

% Last Modified by GUIDE v2.5 31-Mar-2019 00:20:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @lightingGUI_OpeningFcn, ...
    'gui_OutputFcn',  @lightingGUI_OutputFcn, ...
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


% --- Executes just before lightingGUI is made visible.
function lightingGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to lightingGUI (see VARARGIN)

% Choose default command line output for lightingGUI
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
handles.mainSelections = mainGuiData.overlaySelection.Value - 1;
handles.cameras = mainGuiData.cameras;
handles.materials = mainGuiData.materials;
handles.lightType = mainGuiData.lightType;

% load all settings from underlay
uHemis = fieldnames(mainGuiData.underlay);
handles.underlayLoaded.SpecularColorReflectance = mainGuiData.underlay.(uHemis{1}).SpecularColorReflectance;
handles.underlayLoaded.SpecularExponent = mainGuiData.underlay.(uHemis{1}).SpecularExponent;
handles.underlayLoaded.SpecularStrength = mainGuiData.underlay.(uHemis{1}).SpecularStrength;
handles.underlayLoaded.AmbientStrength = mainGuiData.underlay.(uHemis{1}).AmbientStrength;
handles.underlayLoaded.DiffuseStrength = mainGuiData.underlay.(uHemis{1}).DiffuseStrength;
handles.underlayLoaded.FaceLighting = mainGuiData.underlay.(uHemis{1}).FaceLighting;

if handles.underlayButton.Value == 1
    handles.specularReflectance.String{1} = handles.underlayLoaded.SpecularColorReflectance;
    handles.specularExponent.String{1} = handles.underlayLoaded.SpecularExponent;
    handles.specularStrength.String{1} = handles.underlayLoaded.SpecularStrength;
    handles.ambientStrength.String{1} = handles.underlayLoaded.AmbientStrength;
    handles.diffusionStrength.String{1} = handles.underlayLoaded.DiffuseStrength;
end

% now check to see if there is only one overlay
if length(handles.mainSelections) == 1 && handles.mainSelections ~= 0 && isfield(mainGuiData.brainMap,'overlay')
    if isvalid(mainGuiData.brainMap.overlay)
        % if so, load all settings from that overlay as long as it's not 'no
        % overlay'
        handles.overlayLoaded.SpecularColorReflectance = mainGuiData.brainMap.overlay.SpecularColorReflectance;
        handles.overlayLoaded.SpecularExponent = mainGuiData.brainMap.overlay.SpecularExponent;
        handles.overlayLoaded.SpecularStrength = mainGuiData.brainMap.overlay.SpecularStrength;
        handles.overlayLoaded.AmbientStrength = mainGuiData.brainMap.overlay.AmbientStrength;
        handles.overlayLoaded.DiffuseStrength = mainGuiData.brainMap.overlay.DiffuseStrength;
        handles.overlayLoaded.FaceLighting = mainGuiData.brainMap.overlay.FaceLighting;
        
        if handles.overlayButton.Value == 1
            handles.specularReflectance.String{1} = handles.overlayLoaded.SpecularColorReflectance;
            handles.specularExponent.String{1} = handles.overlayLoaded.SpecularExponent;
            handles.specularStrength.String{1} = handles.overlayLoaded.SpecularStrength;
            handles.ambientStrength.String{1} = handles.overlayLoaded.AmbientStrength;
            handles.diffusionStrength.String{1} = handles.overlayLoaded.DiffuseStrength;
        end
    end
elseif length(handles.mainSelections) > 1
    % if there are multiple underlays, then load all settings from overlay
    % that would end up on top
    handles.overlayLoaded.SpecularColorReflectance = mainGuiData.brainMap.overlay{mainGuiData.overlaySelection.Value(end) - 1}.SpecularColorReflectance;
    handles.overlayLoaded.SpecularExponent = mainGuiData.brainMap.overlay{mainGuiData.overlaySelection.Value(end) - 1}.SpecularExponent;
    handles.overlayLoaded.SpecularStrength = mainGuiData.brainMap.overlay{mainGuiData.overlaySelection.Value(end) - 1}.SpecularStrength;
    handles.overlayLoaded.AmbientStrength = mainGuiData.brainMap.overlay{mainGuiData.overlaySelection.Value(end) - 1}.AmbientStrength;
    handles.overlayLoaded.DiffuseStrength = mainGuiData.brainMap.overlay{mainGuiData.overlaySelection.Value(end) - 1}.DiffuseStrength;
    handles.overlayLoaded.FaceLighting = mainGuiData.brainMap.overlay{mainGuiData.overlaySelection.Value(end) - 1}.FaceLighting;
    
    if handles.overlayButton.Value == 1
        handles.specularReflectance.String{1} = handles.overlayLoaded.SpecularColorReflectance;
        handles.specularExponent.String{1} = handles.overlayLoaded.SpecularExponent;
        handles.specularStrength.String{1} = handles.overlayLoaded.SpecularStrength;
        handles.ambientStrength.String{1} = handles.overlayLoaded.AmbientStrength;
        handles.diffusionStrength.String{1} = handles.overlayLoaded.DiffuseStrength;
    end   
end

% load camera settings
if cellfun(@isempty,handles.cameras) % if handles.cameras is an empty cell array
    handles.removeLights.Value = 1; % turn on no lights button
    handles.inferiorLightingButton.Value = 0;
    handles.superiorLight.Value = 0;
    handles.posteriorLight.Value = 0;
    handles.anteriorLight.Value = 0;
    handles.rightLateralLight.Value = 0;
    handles.leftLateralLight.Value = 0;    
else
    handles.removeLights.Value = 0;
    checkIdx = find(contains(handles.cameras,'ipsilateral'));
    if ~isempty(checkIdx)
        handles.leftLateralLight.Value = 1;
    end
    checkIdx = find(contains(handles.cameras,'contralateral'));
    if ~isempty(checkIdx)
        handles.rightLateralLight.Value = 1;
    end
    checkIdx = find(contains(handles.cameras,'anterior'));
    if ~isempty(checkIdx)
        handles.anteriorLight.Value = 1;
    end
    checkIdx = find(contains(handles.cameras,'posterior'));
    if ~isempty(checkIdx)
        handles.posteriorLight.Value = 1;
    end
    checkIdx = find(contains(handles.cameras,'superior'));
    if ~isempty(checkIdx)
        handles.superiorLight.Value = 1;
    end
    checkIdx = find(contains(handles.cameras,'flood'));
    if ~isempty(checkIdx)
        handles.inferiorLightingButton.Value = 1;
    end
end
    
% load material
if cellfun(@isempty,handles.materials) % if handles.cameras is an empty cell array
    handles.dullButton.Value = 1; 
    handles.shinyButton.Value = 0; 
    handles.flatButton.Value = 0; 
else
    checkIdx = find(contains(handles.materials,'dull'));
    if ~isempty(checkIdx)
        handles.dullButton.Value = 1;
    end
    checkIdx = find(contains(handles.materials,'shiny'));
    if ~isempty(checkIdx)
        handles.shinyButton.Value = 1;
    end
    checkIdx = find(contains(handles.materials,'metal'));
    if ~isempty(checkIdx)
        handles.flatButton.Value = 1;
    end
end

% load lighting
if cellfun(@isempty,handles.materials) % if handles.cameras is an empty cell array
    handles.flatLight.Value = 0;
    handles.nLight.Value = 1;
    handles.gLight.Value = 0;
    
else 
    checkIdx = find(contains(handles.lightType,'flat'));
    if ~isempty(checkIdx)
        handles.flatLight.Value = 1;
    end
    checkIdx = find(contains(handles.lightType,'gourard'));
    if ~isempty(checkIdx)
        handles.gLight.Value = 1;
    end
    checkIdx = find(contains(handles.lightType,'none'));
    if ~isempty(checkIdx)
        handles.nLight.Value = 1;
    end
end

guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = lightingGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in anteriorLight.
function anteriorLight_Callback(hObject, eventdata, handles)
% hObject    handle to anteriorLight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of anteriorLight
handles.output = hObject;
if handles.anteriorLight.Value == 1
    handles.removeLights.Value = 0;
end

lightCount = handles.inferiorLightingButton.Value + handles.rightLateralLight.Value + handles.superiorLight.Value + handles.leftLateralLight.Value + handles.posteriorLight.Value + handles.anteriorLight.Value;
if lightCount > 4
    handles.anteriorLight.Value = 0;
    warndlg('A maximum of 4 lights is allowed','Error')
end
guidata(hObject, handles);

% --- Executes on button press in posteriorLight.
function posteriorLight_Callback(hObject, eventdata, handles)
% hObject    handle to posteriorLight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;
if handles.posteriorLight.Value == 1
    handles.removeLights.Value = 0;
end

lightCount = handles.inferiorLightingButton.Value + handles.rightLateralLight.Value + handles.superiorLight.Value + handles.leftLateralLight.Value + handles.posteriorLight.Value + handles.anteriorLight.Value;
if lightCount > 4
    handles.posteriorLight.Value = 0;
    warndlg('A maximum of 4 lights is allowed','Error')
end
guidata(hObject, handles);

% --- Executes on button press in leftLateralLight.
function leftLateralLight_Callback(hObject, eventdata, handles)
% hObject    handle to leftLateralLight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;
if handles.leftLateralLight.Value == 1
    handles.removeLights.Value = 0;
end

lightCount = handles.inferiorLightingButton.Value + handles.rightLateralLight.Value + handles.superiorLight.Value + handles.leftLateralLight.Value + handles.posteriorLight.Value + handles.anteriorLight.Value;
if lightCount > 4
    handles.leftLateralLight.Value = 0;
    warndlg('A maximum of 4 lights is allowed','Error')
end
guidata(hObject, handles);

% --- Executes on button press in superiorLight.
function superiorLight_Callback(hObject, eventdata, handles)
% hObject    handle to superiorLight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;
if handles.superiorLight.Value == 1
    handles.removeLights.Value = 0;
end

lightCount = handles.inferiorLightingButton.Value + handles.rightLateralLight.Value + handles.superiorLight.Value + handles.leftLateralLight.Value + handles.posteriorLight.Value + handles.anteriorLight.Value;
if lightCount > 4
    handles.superiorLight.Value = 0;
    warndlg('A maximum of 4 lights is allowed','Error')
end
guidata(hObject, handles);

% --- Executes on button press in rightLateralLight.
function rightLateralLight_Callback(hObject, eventdata, handles)
% hObject    handle to rightLateralLight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;
if handles.rightLateralLight.Value == 1
    handles.removeLights.Value = 0;
end

lightCount = handles.inferiorLightingButton.Value + handles.rightLateralLight.Value + handles.superiorLight.Value + handles.leftLateralLight.Value + handles.posteriorLight.Value + handles.anteriorLight.Value;
if lightCount > 4
    handles.rightLateralLight.Value = 0;
    warndlg('A maximum of 4 lights is allowed','Error')
end
guidata(hObject, handles);

% --- Executes on button press in inferiorLightingButton.
function inferiorLightingButton_Callback(hObject, eventdata, handles)
% hObject    handle to inferiorLightingButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;
if handles.inferiorLightingButton.Value == 1
    handles.removeLights.Value = 0;
end

lightCount = handles.inferiorLightingButton.Value + handles.rightLateralLight.Value + handles.superiorLight.Value + handles.leftLateralLight.Value + handles.posteriorLight.Value + handles.anteriorLight.Value;
if lightCount > 4
    handles.inferiorLightingButton.Value = 0;
    warndlg('A maximum of 4 lights is allowed','Error')
end
guidata(hObject, handles);

% --- Executes on button press in removeLights.
function removeLights_Callback(hObject, eventdata, handles)
% hObject    handle to removeLights (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;
if handles.removeLights.Value == 1
    handles.inferiorLightingButton.Value = 0;
    handles.superiorLight.Value = 0;
    handles.posteriorLight.Value = 0;
    handles.anteriorLight.Value = 0;
    handles.rightLateralLight.Value = 0;
    handles.leftLateralLight.Value = 0;  
end
guidata(hObject, handles);

% --- Executes on button press in dullButton.
function dullButton_Callback(hObject, eventdata, handles)
% hObject    handle to dullButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;
if handles.dullButton.Value == 1
    handles.shinyButton.Value = 0;
    handles.flatButton.Value = 0;
end
guidata(hObject, handles);

% --- Executes on button press in shinyButton.
function shinyButton_Callback(hObject, eventdata, handles)
% hObject    handle to shinyButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;
if handles.shinyButton.Value == 1
    handles.dullButton.Value = 0;
    handles.flatButton.Value = 0;
end
guidata(hObject, handles);

% --- Executes on button press in flatButton.
function flatButton_Callback(hObject, eventdata, handles)
% hObject    handle to flatButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;
if handles.flatButton.Value == 1
    handles.dullButton.Value = 0;
    handles.shinyButton.Value = 0;
end
guidata(hObject, handles);

function specularExponent_Callback(hObject, eventdata, handles)
% hObject    handle to specularExponent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;
if str2double(handles.specularExponent.String) <= 0
    handles.specularExponent.String = '0.001';
end

if handles.underlayButton.Value == 1
    handles.underlayLoaded.SpecularExponent = str2double(handles.specularExponent.String);
elseif handles.overlayButton.Value == 1
    handles.overlayLoaded.SpecularExponent = str2double(handles.specularExponent.String);
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function specularExponent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to specularExponent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function specularStrength_Callback(hObject, eventdata, handles)
% hObject    handle to specularStrength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;
if handles.underlayButton.Value == 1
    handles.underlayLoaded.SpecularStrength = str2double(handles.specularStrength.String);
elseif handles.overlayButton.Value == 1
    handles.overlayLoaded.SpecularStrength = str2double(handles.specularStrength.String);
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function specularStrength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to specularStrength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ambientStrength_Callback(hObject, eventdata, handles)
% hObject    handle to ambientStrength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;
if handles.underlayButton.Value == 1
    handles.underlayLoaded.AmbientStrength = str2double(handles.ambientStrength.String);
elseif handles.overlayButton.Value == 1
    handles.overlayLoaded.AmbientStrength = str2double(handles.ambientStrength.String);
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ambientStrength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ambientStrength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function specularReflectance_Callback(hObject, eventdata, handles)
% hObject    handle to specularReflectance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;

if str2double(handles.specularReflectance.String) > 1
    handles.specularReflectance.String = '1';
elseif str2double(handles.specularReflectance.String) < 0
    handles.specularReflectance.String = '0';
end

if handles.underlayButton.Value == 1
    handles.underlayLoaded.SpecularColorReflectance = str2double(handles.specularReflectance.String);
elseif handles.overlayButton.Value == 1
    handles.overlayLoaded.SpecularColorReflectance = str2double(handles.specularReflectance.String);
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function specularReflectance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to specularReflectance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function diffusionStrength_Callback(hObject, eventdata, handles)
% hObject    handle to diffusionStrength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;
if handles.underlayButton.Value == 1
    handles.underlayLoaded.DiffuseStrength = str2double(handles.diffusionStrength.String);
elseif handles.overlayButton.Value == 1
    handles.overlayLoaded.DiffuseStrength = str2double(handles.diffusionStrength.String);
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function diffusionStrength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to diffusionStrength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in colorEdit.
function underlayButton_Callback(hObject, eventdata, handles)
% hObject    handle to colorEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% close everything
% close figure
handles.output = hObject;
% load all settings from underlay
handles.specularReflectance.String = handles.underlayLoaded.SpecularColorReflectance;
handles.specularExponent.String = handles.underlayLoaded.SpecularExponent;
handles.specularStrength.String = handles.underlayLoaded.SpecularStrength;
handles.ambientStrength.String = handles.underlayLoaded.AmbientStrength;
handles.diffusionStrength.String = handles.underlayLoaded.DiffuseStrength;
guidata(hObject, handles);

% --- Executes on button press in colorEdit.
function overlayButton_Callback(hObject, eventdata, handles)
% hObject    handle to colorEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% close everything
% close figure
handles.output = hObject;
% load all settings from overlay
handles.specularReflectance.String = handles.overlayLoaded.SpecularColorReflectance;
handles.specularExponent.String = handles.overlayLoaded.SpecularExponent;
handles.specularStrength.String = handles.overlayLoaded.SpecularStrength;
handles.ambientStrength.String = handles.overlayLoaded.AmbientStrength;
handles.diffusionStrength.String = handles.overlayLoaded.DiffuseStrength;
guidata(hObject, handles);

% --- Executes on button press in colorEdit.
function colorEdit_Callback(hObject, eventdata, handles)
% hObject    handle to colorEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% close everything
% close figure
handles.output = hObject;
h = get(0,'Children');
% find brain surfer
for hi = 1:length(h)
    if strcmp(h(hi).Name,'Brain Surfer') == 1
        mainGuiNum = hi;
    end
end
mainGuiData = guidata(h(mainGuiNum));
newColor = uisetcolor([1 1 0],'Select a color for the lighting');

aLights = findall(mainGuiData.brainFig,'Type','light');
for i = 1:length(aLights)
    aLights(i).Color = newColor;
end

guidata(hObject, handles);

% --- Executes on button press in applyButton.
function applyButton_Callback(hObject, eventdata, handles)
% hObject    handle to applyButton (see GCBO)
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
mainGuiData = guidata(h(mainGuiNum));

% delete lights only if you have now hit none, or if the saved lights don't
% match the ones you want   

delete(findall(mainGuiData.brainFig,'Type','light'))
  
% add lights/materials and save to mainGUI
% remove colorbar
% remove colorbar if it exists
if isfield(mainGuiData.brainMap,'colorbar')
    delete(mainGuiData.brainMap.colorbar)
    mainGuiData.brainMap = rmfield(mainGuiData.brainMap,'colorbar');
    replot = 1;
else
    replot = 0;
end

mainGuiData.cameras = cell(0);

% add lights and save to mainGUI
if handles.leftLateralLight.Value == 1
    figure(mainGuiData.brainFig)
    temp = camlight(0,0);
    mainGuiData.cameras = vertcat(mainGuiData.cameras,'ipsilateral');
end

if handles.rightLateralLight.Value == 1
    figure(mainGuiData.brainFig)
    temp = camlight(180,0);
    mainGuiData.cameras = vertcat(mainGuiData.cameras,'contralateral');
end

if handles.anteriorLight.Value == 1
    figure(mainGuiData.brainFig)
    temp = camlight(-90,0);
    mainGuiData.cameras = vertcat(mainGuiData.cameras,'anterior');
end

if handles.posteriorLight.Value == 1
    figure(mainGuiData.brainFig)
    temp = camlight(90,0);
    mainGuiData.cameras = vertcat(mainGuiData.cameras,'posterior');
end

if handles.superiorLight.Value == 1
    figure(mainGuiData.brainFig)
    temp = camlight(180,90);
    mainGuiData.cameras = vertcat(mainGuiData.cameras,'superior');
end

if handles.inferiorLightingButton.Value == 1
    figure(mainGuiData.brainFig)
    temp = camlight(180,180);
    temp2 = camlight(0,180);
    mainGuiData.cameras = vertcat(mainGuiData.cameras,'flood');
end

if handles.removeLights.Value == 1
    mainGuiData.cameras = cell(1);
end

% remove any empty cells from lighting
if length(mainGuiData.cameras) > 1
    mainGuiData.cameras = mainGuiData.cameras(~cellfun('isempty', mainGuiData.cameras));
end

% change material and save to mainGUI
if handles.dullButton.Value == 1
    figure(mainGuiData.brainFig)
    material dull
    mainGuiData.materials{1} = 'dull';
end

if handles.shinyButton.Value == 1
    figure(mainGuiData.brainFig)
    material shiny
    mainGuiData.materials{1} = 'shiny';
end

if handles.flatButton.Value == 1
    figure(mainGuiData.brainFig)
    material metal
    mainGuiData.materials{1} = 'metal';
end

% update light properties
%if handles.underlayButton.Value == 1
    % update figure light properties
    hemiU = fieldnames(mainGuiData.underlay);
    for hemii = 1:length(hemiU)
        mainGuiData.underlay.(hemiU{hemii}).SpecularStrength = handles.underlayLoaded.SpecularStrength;
        mainGuiData.underlay.(hemiU{hemii}).SpecularExponent = handles.underlayLoaded.SpecularExponent;
        mainGuiData.underlay.(hemiU{hemii}).SpecularColorReflectance = handles.underlayLoaded.SpecularColorReflectance;
        mainGuiData.underlay.(hemiU{hemii}).DiffuseStrength = handles.underlayLoaded.DiffuseStrength;
        mainGuiData.underlay.(hemiU{hemii}).AmbientStrength = handles.underlayLoaded.AmbientStrength;
    end
%elseif handles.overlayButton.Value == 1
    if isfield(mainGuiData.brainMap,'overlay')
        % loop over overlays
        for overlayi = 1:length(mainGuiData.brainMap.overlay)
            try
                mainGuiData.brainMap.overlay.SpecularStrength = handles.overlayLoaded.SpecularStrength;
                mainGuiData.brainMap.overlay.SpecularExponent = handles.overlayLoaded.SpecularExponent;
                mainGuiData.brainMap.overlay.SpecularColorReflectance = handles.overlayLoaded.SpecularColorReflectance;
                mainGuiData.brainMap.overlay.DiffuseStrength = handles.overlayLoaded.DiffuseStrength;
                mainGuiData.brainMap.overlay.AmbientStrength = handles.overlayLoaded.AmbientStrength;
            catch
                try
                    mainGuiData.brainMap.overlay{overlayi}.SpecularStrength = handles.overlayLoaded.SpecularStrength;
                    mainGuiData.brainMap.overlay{overlayi}.SpecularExponent = handles.overlayLoaded.SpecularExponent;
                    mainGuiData.brainMap.overlay{overlayi}.SpecularColorReflectance = handles.overlayLoaded.SpecularColorReflectance;
                    mainGuiData.brainMap.overlay{overlayi}.DiffuseStrength = handles.overlayLoaded.DiffuseStrength;
                    mainGuiData.brainMap.overlay{overlayi}.AmbientStrength = handles.overlayLoaded.AmbientStrength;
                catch
                end
            end
        end
    end
%end

% update light properties
if handles.flatLight.Value == 1
    figure(mainGuiData.brainFig)
    lighting flat
    mainGuiData.lightType{1} = 'flat';
end

if handles.nLight.Value == 1
    figure(mainGuiData.brainFig)
    lighting none
    mainGuiData.lightType{1} = 'none';
end

if handles.gLight.Value == 1
    figure(mainGuiData.brainFig)
    lighting gouraud
    mainGuiData.lightType{1} = 'gourard';
end

% replot colorbar
if replot == 1
    mainGuiData.brainMap.colorbar = cbar;
    mainGuiData.brainMap.colorbar.TickLength = [0 0];
    imh = mainGuiData.brainMap.colorbar.Children(1);
    imh.AlphaData = mainGuiData.opts.transparencyData;
    imh.AlphaDataMapping = 'direct';
    
    if mainGuiData.colormapSpacing.Value == 4 || mainGuiData.colormapSpacing.Value == 3
        mainGuiData.brainMap.colorbar.YTick = mainGuiData.opts.ticks;
        mainGuiData.brainMap.colorbar.YTickLabel = mainGuiData.opts.tickLabels;
    end
end

guidata(h(mainGuiNum), mainGuiData);
guidata(hObject, handles);

% --- Executes on selection change in presetButton.
function presetButton_Callback(hObject, eventdata, handles)
% hObject    handle to presetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns presetButton contents as cell array
%        contents{get(hObject,'Value')} returns selected item from presetButton
handles.output = hObject;
curr = handles.presetButton.String{handles.presetButton.Value};

handles.output = hObject;
h = get(0,'Children');
% find brain surfer
for hi = 1:length(h)
    if strcmp(h(hi).Name,'Brain Surfer') == 1
        mainGuiNum = hi;
    end
end
mainGuiData = guidata(h(mainGuiNum));

switch curr
    %% underlays
    case ['Alex' '''' 's default']
        
        % update handles
        if handles.underlayButton.Value == 1
            handles.specularStrength.String = '0';
            handles.specularExponent.String = '10';
            handles.specularReflectance.String = '1';
            handles.diffusionStrength.String = '0.85';
            handles.ambientStrength.String = '0.5';
        end
        
        handles.underlayLoaded.SpecularStrength = 0;
        handles.underlayLoaded.SpecularExponent = 10;
        handles.underlayLoaded.SpecularColorReflectance = 1;
        handles.underlayLoaded.DiffuseStrength = 0.85;
        handles.underlayLoaded.AmbientStrength = 0.5;
        
        % set material
        handles.flatButton.Value = 0;
        handles.shinyButton.Value = 0;
        handles.dullButton.Value = 1;
        
        % set light
        handles.flatLight.Value = 1;
        handles.gLight.Value = 0;
        handles.nLight.Value = 0;
        
        handles.anteriorLight.Value = 0;
        handles.posteriorLight.Value = 0;
        handles.leftLateralLight.Value = 0;
        handles.rightLateralLight.Value = 0;
        handles.inferiorLightingButton.Value = 1;
        handles.superiorLight.Value = 0;
        handles.removeLights.Value = 0;
        
    case 'Bright contrast'
        % update handles
        if handles.underlayButton.Value == 1
            handles.specularReflectance.String = '0';
            handles.specularExponent.String = '10';
            handles.specularStrength.String = '0';
            handles.diffusionStrength.String = '0.8';
            handles.ambientStrength.String = '0.3';
        end
        
        handles.underlayLoaded.SpecularColorReflectance = 0;
        handles.underlayLoaded.SpecularExponent = 10;
        handles.underlayLoaded.SpecularStrength = 0;
        handles.underlayLoaded.DiffuseStrength = 0.8;
        handles.underlayLoaded.AmbientStrength = 0.3;
        
        % set material
        handles.flatButton.Value = 0;
        handles.shinyButton.Value = 0;
        handles.dullButton.Value = 1;
        
        % set light
        handles.flatLight.Value = 1;
        handles.gLight.Value = 0;
        handles.nLight.Value = 0;
        
        handles.anteriorLight.Value = 0;
        handles.posteriorLight.Value = 0;
        handles.leftLateralLight.Value = 0;
        handles.rightLateralLight.Value = 0;
        handles.inferiorLightingButton.Value = 1;
        handles.superiorLight.Value = 1;
        handles.removeLights.Value = 0;
        
    case 'True default (bright)'
        % update handles
        if handles.underlayButton.Value == 1
            handles.specularReflectance.String = '0.2';
            handles.specularExponent.String = '1';
            handles.specularStrength.String = '0.01';
            handles.diffusionStrength.String = '0.3';
            handles.ambientStrength.String = '0.7';
        end
        
        handles.underlayLoaded.SpecularColorReflectance = 0.2;
        handles.underlayLoaded.SpecularExponent = 1;
        handles.underlayLoaded.SpecularStrength = 0.01;
        handles.underlayLoaded.DiffuseStrength = 0.3;
        handles.underlayLoaded.AmbientStrength = 0.7;
        
        % set material
        handles.flatButton.Value = 0;
        handles.shinyButton.Value = 0;
        handles.dullButton.Value = 1;
        
        % set light
        handles.flatLight.Value = 1;
        handles.gLight.Value = 0;
        handles.nLight.Value = 0;
        
        handles.anteriorLight.Value = 1;
        handles.posteriorLight.Value = 1;
        handles.leftLateralLight.Value = 1;
        handles.rightLateralLight.Value = 1;
        handles.inferiorLightingButton.Value = 0;
        handles.superiorLight.Value = 1;
        handles.removeLights.Value = 0;
        
    case 'True default (dark)'
        % update handles
        if handles.underlayButton.Value == 1
            handles.specularStrength.String = '0.01';
            handles.specularExponent.String = '1';
            handles.specularReflectance.String = '0.2';
            handles.diffusionStrength.String = '0.3';
            handles.ambientStrength.String = '0.2';
        end
        
        handles.underlayLoaded.SpecularStrength = 0.01;
        handles.underlayLoaded.SpecularExponent = 1;
        handles.underlayLoaded.SpecularColorReflectance = 0.2;
        handles.underlayLoaded.DiffuseStrength = 0.3;
        handles.underlayLoaded.AmbientStrength = 0.2;
        
        % set material
        handles.flatButton.Value = 0;
        handles.shinyButton.Value = 0;
        handles.dullButton.Value = 1;
        
        % set light
        handles.flatLight.Value = 1;
        handles.gLight.Value = 0;
        handles.nLight.Value = 0;
        
        handles.anteriorLight.Value = 0;
        handles.posteriorLight.Value = 0;
        handles.leftLateralLight.Value = 1;
        handles.rightLateralLight.Value = 1;
        handles.inferiorLightingButton.Value = 0;
        handles.superiorLight.Value = 1;
        handles.removeLights.Value = 0;
        
    case 'Dramatic (bright)'
        % update handles
        if handles.underlayButton.Value == 1
            handles.specularStrength.String = '0.2';
            handles.underlayLoaded.SpecularStrength = 0.2;
            handles.specularExponent.String = '2';
            handles.underlayLoaded.SpecularExponent = 2;
            handles.specularReflectance.String = '0.5';
            handles.underlayLoaded.SpecularColorReflectance = 0.5;
            handles.diffusionStrength.String = '0.6';
            handles.underlayLoaded.DiffuseStrength = 0.6;
            handles.ambientStrength.String = '0.4';
            handles.underlayLoaded.AmbientStrength = 0.4;
        end
        
        % set material
        handles.flatButton.Value = 0;
        handles.shinyButton.Value = 1;
        handles.dullButton.Value = 0;
        
        % set light
        handles.flatLight.Value = 1;
        handles.gLight.Value = 0;
        handles.nLight.Value = 0;
        
        handles.anteriorLight.Value = 1;
        handles.posteriorLight.Value = 1;
        handles.leftLateralLight.Value = 1;
        handles.superiorLight.Value = 1;
        handles.rightLateralLight.Value = 1;
        handles.inferiorLightingButton.Value = 0;
        handles.removeLights.Value = 0;
        
    case 'Dramatic (dark)'
        % update handles
        if handles.underlayButton.Value == 1
            handles.specularStrength.String = '0.2';
            handles.specularExponent.String = '2';
            handles.specularReflectance.String = '0.5';
            handles.diffusionStrength.String = '0.6';
            handles.ambientStrength.String = '0.2';
        end
        
        handles.underlayLoaded.SpecularStrength = 0.2;
        handles.underlayLoaded.SpecularExponent = 2;
        handles.underlayLoaded.SpecularColorReflectance = 0.5;
        handles.underlayLoaded.DiffuseStrength = 0.6;
        handles.underlayLoaded.AmbientStrength = 0.2;
        
        % set material
        handles.flatButton.Value = 0;
        handles.shinyButton.Value = 1;
        handles.dullButton.Value = 0;
        
        % set light
        handles.flatLight.Value = 1;
        handles.gLight.Value = 0;
        handles.nLight.Value = 0;
        
        handles.anteriorLight.Value = 0;
        handles.posteriorLight.Value = 0;
        handles.leftLateralLight.Value = 1;
        handles.superiorLight.Value = 0;
        handles.rightLateralLight.Value = 1;
        handles.inferiorLightingButton.Value = 0;
        handles.removeLights.Value = 0;
        
    case 'Dramatic2 (dark)'
        % update handles
        if handles.underlayButton.Value == 1
            handles.specularStrength.String = '0.1';
            handles.specularExponent.String = '2';
            handles.specularReflectance.String = '0.2';
            handles.diffusionStrength.String = '0.7';
            handles.ambientStrength.String = '0.2';
        end
        
        handles.underlayLoaded.SpecularStrength = 0.1;
        handles.underlayLoaded.SpecularExponent = 2;
        handles.underlayLoaded.SpecularColorReflectance = 0.2;
        handles.underlayLoaded.DiffuseStrength = 0.7;
        handles.underlayLoaded.AmbientStrength = 0.2;
        
        % set material
        handles.flatButton.Value = 0;
        handles.shinyButton.Value = 0;
        handles.dullButton.Value = 1;
        
        % set light
        handles.flatLight.Value = 1;
        handles.gLight.Value = 0;
        handles.nLight.Value = 0;
        
        handles.anteriorLight.Value = 1;
        handles.posteriorLight.Value = 1;
        handles.leftLateralLight.Value = 1;
        handles.superiorLight.Value = 0;
        handles.rightLateralLight.Value = 1;
        handles.inferiorLightingButton.Value = 0;
        handles.removeLights.Value = 0;
        
    case 'Subtle perisylvian (bright)'
        % update handles
        if handles.underlayButton.Value == 1
            handles.specularStrength.String = '0.2';
            handles.specularExponent.String = '4';
            handles.specularReflectance.String = '0.6';
            handles.diffusionStrength.String = '0.45';
            handles.ambientStrength.String = '0.35';
        end
        
        handles.underlayLoaded.SpecularStrength = 0.2;
        handles.underlayLoaded.SpecularExponent = 4;
        handles.underlayLoaded.SpecularColorReflectance = 0.6;
        handles.underlayLoaded.DiffuseStrength = 0.45;
        handles.underlayLoaded.AmbientStrength = 0.35;
        
        % set material
        handles.flatButton.Value = 0;
        handles.shinyButton.Value = 1;
        handles.dullButton.Value = 0;
        
        % set light
        handles.flatLight.Value = 1;
        handles.gLight.Value = 0;
        handles.nLight.Value = 0;
        
        handles.anteriorLight.Value = 1;
        handles.posteriorLight.Value = 1;
        handles.leftLateralLight.Value = 1;
        handles.superiorLight.Value = 1;
        handles.rightLateralLight.Value = 1;
        handles.inferiorLightingButton.Value = 0;
        handles.removeLights.Value = 0;
                
    case 'Subtle perisylvian (dark)'
        % update handles
        if handles.underlayButton.Value == 1
            handles.specularStrength.String = '0.1';
            handles.specularExponent.String = '3';
            handles.specularReflectance.String = '0.2';
            handles.diffusionStrength.String = '0.5';
            handles.ambientStrength.String = '0.2';
        end
        
        handles.underlayLoaded.SpecularStrength = 0.1;
        handles.underlayLoaded.SpecularExponent = 3;
        handles.underlayLoaded.SpecularColorReflectance = 0.2;
        handles.underlayLoaded.DiffuseStrength = 0.5;
        handles.underlayLoaded.AmbientStrength = 0.2;
        
        % set material
        handles.flatButton.Value = 0;
        handles.shinyButton.Value = 0;
        handles.dullButton.Value = 1;
        
        % set light
        handles.flatLight.Value = 1;
        handles.gLight.Value = 0;
        handles.nLight.Value = 0;
        
        handles.anteriorLight.Value = 1;
        handles.posteriorLight.Value = 1;
        handles.leftLateralLight.Value = 1;
        handles.superiorLight.Value = 1;
        handles.rightLateralLight.Value = 1;
        handles.inferiorLightingButton.Value = 0;
        handles.removeLights.Value = 0;
        
    case 'Subtler perisylvian (bright)'
        % update handles
        if handles.underlayButton.Value == 1
            handles.specularStrength.String = '0.1';
            handles.specularExponent.String = '2';
            handles.specularReflectance.String = '0.2';
            handles.diffusionStrength.String = '0.7';
            handles.ambientStrength.String = '0.2';
        end
        
        handles.underlayLoaded.SpecularStrength = 0.1;
        handles.underlayLoaded.SpecularExponent = 2;
        handles.underlayLoaded.SpecularColorReflectance = 0.2;
        handles.underlayLoaded.DiffuseStrength = 0.7;
        handles.underlayLoaded.AmbientStrength = 0.2;
        
        % set material
        handles.flatButton.Value = 0;
        handles.shinyButton.Value = 0;
        handles.dullButton.Value = 1;
        
        % set light
        handles.flatLight.Value = 1;
        handles.gLight.Value = 0;
        handles.nLight.Value = 0;
        
        handles.anteriorLight.Value = 1;
        handles.posteriorLight.Value = 1;
        handles.leftLateralLight.Value = 1;
        handles.superiorLight.Value = 1;
        handles.rightLateralLight.Value = 1;
        handles.inferiorLightingButton.Value = 0;
        handles.removeLights.Value = 0;
        
    case 'Polished Mirror'
        % update handles
        if handles.underlayButton.Value == 1
            handles.specularStrength.String = '0.5';
            handles.specularExponent.String = '30';
            handles.specularReflectance.String = '0.5';
            handles.diffusionStrength.String = '0.7';
            handles.ambientStrength.String = '0.1';
        end
        
        handles.underlayLoaded.SpecularStrength = 0.5;
        handles.underlayLoaded.SpecularExponent = 30;
        handles.underlayLoaded.SpecularColorReflectance = 0.5;
        handles.underlayLoaded.DiffuseStrength = 0.7;
        handles.underlayLoaded.AmbientStrength = 0.1;
        
        % set material
        handles.flatButton.Value = 1;
        handles.shinyButton.Value = 0;
        handles.dullButton.Value = 0;
        
          % set light
        handles.flatLight.Value = 1;
        handles.gLight.Value = 0;
        handles.nLight.Value = 0;
        
        handles.anteriorLight.Value = 1;
        handles.posteriorLight.Value = 1;
        handles.leftLateralLight.Value = 1;
        handles.superiorLight.Value = 1;
        handles.rightLateralLight.Value = 1;
        handles.inferiorLightingButton.Value = 0;
        handles.removeLights.Value = 0;
        
        %% overlays
    case ['Alex' '''' 's default (flat)']
        % update handles
        if handles.overlayButton.Value == 1
            handles.specularStrength.String = '0';
            handles.specularExponent.String = '1';
            handles.specularReflectance.String = '0';
            handles.diffusionStrength.String = '0.3';
            handles.ambientStrength.String = '0.8';
        end
        
        handles.overlayLoaded.SpecularStrength = 0;
        handles.overlayLoaded.SpecularExponent = 1;
        handles.overlayLoaded.SpecularColorReflectance = 0;
        handles.overlayLoaded.DiffuseStrength = 0.3;
        handles.overlayLoaded.AmbientStrength = 0.8;
        
    case 'True default (flat)'
        % update handles
        if handles.overlayButton.Value == 1
            handles.specularStrength.String = '0.6';
            handles.specularExponent.String = '1';
            handles.specularReflectance.String = '0.6';
            handles.diffusionStrength.String = '0.6';
            handles.ambientStrength.String = '0.3';
        end
        
        handles.overlayLoaded.SpecularStrength = 0.6;
        handles.overlayLoaded.SpecularExponent = 1;
        handles.overlayLoaded.SpecularColorReflectance = 0.6;
        handles.overlayLoaded.DiffuseStrength = 0.6;
        handles.overlayLoaded.AmbientStrength = 0.3;
        
    case 'True default (reflective)'
        % update handles
        if handles.overlayButton.Value == 1
            handles.specularStrength.String = '0.5';
            handles.specularExponent.String = '3';
            handles.specularReflectance.String = '0.1';
            handles.diffusionStrength.String = '0.6';
            handles.ambientStrength.String = '0.3';
        end
        
        handles.overlayLoaded.SpecularStrength = 0.5;
        handles.overlayLoaded.SpecularExponent = 3;
        handles.overlayLoaded.SpecularColorReflectance = 0.1;
        handles.overlayLoaded.DiffuseStrength = 0.6;
        handles.overlayLoaded.AmbientStrength = 0.3;
        
    case 'Flat with brighter edges'
        % update handles
        if handles.overlayButton.Value == 1
            handles.specularStrength.String = '0';
            handles.specularExponent.String = '1';
            handles.specularReflectance.String = '0.6';
            handles.diffusionStrength.String = '0.75';
            handles.ambientStrength.String = '0';
        end
        
        handles.overlayLoaded.SpecularStrength = 0;
        handles.overlayLoaded.SpecularExponent = 1;
        handles.overlayLoaded.SpecularColorReflectance = 0.6;
        handles.overlayLoaded.DiffuseStrength = 0.75;
        handles.overlayLoaded.AmbientStrength = 0;
        
    case 'Brighter flat'
        % update handles
        if handles.overlayButton.Value == 1
            handles.specularStrength.String = '0';
            handles.specularExponent.String = '1';
            handles.specularReflectance.String = '0.6';
            handles.diffusionStrength.String = '0';
            handles.ambientStrength.String = '1';
        end
        
        handles.overlayLoaded.SpecularStrength = 0;
        handles.overlayLoaded.SpecularExponent = 1;
        handles.overlayLoaded.SpecularColorReflectance = 0.6;
        handles.overlayLoaded.DiffuseStrength = 0;
        handles.overlayLoaded.AmbientStrength = 1;
        
    case 'Brightest flat'
        % update handles
        if handles.overlayButton.Value == 1
            handles.specularStrength.String = '0.0008';
            handles.specularExponent.String = '1';
            handles.specularReflectance.String = '1';
            handles.diffusionStrength.String = '0.001';
            handles.ambientStrength.String = '1';
        end
        
        handles.overlayLoaded.SpecularStrength = 0.008;
        handles.overlayLoaded.SpecularExponent = 1;
        handles.overlayLoaded.SpecularColorReflectance = 1;
        handles.overlayLoaded.DiffuseStrength = 0.001;
        handles.overlayLoaded.AmbientStrength = 1;
        
    case 'Desaturated'
        % update handles
        if handles.overlayButton.Value == 1
            handles.specularStrength.String = '0.1';
            handles.specularExponent.String = '2';
            handles.specularReflectance.String = '0.5';
            handles.diffusionStrength.String = '0.5';
            handles.ambientStrength.String = '0';
        end
        
        handles.overlayLoaded.SpecularStrength = 0.1;
        handles.overlayLoaded.SpecularExponent = 2;
        handles.overlayLoaded.SpecularColorReflectance = 0.5;
        handles.overlayLoaded.DiffuseStrength = 0.5;
        handles.overlayLoaded.AmbientStrength = 0;
        
    case 'realistic'
        % update handles
        if handles.overlayButton.Value == 1
            handles.specularStrength.String = '0.0008';
            handles.specularExponent.String = '1';
            handles.specularReflectance.String = '1';
            handles.diffusionStrength.String = '0.001';
            handles.ambientStrength.String = '0.8';
        end
        
        handles.overlayLoaded.SpecularStrength = 0.008;
        handles.overlayLoaded.SpecularExponent = 1;
        handles.overlayLoaded.SpecularColorReflectance = 1;
        handles.overlayLoaded.DiffuseStrength = 0.001;
        handles.overlayLoaded.AmbientStrength = 0.8;
        
    case 'pop'
        % update handles
        if handles.overlayButton.Value == 1
            handles.specularStrength.String = '0.0008';
            handles.specularExponent.String = '1';
            handles.specularReflectance.String = '1';
            handles.diffusionStrength.String = '0.9';
            handles.ambientStrength.String = '0.9';
        end
        
        handles.overlayLoaded.SpecularStrength = 0.008;
        handles.overlayLoaded.SpecularExponent = 1;
        handles.overlayLoaded.SpecularColorReflectance = 1;
        handles.overlayLoaded.DiffuseStrength = 0.9;
        handles.overlayLoaded.AmbientStrength = 0.9;
end

guidata(h(mainGuiNum), mainGuiData);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function presetButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to presetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in flatLight.
function flatLight_Callback(hObject, eventdata, handles)
% hObject    handle to flatLight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of flatLight
handles.output = hObject;
if handles.flatLight.Value == 1
   handles.nLight.Value = 0;
   handles.gLight.Value = 0;
end
guidata(hObject, handles);

% --- Executes on button press in gLight.
function gLight_Callback(hObject, eventdata, handles)
% hObject    handle to gLight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of gLight
handles.output = hObject;
if handles.gLight.Value == 1
   handles.nLight.Value = 0;
   handles.flatLight.Value = 0;
end
guidata(hObject, handles);

% --- Executes on button press in nLight.
function nLight_Callback(hObject, eventdata, handles)
% hObject    handle to nLight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of nLight
handles.output = hObject;
if handles.nLight.Value == 1
   handles.gLight.Value = 0;
   handles.flatLight.Value = 0;
end
guidata(hObject, handles);
