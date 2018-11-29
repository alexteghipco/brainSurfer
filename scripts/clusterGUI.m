function varargout = clusterGUI(varargin)
% clusterGUI
% Alex Teghipco // alex.teghipco@uci.edu // 11/28/18
% Last Modified by GUIDE v2.5 08-Nov-2018 00:35:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @clusterGUI_OpeningFcn, ...
    'gui_OutputFcn',  @clusterGUI_OutputFcn, ...
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


% --- Executes just before clusterGUI is made visible.
function clusterGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to clusterGUI (see VARARGIN)

% Choose default command line output for clusterGUI
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

% get the selection from brain surfer that you are messing around with in
% transparencyGUI
currSelection = (get(mainGuiData.overlaySelection,'Value') - 1);

% get clusters of last figure
h = waitbar(0,'Compiling list of clusters and retrieving their data...');
titleHandle = get(findobj(h,'Type','axes'),'Title');
set(titleHandle,'FontSize',8)

% remove zeros
idx = find(mainGuiData.brainMap.Original.Data{currSelection} == 0);
[C,ia,ib] = intersect(idx,mainGuiData.opts.verts);
mainGuiData.opts.verts(ib) = [];

try
    handles.faces = mainGuiData.underlay.left.Faces;
catch
    handles.faces = mainGuiData.underlay.right.Faces;
end

[handles.dataClust, handles.clusterLen] = getClusters(mainGuiData.opts.verts, handles.faces);

