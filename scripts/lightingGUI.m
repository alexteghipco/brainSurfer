function varargout = lightingGUI(varargin)
% GUI to control lighting of underlays and overlays
% Alex Teghipco // alex.teghipco@uci.edu // 11/28/18

% Last Modified by GUIDE v2.5 09-Nov-2018 13:29:32

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

% get lighting data
if isfield(mainGuiData,'lights')
    if isfield(mainGuiData.lights,'supLight')
        if isvalid(mainGuiData.lights.supLight)
            handles.superiorLight.Value = 1;
        else
            handles.superiorLight.Value = 0;
        end
    end
    
    if isfield(mainGuiData.lights,'leftlatLight')
        if isvalid(mainGuiData.lights.leftlatLight)
            handles.leftLateralLight.Value = 1;
        else
            handles.leftLateralLight.Value = 0;
        end
    end
    
    if isfield(mainGuiData.lights,'infLight')
        if isvalid(mainGuiData.lights.infLight)
            handles.inferiorLightingButton.Value = 1;
        else
            handles.inferiorLightingButton.Value = 0;
        end
    end
    
    if isfield(mainGuiData.lights,'rightLatLight')
        if isvalid(mainGuiData.lights.rightLatLight)
            handles.rightLateralLight.Value = 1;
        else
            handles.rightLateralLight.Value = 0;
        end
    end
    
    if isfield(mainGuiData.lights,'postLight')
        if isvalid(mainGuiData.lights.postLight)
            handles.posteriorLight.Value = 1;
        else
            handles.posteriorLight.Value = 0;
        end
    end
    
    if isfield(mainGuiData.lights,'antLight')
        if isvalid(mainGuiData.lights.antLight)
            handles.anteriorLight.Value = 1;
        else
            handles.anteriorLight.Value = 0;
        end
    end
else
    handles.dullButton.Value = 1;
end

% check material
if isfield(mainGuiData,'materials')
    if isfield(mainGuiData.materials,'dull')
        if isempty(mainGuiData.materials.dull)
            handles.dullButton.Value = 0;
        else
            handles.dullButton.Value = 1;
        end
    end
    
    if isfield(mainGuiData.materials,'shinyButton')
        if isempty(mainGuiData.materials.shinyButton)
            handles.shinyButton.Value = 0;
        else
            handles.shinyButton.Value = 1;
        end
    end
    
    if isfield(mainGuiData.materials,'flatButton')
        if isempty(mainGuiData.materials.flatButton)
            handles.flatButton.Value = 0;
        else
            handles.flatButton.Value = 1;
        end
    end
    
else
    handles.dullButton.Value = 1;
end

% default is dull so check for that
matCount = handles.dullButton.Value + handles.shinyButton.Value + handles.flatButton.Value;
if matCount == 0
    handles.dullButton.Value = 1;
end

% now get all specular data and place into GUI
if handles.underlayButton.Value == 1
    if isfield(mainGuiData.underlay,'left')
        handles.specularStrength.String{1} = num2str(mainGuiData.underlay.left.SpecularStrength);
        handles.specularExponent.String{1} = num2str(mainGuiData.underlay.left.SpecularExponent);
        handles.specularReflectance.String{1} = num2str(mainGuiData.underlay.left.SpecularColorReflectance);
        handles.diffusionStrength.String{1} = num2str(mainGuiData.underlay.left.DiffuseStrength);
        handles.ambientStrength.String{1} = num2str(mainGuiData.underlay.left.AmbientStrength);
    else
        handles.specularStrength.String{1} = num2str(mainGuiData.underlay.right.SpecularStrength);
        handles.specularExponent.String{1} = num2str(mainGuiData.underlay.right.SpecularExponent);
        handles.specularReflectance.String{1} = num2str(mainGuiData.underlay.right.SpecularColorReflectance);
        handles.diffusionStrength.String{1} = num2str(mainGuiData.underlay.right.DiffuseStrength);
        handles.ambientStrength.String{1} = num2str(mainGuiData.underlay.right.AmbientStrength);
    end
else
    currSelection = (mainGuiData.overlaySelection.Value - 1);
    if isfield(mainGuiData.brainMap.Current{currSelection},'overlay')
        if isvalid(mainGuiData.brainMap.Current{currSelection}.overlay) == 0 || isempty(mainGuiData.brainMap.Current{currSelection}.overlay)
            handles.overlay.SpecularStrength = 'NaN';
            handles.overlay.SpecularExponent = 'NaN';
            handles.overlay.SpecularColorReflectance = 'NaN';
            handles.overlay.DiffuseStrength = 'NaN';
            handles.overlay.AmbientStrength = 'NaN';
            
        elseif isvalid(mainGuiData.brainMap.Current{currSelection}.overlay) == 1 || isempty(mainGuiData.brainMap.Current{currSelection}.overlay) == 0
            handles.specularStrength.String{1} = mainGuiData.brainMap.Current{currSelection}.overlay.SpecularStrength;
            handles.specularExponent.String{1} = mainGuiData.brainMap.Current{currSelection}.overlay.SpecularExponent;
            handles.specularReflectance.String{1} = mainGuiData.brainMap.Current{currSelection}.overlay.SpecularColorReflectance;
            handles.diffusionStrength.String{1} = mainGuiData.brainMap.Current{currSelection}.overlay.DiffuseStrength;
            handles.ambientStrength.String{1} = mainGuiData.brainMap.Current{currSelection}.overlay.AmbientStrength;
            
        end
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

lightCount = handles.inferiorLightingButton.Value + handles.rightLateralLight.Value + handles.superiorLight.Value + handles.leftLateralLight.Value + handles.posteriorLight.Value + handles.anteriorLight.Value;
if lightCount <= 4
    if handles.anteriorLight.Value == 1
        
        % if you have a cbar plot it needs to be removed.
        if isfield(mainGuiData.opts,'colorbar')
            delete(mainGuiData.opts.colorbar)
            replot = 1;
        else
            replot = 0;
        end
        
        figure(mainGuiData.brainFig)
        mainGuiData.lights.antLight = camlight(-90,0);
        
        if replot == 1
            mainGuiData.opts.colorbar = cbar;
            mainGuiData.opts.colorbar.TickLength = [0 0];
            imh = mainGuiData.opts.colorbar.Children(1);
            imh.AlphaData = mainGuiData.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        
        guidata(h(mainGuiNum), mainGuiData);
        guidata(hObject, handles);
    else
        try
            delete(mainGuiData.lights.antLight)
            guidata(h(mainGuiNum), mainGuiData);
        catch
            warning('There is no anterior camera light to delete');
        end
    end
else
    warndlg('A maximum of 4 lights is allowed','Error')
end
guidata(hObject, handles);

% --- Executes on button press in posteriorLight.
function posteriorLight_Callback(hObject, eventdata, handles)
% hObject    handle to posteriorLight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of posteriorLight
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

lightCount = handles.inferiorLightingButton.Value + handles.rightLateralLight.Value + handles.superiorLight.Value + handles.leftLateralLight.Value + handles.posteriorLight.Value + handles.anteriorLight.Value;
if lightCount <= 4
    if handles.posteriorLight.Value == 1
        
        % if you have a cbar plot it needs to be removed.
        if isfield(mainGuiData.opts,'colorbar')
            delete(mainGuiData.opts.colorbar)
            replot = 1;
        else
            replot = 0;
        end
        
        figure(mainGuiData.brainFig)
        mainGuiData.lights.postLight = camlight(90,0);
        
        if replot == 1
            mainGuiData.opts.colorbar = cbar;
            mainGuiData.opts.colorbar.TickLength = [0 0];
            imh = mainGuiData.opts.colorbar.Children(1);
            imh.AlphaData = mainGuiData.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        
        guidata(h(mainGuiNum), mainGuiData);
        guidata(hObject, handles);
    else
        try
            delete(mainGuiData.lights.postLight)
        catch
            warning('There is no posterior camera light to delete');
        end
    end
else
    warndlg('A maximum of 4 lights is allowed','Error')
end
guidata(hObject, handles);

% --- Executes on button press in leftLateralLight.
function leftLateralLight_Callback(hObject, eventdata, handles)
% hObject    handle to leftLateralLight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of leftLateralLight

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

lightCount = handles.inferiorLightingButton.Value + handles.rightLateralLight.Value + handles.superiorLight.Value + handles.leftLateralLight.Value + handles.posteriorLight.Value + handles.anteriorLight.Value;
if lightCount <= 4
    if handles.leftLateralLight.Value == 1
        
        % if you have a cbar plot it needs to be removed.
        if isfield(mainGuiData.opts,'colorbar')
            delete(mainGuiData.opts.colorbar)
            replot = 1;
        else
            replot = 0;
        end
        
        figure(mainGuiData.brainFig)
        mainGuiData.lights.leftlatLight = camlight(0,0);
        
        if replot == 1
            mainGuiData.opts.colorbar = cbar;
            mainGuiData.opts.colorbar.TickLength = [0 0];
            imh = mainGuiData.opts.colorbar.Children(1);
            imh.AlphaData = mainGuiData.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        
        guidata(h(mainGuiNum), mainGuiData);
        guidata(hObject, handles);
    else
        try
            delete(mainGuiData.lights.leftlatLight)
        catch
            warning('There is no left lateral camera light to delete');
        end
    end
else
    warndlg('A maximum of 4 lights is allowed','Error')
end
guidata(hObject, handles);

% --- Executes on button press in superiorLight.
function superiorLight_Callback(hObject, eventdata, handles)
% hObject    handle to superiorLight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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

lightCount = handles.inferiorLightingButton.Value + handles.rightLateralLight.Value + handles.superiorLight.Value + handles.leftLateralLight.Value + handles.posteriorLight.Value + handles.anteriorLight.Value;
if lightCount <= 4
    if handles.superiorLight.Value == 1
        
        % if you have a cbar plot it needs to be removed.
        if isfield(mainGuiData.opts,'colorbar')
            delete(mainGuiData.opts.colorbar)
            replot = 1;
        else
            replot = 0;
        end
        
        figure(mainGuiData.brainFig)
        mainGuiData.lights.supLight = camlight(180,90);
        
        if replot == 1
            mainGuiData.opts.colorbar = cbar;
            mainGuiData.opts.colorbar.TickLength = [0 0];
            imh = mainGuiData.opts.colorbar.Children(1);
            imh.AlphaData = mainGuiData.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        
        guidata(h(mainGuiNum), mainGuiData);
        guidata(hObject, handles);
    else
        try
            delete(mainGuiData.lights.supLight)
        catch
            warning('There is no superior camera light to delete');
        end
    end
else
    warndlg('A maximum of 4 lights is allowed','Error')
end
guidata(hObject, handles);


% --- Executes on button press in rightLateralLight.
function rightLateralLight_Callback(hObject, eventdata, handles)
% hObject    handle to rightLateralLight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rightLateralLight
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

lightCount = handles.inferiorLightingButton.Value + handles.rightLateralLight.Value + handles.superiorLight.Value + handles.leftLateralLight.Value + handles.posteriorLight.Value + handles.anteriorLight.Value;
if lightCount <= 4
    if handles.rightLateralLight.Value == 1
        
        % if you have a cbar plot it needs to be removed.
        if isfield(mainGuiData.opts,'colorbar')
            delete(mainGuiData.opts.colorbar)
            replot = 1;
        else
            replot = 0;
        end
        
        figure(mainGuiData.brainFig)
        mainGuiData.lights.rightLatLight = camlight(180,0);
        
        if replot == 1
            mainGuiData.opts.colorbar = cbar;
            mainGuiData.opts.colorbar.TickLength = [0 0];
            imh = mainGuiData.opts.colorbar.Children(1);
            imh.AlphaData = mainGuiData.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        
        guidata(h(mainGuiNum), mainGuiData);
        guidata(hObject, handles);
    else
        try
            delete(mainGuiData.lights.rightLatLight)
        catch
            warning('There is no right lateral camera light to delete');
        end
    end
