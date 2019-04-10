function varargout = colormapEditorfig(varargin)
% COLORMAPEDITORFIG MATLAB code for colormapEditorfig.fig
%      COLORMAPEDITORFIG, by itself, creates a new COLORMAPEDITORFIG or raises the existing
%      singleton*.
%
%      H = COLORMAPEDITORFIG returns the handle to a new COLORMAPEDITORFIG or the handle to
%      the existing singleton*.
%
%      COLORMAPEDITORFIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COLORMAPEDITORFIG.M with the given input arguments.
%
%      COLORMAPEDITORFIG('Property','Value',...) creates a new COLORMAPEDITORFIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before colormapEditorfig_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to colormapEditorfig_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help colormapEditorfig

% Last Modified by GUIDE v2.5 01-Apr-2019 23:01:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @colormapEditorfig_OpeningFcn, ...
                   'gui_OutputFcn',  @colormapEditorfig_OutputFcn, ...
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


% --- Executes just before colormapEditorfig is made visible.
function colormapEditorfig_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to colormapEditorfig (see VARARGIN)

% Choose default command line output for colormapEditorfig
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

% get cMap
options.colorBins = 1000;
handles.colormapName = handles.selectButton.String{handles.selectButton.Value};
if mainGuiData.colormapCustom(handles.selectButton.Value) ~= 1
    switch handles.colormapName
        case 'jet'
            handles.cMap = jet(options.colorBins);
        case 'parula'
            handles.cMap = parula(options.colorBins);
        case 'hsv'
            handles.cMap = hsv(options.colorBins);
        case 'hot'
            handles.cMap = hot(options.colorBins);
        case 'cool'
            handles.cMap = cool(options.colorBins);
        case 'spring'
            handles.cMap = spring(options.colorBins);
        case 'summer'
            handles.cMap = summer(options.colorBins);
        case 'autumn'
            handles.cMap = autumn(options.colorBins);
        case 'winter'
            handles.cMap = winter(options.colorBins);
        case 'gray'
            handles.cMap = gray(options.colorBins);
        case 'bone'
            handles.cMap = bone(options.colorBins);
        case 'copper'
            handles.cMap = copper(options.colorBins);
        case 'pink'
            handles.cMap = pink(options.colorBins);
        case 'lines'
            handles.cMap = lines(options.colorBins);
        case 'colorcube'
            handles.cMap = colorcube(options.colorBins);
        case 'prism'
            handles.cMap = prism(options.colorBins);
        case 'Spectral'
            handles.cMap=cbrewer('div', options.colorMap, options.colorBins);
        case 'RdYlBu'
            handles.cMap = cbrewer('div', options.colorMap, options.colorBins);
        case 'RdGy'
            handles.cMap = cbrewer('div', options.colorMap, options.colorBins);
        case 'RdBu'
            handles.cMap = cbrewer('div', options.colorMap, options.colorBins);
        case 'PuOr'
            handles.cMap = cbrewer('div', options.colorMap, options.colorBins);
        case 'PRGn'
            handles.cMap = cbrewer('div', options.colorMap, options.colorBins);
        case 'PiYG'
            handles.cMap = cbrewer('div', options.colorMap, options.colorBins);
        case 'BrBG'
            handles.cMap = cbrewer('div', options.colorMap, options.colorBins);
        case 'YlOrRd'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'YlOrBr'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'YlGnBu'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'YlGn'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'Reds'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'RdPu'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'Purples'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'PuRd'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'PuBuGn'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'PuBu'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'OrRd'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'Oranges'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'Greys'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'Greens'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'GnBu'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'BuPu'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'BuGn'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'Blues'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'Set3'
            handles.cMap = cbrewer('qual', options.colorMap, options.colorBins);
        case 'Set2'
            handles.cMap = cbrewer('qual', options.colorMap, options.colorBins);
        case 'Set1'
            handles.cMap = cbrewer('qual', options.colorMap, options.colorBins);
        case 'Pastel2'
            handles.cMap = cbrewer('qual', options.colorMap, options.colorBins);
        case 'Pastel1'
            handles.cMap = cbrewer('qual', options.colorMap, options.colorBins);
        case 'Paired'
            handles.cMap = cbrewer('qual', options.colorMap, options.colorBins);
        case 'Dark2'
            handles.cMap = cbrewer('qual', options.colorMap, options.colorBins);
        case 'Accent'
            handles.cMap = cbrewer('qual', options.colorMap, options.colorBins);
        case 'inferno'
            handles.cMap = inferno(options.colorBins);
        case 'plasma'
            handles.cMap = plasma(options.colorBins);
        case 'vega10'
            handles.cMap = vega10(options.colorBins);
        case 'vega20b'
            handles.cMap = vega20b(options.colorBins);
        case 'vega20c'
            handles.cMap = vega20c(options.colorBins);
        case 'viridis'
            handles.cMap = viridis(options.colorBins);
        case 'thermal'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'haline'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'solar'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'ice'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'oxy'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'deep'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'dense'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'algae'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'matter'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'turbid'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'speed'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'amp'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'tempo'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'balance'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'delta'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'curl'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'phase'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'perceptually distinct'
            handles.cMap = distinguishable_colors(options.colorBins);
    end
    handles.customColor = 0;
