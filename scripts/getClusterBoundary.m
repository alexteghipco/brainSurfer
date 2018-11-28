function [clusters] = getClusterBoundary(clusters, allFaces)

% loop over all clusters
% for clusteri = 1:length(clusters)
%     % We want to make a copy of our original faces because we will
%     % be looking for vertices in our cluster w/at least one
%     % neighbor outside cluster
%     facesTmp = allFaces;
%     % save cluster
%     clusterTmp = clusters{clusteri};
%     % loop over all vertices
%     for verti = 1:length(clusterTmp)
%         faceX = ismember(facesTmp(:,1),clusterTmp(verti));
%         faceY = ismember(facesTmp(:,2),clusterTmp(verti));
%         faceZ = ismember(facesTmp(:,3),clusterTmp(verti));
%         faceXYZ = faceX+faceY+faceZ;
%         faceXYZIdx = find(faceXYZ ~= 0);
%         
%         % neighborhood for vertex
%         area = unique(facesTmp(faceXYZIdx,:));
%         
%         % find the number of neighbors that are not within cluster
%         [C,ia] = setdiff(area,clusterTmp);
%         
%         % if there are neighbors for the vertex not in cluster mark
%         % this cluster as part of the border
%         if length(C) >= 1 % 1 is the number of neighbors for vertex that are not in cluster
%             border(verti) = 1;
%         else
%             border(verti) = 0;
%         end
%     end
%     % find all vertices that are not border
%     notBorder = find(border == 0);
%     
%     % remove them from the list of vertices within cluster
%     clusters{clusteri}(notBorder) = [];
%     clear border
% end

%% Alternative script
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