else
    warndlg('A maximum of 4 lights is allowed','Error')
end

% --- Executes on button press in inferiorLightingButton.
function inferiorLightingButton_Callback(hObject, eventdata, handles)
% hObject    handle to inferiorLightingButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of inferiorLightingButton
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

lightCount = handles.inferiorLightingButton.Value + handles.rightLateralLight.Value + handles.superiorLight.Value + handles.leftLateralLight.Value + handles.posteriorLight.Value + handles.anteriorLight.Value;
if lightCount <= 4
    if handles.inferiorLightingButton.Value == 1
        
        % if you have a cbar plot it needs to be removed.
        if isfield(mainGuiData.opts,'colorbar')
            delete(mainGuiData.opts.colorbar)
            replot = 1;
        else
            replot = 0;
        end
        
        figure(mainGuiData.brainFig)
        mainGuiData.lights.inferiorLighting = camlight(180,180);
        mainGuiData.lights.inferiorLighting2 = camlight(0,180);
        
        if replot == 1
            mainGuiData.opts.colorbar = cbar;
            mainGuiData.opts.colorbar.TickLength = [0 0];
            imh = mainGuiData.opts.colorbar.Children(1);
            imh.AlphaData = mainGuiData.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        
        guidata(h(mainGuiNum), mainGuiData);
        guidata(hObject, handles);
    else
        try
            delete(mainGuiData.lights.inferiorLighting)
            delete(mainGuiData.lights.inferiorLighting2)
        catch
            warning('There is no inferior camera light to delete');
        end
    end
else
    warndlg('A maximum of 4 lights is allowed','Error')
end

