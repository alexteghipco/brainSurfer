function varargout = mathsGUI(varargin)
% GUI for masking an overlay with another overlay
% Alex Teghipco // alex.teghipco@uci.edu // 11/28/18
% Last Modified by GUIDE v2.5 03-Apr-2019 15:37:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mathsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @mathsGUI_OutputFcn, ...
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

% --- Executes just before mathsGUI is made visible.
function mathsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mathsGUI (see VARARGIN)

% Choose default command line output for mathsGUI
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
handles.selectionList.String = vertcat({handles.selectionList.String},mainGuiData.overlaySelection.String{2:end});
set(handles.selectionList,'Max',50,'Min',0); % don't allow more than 50 overlays to be plotted in brainSurfer at once

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mathsGUI wait for user response (see UIRESUME)
% uiwait(handles.mathsGUI);

% --- Outputs from this function are returned to the command line.
function varargout = mathsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function addButton_Callback(hObject, eventdata, handles)
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

% make sure all selections come from the same hemisphere!!
hemis = extractfield([mainGuiData.brainMap.Current{handles.selectionList.Value - 1}],'hemi');

for i = 1:length(handles.selectionList.Value)
    tmpData(:,i) = mainGuiData.brainMap.Current{handles.selectionList.Value(i)}.Data;
end

outData = sum(tmpData,2);
mainGuiData.brainMap.Current{length(handles.selectionList.String)+1} = mainGuiData.brainMap.Current{handles.selectionList.Value(1)};
mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.Data = outData;
mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.limitMin = min(outData);
mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.limitMax = max(outData);
mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.overlayThresholdPos = 0;
mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.overlayThresholdNeg = 0;
mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.pVals = 0;
mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.clusterThresh = 0;
mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.transparencyLimits = [];
mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.transparencyThresholds = [];
mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.transparencyData = [];
mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.transparencyPThresh = [];
mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.binarize = 0;
mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.outline = 'false';
mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.growROI = 0;

mainGuiData.overlayThresholdPos.Value = 0;
mainGuiData.overlayThresholdNeg.Value = 0;
mainGuiData.overlayThresholdPosDynamic.String = '0';
mainGuiData.overlayThresholdNegDynamic.String = '0';
mainGuiData.pSlider.Value = 1;
mainGuiData.pText.String = '1';
mainGuiData.clusterThreshSlider.Value = 0;
mainGuiData.clusterThreshText = '0';

mainGuiData.limitMin.String = mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.limitMin;
mainGuiData.limitMax.String = mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.limitMax;
mainGuiData.growROI.String = '0';
mainGuiData.outlineButton.Value = 0;
mainGuiData.binarizeSwitch.Value = 0;

mainGuiData.smoothAboveThresh.Value = 1;
mainGuiData.smoothBelowThresh.Value = 0;
mainGuiData.valuesButton.Value = 1;
mainGuiData.neighborhoodButton.Value = 0;
mainGuiData.smoothArea.String = '0';
mainGuiData.smoothSteps.String = '0';

mainGuiData.colormap.Value = mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.colormap;
mainGuiData.opacity.String = num2str(mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.opacity);

if strcmp(mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.inclZero,'true')
    mainGuiData.zeroButton.Value = 1;
else
    mainGuiData.zeroButton.Value = 0;
end

if strcmp(mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.outline,'false')
    mainGuiData.outlineButton.Value = 0;
elseif strcmp(mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.outline,'true')
    mainGuiData.outlineButton.Value = 1;
end

if strcmp(mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.invertColor,'false')
    mainGuiData.invertColorButton.Value = 0;
elseif strcmp(mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.invertColor,'true')
    mainGuiData.invertColorButton.Value = 1;
end

mainGuiData.growROI.String = num2str(mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.growROI);

if strcmp(mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.colormapSpacing,'even')
    mainGuiData.colormapSpacing.Value = 2;
elseif strcmp(mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.colormapSpacing,'center on zero')
    mainGuiData.colormapSpacing.Value = 3;
elseif strcmp(mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.colormapSpacing,'center on threshold')
    mainGuiData.colormapSpacing.Value = 4;
end

mainGuiData.overlayThresholdPosDynamic.String = num2str(mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.overlayThresholdPos);
mainGuiData.overlayThresholdNegDynamic.String = num2str(mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.overlayThresholdNeg);
mainGuiData.colorBins.String = num2str(mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.colorBins);

% also update how far the sliders should be capable of moving based on
% the data for this map
mainGuiData.overlayThresholdPos.Max = max(max(max(mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.Data)));
mainGuiData.overlayThresholdNeg.Min = min(min(min(mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.Data)));

name = [];
for i = 1:length(handles.selectionList.Value)
    tmp = num2str(handles.selectionList.Value(i));
    name = [name '_' tmp];
end
template = load_nifti([mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.path mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.name mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.ext]);
template.vol = mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.Data;
mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.name = ['Added_overlays_' name '.nii'];
save_nifti([mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.path mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.name mainGuiData.brainMap.Current{length(handles.selectionList.String)+1}.ext]);
mainGuiData.overlaySelection.String = vertcat(mainGuiData.overlaySelection.String(:),['Added_overlays_' name]);
mainGuiData.overlaySelection.Value = length(handles.selectionList.String)+1;

guidata(hObject, handles);






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
function selectionList_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2

% --- Executes during object creation, after setting all properties.
function selectionList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
