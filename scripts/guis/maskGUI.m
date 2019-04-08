function varargout = maskGUI(varargin)
% GUI for masking an overlay with another overlay
% Alex Teghipco // alex.teghipco@uci.edu // 11/28/18
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
toMask = mainGuiData.overlaySelection.Value - 1; %handles.listbox2.Value - 1;
mask = handles.listbox2.Value - 1; %mainGuiData.overlaySelection.Value - 1;
%currSelection = (get(mainGuiData.overlaySelection,'Value') - 1);

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
        mainGuiData.brainMap.overlay.FaceAlpha = 0;
        mainGuiData.brainMap = rmfield(mainGuiData.brainMap,'overlay');
    end
end

% get thresholded mask data (plot without visualization)
[~, ~, ~, mainGuiData.opts] = plotOverlay(mainGuiData.underlay, mainGuiData.brainMap.Current{mask}.Data,'figHandle', mainGuiData.brainFig, 'threshold',[mainGuiData.brainMap.Current{mask}.overlayThresholdNeg, mainGuiData.brainMap.Current{mask}.overlayThresholdPos], 'hemisphere', mainGuiData.brainMap.Current{mask}.hemi, 'opacity', mainGuiData.brainMap.Current{mask}.opacity, 'colorMap', mainGuiData.colormap.String{mainGuiData.brainMap.Current{mask}.colormap}, 'colorSampling',mainGuiData.brainMap.Current{mask}.colormapSpacing,'colorBins',mainGuiData.brainMap.Current{mask}.colorBins,'limits', [mainGuiData.brainMap.Current{mask}.limitMin mainGuiData.brainMap.Current{mask}.limitMax],'inclZero',mainGuiData.brainMap.Current{mask}.inclZero,'clusterThresh',mainGuiData.brainMap.Current{mask}.clusterThresh,'binarize',mainGuiData.brainMap.Current{mask}.binarize,'outline',mainGuiData.brainMap.Current{mask}.outline,'binarizeClusters',mainGuiData.brainMap.Current{mask}.binarizeClusters,'customColor',mainGuiData.brainMap.Current{mask}.customColor,'pMap',mainGuiData.brainMap.Current{mask}.pVals,'pThresh',mainGuiData.brainMap.Current{mask}.pThresh,'transparencyLimits',mainGuiData.brainMap.Current{mask}.transparencyLimits,'transparencyThresholds',mainGuiData.brainMap.Current{mask}.transparencyThresholds,'transparencyData',mainGuiData.brainMap.Current{mask}.transparencyData,'transparencyPThresh',mainGuiData.brainMap.Current{mask}.transparencyPThresh,'invertColor',mainGuiData.brainMap.Current{mask}.invertColor,'invertOpacity',mainGuiData.brainMap.Current{mask}.invertOpacity,'growROI',mainGuiData.brainMap.Current{mask}.growROI,'plotSwitch','off');
idx = find(mainGuiData.opts.overlayData ~= 0); % find indices that are going to be used as a mask
mainGuiData.brainMap.Current{toMask}.Data(idx) = 0; % update current selection

