function [clusters, clusterLen] = getClusters(verts, allFaces)
% This script will create a cell array where each cell contains the
% vertices of a cluster in your overlay. It requires passing in the
% vertices of your thresholded overlay (inDataVertices), and all faces in
% your underlay ('allFaces'). It will also produce a vector of cluster
% lengths ('clustLen'). Alex Teghipco // alex.teghipco@uci.edu // 11/28/18

% make copy of vertices
dataVert = verts;
allVert = unique(allFaces);

% set up clusters structure
clusteri = 1;
clusters{clusteri} = [];

% start with a vertex in the brain that is not thresholded out
area = dataVert(1);

% we will update a list of vertices we haven't looked at. If it's
% empty, stop analysis
while isempty(dataVert) == 0
    
    % As long as area is not empty
    while isempty(area) == 0
        %disp(num2str(length(vertListCopy)))
        
        % Remove any vertices in area that are not in vertList
        % (i.e., were are below the threshold) and remove from area
        [C,ia] = setdiff(area,dataVert);
        area(ia) = [];
        
        % Remove vertices in the area from the list of vertices we
        % haven't looked at
        [C,ia,ib] = intersect(dataVert,area);
        dataVert(ia) = [];
        
        % Assign remainder of vertices in area to a clusters cell
        clusters{clusteri} = vertcat(clusters{clusteri},area);
        
        % find all allFaces that border the area
        vertFaceX = ismember(allFaces(:,1),area);
        vertFaceY = ismember(allFaces(:,2),area);
        vertFaceZ = ismember(allFaces(:,3),area);
        vertFaceXYZ = vertFaceX+vertFaceY+vertFaceZ;
        vertFaceXYZIdx = find(vertFaceXYZ ~= 0);
        
        area = unique(allFaces(vertFaceXYZIdx,:));
        
        % if area is only 1 face row matches the area sometimes
        % there is an error because of how unique organizes data
        if size(area,1) < size(area,2)
            area = area';
        end
        
        % remove those allFaces already part of the clusters
        [C,ia,ib] = intersect(area,clusters{clusteri});
        area(ia) = [];
    end
    
    if isempty(dataVert) == 0
        area = dataVert(1);
        clusteri = clusteri+1;
        clusters{clusteri} = [];
    end
end

clusterLen = cellfun('length',clusters);
