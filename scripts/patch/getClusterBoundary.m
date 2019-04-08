function [clusters] = getClusterBoundary(clusters, allFaces)
% This script will determine all vertices that are at the bounadry of clusters provided in 'clusters'. 'clusters' is a cell array with vertices. Additionally a matrix of all faces in your underlay must be passed in allFaces.
% Alex Teghipco // alex.teghipco@uci.edu // 11/28/18
vertList = unique(allFaces);

for clusteri = 1:length(clusters)
    vertInside = clusters{clusteri};
    vertOutside = setdiff(vertList,vertInside);
    
    % find all faces that have vertices inside cluster
    faceX = ismember(allFaces(:,1),vertInside);
    faceY = ismember(allFaces(:,2),vertInside);
    faceZ = ismember(allFaces(:,3),vertInside);
    faceXYZ = faceX+faceY+faceZ;
    faceInsideIdx = find(faceXYZ ~= 0); %~= 0);
    facesInside = allFaces(faceInsideIdx,:);
    
    % find which faces that are inside cluster border faces outside cluster
    faceoutsideX = ismember(facesInside(:,1),vertOutside);
    faceoutsideY = ismember(facesInside(:,2),vertOutside);
    faceoutsideZ = ismember(facesInside(:,3),vertOutside);
    faceoutsideXYZ = faceoutsideX+faceoutsideY+faceoutsideZ;
    faceoutsideIdx = find(faceoutsideXYZ >= 2); %~= 0); % if this is zero, then you will outline a boundary around the clusters (i.e., grown by 1 neighbor)
    
    facesInsideBorderOutside = facesInside(faceoutsideIdx,:);
    clusters{clusteri} = unique(facesInsideBorderOutside);
end