else
    handles.customColor = load([mainGuiData.paths.colormapsPath mainGuiData.paths.slash mainGuiData.colormap.String{handles.selectButton.Value} '.mat']);    
    if isa(handles.customColor,'struct') == 1
        field = fieldnames(handles.customColor);
        handles.customColor = handles.customColor.(field{1});
        %handles.colorBins.String = num2str(length(handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor));
        %handles.brainMap.Current{handles.overlaySelection.Value - 1}.colorBins = length(handles.brainMap.Current{handles.overlaySelection.Value - 1}.customColor);
    end
    handles.cMap = handles.customColor;
    %handles.customColor = 1;
end

% update images
axes(handles.allColor)
handles.cMapImage = reshape(handles.cMap,[size(handles.cMap,1),1,3]);
handles.cMapImageR = imrotate(handles.cMapImage,90);
handles.cMapImageH = image(handles.cMapImageR);

set(handles.allColor,'xtick',[])
set(handles.allColor,'xticklabel',[])
set(handles.allColor,'ytick',[])
set(handles.allColor,'yticklabel',[])

if handles.mToggle.Value == 1
    handles.rVal = handles.cMap(ceil(length(handles.cMap)/2),1);
    handles.gVal = handles.cMap(ceil(length(handles.cMap)/2),2);
    handles.bVal = handles.cMap(ceil(length(handles.cMap)/2),3);
    
elseif handles.lToggle.Value == 1
    handles.rVal = handles.cMap(1,1);
    handles.gVal = handles.cMap(1,2);
    handles.bVal = handles.cMap(1,3);
    
elseif handles.rToggle.Value == 1
    handles.rVal = handles.cMap(end,1);
    handles.gVal = handles.cMap(end,2);
    handles.bVal = handles.cMap(end,3);
end

handles.rSlider.Value = handles.rVal;
handles.gSlider.Value = handles.gVal;
handles.bSlider.Value = handles.bVal;

handles.edit1.String = num2str(handles.rVal);
handles.edit4.String = num2str(handles.gVal);
handles.edit5.String = num2str(handles.bVal);

axes(handles.currColor)
handles.curImage = reshape([handles.rVal handles.gVal handles.bVal],[1,1,3]);
handles.cMapImageH = image(handles.curImage);

set(handles.currColor,'xtick',[])
set(handles.currColor,'xticklabel',[])
set(handles.currColor,'ytick',[])
set(handles.currColor,'yticklabel',[])

% Update handles structure
guidata(h(mainGuiNum), mainGuiData);
guidata(hObject, handles);
% UIWAIT makes colormapEditorfig wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = colormapEditorfig_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
handles = guidata(hObject);

