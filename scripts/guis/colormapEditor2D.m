function varargout = colormapEditor2D(varargin)
% COLORMAPEDITOR2D MATLAB code for colormapEditor2D.fig
%      COLORMAPEDITOR2D, by itself, creates a new COLORMAPEDITOR2D or raises the existing
%      singleton*.
%
%      H = COLORMAPEDITOR2D returns the handle to a new COLORMAPEDITOR2D or the handle to
%      the existing singleton*.
%
%      COLORMAPEDITOR2D('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COLORMAPEDITOR2D.M with the given input arguments.
%
%      COLORMAPEDITOR2D('Property','Value',...) creates a new COLORMAPEDITOR2D or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before colormapEditor2D_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to colormapEditor2D_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help colormapEditor2D

% Last Modified by GUIDE v2.5 27-Apr-2019 12:27:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @colormapEditor2D_OpeningFcn, ...
                   'gui_OutputFcn',  @colormapEditor2D_OutputFcn, ...
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


% --- Executes just before colormapEditor2D is made visible.
function colormapEditor2D_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to colormapEditor2D (see VARARGIN)

% Choose default command line output for colormapEditor2D
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
        case 'select colormap'
            handles.cMap = jet(options.colorBins);
            handles.selectButton.Value = 2;
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
            handles.cMap=cbrewer('div', handles.colormapName, options.colorBins);
        case 'RdYlBu'
            handles.cMap = cbrewer('div', handles.colormapName, options.colorBins);
        case 'RdGy'
            handles.cMap = cbrewer('div', handles.colormapName, options.colorBins);
        case 'RdBu'
            handles.cMap = cbrewer('div', handles.colormapName, options.colorBins);
        case 'PuOr'
            handles.cMap = cbrewer('div', handles.colormapName, options.colorBins);
        case 'PRGn'
            handles.cMap = cbrewer('div', handles.colormapName, options.colorBins);
        case 'PiYG'
            handles.cMap = cbrewer('div', handles.colormapName, options.colorBins);
        case 'BrBG'
            handles.cMap = cbrewer('div', handles.colormapName, options.colorBins);
        case 'YlOrRd'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'YlOrBr'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'YlGnBu'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'YlGn'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'Reds'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'RdPu'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'Purples'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'PuRd'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'PuBuGn'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'PuBu'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'OrRd'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'Oranges'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'Greys'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'Greens'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'GnBu'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'BuPu'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'BuGn'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'Blues'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'Set3'
            handles.cMap = cbrewer('qual', handles.colormapName, options.colorBins);
        case 'Set2'
            handles.cMap = cbrewer('qual', handles.colormapName, options.colorBins);
        case 'Set1'
            handles.cMap = cbrewer('qual', handles.colormapName, options.colorBins);
        case 'Pastel2'
            handles.cMap = cbrewer('qual', handles.colormapName, options.colorBins);
        case 'Pastel1'
            handles.cMap = cbrewer('qual', handles.colormapName, options.colorBins);
        case 'Paired'
            handles.cMap = cbrewer('qual', handles.colormapName, options.colorBins);
        case 'Dark2'
            handles.cMap = cbrewer('qual', handles.colormapName, options.colorBins);
        case 'Accent'
            handles.cMap = cbrewer('qual', handles.colormapName, options.colorBins);
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
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'haline'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'solar'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'ice'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'oxy'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'deep'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'dense'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'algae'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'matter'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'turbid'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'speed'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'amp'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'tempo'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'balance'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'delta'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'curl'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'phase'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
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

axes(handles.axes3)
handles.curImageMulti = reshape([1 1 1],[1,1,3]);
handles.cMapImageHMulti = image(handles.curImageMulti);

set(handles.axes3,'xtick',[])
set(handles.axes3,'xticklabel',[])
set(handles.axes3,'ytick',[])
set(handles.axes3,'yticklabel',[])

handles.listbox.String = vertcat({handles.listbox.String},mainGuiData.overlaySelection.String{2:end});
set(handles.listbox,'Max',2,'Min',0);
handles.edit14.String = num2str(size(handles.cMap,1));

% Update handles structure
guidata(h(mainGuiNum), mainGuiData);
guidata(hObject, handles);
% UIWAIT makes colormapEditor2D wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = colormapEditor2D_OutputFcn(hObject, eventdata, handles) 
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
            handles.cMap=cbrewer('div', handles.colormapName, options.colorBins);
        case 'RdYlBu'
            handles.cMap = cbrewer('div', handles.colormapName, options.colorBins);
        case 'RdGy'
            handles.cMap = cbrewer('div', handles.colormapName, options.colorBins);
        case 'RdBu'
            handles.cMap = cbrewer('div', handles.colormapName, options.colorBins);
        case 'PuOr'
            handles.cMap = cbrewer('div', handles.colormapName, options.colorBins);
        case 'PRGn'
            handles.cMap = cbrewer('div', handles.colormapName, options.colorBins);
        case 'PiYG'
            handles.cMap = cbrewer('div', handles.colormapName, options.colorBins);
        case 'BrBG'
            handles.cMap = cbrewer('div', handles.colormapName, options.colorBins);
        case 'YlOrRd'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'YlOrBr'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'YlGnBu'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'YlGn'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'Reds'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'RdPu'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'Purples'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'PuRd'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'PuBuGn'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'PuBu'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'OrRd'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'Oranges'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'Greys'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'Greens'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'GnBu'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'BuPu'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'BuGn'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'Blues'
            handles.cMap = cbrewer('seq', handles.colormapName, options.colorBins);
        case 'Set3'
            handles.cMap = cbrewer('qual', handles.colormapName, options.colorBins);
        case 'Set2'
            handles.cMap = cbrewer('qual', handles.colormapName, options.colorBins);
        case 'Set1'
            handles.cMap = cbrewer('qual', handles.colormapName, options.colorBins);
        case 'Pastel2'
            handles.cMap = cbrewer('qual', handles.colormapName, options.colorBins);
        case 'Pastel1'
            handles.cMap = cbrewer('qual', handles.colormapName, options.colorBins);
        case 'Paired'
            handles.cMap = cbrewer('qual', handles.colormapName, options.colorBins);
        case 'Dark2'
            handles.cMap = cbrewer('qual', handles.colormapName, options.colorBins);
        case 'Accent'
            handles.cMap = cbrewer('qual', handles.colormapName, options.colorBins);
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
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'haline'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'solar'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'ice'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'oxy'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'deep'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'dense'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'algae'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'matter'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'turbid'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'speed'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'amp'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'tempo'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'balance'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'delta'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'curl'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
        case 'phase'
            handles.cMap = cmocean(handles.colormapName, options.colorBins);
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
handles.edit14.String = num2str(size(handles.cMap,1));

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


% --- Executes on button press in patchButton.
function patchButton_Callback(hObject, eventdata, handles)
% hObject    handle to patchButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
if length(handles.listbox.Value) == 2
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
    lims(2,1) = str2num(handles.dim1Max.String);
    lims(2,2) = str2num(handles.dim2Max.String);
    
    allData(:,1) = mainGuiData.brainMap.Current{handles.listbox.Value(1) - 1}.Data;
    allData(:,2) = mainGuiData.brainMap.Current{handles.listbox.Value(2) - 1}.Data;
    
    [handles.underlay, handles.overlay] = plot2dOverlay(allData, handles.cMapImageHMulti.CData, lims, size(handles.cMapImageHMulti.CData,1));
    handles.overlay.FaceAlpha = str2double(handles.opacity.String);
    
    guidata(h(mainGuiNum), mainGuiData);
end
guidata(hObject, handles);


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


% --- Executes on button press in setLeft.
function setLeft_Callback(hObject, eventdata, handles)
% hObject    handle to setLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
handles.leftColormap = handles.cMap;
colorBins = 1000;

if ~isfield(handles,'rightColormap')
    handles.rightColormap = ones(colorBins,3);
end

cMap = ones(colorBins,colorBins,3);
for i = 1:size(handles.leftColormap,1)
    tmpInterp = customColorMapInterp(vertcat(handles.leftColormap(i,:),handles.rightColormap(i,:)),colorBins);
    cMap(i,:,:) = tmpInterp;
end

axes(handles.axes3)
handles.cMapImageHMulti = image(cMap);
set(handles.axes3,'xtick',[])
set(handles.axes3,'xticklabel',[])
set(handles.axes3,'ytick',[])
set(handles.axes3,'yticklabel',[])

guidata(hObject, handles);

% --- Executes on button press in setRight.
function setRight_Callback(hObject, eventdata, handles)
% hObject    handle to setRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
handles.rightColormap = handles.cMap;
colorBins = 1000;

if ~isfield(handles,'leftColormap')
    handles.leftColormap = ones(colorBins,3);
end

cMap = ones(colorBins,colorBins,3);
for i = 1:size(handles.rightColormap,1)
    tmpInterp = customColorMapInterp(vertcat(handles.leftColormap(i,:),handles.rightColormap(i,:)),colorBins);
    cMap(i,:,:) = tmpInterp;
end

axes(handles.axes3)
handles.cMapImageHMulti = image(cMap);
set(handles.axes3,'xtick',[])
set(handles.axes3,'xticklabel',[])
set(handles.axes3,'ytick',[])
set(handles.axes3,'yticklabel',[])

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

if length(handles.listbox.Value) == 2 && sum(handles.listbox.Value ~= 1) == 2
    handles.dim1Min.String = num2str(min(mainGuiData.brainMap.Current{handles.listbox.Value(1) - 1}.Data));
    handles.dim2Min.String = num2str(min(mainGuiData.brainMap.Current{handles.listbox.Value(2) - 1}.Data));
    handles.dim1Max.String = num2str(max(mainGuiData.brainMap.Current{handles.listbox.Value(1) - 1}.Data));
    handles.dim2Max.String = num2str(max(mainGuiData.brainMap.Current{handles.listbox.Value(2) - 1}.Data));
elseif length(handles.listbox.Value) == 1 && sum(handles.listbox.Value ~= 1) == 1
    handles.dim1Min.String = num2str(min(mainGuiData.brainMap.Current{handles.listbox.Value - 1}.Data));
    handles.dim1Max.String = num2str(max(mainGuiData.brainMap.Current{handles.listbox.Value - 1}.Data));
    handles.dim2Min.String = 'NaN';
    handles.dim2Max.String = 'NaN';
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

function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double
handles = guidata(hObject);
if str2double(handles.edit14.String) < 5
    handles.edit14.String = '5';
end

F = griddedInterpolant(double(handles.cMapImageHMulti.CData));
[sx,sy,sz] = size(handles.cMapImageHMulti.CData);
imRat = size(handles.cMapImageHMulti.CData,1)/str2double(handles.edit14.String);

xq = (0:imRat:sx)';
yq = (0:imRat:sy)';
zq = (1:sz)';
%vq = uint8(F({xq,yq,zq}));
vq = (F({xq,yq,zq}));

axes(handles.axes3)
handles.cMapImageHMulti = image(vq);

set(handles.axes3,'xtick',[])
set(handles.axes3,'xticklabel',[])
set(handles.axes3,'ytick',[])
set(handles.axes3,'yticklabel',[])

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
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


% --- Executes on button press in invert.
function invert_Callback(hObject, eventdata, handles)
% hObject    handle to invert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of invert
handles = guidata(hObject);
% update images
axes(handles.allColor)

handles.cMapImage = flipud(handles.cMapImage);
handles.cMapImageH = image((imrotate(handles.cMapImage,90)));
handles.cMap = flipud(handles.cMap);
%handles.cMapImageH = image(fliplr(imrotate(handles.cMapImage,90)));

set(handles.allColor,'xtick',[])
set(handles.allColor,'xticklabel',[])
set(handles.allColor,'ytick',[])
set(handles.allColor,'yticklabel',[])

guidata(hObject, handles);