handles.clusterNames = 1:length(handles.clusterLen);
handles.clusterNames_str = strtrim(cellstr(num2str(handles.clusterNames'))');
handles.clusterLen_str = strtrim(cellstr(num2str(handles.clusterLen'))');

handles.listbox1.String = horzcat({'Select cluster'},handles.clusterNames_str);

handles.vertCoords = mainGuiData.opts.vertCoords;

for clusteri = 1:length(handles.dataClust)
    disp(num2str(clusteri))
    handles.clusterMean(clusteri) = mean(mainGuiData.brainMap.Original.Data{currSelection}(handles.dataClust{clusteri}));
    handles.clusterStd(clusteri) = std(mainGuiData.brainMap.Original.Data{currSelection}(handles.dataClust{clusteri}));
    handles.clusterSEM(clusteri) = (handles.clusterStd(clusteri)/sqrt(handles.clusterLen(clusteri)));
    
    % find vert coordinates for cluster
    vertClust = handles.vertCoords(handles.dataClust{clusteri},:);
    centroid = [mean(vertClust(:,1)) mean(vertClust(:,2)) mean(vertClust(:,3))];
    [~,distList] = pdist2(vertClust,centroid,'seuclidean','Smallest',1);
    handles.center(clusteri) = handles.dataClust{clusteri}(distList);
    %handles.center(clusteri) = distList;
    handles.centerVal(clusteri) = mainGuiData.brainMap.Original.Data{currSelection}(handles.center(clusteri));
    
    if isempty(mainGuiData.brainMap.Current{currSelection}.pVals) == 0
        handles.centerP(clusteri) = mainGuiData.brainMap.Current{currSelection}.pVals(handles.center(clusteri));
    end
    
end

handles.clusterMean_str = strtrim(cellstr(num2str(handles.clusterMean'))');
handles.clusterStd_str = strtrim(cellstr(num2str(handles.clusterStd'))');
handles.center_str = strtrim(cellstr(num2str(handles.center'))');
handles.centerVal_str = strtrim(cellstr(num2str(handles.centerVal'))');

if isempty(mainGuiData.brainMap.Current{currSelection}.pVals) == 0
    handles.centerP_str = strtrim(cellstr(num2str(handles.centerP'))');
else
    handles.centerP_str = repmat({'NaN'},1,length(handles.dataClust));
end


axes(handles.clusterHist)
handles.p = bar(handles.clusterNames,handles.clusterLen,'k');
title('# of Vertices within cluster');
xlabel('Cluster index');
ylabel('Number of vertices');
hold on

tableData(:,1) = handles.clusterNames_str;
tableData(:,2) = handles.clusterLen_str;
tableData(:,3) = handles.center_str;
tableData(:,4) = handles.centerVal_str;
tableData(:,5) = handles.centerP_str;
tableData(:,6) = handles.clusterMean_str;
tableData(:,7) = handles.clusterStd_str;

set(handles.clusterTable,'Data',tableData);
handles.plotType = 'size';

handles.userColor = cell([length(handles.dataClust),1]);

close(h)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes clusterGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = clusterGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
handles = guidata(hObject);
clusterSelectionIdx = handles.listbox1.Value - 1;

h = get(0,'Children');
% find brain surfer
for hi = 1:length(h)
    if strcmp(h(hi).Name,'Brain Surfer') == 1
        mainGuiNum = hi;
    end
end

% get data from brain surfer
mainGuiData = guidata(h(mainGuiNum));

% get the selection from brain surfer that you are messing around with in
% transparencyGUI
currSelection = (get(mainGuiData.overlaySelection,'Value') - 1);

if clusterSelectionIdx ~= 0
    
    if isempty(handles.userColor{clusterSelectionIdx}) == 1
        handles.userColor{clusterSelectionIdx} = [0 1 1];
    end
    
    % make bar for selection blue
    if isfield(handles,'r')
        delete(handles.r)
    end
    
    axes(handles.clusterHist)
    switch handles.plotType
        case 'size'
            handles.r = bar(handles.clusterNames(clusterSelectionIdx),handles.clusterLen(clusterSelectionIdx),'FaceColor',handles.userColor{clusterSelectionIdx});
            
        case 'mean'
            handles.r = bar(handles.clusterNames(clusterSelectionIdx),handles.clusterMean(clusterSelectionIdx),'FaceColor',handles.userColor{clusterSelectionIdx});
    end
    
    % now change overlayData to 1s and 2s
    allClustVert = vertcat(handles.dataClust{:});
    redClust = handles.dataClust{clusterSelectionIdx};
    [C,ia] = setdiff(allClustVert,redClust);
    blackClust = allClustVert(ia);
    vertList = unique(handles.faces);
    nonClusterVerts = setdiff(vertList,allClustVert);
    
    handles.cData = ones([length(vertList),3]);
    handles.cData(redClust,1) = handles.userColor{clusterSelectionIdx}(1);
    handles.cData(redClust,2) = handles.userColor{clusterSelectionIdx}(2);
    handles.cData(redClust,3) = handles.userColor{clusterSelectionIdx}(3);
    
    handles.cData(blackClust,1) = 0;
    handles.cData(blackClust,2) = 0;
    handles.cData(blackClust,3) = 0;
    
    handles.cData(nonClusterVerts,1) = 1;
    handles.cData(nonClusterVerts,2) = 1;
    handles.cData(nonClusterVerts,3) = 1;
    
    handles.FaceVertexAlphaData = (ones([length(vertList),1])) * 62;
    handles.FaceVertexAlphaData(nonClusterVerts) = 0;
    
    % plot overlayData and update main GUI
    if isfield(mainGuiData.opts,'colorbar')
        delete(mainGuiData.opts.colorbar)
    end
    
    if isfield(mainGuiData.brainMap.Current{currSelection},'overlay')
        mainGuiData.brainMap.Current{currSelection}.overlay.FaceAlpha = 0;
    end
    
    if isfield(handles,'overlay')
        delete(handles.overlay)
    end
    
    figure(mainGuiData.brainFig)
    handles.overlay = patch('Faces',handles.faces,'Vertices',handles.vertCoords,'FaceVertexCData',handles.cData,'FaceVertexAlphaData',handles.FaceVertexAlphaData/1.5, 'AlphaDataMapping' ,'direct','CDataMapping','direct','facecolor','interp','edgecolor','none');
    handles.overlay.FaceAlpha = 'interp';
    
    guidata(h(mainGuiNum), mainGuiData);
    
else
    if isfield(handles,'r')
        delete(handles.r)
    end
    
    for clusteri = 1:length(handles.dataClust)
        if isempty(handles.userColor{clusteri}) == 1
            handles.userColor{clusteri} = [0 1 1];
        end
        switch handles.plotType
            case 'size'
                handles.r2 = bar(handles.clusterNames(clusteri),handles.clusterLen(clusteri),'FaceColor',[0 0 0],'EdgeColor',handles.userColor{clusteri},'LineWidth',1.5);
            case 'mean'
                handles.r2 = bar(handles.clusterNames(clusteri),handles.clusterMean(clusteri),'FaceColor',[0 0 0],'EdgeColor',handles.userColor{clusteri},'LineWidth',1.5);
                %handles.r = bar(handles.clusterNames(clusteri),handles.clusterMean(clusteri),clusteri);
        end
    end
    
    allClustVert = vertcat(handles.dataClust{:});
    vertList = unique(handles.faces);
    handles.cData = ones([length(vertList),3]);
    handles.FaceVertexAlphaData = (ones([length(vertList),1])) * 62;
    for clusteri = 1:length(handles.dataClust)
        % now change overlayData to 1s and 2s
        redClust = handles.dataClust{clusteri};
        
        if isempty(handles.userColor{clusteri}) == 1
            handles.userColor{clusteri} = [0 1 1];
        end
        
        handles.cData(redClust,1) = handles.userColor{clusteri}(1);
        handles.cData(redClust,2) = handles.userColor{clusteri}(2);
        handles.cData(redClust,3) = handles.userColor{clusteri}(3);
    end
    
    nonClusterVerts = setdiff(vertList,allClustVert);
    handles.FaceVertexAlphaData(nonClusterVerts) = 0;
    handles.cData(nonClusterVerts,1) = 1;
    handles.cData(nonClusterVerts,2) = 1;
    handles.cData(nonClusterVerts,3) = 1;
    
    % now patch
    handles.FaceVertexAlphaData = (ones([length(vertList),1])) * 62;
    handles.FaceVertexAlphaData(nonClusterVerts) = 0;
    
    % plot overlayData and update main GUI
    if isfield(mainGuiData.opts,'colorbar')
        delete(mainGuiData.opts.colorbar)
    end
    
    if isfield(mainGuiData.brainMap.Current{currSelection},'overlay')
        mainGuiData.brainMap.Current{currSelection}.overlay.FaceAlpha = 0;
    end
    
    if isfield(handles,'overlay')
        delete(handles.overlay)
    end
    
    figure(mainGuiData.brainFig)
    handles.overlay = patch('Faces',handles.faces,'Vertices',handles.vertCoords,'FaceVertexCData',handles.cData,'FaceVertexAlphaData',handles.FaceVertexAlphaData/1.5, 'AlphaDataMapping' ,'direct','CDataMapping','direct','facecolor','interp','edgecolor','none');
    handles.overlay.FaceAlpha = 'interp';
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in deleteButton.
function deleteButton_Callback(hObject, eventdata, handles)
% hObject    handle to deleteButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);

if (handles.listbox1.Value - 1) ~= 0
    
    h = get(0,'Children');
    % find brain surfer
    for hi = 1:length(h)
        if strcmp(h(hi).Name,'Brain Surfer') == 1
            mainGuiNum = hi;
        end
    end
    
    % get data from brain surfer
    mainGuiData = guidata(h(mainGuiNum));
    
    selectionRemove = handles.listbox1.Value - 1;
    handles.listbox1.String(handles.listbox1.Value) = [];
    
    % remove selection from all data in handles
    handles.clusterMean(selectionRemove) = [];
    handles.clusterStd(selectionRemove) = [];
    handles.clusterSEM(selectionRemove) = [];
    handles.center(selectionRemove) = [];
    handles.centerVal(selectionRemove) = [];
    handles.clusterMean_str(selectionRemove) = [];
    handles.clusterStd_str(selectionRemove) = [];
    handles.center_str(selectionRemove) = [];
    handles.centerVal_str(selectionRemove) = [];
    handles.centerP_str(selectionRemove) = [];
    handles.clusterLen_str(selectionRemove) = [];
    handles.clusterNames_str(selectionRemove) = [];
    handles.clusterNames(selectionRemove) = [];
    handles.clusterLen(selectionRemove) = [];
    handles.dataClust(selectionRemove) = [];
    handles.userColor(selectionRemove) = [];
    
    % remove this cluster and replot everything
    clusterSelectionIdx = selectionRemove;
    
    % replot axes
    if isfield(handles,'p')
        delete(handles.p)
    end
    
    if isfield(handles,'r')
        delete(handles.r)
    end
    
    if isfield(handles,'e')
        delete(handles.e)
    end
    
    if isempty(handles.userColor{clusterSelectionIdx}) == 1
        handles.userColor{clusterSelectionIdx} = [0 1 1];
    end
    
    axes(handles.clusterHist)
    switch handles.plotType
        case 'size'
            handles.p = bar(handles.clusterNames,handles.clusterLen,'k');
            
            title('# of Vertices within cluster');
            xlabel('Cluster index');
            ylabel('Number of vertices');
            hold on
            
            handles.r = bar(handles.clusterNames(clusterSelectionIdx),handles.clusterLen(clusterSelectionIdx),'FaceColor',handles.userColor{clusterSelectionIdx});
        case 'mean'
            handles.p = bar(handles.clusterNames,handles.clusterMean,'k');
            handles.e = errorbar(handles.clusterNames,handles.clusterMean,-1*(handles.clusterSEM),handles.clusterSEM,'o','MarkerEdgeColor','none','Color',[0.5 0.5 0.5],'CapSize',8,'LineWidth',1.5);
            
            title('Mean of data within cluster');
            xlabel('Cluster index');
            ylabel('Mean of data');
            hold on
            handles.r = bar(handles.clusterNames(clusterSelectionIdx),handles.clusterMean(clusterSelectionIdx),'FaceColor',handles.userColor{clusterSelectionIdx});
    end
    
    % now repatch brain
    allClustVert = vertcat(handles.dataClust{:});
    redClust = handles.dataClust{clusterSelectionIdx};
    [C,ia] = setdiff(allClustVert,redClust);
    blackClust = allClustVert(ia);
    vertList = unique(handles.faces);
    nonClusterVerts = setdiff(vertList,allClustVert);
    
    handles.cData = ones([length(vertList),3]);
    handles.cData(redClust,1) = handles.userColor{clusterSelectionIdx}(1);
    handles.cData(redClust,2) = handles.userColor{clusterSelectionIdx}(2);
    handles.cData(redClust,3) = handles.userColor{clusterSelectionIdx}(3);
    
    handles.cData(blackClust,1) = 0;
    handles.cData(blackClust,2) = 0;
    handles.cData(blackClust,3) = 0;
    
    handles.cData(nonClusterVerts,1) = 1;
    handles.cData(nonClusterVerts,2) = 1;
    handles.cData(nonClusterVerts,3) = 1;
    
    handles.FaceVertexAlphaData = (ones([length(vertList),1])) * 62;
    handles.FaceVertexAlphaData(nonClusterVerts) = 0;
    
    if isfield(handles,'overlay')
        delete(handles.overlay)
    end
    
    figure(mainGuiData.brainFig)
    handles.overlay = patch('Faces',handles.faces,'Vertices',handles.vertCoords,'FaceVertexCData',handles.cData,'FaceVertexAlphaData',handles.FaceVertexAlphaData/1.5, 'AlphaDataMapping' ,'direct','CDataMapping','direct','facecolor','interp','edgecolor','none');
    handles.overlay.FaceAlpha = 'interp';
    
end
guidata(hObject, handles);

% --- Executes on button press in colorButton.
function colorButton_Callback(hObject, eventdata, handles)
% hObject    handle to colorButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
clusterSelectionIdx = handles.listbox1.Value - 1;

if clusterSelectionIdx ~= 0
    
    h = get(0,'Children');
    % find brain surfer
    for hi = 1:length(h)
        if strcmp(h(hi).Name,'Brain Surfer') == 1
            mainGuiNum = hi;
        end
    end
    
    % get data from brain surfer
    mainGuiData = guidata(h(mainGuiNum));
    
    tmpColor = uisetcolor([0 1 1],'Select a color for this cluster');
    
    % if you didn't hit cancel set up a cluster color vector
    handles.userColor{clusterSelectionIdx} = tmpColor;
    
    % replot axes
    if isfield(handles,'p')
        delete(handles.p)
    end
    
    if isfield(handles,'r')
        delete(handles.r)
    end
    
    if isfield(handles,'e')
        delete(handles.e)
    end
    
    axes(handles.clusterHist)
    switch handles.plotType
        case 'size'
            handles.p = bar(handles.clusterNames,handles.clusterLen,'k');
            
            title('# of Vertices within cluster');
            xlabel('Cluster index');
            ylabel('Number of vertices');
            hold on
            handles.r = bar(handles.clusterNames(clusterSelectionIdx),handles.clusterLen(clusterSelectionIdx),'FaceColor',handles.userColor{clusterSelectionIdx});
        case 'mean'
            handles.p = bar(handles.clusterNames,handles.clusterMean,'k');
            handles.e = errorbar(handles.clusterNames,handles.clusterMean,-1*(handles.clusterSEM),handles.clusterSEM,'o','MarkerEdgeColor','none','Color',[0.5 0.5 0.5],'CapSize',8,'LineWidth',1.5);
            
            title('Mean of data within cluster');
            xlabel('Cluster index');
            ylabel('Mean of data');
            hold on
            handles.r = bar(handles.clusterNames(clusterSelectionIdx),handles.clusterMean(clusterSelectionIdx),'FaceColor',handles.userColor{clusterSelectionIdx});
    end
    
    % now repatch brain
    allClustVert = vertcat(handles.dataClust{:});
    redClust = handles.dataClust{clusterSelectionIdx};
    [C,ia] = setdiff(allClustVert,redClust);
    blackClust = allClustVert(ia);
    vertList = unique(handles.faces);
    nonClusterVerts = setdiff(vertList,allClustVert);
    
    handles.cData = ones([length(vertList),3]);
    handles.cData(redClust,1) = handles.userColor{clusterSelectionIdx}(1);
    handles.cData(redClust,2) = handles.userColor{clusterSelectionIdx}(2);
    handles.cData(redClust,3) = handles.userColor{clusterSelectionIdx}(3);
    
    handles.cData(blackClust,1) = 0;
    handles.cData(blackClust,2) = 0;
    handles.cData(blackClust,3) = 0;
    
    handles.cData(nonClusterVerts,1) = 1;
    handles.cData(nonClusterVerts,2) = 1;
    handles.cData(nonClusterVerts,3) = 1;
    
    handles.FaceVertexAlphaData = (ones([length(vertList),1])) * 62;
    handles.FaceVertexAlphaData(nonClusterVerts) = 0;
    
    if isfield(handles,'overlay')
        delete(handles.overlay)
    end
    
    figure(mainGuiData.brainFig)
    handles.overlay = patch('Faces',handles.faces,'Vertices',handles.vertCoords,'FaceVertexCData',handles.cData,'FaceVertexAlphaData',handles.FaceVertexAlphaData/1.5, 'AlphaDataMapping' ,'direct','CDataMapping','direct','facecolor','interp','edgecolor','none');
    handles.overlay.FaceAlpha = 'interp';
    
    
end
guidata(hObject, handles);

% --- Executes on button press in meanButton.
function meanButton_Callback(hObject, eventdata, handles)
% hObject    handle to meanButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
clusterSelectionIdx = handles.listbox1.Value - 1;

if clusterSelectionIdx ~= 0
    
    if isempty(handles.userColor{clusterSelectionIdx}) == 1
        handles.userColor{clusterSelectionIdx} = [0 1 1];
    end
    
    if isfield(handles,'p')
        delete(handles.p)
    end
    
    if isfield(handles,'r')
        delete(handles.r)
    end
    
    if isfield(handles,'e')
        delete(handles.e)
    end
    
    axes(handles.clusterHist)
    handles.p = bar(handles.clusterNames,handles.clusterMean,'k');
    handles.e = errorbar(handles.clusterNames,handles.clusterMean,-1*(handles.clusterSEM),handles.clusterSEM,'o','MarkerEdgeColor','none','Color',[0.5 0.5 0.5],'CapSize',8,'LineWidth',1.5);
    
    title('Mean of data within cluster');
    xlabel('Cluster index');
    ylabel('Mean of data');
    hold on
    handles.r = bar(handles.clusterNames(clusterSelectionIdx),handles.clusterMean(clusterSelectionIdx),'FaceColor',handles.userColor{clusterSelectionIdx});
    handles.plotType = 'mean';
end

guidata(hObject, handles);

% --- Executes on button press in sizeButton.
function sizeButton_Callback(hObject, eventdata, handles)
% hObject    handle to sizeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
clusterSelectionIdx = handles.listbox1.Value - 1;

if clusterSelectionIdx ~= 0
    
    if isempty(handles.userColor{clusterSelectionIdx}) == 1
        handles.userColor{clusterSelectionIdx} = [0 1 1];
    end
    
    if isfield(handles,'p')
        delete(handles.p)
    end
    
    if isfield(handles,'r')
        delete(handles.r)
    end
    
    if isfield(handles,'e')
        delete(handles.e)
    end
    
    axes(handles.clusterHist)
    handles.p = bar(handles.clusterNames,handles.clusterLen,'k');
    
    title('# of Vertices within cluster');
    xlabel('Cluster index');
    ylabel('Number of vertices');
    hold on
    handles.r = bar(handles.clusterNames(clusterSelectionIdx),handles.clusterLen(clusterSelectionIdx),'FaceColor',handles.userColor{clusterSelectionIdx});
    
    handles.plotType = 'size';
end

guidata(hObject, handles);

% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);

clusterSelectionIdx = handles.listbox1.Value - 1;

h = get(0,'Children');
% find brain surfer
for hi = 1:length(h)
    if strcmp(h(hi).Name,'Brain Surfer') == 1
        mainGuiNum = hi;
    end
end

% get data from brain surfer
mainGuiData = guidata(h(mainGuiNum));

% get the selection from brain surfer that you are messing around with in
% transparencyGUI
currSelection = (get(mainGuiData.overlaySelection,'Value') - 1);

vertList = unique(handles.faces);
allClustVert = vertcat(handles.dataClust{:});
nonClusterVerts = setdiff(vertList,allClustVert);

mainGuiData.brainMap.Current{currSelection}.Data(nonClusterVerts) = 0;

% delete overlay
if isfield(handles,'overlay')
    delete(handles.overlay)
end

% replot overlay you started out with but with new colormap
[mainGuiData.underlay, mainGuiData.brainMap.Current{currSelection}.overlay, mainGuiData.brainFig, mainGuiData.opts] = plotOverlay(mainGuiData.underlay, mainGuiData.brainMap.Current{currSelection}.Data, 'overlay', mainGuiData.brainMap.Current{currSelection}.overlay,'figHandle', mainGuiData.brainFig, 'threshold',[mainGuiData.overlayThresholdNeg.Value, mainGuiData.overlayThresholdPos.Value], 'hemisphere', mainGuiData.brainMap.hemi{currSelection}, 'opacity', str2double(mainGuiData.opacity.String), 'colorMap', mainGuiData.colormap.String{mainGuiData.colormap.Value}, 'colorSampling',mainGuiData.colormapSpacing.String{mainGuiData.colormapSpacing.Value},'colorBins',str2double(mainGuiData.colorBins.String),'limits', [str2double(mainGuiData.limitMin.String) str2double(mainGuiData.limitMax.String)],'inclZero','false','clusterThresh',mainGuiData.brainMap.Current{currSelection}.clusterThresh,'binarize',mainGuiData.brainMap.Current{currSelection}.binarize,'outline',mainGuiData.brainMap.Current{currSelection}.outline,'binarizeClusters',mainGuiData.brainMap.Current{currSelection}.binarizeClusters,'customColor',mainGuiData.brainMap.Current{currSelection}.customColor,'pMap',mainGuiData.brainMap.Current{currSelection}.pVals,'pThresh',mainGuiData.brainMap.Current{currSelection}.pThresh,'transparencyLimits',mainGuiData.brainMap.Current{currSelection}.transparencyLimits,'transparencyThresholds',mainGuiData.brainMap.Current{currSelection}.transparencyThresholds,'transparencyData',mainGuiData.brainMap.Current{currSelection}.transparencyData,'transparencyPThresh',mainGuiData.brainMap.Current{currSelection}.transparencyPThresh,'invertColor',mainGuiData.brainMap.Current{currSelection}.invertColor,'invertOpacity',mainGuiData.brainMap.Current{currSelection}.invertOpacity,'growROI',mainGuiData.brainMap.Current{currSelection}.growROI);

mainGuiData.brainMap.Current{currSelection}.inclZero = 'false';
mainGuiData.zeroButton.Value = 0;

mainGuiData.opts.colorbar = cbar;
mainGuiData.opts.colorbar.TickLength = [0 0];
imh = mainGuiData.opts.colorbar.Children(1);
imh.AlphaData = mainGuiData.opts.transparencyData;
imh.AlphaDataMapping = 'direct';

% save GUI
guidata(h(mainGuiNum), mainGuiData);

% close everything
% close figure
h = get(0,'Children');
% find transparencyFig
for hi = 1:length(h)
    if strcmp(h(hi).Name,'clusterGUI') == 1
        close(h(hi))
    end
end

% --- Executes on button press in deleteAllButton.
function deleteAllButton_Callback(hObject, eventdata, handles)
% hObject    handle to deleteAllButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);

if (handles.listbox1.Value - 1) ~= 0
    
    h = get(0,'Children');
    % find brain surfer
    for hi = 1:length(h)
        if strcmp(h(hi).Name,'Brain Surfer') == 1
            mainGuiNum = hi;
        end
    end
    
    % get data from brain surfer
    mainGuiData = guidata(h(mainGuiNum));
    
    selection = handles.listbox1.Value - 1;
    selectionRemove = 1:length(handles.listbox1.String)-1;
    handles.listbox1.Value = 2;
    selectionRemove(selection) = [];
    
    handles.listbox1.String(selectionRemove+1) = [];
    
    % remove selection from all data in handles
    handles.clusterMean(selectionRemove) = [];
    handles.clusterStd(selectionRemove) = [];
    handles.clusterSEM(selectionRemove) = [];
    handles.center(selectionRemove) = [];
    handles.centerVal(selectionRemove) = [];
    handles.clusterMean_str(selectionRemove) = [];
    handles.clusterStd_str(selectionRemove) = [];
    handles.center_str(selectionRemove) = [];
    handles.centerVal_str(selectionRemove) = [];
    handles.centerP_str(selectionRemove) = [];
    handles.clusterLen_str(selectionRemove) = [];
    handles.clusterNames_str(selectionRemove) = [];
    handles.clusterNames(selectionRemove) = [];
    handles.clusterLen(selectionRemove) = [];
    handles.dataClust(selectionRemove) = [];
    handles.userColor(selectionRemove) = [];
    
    % remove this cluster and replot everything
    clusterSelectionIdx = 1;
    
    if isempty(handles.userColor{clusterSelectionIdx}) == 1
        handles.userColor{clusterSelectionIdx} = [0 1 1];
    end
    
    % replot axes
    if isfield(handles,'p')
        delete(handles.p)
    end
    
    if isfield(handles,'r')
        delete(handles.r)
    end
    
    if isfield(handles,'e')
        delete(handles.e)
    end
    
    axes(handles.clusterHist)
    switch handles.plotType
        case 'size'
            handles.p = bar(handles.clusterNames,handles.clusterLen,'k');
            
            title('# of Vertices within cluster');
            xlabel('Cluster index');
            ylabel('Number of vertices');
            hold on
            handles.r = bar(handles.clusterNames(clusterSelectionIdx),handles.clusterLen(clusterSelectionIdx),'FaceColor',handles.userColor{clusterSelectionIdx});
        case 'mean'
            handles.p = bar(handles.clusterNames,handles.clusterMean,'k');
            handles.e = errorbar(handles.clusterNames,handles.clusterMean,-1*(handles.clusterSEM),handles.clusterSEM,'o','MarkerEdgeColor','none','Color',[0.5 0.5 0.5],'CapSize',8,'LineWidth',1.5);
            
            title('Mean of data within cluster');
            xlabel('Cluster index');
            ylabel('Mean of data');
            hold on
            handles.r = bar(handles.clusterNames(clusterSelectionIdx),handles.clusterMean(clusterSelectionIdx),'FaceColor',handles.userColor{clusterSelectionIdx});
    end
    
    % now repatch brain
    allClustVert = vertcat(handles.dataClust{:});
    redClust = handles.dataClust{clusterSelectionIdx};
    [C,ia] = setdiff(allClustVert,redClust);
    blackClust = allClustVert(ia);
    vertList = unique(handles.faces);
    nonClusterVerts = setdiff(vertList,allClustVert);
    
    handles.cData = ones([length(vertList),3]);
    handles.cData(redClust,1) = handles.userColor{clusterSelectionIdx}(1);
    handles.cData(redClust,2) = handles.userColor{clusterSelectionIdx}(1);
    handles.cData(redClust,3) = handles.userColor{clusterSelectionIdx}(1);
    
    handles.cData(blackClust,1) = 0;
    handles.cData(blackClust,2) = 0;
    handles.cData(blackClust,3) = 0;
    
    handles.cData(nonClusterVerts,1) = 1;
    handles.cData(nonClusterVerts,2) = 1;
    handles.cData(nonClusterVerts,3) = 1;
    
    handles.FaceVertexAlphaData = (ones([length(vertList),1])) * 62;
    handles.FaceVertexAlphaData(nonClusterVerts) = 0;
    
    if isfield(handles,'overlay')
        delete(handles.overlay)
    end
    
    figure(mainGuiData.brainFig)
    handles.overlay = patch('Faces',handles.faces,'Vertices',handles.vertCoords,'FaceVertexCData',handles.cData,'FaceVertexAlphaData',handles.FaceVertexAlphaData/1.5, 'AlphaDataMapping' ,'direct','CDataMapping','direct','facecolor','interp','edgecolor','none');
    handles.overlay.FaceAlpha = 'interp';
end
guidata(hObject, handles);

% --- Executes on button press in saveClustColor.
function saveClustColor_Callback(hObject, eventdata, handles)
% hObject    handle to saveClustColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% save the raw data you've built up and the colormap you've basically been
% creating.

handles = guidata(hObject);

clusterSelectionIdx = handles.listbox1.Value - 1;

h = get(0,'Children');
% find brain surfer
for hi = 1:length(h)
    if strcmp(h(hi).Name,'Brain Surfer') == 1
        mainGuiNum = hi;
    end
end

% get data from brain surfer
mainGuiData = guidata(h(mainGuiNum));

% get the selection from brain surfer that you are messing around with in
% transparencyGUI
currSelection = (get(mainGuiData.overlaySelection,'Value') - 1);

vertList = unique(handles.faces);
allClustVert = vertcat(handles.dataClust{:});
nonClusterVerts = setdiff(vertList,allClustVert);
customColor = zeros([length(handles.dataClust),3]);

% write in cluster number into data for overlay
for clusteri = 1:length(handles.dataClust)
    mainGuiData.brainMap.Current{currSelection}.Data(handles.dataClust{clusteri}) = clusteri;
    if isempty(handles.userColor{clusteri})
        customColor(clusteri,:) = [0 1 1];
    else
        customColor(clusteri,:) = handles.userColor{clusteri};
    end
end
% remove everything not in clusters from data
mainGuiData.brainMap.Current{currSelection}.Data(nonClusterVerts) = 0;

% save colormap into main GUI handle
mainGuiData.brainMap.Current{currSelection}.customColor = customColor;
% save colormap into colormap folder
[oFile, oPath] = uiputfile({'*.mat'},'Pick a name for your colormap',[mainGuiData.paths.colormapsPath '/colormap']);
save([oPath oFile]','customColor')

% delete overlay
if isfield(handles,'overlay')
    delete(handles.overlay)
end

% update all options
mainGuiData.brainMap.Current{currSelection}.inclZero = 'false';
mainGuiData.brainMap.Current{currSelection}.limitMin = 1;
mainGuiData.brainMap.Current{currSelection}.limitMax = max(mainGuiData.brainMap.Current{currSelection}.Data);
mainGuiData.brainMap.Current{currSelection}.overlayThresholdNeg = 0;
mainGuiData.brainMap.Current{currSelection}.overlayThresholdPos = mainGuiData.brainMap.Current{currSelection}.limitMin;
mainGuiData.brainMap.Current{currSelection}.colormapSpacing = 'even';
mainGuiData.brainMap.Current{currSelection}.clusterThresh = 0;
mainGuiData.brainMap.Current{currSelection}.pThresh = [];
mainGuiData.brainMap.Current{currSelection}.growROI = 0;

mainGuiData.zeroButton.Value = 0;
mainGuiData.limitMin.String = num2str(mainGuiData.brainMap.Current{currSelection}.limitMin);
mainGuiData.limitMax.String = num2str(mainGuiData.brainMap.Current{currSelection}.limitMax);
mainGuiData.overlayThresholdNeg.Value = mainGuiData.brainMap.Current{currSelection}.overlayThresholdNeg;
mainGuiData.overlayThresholdNegDynamic.String = num2str(mainGuiData.brainMap.Current{currSelection}.overlayThresholdNeg);
mainGuiData.overlayThresholdPos.Value = mainGuiData.brainMap.Current{currSelection}.overlayThresholdPos;
mainGuiData.overlayThresholdPosDynamic.String = num2str(mainGuiData.brainMap.Current{currSelection}.overlayThresholdPos);
mainGuiData.colormapSpacing.Value = 2;
mainGuiData.clusterThreshText.String = '0';
mainGuiData.clusterThreshSlider.Value = 0;
mainGuiData.pSlider.Value = 1;
mainGuiData.pText.String = '1';
mainGuiData.growText.String = '0';

% load in colormaps since you just saved one
colormapDir = dir([mainGuiData.paths.colormapsPath '/*.mat']);
colormaps = {colormapDir.name};
for colori = 1:length(colormaps)
    colormaps{colori} = colormaps{colori}(1:end-4);
end

if isempty(colormaps) == 0
    mainGuiData.colormapCustom = vertcat(zeros([length(mainGuiData.colormap.String), 1]),ones([length(colormaps), 1]));
    mainGuiData.colormap.String = vertcat(mainGuiData.colormap.String,colormaps');
end

% find colormap string corresponding to file name you just saved
idx = find(strcmp(mainGuiData.colormap.String, oFile(1:end-4)));
if length(idx) > 1
    mainGuiData.colormap.Value = idx(1);
end

% replot overlay you started out with
[mainGuiData.underlay, mainGuiData.brainMap.Current{currSelection}.overlay, mainGuiData.brainFig, mainGuiData.opts] = plotOverlay(mainGuiData.underlay, mainGuiData.brainMap.Current{currSelection}.Data, 'overlay', mainGuiData.brainMap.Current{currSelection}.overlay,'figHandle', mainGuiData.brainFig, 'threshold',[mainGuiData.overlayThresholdNeg.Value, mainGuiData.overlayThresholdPos.Value], 'hemisphere', mainGuiData.brainMap.hemi{currSelection}, 'opacity', str2double(mainGuiData.opacity.String), 'colorMap', mainGuiData.colormap.String{mainGuiData.colormap.Value}, 'colorSampling',mainGuiData.colormapSpacing.String{mainGuiData.colormapSpacing.Value},'colorBins',str2double(mainGuiData.colorBins.String),'limits', [str2double(mainGuiData.limitMin.String) str2double(mainGuiData.limitMax.String)],'inclZero','false','clusterThresh',mainGuiData.brainMap.Current{currSelection}.clusterThresh,'binarize',mainGuiData.brainMap.Current{currSelection}.binarize,'outline',mainGuiData.brainMap.Current{currSelection}.outline,'binarizeClusters',mainGuiData.brainMap.Current{currSelection}.binarizeClusters,'customColor',mainGuiData.brainMap.Current{currSelection}.customColor,'pMap',mainGuiData.brainMap.Current{currSelection}.pVals,'pThresh',mainGuiData.brainMap.Current{currSelection}.pThresh,'transparencyLimits',mainGuiData.brainMap.Current{currSelection}.transparencyLimits,'transparencyThresholds',mainGuiData.brainMap.Current{currSelection}.transparencyThresholds,'transparencyData',mainGuiData.brainMap.Current{currSelection}.transparencyData,'transparencyPThresh',mainGuiData.brainMap.Current{currSelection}.transparencyPThresh,'invertColor',mainGuiData.brainMap.Current{currSelection}.invertColor,'invertOpacity',mainGuiData.brainMap.Current{currSelection}.invertOpacity,'growROI',mainGuiData.brainMap.Current{currSelection}.growROI);

mainGuiData.opts.colorbar = cbar;
mainGuiData.opts.colorbar.TickLength = [0 0];
imh = mainGuiData.opts.colorbar.Children(1);
imh.AlphaData = mainGuiData.opts.transparencyData;
imh.AlphaDataMapping = 'direct';

% save GUI
guidata(h(mainGuiNum), mainGuiData);

% close everything
% close figure
h = get(0,'Children');
% find transparencyFig
for hi = 1:length(h)
    if strcmp(h(hi).Name,'clusterGUI') == 1
        close(h(hi))
    end
end