% --- Executes on button press in removeLights.
function removeLights_Callback(hObject, eventdata, handles)
% hObject    handle to removeLights (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of removeLights
handles.output = hObject;

if handles.removeLights.Value == 1
    h = get(0,'Children');
    % find brain surfer
    for hi = 1:length(h)
        if strcmp(h(hi).Name,'Brain Surfer') == 1
            mainGuiNum = hi;
        end
    end
    
    % get data from brain surfer
    mainGuiData = guidata(h(mainGuiNum));
    
    figure(mainGuiData.brainFig)
    delete(findall(gcf,'Type','light'))
    
    if isfield(mainGuiData.lights,'supLight')
        delete(mainGuiData.lights.supLight)
    end
    
    if isfield(mainGuiData.lights,'leftlatLight')
        delete(mainGuiData.lights.leftlatLight)
    end
    
    if isfield(mainGuiData.lights,'infLight')
        delete(mainGuiData.lights.infLight)
    end
    
    if isfield(mainGuiData.lights,'rightLatLight')
        delete(mainGuiData.lights.rightLatLight)
    end
    
    if isfield(mainGuiData.lights,'postLight')
        delete(mainGuiData.lights.postLight)
    end
    
    if isfield(mainGuiData.lights,'antLight')
        delete(mainGuiData.lights.antLight)
    end
    
    % reset buttons
    handles.inferiorLightingButton.Value  = 0;
    handles.rightLateralLight.Value = 0;
    handles.superiorLight.Value = 0;
    handles.leftLateralLight.Value = 0;
    handles.posteriorLight.Value = 0;
    handles.anteriorLight.Value = 0;
    
    % save
    guidata(h(mainGuiNum), mainGuiData);
    guidata(hObject, handles);
    handles.removeLights.Value = 0;
end
guidata(h(mainGuiNum), mainGuiData);
guidata(hObject, handles);


% --- Executes on button press in dullButton.
function dullButton_Callback(hObject, eventdata, handles)
% hObject    handle to dullButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dullButton
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

if handles.dullButton.Value == 1
    handles.output = hObject;
    
    handles.shinyButton.Value = 0;
    handles.flatButton.Value = 0;
    
    if isfield(mainGuiData.opts,'colorbar')
        delete(mainGuiData.opts.colorbar)
        replot = 1;
    else
        replot = 0;
    end
    
    figure(mainGuiData.brainFig)
    material dull
    mainGuiData.materials.dullButton = 1;
    mainGuiData.materials.shinyButton = [];
    mainGuiData.materials.flatButton = [];
    
    if replot == 1
        mainGuiData.opts.colorbar = cbar;
        mainGuiData.opts.colorbar.TickLength = [0 0];
        imh = mainGuiData.opts.colorbar.Children(1);
        imh.AlphaData = mainGuiData.opts.transparencyData;
        imh.AlphaDataMapping = 'direct';
    end
    
    guidata(h(mainGuiNum), mainGuiData);
    guidata(hObject, handles);
    
else
    mainGuiData.materials.dullButton = [];
    guidata(h(mainGuiNum), mainGuiData);
    guidata(hObject, handles);
end

% --- Executes on button press in shinyButton.
function shinyButton_Callback(hObject, eventdata, handles)
% hObject    handle to shinyButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of shinyButton
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

if handles.shinyButton.Value == 1
    handles.output = hObject;
    
    handles.dullButton.Value = 0;
    handles.flatButton.Value = 0;
    
    if isfield(mainGuiData.opts,'colorbar')
        delete(mainGuiData.opts.colorbar)
        replot = 1;
    else
        replot = 0;
    end
    
    figure(mainGuiData.brainFig)
    material shiny
    mainGuiData.materials.dullButton = [];
    mainGuiData.materials.shinyButton = 1;
    mainGuiData.materials.flatButton = [];
    
    if replot == 1
        mainGuiData.opts.colorbar = cbar;
        mainGuiData.opts.colorbar.TickLength = [0 0];
        imh = mainGuiData.opts.colorbar.Children(1);
        imh.AlphaData = mainGuiData.opts.transparencyData;
        imh.AlphaDataMapping = 'direct';
    end
    
    guidata(h(mainGuiNum), mainGuiData);
    guidata(hObject, handles);
    
else
    mainGuiData.materials.shinyButton = [];
    guidata(h(mainGuiNum), mainGuiData);
    guidata(hObject, handles);
end

% --- Executes on button press in flatButton.
function flatButton_Callback(hObject, eventdata, handles)
% hObject    handle to flatButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of flatButton
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

if handles.flatButton.Value == 1
    handles.output = hObject;
    
    handles.shinyButton.Value = 0;
    handles.dullButton.Value = 0;
    
    if isfield(mainGuiData.opts,'colorbar')
        delete(mainGuiData.opts.colorbar)
        replot = 1;
    else
        replot = 0;
    end
    
    figure(mainGuiData.brainFig)
    material metal
    mainGuiData.materials.dullButton = [];
    mainGuiData.materials.shinyButton = [];
    mainGuiData.materials.flatButton = 1;
    
    if replot == 1
        mainGuiData.opts.colorbar = cbar;
        mainGuiData.opts.colorbar.TickLength = [0 0];
        imh = mainGuiData.opts.colorbar.Children(1);
        imh.AlphaData = mainGuiData.opts.transparencyData;
        imh.AlphaDataMapping = 'direct';
    end
    
    guidata(h(mainGuiNum), mainGuiData);
    guidata(hObject, handles);
else
    mainGuiData.materials.flatButton = [];
    guidata(h(mainGuiNum), mainGuiData);
    guidata(hObject, handles);
end

function specularExponent_Callback(hObject, eventdata, handles)
% hObject    handle to specularExponent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of specularExponent as text
%        str2double(get(hObject,'String')) returns contents of specularExponent as a double
handles.output = hObject;
h = get(0,'Children');
% find brain surfer
for hi = 1:length(h)
    if strcmp(h(hi).Name,'Brain Surfer') == 1
        mainGuiNum = hi;
    end
end
mainGuiData = guidata(h(mainGuiNum));

val = str2num(handles.specularExponent.String{1});
if handles.overlayButton.Value == 1
    currSelection = (mainGuiData.overlaySelection.Value - 1);
    if isfield(mainGuiData.brainMap.Current{currSelection},'overlay')
        if isvalid(mainGuiData.brainMap.Current{currSelection}.overlay) == 1 || isempty(mainGuiData.brainMap.Current{currSelection}.overlay) == 0
            mainGuiData.brainMap.Current{currSelection}.overlay.SpecularExponent = val;
        end
    end
else
    % get all underlays and apply changes
    underNames = fieldnames(mainGuiData.underlay);
    for hemii = 1:length(underNames)
        mainGuiData.underlay.(underNames{hemii}).SpecularExponent = val;
    end
end

guidata(h(mainGuiNum), mainGuiData);
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

% Hints: get(hObject,'String') returns contents of specularStrength as text
%        str2double(get(hObject,'String')) returns contents of specularStrength as a double
handles.output = hObject;
h = get(0,'Children');
% find brain surfer
for hi = 1:length(h)
    if strcmp(h(hi).Name,'Brain Surfer') == 1
        mainGuiNum = hi;
    end
end
mainGuiData = guidata(h(mainGuiNum));

val = str2num(handles.specularStrength.String{1});
if handles.overlayButton.Value == 1
    currSelection = (mainGuiData.overlaySelection.Value - 1);
    if isfield(mainGuiData.brainMap.Current{currSelection},'overlay')
        if isvalid(mainGuiData.brainMap.Current{currSelection}.overlay) == 1 || isempty(mainGuiData.brainMap.Current{currSelection}.overlay) == 0
            mainGuiData.brainMap.Current{currSelection}.overlay.SpecularStrength = val;
        end
    end
else
    % get all underlays and apply changes
    underNames = fieldnames(mainGuiData.underlay);
    for hemii = 1:length(underNames)
        mainGuiData.underlay.(underNames{hemii}).SpecularStrength = val;
    end
end

guidata(h(mainGuiNum), mainGuiData);
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

% Hints: get(hObject,'String') returns contents of ambientStrength as text
%        str2double(get(hObject,'String')) returns contents of ambientStrength as a double
handles.output = hObject;
h = get(0,'Children');
% find brain surfer
for hi = 1:length(h)
    if strcmp(h(hi).Name,'Brain Surfer') == 1
        mainGuiNum = hi;
    end
end
mainGuiData = guidata(h(mainGuiNum));

val = str2num(handles.ambientStrength.String{1});
if handles.overlayButton.Value == 1
    currSelection = (mainGuiData.overlaySelection.Value - 1);
    if isfield(mainGuiData.brainMap.Current{currSelection},'overlay')
        if isvalid(mainGuiData.brainMap.Current{currSelection}.overlay) == 1 || isempty(mainGuiData.brainMap.Current{currSelection}.overlay) == 0
            mainGuiData.brainMap.Current{currSelection}.overlay.AmbientStrength = val;
        end
    end
else
    % get all underlays and apply changes
    underNames = fieldnames(mainGuiData.underlay);
    for hemii = 1:length(underNames)
        mainGuiData.underlay.(underNames{hemii}).AmbientStrength = val;
    end
end

guidata(h(mainGuiNum), mainGuiData);
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

% Hints: get(hObject,'String') returns contents of specularReflectance as text
%        str2double(get(hObject,'String')) returns contents of specularReflectance as a double
handles.output = hObject;
h = get(0,'Children');
% find brain surfer
for hi = 1:length(h)
    if strcmp(h(hi).Name,'Brain Surfer') == 1
        mainGuiNum = hi;
    end
end
mainGuiData = guidata(h(mainGuiNum));

val = str2num(handles.specularReflectance.String{1});
if handles.overlayButton.Value == 1
    currSelection = (mainGuiData.overlaySelection.Value - 1);
    if isfield(mainGuiData.brainMap.Current{currSelection},'overlay')
        if isvalid(mainGuiData.brainMap.Current{currSelection}.overlay) == 1 || isempty(mainGuiData.brainMap.Current{currSelection}.overlay) == 0
            mainGuiData.brainMap.Current{currSelection}.overlay.SpecularColorReflectance = val;
        end
    end
else
    % get all underlays and apply changes
    underNames = fieldnames(mainGuiData.underlay);
    for hemii = 1:length(underNames)
        mainGuiData.underlay.(underNames{hemii}).SpecularColorReflectance = val;
    end
end

guidata(h(mainGuiNum), mainGuiData);
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

% Hints: get(hObject,'String') returns contents of diffusionStrength as text
%        str2double(get(hObject,'String')) returns contents of diffusionStrength as a double
handles.output = hObject;
h = get(0,'Children');
% find brain surfer
for hi = 1:length(h)
    if strcmp(h(hi).Name,'Brain Surfer') == 1
        mainGuiNum = hi;
    end
end
mainGuiData = guidata(h(mainGuiNum));

val = str2num(handles.diffusionStrength.String{1});
if handles.overlayButton.Value == 1
    currSelection = (mainGuiData.overlaySelection.Value - 1);
    if isfield(mainGuiData.brainMap.Current{currSelection},'overlay')
        if isvalid(mainGuiData.brainMap.Current{currSelection}.overlay) == 1 || isempty(mainGuiData.brainMap.Current{currSelection}.overlay) == 0
            mainGuiData.brainMap.Current{currSelection}.overlay.DiffuseStrength = val;
        end
    end
else
    % get all underlays and apply changes
    underNames = fieldnames(mainGuiData.underlay);
    for hemii = 1:length(underNames)
        mainGuiData.underlay.(underNames{hemii}).DiffuseStrength = val;
    end
end

guidata(h(mainGuiNum), mainGuiData);
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

% --- Executes on button press in closeButton.
function underlayButton_Callback(hObject, eventdata, handles)
% hObject    handle to closeButton (see GCBO)
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

if handles.underlayButton.Value == 1
    if isfield(mainGuiData.underlay,'left')
        handles.specularStrength.String{1} = num2str(mainGuiData.underlay.left.SpecularStrength);
        handles.specularExponent.String{1} = num2str(mainGuiData.underlay.left.SpecularExponent);
        handles.specularReflectance.String{1} = num2str(mainGuiData.underlay.left.SpecularColorReflectance);
        handles.diffusionStrength.String{1} = num2str(mainGuiData.underlay.left.DiffuseStrength);
        handles.ambientStrength.String{1} = num2str(mainGuiData.underlay.left.AmbientStrength);
    else
        handles.specularStrength.String{1} = num2str(mainGuiData.underlay.right.SpecularStrength);
        handles.specularExponent.String{1} = num2str(mainGuiData.underlay.right.SpecularExponent);
        handles.specularReflectance.String{1} = num2str(mainGuiData.underlay.right.SpecularColorReflectance);
        handles.diffusionStrength.String{1} = num2str(mainGuiData.underlay.right.DiffuseStrength);
        handles.ambientStrength.String{1} = num2str(mainGuiData.underlay.right.AmbientStrength);
    end
else
    currSelection = (mainGuiData.overlaySelection.Value - 1);
    if isfield(mainGuiData.brainMap.Current{currSelection},'overlay')
        if isvalid(mainGuiData.brainMap.Current{currSelection}.overlay) == 0 || isempty(mainGuiData.brainMap.Current{currSelection}.overlay)
            handles.overlay.SpecularStrength = 'NaN';
            handles.overlay.SpecularExponent = 'NaN';
            handles.overlay.SpecularColorReflectance = 'NaN';
            handles.overlay.DiffuseStrength = 'NaN';
            handles.overlay.AmbientStrength = 'NaN';
            
        elseif isvalid(mainGuiData.brainMap.Current{currSelection}.overlay) == 1 || isempty(mainGuiData.brainMap.Current{currSelection}.overlay) == 0
            handles.specularStrength.String{1} = mainGuiData.brainMap.Current{currSelection}.overlay.SpecularStrength;
            handles.specularExponent.String{1} = mainGuiData.brainMap.Current{currSelection}.overlay.SpecularExponent;
            handles.specularReflectance.String{1} = mainGuiData.brainMap.Current{currSelection}.overlay.SpecularColorReflectance;
            handles.diffusionStrength.String{1} = mainGuiData.brainMap.Current{currSelection}.overlay.DiffuseStrength;
            handles.ambientStrength.String{1} = mainGuiData.brainMap.Current{currSelection}.overlay.AmbientStrength;
            
        end
    end
end

guidata(h(mainGuiNum), mainGuiData);
guidata(hObject, handles);

% --- Executes on button press in closeButton.
function overlayButton_Callback(hObject, eventdata, handles)
% hObject    handle to closeButton (see GCBO)
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

if handles.underlayButton.Value == 1
    if isfield(mainGuiData.underlay,'left')
        handles.specularStrength.String{1} = num2str(mainGuiData.underlay.left.SpecularStrength);
        handles.specularExponent.String{1} = num2str(mainGuiData.underlay.left.SpecularExponent);
        handles.specularReflectance.String{1} = num2str(mainGuiData.underlay.left.SpecularColorReflectance);
        handles.diffusionStrength.String{1} = num2str(mainGuiData.underlay.left.DiffuseStrength);
        handles.ambientStrength.String{1} = num2str(mainGuiData.underlay.left.AmbientStrength);
    else
        handles.specularStrength.String{1} = num2str(mainGuiData.underlay.right.SpecularStrength);
        handles.specularExponent.String{1} = num2str(mainGuiData.underlay.right.SpecularExponent);
        handles.specularReflectance.String{1} = num2str(mainGuiData.underlay.right.SpecularColorReflectance);
        handles.diffusionStrength.String{1} = num2str(mainGuiData.underlay.right.DiffuseStrength);
        handles.ambientStrength.String{1} = num2str(mainGuiData.underlay.right.AmbientStrength);
    end
else
    currSelection = (mainGuiData.overlaySelection.Value - 1);
    if isfield(mainGuiData.brainMap.Current{currSelection},'overlay')
        if isvalid(mainGuiData.brainMap.Current{currSelection}.overlay) == 0 || isempty(mainGuiData.brainMap.Current{currSelection}.overlay)
            handles.overlay.SpecularStrength = 'NaN';
            handles.overlay.SpecularExponent = 'NaN';
            handles.overlay.SpecularColorReflectance = 'NaN';
            handles.overlay.DiffuseStrength = 'NaN';
            handles.overlay.AmbientStrength = 'NaN';
            
        elseif isvalid(mainGuiData.brainMap.Current{currSelection}.overlay) == 1 || isempty(mainGuiData.brainMap.Current{currSelection}.overlay) == 0
            handles.specularStrength.String{1} = mainGuiData.brainMap.Current{currSelection}.overlay.SpecularStrength;
            handles.specularExponent.String{1} = mainGuiData.brainMap.Current{currSelection}.overlay.SpecularExponent;
            handles.specularReflectance.String{1} = mainGuiData.brainMap.Current{currSelection}.overlay.SpecularColorReflectance;
            handles.diffusionStrength.String{1} = mainGuiData.brainMap.Current{currSelection}.overlay.DiffuseStrength;
            handles.ambientStrength.String{1} = mainGuiData.brainMap.Current{currSelection}.overlay.AmbientStrength;
            
        end
    end
end

guidata(h(mainGuiNum), mainGuiData);
guidata(hObject, handles);

% --- Executes on button press in closeButton.
function closeButton_Callback(hObject, eventdata, handles)
% hObject    handle to closeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% close everything
% close figure
h = get(0,'Children');
% find transparencyFig
for hi = 1:length(h)
    if strcmp(h(hi).Name,'lightingGUI') == 1
        close(h(hi))
    end
end


% --- Executes on button press in applyButton.
function applyButton_Callback(hObject, eventdata, handles)
% hObject    handle to applyButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.overlayButton.Value == 1
    handles.output = hObject;
    h = get(0,'Children');
    % find brain surfer
    for hi = 1:length(h)
        if strcmp(h(hi).Name,'Brain Surfer') == 1
            mainGuiNum = hi;
        end
    end
    mainGuiData = guidata(h(mainGuiNum));
    
    currSelection = (mainGuiData.overlaySelection.Value - 1);
    if isfield(mainGuiData.brainMap.Current{currSelection},'overlay')
        % loop over overlays
        for overlayi = 1:length(mainGuiData.brainMap.Current)
            mainGuiData.brainMap.Current{overlayi}.overlay.SpecularStrength = str2num(handles.specularStrength.String{1});
            mainGuiData.brainMap.Current{overlayi}.overlay.SpecularExponent = str2num(handles.specularExponent.String{1});
            mainGuiData.brainMap.Current{overlayi}.overlay.SpecularColorReflectance = str2num(handles.specularReflectance.String{1});
            mainGuiData.brainMap.Current{overlayi}.overlay.DiffuseStrength = str2num(handles.diffusionStrength.String{1});
            mainGuiData.brainMap.Current{overlayi}.overlay.AmbientStrength = str2num(handles.ambientStrength.String{1});
        end
    end
    guidata(h(mainGuiNum), mainGuiData);
else
    warning('Please toggle overlay light properties first')
end
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
            handles.specularStrength.String{1} = '0';
            handles.specularExponent.String{1} = '10';
            handles.specularReflectance.String{1} = '1';
            handles.diffusionStrength.String{1} = '0.85';
            handles.ambientStrength.String{1} = '0.5';
        end
        
        % remove all lights
        figure(mainGuiData.brainFig)
        delete(findall(gcf,'Type','light'))
        if isfield(mainGuiData,'lights')
            if isfield(mainGuiData.lights,'supLight')
                delete(mainGuiData.lights.supLight)
            end
            if isfield(mainGuiData.lights,'leftlatLight')
                delete(mainGuiData.lights.leftlatLight)
            end
            if isfield(mainGuiData.lights,'infLight')
                delete(mainGuiData.lights.infLight)
            end
            if isfield(mainGuiData.lights,'rightLatLight')
                delete(mainGuiData.lights.rightLatLight)
            end
            if isfield(mainGuiData.lights,'postLight')
                delete(mainGuiData.lights.postLight)
            end
            if isfield(mainGuiData.lights,'antLight')
                delete(mainGuiData.lights.antLight)
            end
        end
        
        % set material
        handles.flatButton.Value = 0;
        handles.shinyButton.Value = 0;
        handles.dullButton.Value = 1;
        
        if isfield(mainGuiData.opts,'colorbar')
            delete(mainGuiData.opts.colorbar)
            replot = 1;
        else
            replot = 0;
        end
        figure(mainGuiData.brainFig)
        material dull
        mainGuiData.materials.dullButton = 1;
        mainGuiData.materials.shinyButton = [];
        mainGuiData.materials.flatButton = [];
        
        % add lights
        figure(mainGuiData.brainFig)
        view(-90, 0);
        mainGuiData.lights.inferiorLighting = camlight(180,180);
        mainGuiData.lights.inferiorLighting2 = camlight(0,180);

        handles.anteriorLight.Value = 0;
        handles.posteriorLight.Value = 0;
        handles.leftLateralLight.Value = 0;
        handles.rightLateralLight.Value = 0;
        handles.inferiorLightingButton.Value = 1;
        handles.superiorLight.Value = 0;
        
        % now change underlay(s)
        underNames = fieldnames(mainGuiData.underlay);
        for hemii = 1:length(underNames)
            mainGuiData.underlay.(underNames{hemii}).SpecularStrength = str2num(handles.specularStrength.String{1});
            mainGuiData.underlay.(underNames{hemii}).SpecularExponent = str2num(handles.specularExponent.String{1});
            mainGuiData.underlay.(underNames{hemii}).SpecularColorReflectance = str2num(handles.specularReflectance.String{1});
            mainGuiData.underlay.(underNames{hemii}).DiffuseStrength = str2num(handles.diffusionStrength.String{1});
            mainGuiData.underlay.(underNames{hemii}).AmbientStrength = str2num(handles.ambientStrength.String{1});
        end
        
        % see if replot is needed
        if replot == 1
            mainGuiData.opts.colorbar = cbar;
            mainGuiData.opts.colorbar.TickLength = [0 0];
            imh = mainGuiData.opts.colorbar.Children(1);
            imh.AlphaData = mainGuiData.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        
    case 'Bright contrast'
        % update handles
        if handles.underlayButton.Value == 1
            handles.specularReflectance.String{1} = '0';
            handles.specularExponent.String{1} = '10';
            handles.specularStrength.String{1} = '0';
            handles.diffusionStrength.String{1} = '0.8';
            handles.ambientStrength.String{1} = '0.3';
        end
        
        % remove all lights
        figure(mainGuiData.brainFig)
        delete(findall(gcf,'Type','light'))
        if isfield(mainGuiData,'lights')
            if isfield(mainGuiData.lights,'supLight')
                delete(mainGuiData.lights.supLight)
            end
            if isfield(mainGuiData.lights,'leftlatLight')
                delete(mainGuiData.lights.leftlatLight)
            end
            if isfield(mainGuiData.lights,'infLight')
                delete(mainGuiData.lights.infLight)
            end
            if isfield(mainGuiData.lights,'rightLatLight')
                delete(mainGuiData.lights.rightLatLight)
            end
            if isfield(mainGuiData.lights,'postLight')
                delete(mainGuiData.lights.postLight)
            end
            if isfield(mainGuiData.lights,'antLight')
                delete(mainGuiData.lights.antLight)
            end
        end
        
        % set material
        handles.flatButton.Value = 0;
        handles.shinyButton.Value = 0;
        handles.dullButton.Value = 1;
        
        if isfield(mainGuiData.opts,'colorbar')
            delete(mainGuiData.opts.colorbar)
            replot = 1;
        else
            replot = 0;
        end
        figure(mainGuiData.brainFig)
        material dull
        mainGuiData.materials.dullButton = 1;
        mainGuiData.materials.shinyButton = [];
        mainGuiData.materials.flatButton = [];
        
        % add lights
        figure(mainGuiData.brainFig)
        view(-90, 0);
        mainGuiData.lights.inferiorLighting = camlight(180,180);
        mainGuiData.lights.inferiorLighting2 = camlight(0,180);

        mainGuiData.lights.supLight = camlight(180,90);
        
        handles.anteriorLight.Value = 0;
        handles.posteriorLight.Value = 0;
        handles.leftLateralLight.Value = 0;
        handles.rightLateralLight.Value = 0;
        handles.inferiorLightingButton.Value = 1;
        handles.superiorLight.Value = 1;
        
        % now change underlay(s)
        underNames = fieldnames(mainGuiData.underlay);
        for hemii = 1:length(underNames)
            mainGuiData.underlay.(underNames{hemii}).SpecularStrength = str2num(handles.specularStrength.String{1});
            mainGuiData.underlay.(underNames{hemii}).SpecularExponent = str2num(handles.specularExponent.String{1});
            mainGuiData.underlay.(underNames{hemii}).SpecularColorReflectance = str2num(handles.specularReflectance.String{1});
            mainGuiData.underlay.(underNames{hemii}).DiffuseStrength = str2num(handles.diffusionStrength.String{1});
            mainGuiData.underlay.(underNames{hemii}).AmbientStrength = str2num(handles.ambientStrength.String{1});
        end
        
        % see if replot is needed
        if replot == 1
            mainGuiData.opts.colorbar = cbar;
            mainGuiData.opts.colorbar.TickLength = [0 0];
            imh = mainGuiData.opts.colorbar.Children(1);
            imh.AlphaData = mainGuiData.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        
    case 'True default (bright)'
        % update handles
        if handles.underlayButton.Value == 1
            handles.specularReflectance.String{1} = '0.2';
            handles.specularExponent.String{1} = '1';
            handles.endspecularStrength.String{1} = '0.01';
            handles.diffusionStrength.String{1} = '0.3';
            handles.ambientStrength.String{1} = '0.7';
        end
        
        % remove all lights
        figure(mainGuiData.brainFig)
        delete(findall(gcf,'Type','light'))
        if isfield(mainGuiData,'lights')
            if isfield(mainGuiData.lights,'supLight')
                delete(mainGuiData.lights.supLight)
            end
            if isfield(mainGuiData.lights,'leftlatLight')
                delete(mainGuiData.lights.leftlatLight)
            end
            if isfield(mainGuiData.lights,'infLight')
                delete(mainGuiData.lights.infLight)
            end
            if isfield(mainGuiData.lights,'rightLatLight')
                delete(mainGuiData.lights.rightLatLight)
            end
            if isfield(mainGuiData.lights,'postLight')
                delete(mainGuiData.lights.postLight)
            end
            if isfield(mainGuiData.lights,'antLight')
                delete(mainGuiData.lights.antLight)
            end
        end
        
        % set material
        handles.flatButton.Value = 0;
        handles.shinyButton.Value = 0;
        handles.dullButton.Value = 1;
        
        if isfield(mainGuiData.opts,'colorbar')
            delete(mainGuiData.opts.colorbar)
            replot = 1;
        else
            replot = 0;
        end
        figure(mainGuiData.brainFig)
        material dull
        mainGuiData.materials.dullButton = 1;
        mainGuiData.materials.shinyButton = [];
        mainGuiData.materials.flatButton = [];
        
        % add lights
        figure(mainGuiData.brainFig)
        view(-90, 0);
        mainGuiData.lights.supLight = camlight(180,90);
        mainGuiData.lights.postLight = camlight(90,0);
        mainGuiData.lights.antLight = camlight(-90,0);
        mainGuiData.lights.leftlatLight = camlight(0,0);
        mainGuiData.lights.rightLatLight = camlight(180,0);
        
        handles.anteriorLight.Value =1;
        handles.posteriorLight.Value = 1;
        handles.leftLateralLight.Value = 1;
        handles.rightLateralLight.Value = 1;
        handles.inferiorLightingButton.Value = 0;
        handles.superiorLight.Value = 1;
        
        % now change underlay(s)
        underNames = fieldnames(mainGuiData.underlay);
        for hemii = 1:length(underNames)
            mainGuiData.underlay.(underNames{hemii}).SpecularStrength = str2num(handles.specularStrength.String{1});
            mainGuiData.underlay.(underNames{hemii}).SpecularExponent = str2num(handles.specularExponent.String{1});
            mainGuiData.underlay.(underNames{hemii}).SpecularColorReflectance = str2num(handles.specularReflectance.String{1});
            mainGuiData.underlay.(underNames{hemii}).DiffuseStrength = str2num(handles.diffusionStrength.String{1});
            mainGuiData.underlay.(underNames{hemii}).AmbientStrength = str2num(handles.ambientStrength.String{1});
        end
        
        % see if replot is needed
        if replot == 1
            mainGuiData.opts.colorbar = cbar;
            mainGuiData.opts.colorbar.TickLength = [0 0];
            imh = mainGuiData.opts.colorbar.Children(1);
            imh.AlphaData = mainGuiData.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        
    case 'True default (dark)'
        % update handles
        if handles.underlayButton.Value == 1
            handles.specularStrength.String{1} = '0.01';
            handles.specularExponent.String{1} = '1';
            handles.specularReflectance.String{1} = '0.2';
            handles.diffusionStrength.String{1} = '0.3';
            handles.ambientStrength.String{1} = '0.2';
        end
        
        % remove all lights
        figure(mainGuiData.brainFig)
        delete(findall(gcf,'Type','light'))
        if isfield(mainGuiData,'lights')
            if isfield(mainGuiData.lights,'supLight')
                delete(mainGuiData.lights.supLight)
            end
            if isfield(mainGuiData.lights,'leftlatLight')
                delete(mainGuiData.lights.leftlatLight)
            end
            if isfield(mainGuiData.lights,'infLight')
                delete(mainGuiData.lights.infLight)
            end
            if isfield(mainGuiData.lights,'rightLatLight')
                delete(mainGuiData.lights.rightLatLight)
            end
            if isfield(mainGuiData.lights,'postLight')
                delete(mainGuiData.lights.postLight)
            end
            if isfield(mainGuiData.lights,'antLight')
                delete(mainGuiData.lights.antLight)
            end
        end
        
        % set material
        handles.flatButton.Value = 0;
        handles.shinyButton.Value = 0;
        handles.dullButton.Value = 1;
        
        if isfield(mainGuiData.opts,'colorbar')
            delete(mainGuiData.opts.colorbar)
            replot = 1;
        else
            replot = 0;
        end
        figure(mainGuiData.brainFig)
        material dull
        mainGuiData.materials.dullButton = 1;
        mainGuiData.materials.shinyButton = [];
        mainGuiData.materials.flatButton = [];
        
        % add lights
        figure(mainGuiData.brainFig)
        view(-90, 0);
        mainGuiData.lights.leftlatLight = camlight(0,0);
        mainGuiData.lights.rightLatLight = camlight(180,0);
        
        handles.anteriorLight.Value = 0;
        handles.posteriorLight.Value = 0;
        handles.leftLateralLight.Value = 1;
        handles.rightLateralLight.Value = 1;
        handles.inferiorLightingButton.Value = 0;
        handles.superiorLight.Value = 1;
        
        % now change underlay(s)
        underNames = fieldnames(mainGuiData.underlay);
        for hemii = 1:length(underNames)
            mainGuiData.underlay.(underNames{hemii}).SpecularStrength = str2num(handles.specularStrength.String{1});
            mainGuiData.underlay.(underNames{hemii}).SpecularExponent = str2num(handles.specularExponent.String{1});
            mainGuiData.underlay.(underNames{hemii}).SpecularColorReflectance = str2num(handles.specularReflectance.String{1});
            mainGuiData.underlay.(underNames{hemii}).DiffuseStrength = str2num(handles.diffusionStrength.String{1});
            mainGuiData.underlay.(underNames{hemii}).AmbientStrength = str2num(handles.ambientStrength.String{1});
        end
        
        % see if replot is needed
        if replot == 1
            mainGuiData.opts.colorbar = cbar;
            mainGuiData.opts.colorbar.TickLength = [0 0];
            imh = mainGuiData.opts.colorbar.Children(1);
            imh.AlphaData = mainGuiData.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        
    case 'Dramatic (bright)'
        % update handles
        if handles.underlayButton.Value == 1
            handles.specularStrength.String{1} = '0.2';
            handles.specularExponent.String{1} = '2';
            handles.specularReflectance.String{1} = '0.5';
            handles.diffusionStrength.String{1} = '0.6';
            handles.ambientStrength.String{1} = '0.4';
        end
        
        % remove all lights
        figure(mainGuiData.brainFig)
        delete(findall(gcf,'Type','light'))
        if isfield(mainGuiData,'lights')
            if isfield(mainGuiData.lights,'supLight')
                delete(mainGuiData.lights.supLight)
            end
            if isfield(mainGuiData.lights,'leftlatLight')
                delete(mainGuiData.lights.leftlatLight)
            end
            if isfield(mainGuiData.lights,'infLight')
                delete(mainGuiData.lights.infLight)
            end
            if isfield(mainGuiData.lights,'rightLatLight')
                delete(mainGuiData.lights.rightLatLight)
            end
            if isfield(mainGuiData.lights,'postLight')
                delete(mainGuiData.lights.postLight)
            end
            if isfield(mainGuiData.lights,'antLight')
                delete(mainGuiData.lights.antLight)
            end
        end
        
        % set material
        handles.flatButton.Value = 0;
        handles.shinyButton.Value = 1;
        handles.dullButton.Value = 0;
        
        if isfield(mainGuiData.opts,'colorbar')
            delete(mainGuiData.opts.colorbar)
            replot = 1;
        else
            replot = 0;
        end
        figure(mainGuiData.brainFig)
        material shiny
        mainGuiData.materials.dullButton = [];
        mainGuiData.materials.shinyButton = 1;
        mainGuiData.materials.flatButton = [];
        
        % add lights
        figure(mainGuiData.brainFig)
        view(-90, 0);
        mainGuiData.lights.supLight = camlight(180,90);
        mainGuiData.lights.postLight = camlight(90,0);
        mainGuiData.lights.antLight = camlight(-90,0);
        mainGuiData.lights.leftlatLight = camlight(0,0);
        mainGuiData.lights.rightLatLight = camlight(180,0);
        
        handles.anteriorLight.Value = 1;
        handles.posteriorLight.Value = 1;
        handles.leftLateralLight.Value = 1;
        handles.superiorLight.Value = 1;
        handles.rightLateralLight.Value = 1;
        handles.inferiorLightingButton.Value = 0;
        
        % now change underlay(s)
        underNames = fieldnames(mainGuiData.underlay);
        for hemii = 1:length(underNames)
            mainGuiData.underlay.(underNames{hemii}).SpecularStrength = str2num(handles.specularStrength.String{1});
            mainGuiData.underlay.(underNames{hemii}).SpecularExponent = str2num(handles.specularExponent.String{1});
            mainGuiData.underlay.(underNames{hemii}).SpecularColorReflectance = str2num(handles.specularReflectance.String{1});
            mainGuiData.underlay.(underNames{hemii}).DiffuseStrength = str2num(handles.diffusionStrength.String{1});
            mainGuiData.underlay.(underNames{hemii}).AmbientStrength = str2num(handles.ambientStrength.String{1});
        end
        
        % see if replot is needed
        if replot == 1
            mainGuiData.opts.colorbar = cbar;
            mainGuiData.opts.colorbar.TickLength = [0 0];
            imh = mainGuiData.opts.colorbar.Children(1);
            imh.AlphaData = mainGuiData.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        
    case 'Dramatic (dark)'
        % update handles
        if handles.underlayButton.Value == 1
            handles.specularStrength.String{1} = '0.2';
            handles.specularExponent.String{1} = '2';
            handles.specularReflectance.String{1} = '0.5';
            handles.diffusionStrength.String{1} = '0.6';
            handles.ambientStrength.String{1} = '0.2';
        end
        
        % remove all lights
        figure(mainGuiData.brainFig)
        delete(findall(gcf,'Type','light'))
        if isfield(mainGuiData,'lights')
            if isfield(mainGuiData.lights,'supLight')
                delete(mainGuiData.lights.supLight)
            end
            if isfield(mainGuiData.lights,'leftlatLight')
                delete(mainGuiData.lights.leftlatLight)
            end
            if isfield(mainGuiData.lights,'infLight')
                delete(mainGuiData.lights.infLight)
            end
            if isfield(mainGuiData.lights,'rightLatLight')
                delete(mainGuiData.lights.rightLatLight)
            end
            if isfield(mainGuiData.lights,'postLight')
                delete(mainGuiData.lights.postLight)
            end
            if isfield(mainGuiData.lights,'antLight')
                delete(mainGuiData.lights.antLight)
            end
        end
        
        % set material
        handles.flatButton.Value = 0;
        handles.shinyButton.Value = 1;
        handles.dullButton.Value = 0;
        
        if isfield(mainGuiData.opts,'colorbar')
            delete(mainGuiData.opts.colorbar)
            replot = 1;
        else
            replot = 0;
        end
        figure(mainGuiData.brainFig)
        material shiny
        mainGuiData.materials.dullButton = [];
        mainGuiData.materials.shinyButton = 1;
        mainGuiData.materials.flatButton = [];
        
        % add lights
        figure(mainGuiData.brainFig)
        view(-90, 0);
        mainGuiData.lights.leftlatLight = camlight(0,0);
        mainGuiData.lights.rightLatLight = camlight(180,0);
        
        handles.anteriorLight.Value = 0;
        handles.posteriorLight.Value = 0;
        handles.leftLateralLight.Value = 1;
        handles.superiorLight.Value = 0;
        handles.rightLateralLight.Value = 1;
        handles.inferiorLightingButton.Value = 0;
        
        % now change underlay(s)
        underNames = fieldnames(mainGuiData.underlay);
        for hemii = 1:length(underNames)
            mainGuiData.underlay.(underNames{hemii}).SpecularStrength = str2num(handles.specularStrength.String{1});
            mainGuiData.underlay.(underNames{hemii}).SpecularExponent = str2num(handles.specularExponent.String{1});
            mainGuiData.underlay.(underNames{hemii}).SpecularColorReflectance = str2num(handles.specularReflectance.String{1});
            mainGuiData.underlay.(underNames{hemii}).DiffuseStrength = str2num(handles.diffusionStrength.String{1});
            mainGuiData.underlay.(underNames{hemii}).AmbientStrength = str2num(handles.ambientStrength.String{1});
        end
        
        % see if replot is needed
        if replot == 1
            mainGuiData.opts.colorbar = cbar;
            mainGuiData.opts.colorbar.TickLength = [0 0];
            imh = mainGuiData.opts.colorbar.Children(1);
            imh.AlphaData = mainGuiData.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        
    case 'Dramatic2 (dark)'
        % update handles
        if handles.underlayButton.Value == 1
            handles.specularStrength.String{1} = '0.1';
            handles.specularExponent.String{1} = '2';
            handles.specularReflectance.String{1} = '0.2';
            handles.diffusionStrength.String{1} = '0.7';
            handles.ambientStrength.String{1} = '0.2';
        end
        
        % remove all lights
        figure(mainGuiData.brainFig)
        delete(findall(gcf,'Type','light'))
        if isfield(mainGuiData,'lights')
            if isfield(mainGuiData.lights,'supLight')
                delete(mainGuiData.lights.supLight)
            end
            if isfield(mainGuiData.lights,'leftlatLight')
                delete(mainGuiData.lights.leftlatLight)
            end
            if isfield(mainGuiData.lights,'infLight')
                delete(mainGuiData.lights.infLight)
            end
            if isfield(mainGuiData.lights,'rightLatLight')
                delete(mainGuiData.lights.rightLatLight)
            end
            if isfield(mainGuiData.lights,'postLight')
                delete(mainGuiData.lights.postLight)
            end
            if isfield(mainGuiData.lights,'antLight')
                delete(mainGuiData.lights.antLight)
            end
        end
        
        % set material
        handles.flatButton.Value = 0;
        handles.shinyButton.Value = 0;
        handles.dullButton.Value = 1;
        
        if isfield(mainGuiData.opts,'colorbar')
            delete(mainGuiData.opts.colorbar)
            replot = 1;
        else
            replot = 0;
        end
        figure(mainGuiData.brainFig)
        material shiny
        mainGuiData.materials.dullButton = 1;
        mainGuiData.materials.shinyButton = [];
        mainGuiData.materials.flatButton = [];
        
        % add lights
        figure(mainGuiData.brainFig)
        view(-90, 0);
        mainGuiData.lights.leftlatLight = camlight(0,0);
        mainGuiData.lights.rightLatLight = camlight(180,0);
        mainGuiData.lights.antLight = camlight(-90,0);
        mainGuiData.lights.postLight = camlight(90,0);
        
        handles.anteriorLight.Value = 1;
        handles.posteriorLight.Value = 1;
        handles.leftLateralLight.Value = 1;
        handles.superiorLight.Value = 0;
        handles.rightLateralLight.Value = 1;
        handles.inferiorLightingButton.Value = 0;
        
        % now change underlay(s)
        underNames = fieldnames(mainGuiData.underlay);
        for hemii = 1:length(underNames)
            mainGuiData.underlay.(underNames{hemii}).SpecularStrength = str2num(handles.specularStrength.String{1});
            mainGuiData.underlay.(underNames{hemii}).SpecularExponent = str2num(handles.specularExponent.String{1});
            mainGuiData.underlay.(underNames{hemii}).SpecularColorReflectance = str2num(handles.specularReflectance.String{1});
            mainGuiData.underlay.(underNames{hemii}).DiffuseStrength = str2num(handles.diffusionStrength.String{1});
            mainGuiData.underlay.(underNames{hemii}).AmbientStrength = str2num(handles.ambientStrength.String{1});
        end
        
        % see if replot is needed
        if replot == 1
            mainGuiData.opts.colorbar = cbar;
            mainGuiData.opts.colorbar.TickLength = [0 0];
            imh = mainGuiData.opts.colorbar.Children(1);
            imh.AlphaData = mainGuiData.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        
    case 'Subtle perisylvian (bright)'
        % update handles
        if handles.underlayButton.Value == 1
            handles.specularStrength.String{1} = '0.2';
            handles.specularExponent.String{1} = '4';
            handles.specularReflectance.String{1} = '0.6';
            handles.diffusionStrength.String{1} = '0.45';
            handles.ambientStrength.String{1} = '0.35';
        end
        
        % remove all lights
        figure(mainGuiData.brainFig)
        delete(findall(gcf,'Type','light'))
        if isfield(mainGuiData,'lights')
            if isfield(mainGuiData.lights,'supLight')
                delete(mainGuiData.lights.supLight)
            end
            if isfield(mainGuiData.lights,'leftlatLight')
                delete(mainGuiData.lights.leftlatLight)
            end
            if isfield(mainGuiData.lights,'infLight')
                delete(mainGuiData.lights.infLight)
            end
            if isfield(mainGuiData.lights,'rightLatLight')
                delete(mainGuiData.lights.rightLatLight)
            end
            if isfield(mainGuiData.lights,'postLight')
                delete(mainGuiData.lights.postLight)
            end
            if isfield(mainGuiData.lights,'antLight')
                delete(mainGuiData.lights.antLight)
            end
        end
        
        % set material
        handles.flatButton.Value = 0;
        handles.shinyButton.Value = 1;
        handles.dullButton.Value = 0;
        
        if isfield(mainGuiData.opts,'colorbar')
            delete(mainGuiData.opts.colorbar)
            replot = 1;
        else
            replot = 0;
        end
        figure(mainGuiData.brainFig)
        material shiny
        mainGuiData.materials.dullButton = [];
        mainGuiData.materials.shinyButton = 1;
        mainGuiData.materials.flatButton = [];
        
        % add lights
        figure(mainGuiData.brainFig)
        view(-90, 0);
        mainGuiData.lights.leftlatLight = camlight(0,0);
        mainGuiData.lights.rightLatLight = camlight(180,0);
        mainGuiData.lights.antLight = camlight(-90,0);
        mainGuiData.lights.postLight = camlight(90,0);
        mainGuiData.lights.supLight = camlight(180,90);
        
        handles.anteriorLight.Value = 1;
        handles.posteriorLight.Value = 1;
        handles.leftLateralLight.Value = 1;
        handles.superiorLight.Value = 1;
        handles.rightLateralLight.Value = 1;
        handles.inferiorLightingButton.Value = 0;
        
        % now change underlay(s)
        underNames = fieldnames(mainGuiData.underlay);
        for hemii = 1:length(underNames)
            mainGuiData.underlay.(underNames{hemii}).SpecularStrength = str2num(handles.specularStrength.String{1});
            mainGuiData.underlay.(underNames{hemii}).SpecularExponent = str2num(handles.specularExponent.String{1});
            mainGuiData.underlay.(underNames{hemii}).SpecularColorReflectance = str2num(handles.specularReflectance.String{1});
            mainGuiData.underlay.(underNames{hemii}).DiffuseStrength = str2num(handles.diffusionStrength.String{1});
            mainGuiData.underlay.(underNames{hemii}).AmbientStrength = str2num(handles.ambientStrength.String{1});
        end
        
        % see if replot is needed
        if replot == 1
            mainGuiData.opts.colorbar = cbar;
            mainGuiData.opts.colorbar.TickLength = [0 0];
            imh = mainGuiData.opts.colorbar.Children(1);
            imh.AlphaData = mainGuiData.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        
    case 'Subtle perisylvian (dark)'
        % update handles
        if handles.underlayButton.Value == 1
            handles.specularStrength.String{1} = '0.1';
            handles.specularExponent.String{1} = '3';
            handles.specularReflectance.String{1} = '0.2';
            handles.diffusionStrength.String{1} = '0.5';
            handles.ambientStrength.String{1} = '0.2';
        end
        
        % remove all lights
        figure(mainGuiData.brainFig)
        delete(findall(gcf,'Type','light'))
        if isfield(mainGuiData,'lights')
            if isfield(mainGuiData.lights,'supLight')
                delete(mainGuiData.lights.supLight)
            end
            if isfield(mainGuiData.lights,'leftlatLight')
                delete(mainGuiData.lights.leftlatLight)
            end
            if isfield(mainGuiData.lights,'infLight')
                delete(mainGuiData.lights.infLight)
            end
            if isfield(mainGuiData.lights,'rightLatLight')
                delete(mainGuiData.lights.rightLatLight)
            end
            if isfield(mainGuiData.lights,'postLight')
                delete(mainGuiData.lights.postLight)
            end
            if isfield(mainGuiData.lights,'antLight')
                delete(mainGuiData.lights.antLight)
            end
        end
        
        % set material
        handles.flatButton.Value = 0;
        handles.shinyButton.Value = 0;
        handles.dullButton.Value = 1;
        
        if isfield(mainGuiData.opts,'colorbar')
            delete(mainGuiData.opts.colorbar)
            replot = 1;
        else
            replot = 0;
        end
        figure(mainGuiData.brainFig)
        material dull
        mainGuiData.materials.dullButton = 1;
        mainGuiData.materials.shinyButton = [];
        mainGuiData.materials.flatButton = [];
        
        % add lights
        figure(mainGuiData.brainFig)
        view(-90, 0);
        mainGuiData.lights.leftlatLight = camlight(0,0);
        mainGuiData.lights.rightLatLight = camlight(180,0);
        mainGuiData.lights.antLight = camlight(-90,0);
        mainGuiData.lights.postLight = camlight(90,0);
        mainGuiData.lights.supLight = camlight(180,90);
        
        handles.anteriorLight.Value = 1;
        handles.posteriorLight.Value = 1;
        handles.leftLateralLight.Value = 1;
        handles.superiorLight.Value = 1;
        handles.rightLateralLight.Value = 1;
        handles.inferiorLightingButton.Value = 0;
        
        % now change underlay(s)
        underNames = fieldnames(mainGuiData.underlay);
        for hemii = 1:length(underNames)
            mainGuiData.underlay.(underNames{hemii}).SpecularStrength = str2num(handles.specularStrength.String{1});
            mainGuiData.underlay.(underNames{hemii}).SpecularExponent = str2num(handles.specularExponent.String{1});
            mainGuiData.underlay.(underNames{hemii}).SpecularColorReflectance = str2num(handles.specularReflectance.String{1});
            mainGuiData.underlay.(underNames{hemii}).DiffuseStrength = str2num(handles.diffusionStrength.String{1});
            mainGuiData.underlay.(underNames{hemii}).AmbientStrength = str2num(handles.ambientStrength.String{1});
        end
        
        % see if replot is needed
        if replot == 1
            mainGuiData.opts.colorbar = cbar;
            mainGuiData.opts.colorbar.TickLength = [0 0];
            imh = mainGuiData.opts.colorbar.Children(1);
            imh.AlphaData = mainGuiData.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        
    case 'Subtler perisylvian (bright)'
        % update handles
        if handles.underlayButton.Value == 1
            handles.specularStrength.String{1} = '0.1';
            handles.specularExponent.String{1} = '2';
            handles.specularReflectance.String{1} = '0.2';
            handles.diffusionStrength.String{1} = '0.7';
            handles.ambientStrength.String{1} = '0.2';
        end
        
        % remove all lights
        figure(mainGuiData.brainFig)
        delete(findall(gcf,'Type','light'))
        if isfield(mainGuiData,'lights')
            if isfield(mainGuiData.lights,'supLight')
                delete(mainGuiData.lights.supLight)
            end
            if isfield(mainGuiData.lights,'leftlatLight')
                delete(mainGuiData.lights.leftlatLight)
            end
            if isfield(mainGuiData.lights,'infLight')
                delete(mainGuiData.lights.infLight)
            end
            if isfield(mainGuiData.lights,'rightLatLight')
                delete(mainGuiData.lights.rightLatLight)
            end
            if isfield(mainGuiData.lights,'postLight')
                delete(mainGuiData.lights.postLight)
            end
            if isfield(mainGuiData.lights,'antLight')
                delete(mainGuiData.lights.antLight)
            end
        end
        
        % set material
        handles.flatButton.Value = 0;
        handles.shinyButton.Value = 0;
        handles.dullButton.Value = 1;
        
        if isfield(mainGuiData.opts,'colorbar')
            delete(mainGuiData.opts.colorbar)
            replot = 1;
        else
            replot = 0;
        end
        figure(mainGuiData.brainFig)
        material dull
        mainGuiData.materials.dullButton = 1;
        mainGuiData.materials.shinyButton = [];
        mainGuiData.materials.flatButton = [];
        
        % add lights
        figure(mainGuiData.brainFig)
        view(-90, 0);
        mainGuiData.lights.leftlatLight = camlight(0,0);
        mainGuiData.lights.rightLatLight = camlight(180,0);
        mainGuiData.lights.antLight = camlight(-90,0);
        mainGuiData.lights.postLight = camlight(90,0);
        mainGuiData.lights.supLight = camlight(180,90);
        
        handles.anteriorLight.Value = 1;
        handles.posteriorLight.Value = 1;
        handles.leftLateralLight.Value = 1;
        handles.superiorLight.Value = 1;
        handles.rightLateralLight.Value = 1;
        handles.inferiorLightingButton.Value = 0;
        
        % now change underlay(s)
        underNames = fieldnames(mainGuiData.underlay);
        for hemii = 1:length(underNames)
            mainGuiData.underlay.(underNames{hemii}).SpecularStrength = str2num(handles.specularStrength.String{1});
            mainGuiData.underlay.(underNames{hemii}).SpecularExponent = str2num(handles.specularExponent.String{1});
            mainGuiData.underlay.(underNames{hemii}).SpecularColorReflectance = str2num(handles.specularReflectance.String{1});
            mainGuiData.underlay.(underNames{hemii}).DiffuseStrength = str2num(handles.diffusionStrength.String{1});
            mainGuiData.underlay.(underNames{hemii}).AmbientStrength = str2num(handles.ambientStrength.String{1});
        end
        
        % see if replot is needed
        if replot == 1
            mainGuiData.opts.colorbar = cbar;
            mainGuiData.opts.colorbar.TickLength = [0 0];
            imh = mainGuiData.opts.colorbar.Children(1);
            imh.AlphaData = mainGuiData.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        
    case 'Polished Mirror'
        % update handles
        if handles.underlayButton.Value == 1
            handles.specularStrength.String{1} = '0.5';
            handles.specularExponent.String{1} = '30';
            handles.specularReflectance.String{1} = '0.5';
            handles.diffusionStrength.String{1} = '0.7';
            handles.ambientStrength.String{1} = '0.1';
        end
        
        % remove all lights
        figure(mainGuiData.brainFig)
        delete(findall(gcf,'Type','light'))
        if isfield(mainGuiData,'lights')
            if isfield(mainGuiData.lights,'supLight')
                delete(mainGuiData.lights.supLight)
            end
            if isfield(mainGuiData.lights,'leftlatLight')
                delete(mainGuiData.lights.leftlatLight)
            end
            if isfield(mainGuiData.lights,'infLight')
                delete(mainGuiData.lights.infLight)
            end
            if isfield(mainGuiData.lights,'rightLatLight')
                delete(mainGuiData.lights.rightLatLight)
            end
            if isfield(mainGuiData.lights,'postLight')
                delete(mainGuiData.lights.postLight)
            end
            if isfield(mainGuiData.lights,'antLight')
                delete(mainGuiData.lights.antLight)
            end
        end
        
        % set material
        handles.flatButton.Value = 1;
        handles.shinyButton.Value = 0;
        handles.dullButton.Value = 0;
        
        if isfield(mainGuiData.opts,'colorbar')
            delete(mainGuiData.opts.colorbar)
            replot = 1;
        else
            replot = 0;
        end
        figure(mainGuiData.brainFig)
        material metal
        mainGuiData.materials.dullButton = [];
        mainGuiData.materials.shinyButton = [];
        mainGuiData.materials.flatButton = 1;
        
        % add lights
        figure(mainGuiData.brainFig)
        view(-90, 0);
        mainGuiData.lights.leftlatLight = camlight(0,0);
        mainGuiData.lights.rightLatLight = camlight(180,0);
        mainGuiData.lights.antLight = camlight(-90,0);
        mainGuiData.lights.postLight = camlight(90,0);
        mainGuiData.lights.supLight = camlight(180,90);
        
        handles.anteriorLight.Value = 1;
        handles.posteriorLight.Value = 1;
        handles.leftLateralLight.Value = 1;
        handles.superiorLight.Value = 1;
        handles.rightLateralLight.Value = 1;
        handles.inferiorLightingButton.Value = 0;
        
        % now change underlay(s)
        underNames = fieldnames(mainGuiData.underlay);
        for hemii = 1:length(underNames)
            mainGuiData.underlay.(underNames{hemii}).SpecularStrength = str2num(handles.specularStrength.String{1});
            mainGuiData.underlay.(underNames{hemii}).SpecularExponent = str2num(handles.specularExponent.String{1});
            mainGuiData.underlay.(underNames{hemii}).SpecularColorReflectance = str2num(handles.specularReflectance.String{1});
            mainGuiData.underlay.(underNames{hemii}).DiffuseStrength = str2num(handles.diffusionStrength.String{1});
            mainGuiData.underlay.(underNames{hemii}).AmbientStrength = str2num(handles.ambientStrength.String{1});
        end
        
        % see if replot is needed
        if replot == 1
            mainGuiData.opts.colorbar = cbar;
            mainGuiData.opts.colorbar.TickLength = [0 0];
            imh = mainGuiData.opts.colorbar.Children(1);
            imh.AlphaData = mainGuiData.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        
        %% overlays
    case ['Alex' '''' 's default (flat)']
        % update handles
        if handles.overlayButton.Value == 1
            handles.specularStrength.String{1} = '0';
            handles.specularExponent.String{1} = '1';
            handles.specularReflectance.String{1} = '0';
            handles.diffusionStrength.String{1} = '0.3';
            handles.ambientStrength.String{1} = '0.8';
        end
        
        % remove all lights
        %         figure(mainGuiData.brainFig)
        %         delete(findall(gcf,'Type','light'))
        %         if isfield(mainGuiData,'lights')
        %             if isfield(mainGuiData.lights,'supLight')
        %                 delete(mainGuiData.lights.supLight)
        %             end
        %             if isfield(mainGuiData.lights,'leftlatLight')
        %                 delete(mainGuiData.lights.leftlatLight)
        %             end
        %             if isfield(mainGuiData.lights,'infLight')
        %                 delete(mainGuiData.lights.infLight)
        %             end
        %             if isfield(mainGuiData.lights,'rightLatLight')
        %                 delete(mainGuiData.lights.rightLatLight)
        %             end
        %             if isfield(mainGuiData.lights,'postLight')
        %                 delete(mainGuiData.lights.postLight)
        %             end
        %             if isfield(mainGuiData.lights,'antLight')
        %                 delete(mainGuiData.lights.antLight)
        %             end
        %         end
        
        % now change overlay(s)
        currSelection = (mainGuiData.overlaySelection.Value - 1);
        if isfield(mainGuiData.brainMap.Current{currSelection},'overlay')
            % loop over overlays
            for overlayi = 1:length(mainGuiData.brainMap.Current)
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularStrength = str2num(handles.specularStrength.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularExponent = str2num(handles.specularExponent.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularColorReflectance = str2num(handles.specularReflectance.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.DiffuseStrength = str2num(handles.diffusionStrength.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.AmbientStrength = str2num(handles.ambientStrength.String{1});
            end
        end
        
        if isfield(mainGuiData.opts,'colorbar')
            delete(mainGuiData.opts.colorbar)
            replot = 1;
        else
            replot = 0;
        end
        
        % add lights
        figure(mainGuiData.brainFig)
        %view(-90, 0);
        %         mainGuiData.lights.inferiorLighting = camlight(180,180);
        
        % see if replot is needed
        if replot == 1
            mainGuiData.opts.colorbar = cbar;
            mainGuiData.opts.colorbar.TickLength = [0 0];
            imh = mainGuiData.opts.colorbar.Children(1);
            imh.AlphaData = mainGuiData.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
    case 'True default (flat)'
        % update handles
        if handles.overlayButton.Value == 1
            handles.specularStrength.String{1} = '0.6';
            handles.specularExponent.String{1} = '1';
            handles.specularReflectance.String{1} = '0.6';
            handles.diffusionStrength.String{1} = '0.6';
            handles.ambientStrength.String{1} = '0.3';
        end
        
        % remove all lights
        %         figure(mainGuiData.brainFig)
        %         delete(findall(gcf,'Type','light'))
        %         if isfield(mainGuiData,'lights')
        %             if isfield(mainGuiData.lights,'supLight')
        %                 delete(mainGuiData.lights.supLight)
        %             end
        %             if isfield(mainGuiData.lights,'leftlatLight')
        %                 delete(mainGuiData.lights.leftlatLight)
        %             end
        %             if isfield(mainGuiData.lights,'infLight')
        %                 delete(mainGuiData.lights.infLight)
        %             end
        %             if isfield(mainGuiData.lights,'rightLatLight')
        %                 delete(mainGuiData.lights.rightLatLight)
        %             end
        %             if isfield(mainGuiData.lights,'postLight')
        %                 delete(mainGuiData.lights.postLight)
        %             end
        %             if isfield(mainGuiData.lights,'antLight')
        %                 delete(mainGuiData.lights.antLight)
        %             end
        %         end
        % now change overlay(s)
        currSelection = (mainGuiData.overlaySelection.Value - 1);
        if isfield(mainGuiData.brainMap.Current{currSelection},'overlay')
            % loop over overlays
            for overlayi = 1:length(mainGuiData.brainMap.Current)
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularStrength = str2num(handles.specularStrength.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularExponent = str2num(handles.specularExponent.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularColorReflectance = str2num(handles.specularReflectance.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.DiffuseStrength = str2num(handles.diffusionStrength.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.AmbientStrength = str2num(handles.ambientStrength.String{1});
            end
        end
        
        if isfield(mainGuiData.opts,'colorbar')
            delete(mainGuiData.opts.colorbar)
            replot = 1;
        else
            replot = 0;
        end
        
        % add lights
        %         figure(mainGuiData.brainFig)
        %         view(-90, 0);
        %         mainGuiData.lights.leftlatLight = camlight(0,0);
        %         mainGuiData.lights.rightLatLight = camlight(180,0);
        %         mainGuiData.lights.antLight = camlight(-90,0);
        %         mainGuiData.lights.postLight = camlight(90,0);
        %         mainGuiData.lights.supLight = camlight(180,90);
        %
        % see if replot is needed
        figure(mainGuiData.brainFig)
        if replot == 1
            mainGuiData.opts.colorbar = cbar;
            mainGuiData.opts.colorbar.TickLength = [0 0];
            imh = mainGuiData.opts.colorbar.Children(1);
            imh.AlphaData = mainGuiData.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
    case 'True default (reflective)'
        % update handles
        if handles.overlayButton.Value == 1
            handles.specularStrength.String{1} = '0.5';
            handles.specularExponent.String{1} = '3';
            handles.specularReflectance.String{1} = '0.1';
            handles.diffusionStrength.String{1} = '0.6';
            handles.ambientStrength.String{1} = '0.3';
        end
        
        % remove all lights
        %         figure(mainGuiData.brainFig)
        %         delete(findall(gcf,'Type','light'))
        %         if isfield(mainGuiData,'lights')
        %             if isfield(mainGuiData.lights,'supLight')
        %                 delete(mainGuiData.lights.supLight)
        %             end
        %             if isfield(mainGuiData.lights,'leftlatLight')
        %                 delete(mainGuiData.lights.leftlatLight)
        %             end
        %             if isfield(mainGuiData.lights,'infLight')
        %                 delete(mainGuiData.lights.infLight)
        %             end
        %             if isfield(mainGuiData.lights,'rightLatLight')
        %                 delete(mainGuiData.lights.rightLatLight)
        %             end
        %             if isfield(mainGuiData.lights,'postLight')
        %                 delete(mainGuiData.lights.postLight)
        %             end
        %             if isfield(mainGuiData.lights,'antLight')
        %                 delete(mainGuiData.lights.antLight)
        %             end
        %         end
        
        % now change overlay(s)
        currSelection = (mainGuiData.overlaySelection.Value - 1);
        if isfield(mainGuiData.brainMap.Current{currSelection},'overlay')
            % loop over overlays
            for overlayi = 1:length(mainGuiData.brainMap.Current)
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularStrength = str2num(handles.specularStrength.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularExponent = str2num(handles.specularExponent.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularColorReflectance = str2num(handles.specularReflectance.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.DiffuseStrength = str2num(handles.diffusionStrength.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.AmbientStrength = str2num(handles.ambientStrength.String{1});
            end
        end
        
        if isfield(mainGuiData.opts,'colorbar')
            delete(mainGuiData.opts.colorbar)
            replot = 1;
        else
            replot = 0;
        end
        
        % add lights
        %         figure(mainGuiData.brainFig)
        %         view(-90, 0);
        %         mainGuiData.lights.leftlatLight = camlight(0,0);
        %         mainGuiData.lights.rightLatLight = camlight(180,0);
        %         mainGuiData.lights.antLight = camlight(-90,0);
        %         mainGuiData.lights.postLight = camlight(90,0);
        %         mainGuiData.lights.supLight = camlight(180,90);
        
        % see if replot is needed
        figure(mainGuiData.brainFig)
        if replot == 1
            mainGuiData.opts.colorbar = cbar;
            mainGuiData.opts.colorbar.TickLength = [0 0];
            imh = mainGuiData.opts.colorbar.Children(1);
            imh.AlphaData = mainGuiData.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
    case 'Flat with brighter edges'
        % update handles
        if handles.overlayButton.Value == 1
            handles.specularStrength.String{1} = '0';
            handles.specularExponent.String{1} = '1';
            handles.specularReflectance.String{1} = '0.6';
            handles.diffusionStrength.String{1} = '0.75';
            handles.ambientStrength.String{1} = '0';
        end
        
        % remove all lights
        %         figure(mainGuiData.brainFig)
        %         delete(findall(gcf,'Type','light'))
        %         if isfield(mainGuiData.lights,'supLight')
        %             delete(mainGuiData.lights.supLight)
        %         end
        %         if isfield(mainGuiData.lights,'leftlatLight')
        %             delete(mainGuiData.lights.leftlatLight)
        %         end
        %         if isfield(mainGuiData.lights,'infLight')
        %             delete(mainGuiData.lights.infLight)
        %         end
        %         if isfield(mainGuiData.lights,'rightLatLight')
        %             delete(mainGuiData.lights.rightLatLight)
        %         end
        %         if isfield(mainGuiData.lights,'postLight')
        %             delete(mainGuiData.lights.postLight)
        %         end
        %         if isfield(mainGuiData.lights,'antLight')
        %             delete(mainGuiData.lights.antLight)
        %         end
        
        % now change overlay(s)
        currSelection = (mainGuiData.overlaySelection.Value - 1);
        if isfield(mainGuiData.brainMap.Current{currSelection},'overlay')
            % loop over overlays
            for overlayi = 1:length(mainGuiData.brainMap.Current)
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularStrength = str2num(handles.specularStrength.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularExponent = str2num(handles.specularExponent.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularColorReflectance = str2num(handles.specularReflectance.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.DiffuseStrength = str2num(handles.diffusionStrength.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.AmbientStrength = str2num(handles.ambientStrength.String{1});
            end
        end
        
        if isfield(mainGuiData.opts,'colorbar')
            delete(mainGuiData.opts.colorbar)
            replot = 1;
        else
            replot = 0;
        end
        
        % add lights
        %         figure(mainGuiData.brainFig)
        %         view(-90, 0);
        %         mainGuiData.lights.leftlatLight = camlight(0,0);
        %         mainGuiData.lights.rightLatLight = camlight(180,0);
        %         mainGuiData.lights.antLight = camlight(-90,0);
        %         mainGuiData.lights.postLight = camlight(90,0);
        %         mainGuiData.lights.supLight = camlight(180,90);
        
        % see if replot is needed
        figure(mainGuiData.brainFig)
        if replot == 1
            mainGuiData.opts.colorbar = cbar;
            mainGuiData.opts.colorbar.TickLength = [0 0];
            imh = mainGuiData.opts.colorbar.Children(1);
            imh.AlphaData = mainGuiData.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        
    case 'Brighter flat'
        % update handles
        if handles.overlayButton.Value == 1
            handles.specularStrength.String{1} = '0';
            handles.specularExponent.String{1} = '1';
            handles.specularReflectance.String{1} = '0.6';
            handles.diffusionStrength.String{1} = '0';
            handles.ambientStrength.String{1} = '1';
        end
        
        % remove all lights
        %         figure(mainGuiData.brainFig)
        %         delete(findall(gcf,'Type','light'))
        %         if isfield(mainGuiData.lights,'supLight')
        %             delete(mainGuiData.lights.supLight)
        %         end
        %         if isfield(mainGuiData.lights,'leftlatLight')
        %             delete(mainGuiData.lights.leftlatLight)
        %         end
        %         if isfield(mainGuiData.lights,'infLight')
        %             delete(mainGuiData.lights.infLight)
        %         end
        %         if isfield(mainGuiData.lights,'rightLatLight')
        %             delete(mainGuiData.lights.rightLatLight)
        %         end
        %         if isfield(mainGuiData.lights,'postLight')
        %             delete(mainGuiData.lights.postLight)
        %         end
        %         if isfield(mainGuiData.lights,'antLight')
        %             delete(mainGuiData.lights.antLight)
        %         end
        
        % now change overlay(s)
        currSelection = (mainGuiData.overlaySelection.Value - 1);
        if isfield(mainGuiData.brainMap.Current{currSelection},'overlay')
            % loop over overlays
            for overlayi = 1:length(mainGuiData.brainMap.Current)
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularStrength = str2num(handles.specularStrength.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularExponent = str2num(handles.specularExponent.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularColorReflectance = str2num(handles.specularReflectance.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.DiffuseStrength = str2num(handles.diffusionStrength.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.AmbientStrength = str2num(handles.ambientStrength.String{1});
            end
        end
        
        if isfield(mainGuiData.opts,'colorbar')
            delete(mainGuiData.opts.colorbar)
            replot = 1;
        else
            replot = 0;
        end
        
        % add lights
        %         figure(mainGuiData.brainFig)
        %         view(-90, 0);
        %         mainGuiData.lights.leftlatLight = camlight(0,0);
        %         mainGuiData.lights.rightLatLight = camlight(180,0);
        %         mainGuiData.lights.antLight = camlight(-90,0);
        %         mainGuiData.lights.postLight = camlight(90,0);
        %         mainGuiData.lights.supLight = camlight(180,90);
        
        % see if replot is needed
        figure(mainGuiData.brainFig)
        if replot == 1
            mainGuiData.opts.colorbar = cbar;
            mainGuiData.opts.colorbar.TickLength = [0 0];
            imh = mainGuiData.opts.colorbar.Children(1);
            imh.AlphaData = mainGuiData.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        
    case 'Brightest flat'
        % update handles
        if handles.overlayButton.Value == 1
            handles.specularStrength.String{1} = '0.0008';
            handles.specularExponent.String{1} = '1';
            handles.specularReflectance.String{1} = '1';
            handles.diffusionStrength.String{1} = '0.001';
            handles.ambientStrength.String{1} = '1';
        end
        
        % remove all lights
        %         figure(mainGuiData.brainFig)
        %         delete(findall(gcf,'Type','light'))
        %         if isfield(mainGuiData.lights,'supLight')
        %             delete(mainGuiData.lights.supLight)
        %         end
        %         if isfield(mainGuiData.lights,'leftlatLight')
        %             delete(mainGuiData.lights.leftlatLight)
        %         end
        %         if isfield(mainGuiData.lights,'infLight')
        %             delete(mainGuiData.lights.infLight)
        %         end
        %         if isfield(mainGuiData.lights,'rightLatLight')
        %             delete(mainGuiData.lights.rightLatLight)
        %         end
        %         if isfield(mainGuiData.lights,'postLight')
        %             delete(mainGuiData.lights.postLight)
        %         end
        %         if isfield(mainGuiData.lights,'antLight')
        %             delete(mainGuiData.lights.antLight)
        %         end
        
        % now change overlay(s)
        currSelection = (mainGuiData.overlaySelection.Value - 1);
        if isfield(mainGuiData.brainMap.Current{currSelection},'overlay')
            % loop over overlays
            for overlayi = 1:length(mainGuiData.brainMap.Current)
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularStrength = str2num(handles.specularStrength.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularExponent = str2num(handles.specularExponent.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularColorReflectance = str2num(handles.specularReflectance.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.DiffuseStrength = str2num(handles.diffusionStrength.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.AmbientStrength = str2num(handles.ambientStrength.String{1});
            end
        end
        
        if isfield(mainGuiData.opts,'colorbar')
            delete(mainGuiData.opts.colorbar)
            replot = 1;
        else
            replot = 0;
        end
        
        % add lights
        %         figure(mainGuiData.brainFig)
        %         view(-90, 0);
        %         mainGuiData.lights.inferiorLighting = camlight(180,180);
        
        % see if replot is needed
        figure(mainGuiData.brainFig)
        if replot == 1
            mainGuiData.opts.colorbar = cbar;
            mainGuiData.opts.colorbar.TickLength = [0 0];
            imh = mainGuiData.opts.colorbar.Children(1);
            imh.AlphaData = mainGuiData.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        
    case 'Desaturated'
        % update handles
        if handles.overlayButton.Value == 1
            handles.specularStrength.String{1} = '0.1';
            handles.specularExponent.String{1} = '2';
            handles.specularReflectance.String{1} = '0.5';
            handles.diffusionStrength.String{1} = '0.5';
            handles.ambientStrength.String{1} = '0';
        end
        
        % remove all lights
        %         figure(mainGuiData.brainFig)
        %         delete(findall(gcf,'Type','light'))
        %         if isfield(mainGuiData.lights,'supLight')
        %             delete(mainGuiData.lights.supLight)
        %         end
        %         if isfield(mainGuiData.lights,'leftlatLight')
        %             delete(mainGuiData.lights.leftlatLight)
        %         end
        %         if isfield(mainGuiData.lights,'infLight')
        %             delete(mainGuiData.lights.infLight)
        %         end
        %         if isfield(mainGuiData.lights,'rightLatLight')
        %             delete(mainGuiData.lights.rightLatLight)
        %         end
        %         if isfield(mainGuiData.lights,'postLight')
        %             delete(mainGuiData.lights.postLight)
        %         end
        %         if isfield(mainGuiData.lights,'antLight')
        %             delete(mainGuiData.lights.antLight)
        %         end
        
        % now change overlay(s)
        currSelection = (mainGuiData.overlaySelection.Value - 1);
        if isfield(mainGuiData.brainMap.Current{currSelection},'overlay')
            % loop over overlays
            for overlayi = 1:length(mainGuiData.brainMap.Current)
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularStrength = str2num(handles.specularStrength.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularExponent = str2num(handles.specularExponent.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularColorReflectance = str2num(handles.specularReflectance.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.DiffuseStrength = str2num(handles.diffusionStrength.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.AmbientStrength = str2num(handles.ambientStrength.String{1});
            end
        end
        
        if isfield(mainGuiData.opts,'colorbar')
            delete(mainGuiData.opts.colorbar)
            replot = 1;
        else
            replot = 0;
        end
        
        % add lights
        %         figure(mainGuiData.brainFig)
        %         view(-90, 0);
        %         mainGuiData.lights.leftlatLight = camlight(0,0);
        %         mainGuiData.lights.rightLatLight = camlight(180,0);
        %         mainGuiData.lights.antLight = camlight(-90,0);
        %         mainGuiData.lights.postLight = camlight(90,0);
        %         mainGuiData.lights.supLight = camlight(180,90);
        
        % see if replot is needed
        figure(mainGuiData.brainFig)
        if replot == 1
            mainGuiData.opts.colorbar = cbar;
            mainGuiData.opts.colorbar.TickLength = [0 0];
            imh = mainGuiData.opts.colorbar.Children(1);
            imh.AlphaData = mainGuiData.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        
    case 'realistic'
        % update handles
        if handles.overlayButton.Value == 1
            handles.specularStrength.String{1} = '0.0008';
            handles.specularExponent.String{1} = '1';
            handles.specularReflectance.String{1} = '1';
            handles.diffusionStrength.String{1} = '0.001';
            handles.ambientStrength.String{1} = '0.8';
        end
        
        % remove all lights
        %         figure(mainGuiData.brainFig)
        %         delete(findall(gcf,'Type','light'))
        %         if isfield(mainGuiData.lights,'supLight')
        %             delete(mainGuiData.lights.supLight)
        %         end
        %         if isfield(mainGuiData.lights,'leftlatLight')
        %             delete(mainGuiData.lights.leftlatLight)
        %         end
        %         if isfield(mainGuiData.lights,'infLight')
        %             delete(mainGuiData.lights.infLight)
        %         end
        %         if isfield(mainGuiData.lights,'rightLatLight')
        %             delete(mainGuiData.lights.rightLatLight)
        %         end
        %         if isfield(mainGuiData.lights,'postLight')
        %             delete(mainGuiData.lights.postLight)
        %         end
        %         if isfield(mainGuiData.lights,'antLight')
        %             delete(mainGuiData.lights.antLight)
        %         end
        
        % now change overlay(s)
        currSelection = (mainGuiData.overlaySelection.Value - 1);
        if isfield(mainGuiData.brainMap.Current{currSelection},'overlay')
            % loop over overlays
            for overlayi = 1:length(mainGuiData.brainMap.Current)
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularStrength = str2num(handles.specularStrength.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularExponent = str2num(handles.specularExponent.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularColorReflectance = str2num(handles.specularReflectance.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.DiffuseStrength = str2num(handles.diffusionStrength.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.AmbientStrength = str2num(handles.ambientStrength.String{1});
            end
        end
        
        if isfield(mainGuiData.opts,'colorbar')
            delete(mainGuiData.opts.colorbar)
            replot = 1;
        else
            replot = 0;
        end
        
        % add lights
        %         figure(mainGuiData.brainFig)
        %         view(-90, 0);
        %         mainGuiData.lights.supLight = camlight(180,90);
        
        % see if replot is needed
        figure(mainGuiData.brainFig)
        if replot == 1
            mainGuiData.opts.colorbar = cbar;
            mainGuiData.opts.colorbar.TickLength = [0 0];
            imh = mainGuiData.opts.colorbar.Children(1);
            imh.AlphaData = mainGuiData.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        
    case 'pop'
        % update handles
        if handles.overlayButton.Value == 1
            handles.specularStrength.String{1} = '0.0008';
            handles.specularExponent.String{1} = '1';
            handles.specularReflectance.String{1} = '1';
            handles.diffusionStrength.String{1} = '0.9';
            handles.ambientStrength.String{1} = '0.9';
        end
        
        % remove all lights
        %         figure(mainGuiData.brainFig)
        %         delete(findall(gcf,'Type','light'))
        %         if isfield(mainGuiData.lights,'supLight')
        %             delete(mainGuiData.lights.supLight)
        %         end
        %         if isfield(mainGuiData.lights,'leftlatLight')
        %             delete(mainGuiData.lights.leftlatLight)
        %         end
        %         if isfield(mainGuiData.lights,'infLight')
        %             delete(mainGuiData.lights.infLight)
        %         end
        %         if isfield(mainGuiData.lights,'rightLatLight')
        %             delete(mainGuiData.lights.rightLatLight)
        %         end
        %         if isfield(mainGuiData.lights,'postLight')
        %             delete(mainGuiData.lights.postLight)
        %         end
        %         if isfield(mainGuiData.lights,'antLight')
        %             delete(mainGuiData.lights.antLight)
        %         end
        
        % now change overlay(s)
        currSelection = (mainGuiData.overlaySelection.Value - 1);
        if isfield(mainGuiData.brainMap.Current{currSelection},'overlay')
            % loop over overlays
            for overlayi = 1:length(mainGuiData.brainMap.Current)
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularStrength = str2num(handles.specularStrength.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularExponent = str2num(handles.specularExponent.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.SpecularColorReflectance = str2num(handles.specularReflectance.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.DiffuseStrength = str2num(handles.diffusionStrength.String{1});
                mainGuiData.brainMap.Current{overlayi}.overlay.AmbientStrength = str2num(handles.ambientStrength.String{1});
            end
        end
        
        if isfield(mainGuiData.opts,'colorbar')
            delete(mainGuiData.opts.colorbar)
            replot = 1;
        else
            replot = 0;
        end
        
        % add lights
        %         figure(mainGuiData.brainFig)
        %         view(-90, 0);
        %         mainGuiData.lights.supLight = camlight(180,90);
        
        % see if replot is needed
        figure(mainGuiData.brainFig)
        if replot == 1
            mainGuiData.opts.colorbar = cbar;
            mainGuiData.opts.colorbar.TickLength = [0 0];
            imh = mainGuiData.opts.colorbar.Children(1);
            imh.AlphaData = mainGuiData.opts.transparencyData;
            imh.AlphaDataMapping = 'direct';
        end
        
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