handles.rSlider.Value = str2double(handles.edit1.String);
handles.rVal = handles.rSlider.Value;
handles.edit1.String = num2str(handles.rSlider.Value);

axes(handles.currColor)
handles.curImage = reshape([handles.rVal handles.gVal handles.bVal],[1,1,3]);
handles.cMapImageH = image(handles.curImage);

set(handles.currColor,'xtick',[])
set(handles.currColor,'xticklabel',[])
set(handles.currColor,'ytick',[])
set(handles.currColor,'yticklabel',[])
guidata(hObject, handles);

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


% --- Executes on slider movement.
function rSlider_Callback(hObject, eventdata, handles)
% hObject    handle to rSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles = guidata(hObject);

handles.rVal = handles.rSlider.Value;
handles.edit1.String = num2str(handles.rSlider.Value);

axes(handles.currColor)
handles.curImage = reshape([handles.rVal handles.gVal handles.bVal],[1,1,3]);
handles.cMapImageH = image(handles.curImage);

set(handles.currColor,'xtick',[])
set(handles.currColor,'xticklabel',[])
set(handles.currColor,'ytick',[])
set(handles.currColor,'yticklabel',[])

% handles.rSlider.Value = handles.rVal;
% handles.gSlider.Value = handles.gVal;
% handles.bSlider.Value = handles.bVal;
% 
% handles.edit1.String = num2str(handles.rVal);
% handles.edit4.String = num2str(handles.gVal);
% handles.edit5.String = num2str(handles.bVal);
% 
% axes(handles.currColor)
% handles.curImage = reshape([handles.rVal handles.gVal handles.bVal],[1,1,3]);
% handles.cMapImageH = image(handles.curImage);
% 
% set(handles.currColor,'xtick',[])
% set(handles.currColor,'xticklabel',[])
% set(handles.currColor,'ytick',[])
% set(handles.currColor,'yticklabel',[])

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function rSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function gSlider_Callback(hObject, eventdata, handles)
% hObject    handle to gSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles = guidata(hObject);

handles.gVal = handles.gSlider.Value;
handles.edit4.String = num2str(handles.gSlider.Value);

axes(handles.currColor)
handles.curImage = reshape([handles.rVal handles.gVal handles.bVal],[1,1,3]);
handles.cMapImageH = image(handles.curImage);

set(handles.currColor,'xtick',[])
set(handles.currColor,'xticklabel',[])
set(handles.currColor,'ytick',[])
set(handles.currColor,'yticklabel',[])
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function gSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function bSlider_Callback(hObject, eventdata, handles)
% hObject    handle to bSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles = guidata(hObject);

handles.bVal = handles.bSlider.Value;
handles.edit5.String = num2str(handles.bSlider.Value);

axes(handles.currColor)
handles.curImage = reshape([handles.rVal handles.gVal handles.bVal],[1,1,3]);
handles.cMapImageH = image(handles.curImage);

set(handles.currColor,'xtick',[])
set(handles.currColor,'xticklabel',[])
set(handles.currColor,'ytick',[])
set(handles.currColor,'yticklabel',[])
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function bSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
handles = guidata(hObject);

handles.gSlider.Value = str2double(handles.edit4.String);
handles.gVal = handles.gSlider.Value;

axes(handles.currColor)
handles.curImage = reshape([handles.rVal handles.gVal handles.bVal],[1,1,3]);
handles.cMapImageH = image(handles.curImage);

set(handles.currColor,'xtick',[])
set(handles.currColor,'xticklabel',[])
set(handles.currColor,'ytick',[])
set(handles.currColor,'yticklabel',[])
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double
handles = guidata(hObject);

handles.bSlider.Value = str2double(handles.edit5.String);
handles.bVal = handles.bSlider.Value;

axes(handles.currColor)
handles.curImage = reshape([handles.rVal handles.gVal handles.bVal],[1,1,3]);
handles.cMapImageH = image(handles.curImage);