%[mainGuiData.underlay, ~, ~, mainGuiData.opts] = plotOverlay(mainGuiData.underlay, mainGuiData.brainMap.Current{mask}.Data,'plotSwitch','off', 'threshold',[mainGuiData.overlayThresholdNeg.Value, mainGuiData.overlayThresholdPos.Value], 'hemisphere', mainGuiData.brainMap.hemi{mask}, 'colorMap', mainGuiData.colormap.String{mainGuiData.colormap.Value}, 'colorSampling',mainGuiData.colormapSpacing.String{mainGuiData.colormapSpacing.Value},'colorBins',str2double(mainGuiData.colorBins.String),'limits', [str2double(mainGuiData.limitMin.String) str2double(mainGuiData.limitMax.String)],'inclZero','false','clusterThresh',mainGuiData.brainMap.Current{mask}.clusterThresh,'binarize',mainGuiData.brainMap.Current{mask}.binarize,'outline',mainGuiData.brainMap.Current{mask}.outline,'binarizeClusters',mainGuiData.brainMap.Current{mask}.binarizeClusters,'customColor',mainGuiData.brainMap.Current{mask}.customColor,'pMap',mainGuiData.brainMap.Current{mask}.pVals,'pThresh',mainGuiData.brainMap.Current{mask}.pThresh,'transparencyLimits',mainGuiData.brainMap.Current{mask}.transparencyLimits,'transparencyThresholds',mainGuiData.brainMap.Current{mask}.transparencyThresholds,'transparencyData',mainGuiData.brainMap.Current{mask}.transparencyData,'transparencyPThresh',mainGuiData.brainMap.Current{mask}.transparencyPThresh,'growROI',mainGuiData.brainMap.Current{mask}.growROI);
%[mainGuiData.underlay, mainGuiData.brainMap.overlay, mainGuiData.brainFig, mainGuiData.opts] = plotOverlay(mainGuiData.underlay, mainGuiData.brainMap.Current{mask}.Data,'figHandle', mainGuiData.brainFig, 'threshold',[mainGuiData.brainMap.Current{mask}.overlayThresholdNeg, mainGuiData.brainMap.Current{mask}.overlayThresholdPos], 'hemisphere', mainGuiData.brainMap.Current{mask}.hemi, 'opacity', mainGuiData.brainMap.Current{mask}.opacity, 'colorMap', mainGuiData.colormap.String{mainGuiData.brainMap.Current{mask}.colormap}, 'colorSampling',mainGuiData.brainMap.Current{mask}.colormapSpacing,'colorBins',mainGuiData.brainMap.Current{mask}.colorBins,'limits', [mainGuiData.brainMap.Current{mask}.limitMin mainGuiData.brainMap.Current{mask}.limitMax],'inclZero',mainGuiData.brainMap.Current{mask}.inclZero,'clusterThresh',mainGuiData.brainMap.Current{mask}.clusterThresh,'binarize',mainGuiData.brainMap.Current{mask}.binarize,'outline',mainGuiData.brainMap.Current{mask}.outline,'binarizeClusters',mainGuiData.brainMap.Current{mask}.binarizeClusters,'customColor',mainGuiData.brainMap.Current{mask}.customColor,'pMap',mainGuiData.brainMap.Current{mask}.pVals,'pThresh',mainGuiData.brainMap.Current{mask}.pThresh,'transparencyLimits',mainGuiData.brainMap.Current{mask}.transparencyLimits,'transparencyThresholds',mainGuiData.brainMap.Current{mask}.transparencyThresholds,'transparencyData',mainGuiData.brainMap.Current{mask}.transparencyData,'transparencyPThresh',mainGuiData.brainMap.Current{mask}.transparencyPThresh,'invertColor',mainGuiData.brainMap.Current{mask}.invertColor,'invertOpacity',mainGuiData.brainMap.Current{mask}.invertOpacity,'growROI',mainGuiData.brainMap.Current{mask}.growROI);
[mainGuiData.underlay, mainGuiData.brainMap.overlay, mainGuiData.brainFig, mainGuiData.opts] = plotOverlay(mainGuiData.underlay, mainGuiData.brainMap.Current{toMask}.Data,'figHandle', mainGuiData.brainFig, 'threshold',[mainGuiData.brainMap.Current{toMask}.overlayThresholdNeg, mainGuiData.brainMap.Current{toMask}.overlayThresholdPos], 'hemisphere', mainGuiData.brainMap.Current{toMask}.hemi, 'opacity', mainGuiData.brainMap.Current{toMask}.opacity, 'colorMap', mainGuiData.colormap.String{mainGuiData.brainMap.Current{toMask}.colormap}, 'colorSampling',mainGuiData.brainMap.Current{toMask}.colormapSpacing,'colorBins',mainGuiData.brainMap.Current{toMask}.colorBins,'limits', [mainGuiData.brainMap.Current{toMask}.limitMin mainGuiData.brainMap.Current{toMask}.limitMax],'inclZero',mainGuiData.brainMap.Current{toMask}.inclZero,'clusterThresh',mainGuiData.brainMap.Current{toMask}.clusterThresh,'binarize',mainGuiData.brainMap.Current{toMask}.binarize,'outline',mainGuiData.brainMap.Current{toMask}.outline,'binarizeClusters',mainGuiData.brainMap.Current{toMask}.binarizeClusters,'customColor',mainGuiData.brainMap.Current{toMask}.customColor,'pMap',mainGuiData.brainMap.Current{toMask}.pVals,'pThresh',mainGuiData.brainMap.Current{toMask}.pThresh,'transparencyLimits',mainGuiData.brainMap.Current{toMask}.transparencyLimits,'transparencyThresholds',mainGuiData.brainMap.Current{toMask}.transparencyThresholds,'transparencyData',mainGuiData.brainMap.Current{toMask}.transparencyData,'transparencyPThresh',mainGuiData.brainMap.Current{toMask}.transparencyPThresh,'invertColor',mainGuiData.brainMap.Current{toMask}.invertColor,'invertOpacity',mainGuiData.brainMap.Current{toMask}.invertOpacity,'growROI',mainGuiData.brainMap.Current{toMask}.growROI);

mainGuiData.brainMap.colorbar = cbar;
mainGuiData.brainMap.colorbar.TickLength = [0 0];
imh = mainGuiData.brainMap.colorbar.Children(1);
imh.AlphaData = mainGuiData.opts.transparencyData;
imh.AlphaDataMapping = 'direct';

if mainGuiData.colormapSpacing.Value == 4 || mainGuiData.colormapSpacing.Value == 3
    mainGuiData.brainMap.colorbar.YTick = mainGuiData.opts.ticks;
    mainGuiData.brainMap.colorbar.YTickLabel = mainGuiData.opts.tickLabels;
end

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