set(handles.currColor,'xtick',[])
set(handles.currColor,'xticklabel',[])
set(handles.currColor,'ytick',[])
set(handles.currColor,'yticklabel',[])
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
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
handles = guidata(hObject); 
handles.colormapName = handles.selectButton.String{handles.selectButton.Value};

handles.output = hObject;
h = get(0,'Children');
% find brain surfer
for hi = 1:length(h)
    if strcmp(h(hi).Name,'Brain Surfer') == 1
        mainGuiNum = hi;
    end
end
mainGuiData = guidata(h(mainGuiNum));
options.colorBins = 1000;

if mainGuiData.colormapCustom(handles.selectButton.Value) ~= 1
    switch handles.colormapName
        case 'jet'
            handles.cMap = jet(options.colorBins);
        case 'parula'
            handles.cMap = parula(options.colorBins);
        case 'hsv'
            handles.cMap = hsv(options.colorBins);
        case 'hot'
            handles.cMap = hot(options.colorBins);
        case 'cool'
            handles.cMap = cool(options.colorBins);
        case 'spring'
            handles.cMap = spring(options.colorBins);
        case 'summer'
            handles.cMap = summer(options.colorBins);
        case 'autumn'
            handles.cMap = autumn(options.colorBins);
        case 'winter'
            handles.cMap = winter(options.colorBins);
        case 'gray'
            handles.cMap = gray(options.colorBins);
        case 'bone'
            handles.cMap = bone(options.colorBins);
        case 'copper'
            handles.cMap = copper(options.colorBins);
        case 'pink'
            handles.cMap = pink(options.colorBins);
        case 'lines'
            handles.cMap = lines(options.colorBins);
        case 'colorcube'
            handles.cMap = colorcube(options.colorBins);
        case 'prism'
            handles.cMap = prism(options.colorBins);
        case 'Spectral'
            handles.cMap=cbrewer('div', options.colorMap, options.colorBins);
        case 'RdYlBu'
            handles.cMap = cbrewer('div', options.colorMap, options.colorBins);
        case 'RdGy'
            handles.cMap = cbrewer('div', options.colorMap, options.colorBins);
        case 'RdBu'
            handles.cMap = cbrewer('div', options.colorMap, options.colorBins);
        case 'PuOr'
            handles.cMap = cbrewer('div', options.colorMap, options.colorBins);
        case 'PRGn'
            handles.cMap = cbrewer('div', options.colorMap, options.colorBins);
        case 'PiYG'
            handles.cMap = cbrewer('div', options.colorMap, options.colorBins);
        case 'BrBG'
            handles.cMap = cbrewer('div', options.colorMap, options.colorBins);
        case 'YlOrRd'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'YlOrBr'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'YlGnBu'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'YlGn'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'Reds'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'RdPu'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'Purples'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'PuRd'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'PuBuGn'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'PuBu'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'OrRd'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'Oranges'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'Greys'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'Greens'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'GnBu'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'BuPu'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'BuGn'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'Blues'
            handles.cMap = cbrewer('seq', options.colorMap, options.colorBins);
        case 'Set3'
            handles.cMap = cbrewer('qual', options.colorMap, options.colorBins);
        case 'Set2'
            handles.cMap = cbrewer('qual', options.colorMap, options.colorBins);
        case 'Set1'
            handles.cMap = cbrewer('qual', options.colorMap, options.colorBins);
        case 'Pastel2'
            handles.cMap = cbrewer('qual', options.colorMap, options.colorBins);
        case 'Pastel1'
            handles.cMap = cbrewer('qual', options.colorMap, options.colorBins);
        case 'Paired'
            handles.cMap = cbrewer('qual', options.colorMap, options.colorBins);
        case 'Dark2'
            handles.cMap = cbrewer('qual', options.colorMap, options.colorBins);
        case 'Accent'
            handles.cMap = cbrewer('qual', options.colorMap, options.colorBins);
        case 'inferno'
            handles.cMap = inferno(options.colorBins);
        case 'plasma'
            handles.cMap = plasma(options.colorBins);
        case 'vega10'
            handles.cMap = vega10(options.colorBins);
        case 'vega20b'
            handles.cMap = vega20b(options.colorBins);
        case 'vega20c'
            handles.cMap = vega20c(options.colorBins);
        case 'viridis'
            handles.cMap = viridis(options.colorBins);
        case 'thermal'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'haline'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'solar'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'ice'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'oxy'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'deep'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'dense'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'algae'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'matter'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'turbid'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'speed'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'amp'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'tempo'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'balance'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'delta'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'curl'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'phase'
            handles.cMap = cmocean(options.colorMap, options.colorBins);
        case 'perceptually distinct'
            handles.cMap = distinguishable_colors(options.colorBins);
    end
    handles.customColor = 0;
else
    %handles.customColor = load([mainGuiData.paths.colormapsPath mainGuiData.paths.slash mainGuiData.colormap.String{handles.selectButton.Value} '.mat']);    
    handles.cMap = handles.customColor;
    %handles.customColor = 1;
end
  
axes(handles.allColor)
handles.cMapImage = reshape(handles.cMap,[size(handles.cMap,1),1,3]);
handles.cMapImageR = imrotate(handles.cMapImage,90);
handles.cMapImageH = image(handles.cMapImageR);

set(handles.allColor,'xtick',[])
set(handles.allColor,'xticklabel',[])
set(handles.allColor,'ytick',[])
set(handles.allColor,'yticklabel',[])

if handles.mToggle.Value == 1
    handles.rVal = handles.cMap(ceil(length(handles.cMap)/2),1);
    handles.gVal = handles.cMap(ceil(length(handles.cMap)/2),2);
    handles.bVal = handles.cMap(ceil(length(handles.cMap)/2),3);
    
elseif handles.lToggle.Value == 1
    handles.rVal = handles.cMap(1,1);
    handles.gVal = handles.cMap(1,2);
    handles.bVal = handles.cMap(1,3);
    
elseif handles.rToggle.Value == 1
    handles.rVal = handles.cMap(end,1);
    handles.gVal = handles.cMap(end,2);
    handles.bVal = handles.cMap(end,3);
end

handles.rSlider.Value = handles.rVal;
handles.gSlider.Value = handles.gVal;
handles.bSlider.Value = handles.bVal;

handles.edit1.String = num2str(handles.rVal);
handles.edit4.String = num2str(handles.gVal);
handles.edit5.String = num2str(handles.bVal);

axes(handles.currColor)
handles.curImage = reshape([handles.rVal handles.gVal handles.bVal],[1,1,3]);
handles.cMapImageH = image(handles.curImage);

set(handles.currColor,'xtick',[])
set(handles.currColor,'xticklabel',[])
set(handles.currColor,'ytick',[])
set(handles.currColor,'yticklabel',[])

guidata(h(mainGuiNum), mainGuiData);
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


% --- Executes on button press in saveColor.
function saveColor_Callback(hObject, eventdata, handles)
% hObject    handle to saveColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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
customColor = handles.cMap;

[oFile, oPath] = uiputfile({'*.mat'},'Pick a name for your colormap',[mainGuiData.paths.colormapsPath mainGuiData.paths.slash 'colormap']);
save([oPath oFile]','customColor')

mainGuiData.colormapCustom = vertcat(mainGuiData.colormapCustom,1);
mainGuiData.colormap.String = vertcat(mainGuiData.colormap.String,oFile(1:end-4));
mainGuiData.colormap.Value = length(mainGuiData.colormap.String);
mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.colormap = length(mainGuiData.colormap.String);
mainGuiData.brainMap.Current{mainGuiData.overlaySelection.Value - 1}.customColor = customColor;

% remove colorbar if it exists
if isfield(mainGuiData.brainMap,'colorbar')
    delete(mainGuiData.brainMap.colorbar)
    mainGuiData.brainMap = rmfield(mainGuiData.brainMap,'colorbar');
    replot = 1;
else
    replot = 0;
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

if isfield(mainGuiData.overlayCopy,'overlayCopy')
    mainGuiData.overlayCopy.brainMap.overlay.SpecularStrength = mainGuiData.overlayCopy.overlayCopy.SpecularStrength;
    mainGuiData.overlayCopy.brainMap.overlay.SpecularExponent = mainGuiData.overlayCopy.overlayCopy.SpecularExponent;
    mainGuiData.overlayCopy.brainMap.overlay.SpecularColorReflectance =  mainGuiData.overlayCopy.overlayCopy.SpecularColorReflectance;
    mainGuiData.overlayCopy.brainMap.overlay.DiffuseStrength = mainGuiData.overlayCopy.overlayCopy.DiffuseStrength;
    mainGuiData.overlayCopy.brainMap.overlay.AmbientStrength =  mainGuiData.overlayCopy.overlayCopy.AmbientStrength;
end

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

h = get(0,'Children');
% find transparencyFig
for hi = 1:length(h)
    if strcmp(h(hi).Name,'colormap editor') == 1
        close(h(hi))
    end
end

% --- Executes on button press in applyButton.
function applyButton_Callback(hObject, eventdata, handles)
% hObject    handle to applyButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);

if handles.checkbox1.Value ~= 1
    if handles.rToggle.Value == 1
        tmp1 = customColorMapInterp([handles.cMap(1,1) handles.cMap(1,2) handles.cMap(1,3); handles.cMap(ceil(length(handles.cMap)/2),1) handles.cMap(ceil(length(handles.cMap)/2),2) handles.cMap(ceil(length(handles.cMap)/2),3)],500);
        tmp2 = customColorMapInterp([handles.cMap(ceil(length(handles.cMap)/2),1) handles.cMap(ceil(length(handles.cMap)/2),2) handles.cMap(ceil(length(handles.cMap)/2),3); handles.rVal handles.gVal handles.bVal],500);
    elseif handles.lToggle.Value == 1
        tmp1 = customColorMapInterp([handles.rVal handles.gVal handles.bVal; handles.cMap(ceil(length(handles.cMap)/2),1) handles.cMap(ceil(length(handles.cMap)/2),2) handles.cMap(ceil(length(handles.cMap)/2),3)],500);
        tmp2 = customColorMapInterp([handles.cMap(ceil(length(handles.cMap)/2),1) handles.cMap(ceil(length(handles.cMap)/2),2) handles.cMap(ceil(length(handles.cMap)/2),3); handles.cMap(end,1) handles.cMap(end,2) handles.cMap(end,3)],500);
    elseif handles.mToggle.Value == 1
        tmp1 = customColorMapInterp([handles.cMap(1,1) handles.cMap(1,2) handles.cMap(1,3); handles.rVal handles.gVal handles.bVal],500);
        tmp2 = customColorMapInterp([handles.rVal handles.gVal handles.bVal; handles.cMap(end,1) handles.cMap(end,2) handles.cMap(end,3)],500);
    end
    handles.cMap = vertcat(tmp1,tmp2);
else
    if handles.lToggle.Value == 1
        handles.cMap = customColorMapInterp([handles.rVal handles.gVal handles.bVal; handles.cMap(end,1) handles.cMap(end,2) handles.cMap(end,3)],1000);
    elseif handles.rToggle.Value == 1
        handles.cMap = customColorMapInterp([handles.cMap(1,1) handles.cMap(1,2) handles.cMap(1,3); handles.rVal handles.gVal handles.bVal],1000);
    end
    
end

axes(handles.allColor)
handles.cMapImage = reshape(handles.cMap,[size(handles.cMap,1),1,3]);
handles.cMapImageR = imrotate(handles.cMapImage,90);
handles.cMapImageH = image(handles.cMapImageR);

set(handles.allColor,'xtick',[])
set(handles.allColor,'xticklabel',[])
set(handles.allColor,'ytick',[])
set(handles.allColor,'yticklabel',[])

guidata(hObject, handles);

% --- Executes on button press in applyButton.
function mToggle_Callback(hObject, eventdata, handles)
% hObject    handle to applyButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);

handles.rVal = handles.cMap(ceil(length(handles.cMap)/2),1);
handles.gVal = handles.cMap(ceil(length(handles.cMap)/2),2);
handles.bVal = handles.cMap(ceil(length(handles.cMap)/2),3);

handles.rSlider.Value = handles.rVal;
handles.gSlider.Value = handles.gVal;
handles.bSlider.Value = handles.bVal;

handles.edit1.String = num2str(handles.rVal);
handles.edit4.String = num2str(handles.gVal);
handles.edit5.String = num2str(handles.bVal);

axes(handles.currColor)
handles.curImage = reshape([handles.rVal handles.gVal handles.bVal],[1,1,3]);
handles.cMapImageH = image(handles.curImage);

set(handles.currColor,'xtick',[])
set(handles.currColor,'xticklabel',[])
set(handles.currColor,'ytick',[])
set(handles.currColor,'yticklabel',[])
guidata(hObject, handles);

% --- Executes on button press in applyButton.
function rToggle_Callback(hObject, eventdata, handles)
% hObject    handle to applyButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);

handles.rVal = handles.cMap(end,1);
handles.gVal = handles.cMap(end,2);
handles.bVal = handles.cMap(end,3);

handles.rSlider.Value = handles.rVal;
handles.gSlider.Value = handles.gVal;
handles.bSlider.Value = handles.bVal;

handles.edit1.String = num2str(handles.rVal);
handles.edit4.String = num2str(handles.gVal);
handles.edit5.String = num2str(handles.bVal);

axes(handles.currColor)
handles.curImage = reshape([handles.rVal handles.gVal handles.bVal],[1,1,3]);
handles.cMapImageH = image(handles.curImage);

set(handles.currColor,'xtick',[])
set(handles.currColor,'xticklabel',[])
set(handles.currColor,'ytick',[])
set(handles.currColor,'yticklabel',[])
guidata(hObject, handles);

% --- Executes on button press in applyButton.
function lToggle_Callback(hObject, eventdata, handles)
% hObject    handle to applyButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);

handles.rVal = handles.cMap(1,1);
handles.gVal = handles.cMap(1,2);
handles.bVal = handles.cMap(1,3);

handles.rSlider.Value = handles.rVal;
handles.gSlider.Value = handles.gVal;
handles.bSlider.Value = handles.bVal;

handles.edit1.String = num2str(handles.rVal);
handles.edit4.String = num2str(handles.gVal);
handles.edit5.String = num2str(handles.bVal);

axes(handles.currColor)
handles.curImage = reshape([handles.rVal handles.gVal handles.bVal],[1,1,3]);
handles.cMapImageH = image(handles.curImage);

set(handles.currColor,'xtick',[])
set(handles.currColor,'xticklabel',[])
set(handles.currColor,'ytick',[])
set(handles.currColor,'yticklabel',[])
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function mToggle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function lToggle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function rToggle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
handles = guidata(hObject);

if handles.checkbox1.Value == 1
    handles.cMap = customColorMapInterp([handles.cMap(1,1) handles.cMap(1,2) handles.cMap(1,3); handles.cMap(end,1) handles.cMap(end,2) handles.cMap(end,3)],1000);
end
axes(handles.allColor)
handles.cMapImage = reshape(handles.cMap,[size(handles.cMap,1),1,3]);
handles.cMapImageR = imrotate(handles.cMapImage,90);
handles.cMapImageH = image(handles.cMapImageR);

set(handles.allColor,'xtick',[])
set(handles.allColor,'xticklabel',[])
set(handles.allColor,'ytick',[])
set(handles.allColor,'yticklabel',[])

guidata(hObject, handles);
