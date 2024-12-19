function [clusters] = getClusterBoundary(clusters, allFaces)
% Determines the boundary vertices of given clusters within a mesh.
%
%   This function identifies and updates the boundary vertices for each cluster
%   provided in the 'clusters' cell array. A boundary vertex is defined as a vertex
%   that is part of a face where at least one other vertex lies outside the cluster.
%   The function processes each cluster individually, ensuring that the resulting
%   clusters accurately represent their boundaries within the mesh.
%
% **Mandatory Arguments**
% -----------------------
%   clusters    - (1 x c cell array) Cell array where each cell contains a vector of
%                vertex indices representing a cluster within the mesh.
%
%   allFaces    - (f x 3 matrix) Matrix defining the mesh faces, where each row contains
%                three vertex indices that form a triangular face.
%
% **Output**
% ----------
%   clusters    - (1 x c cell array) Updated cell array where each cell contains a vector
%                of vertex indices representing the boundary vertices of the original
%                clusters.
%
% **Function Call Examples**
% --------------------------
%   % Example 1: Basic usage with predefined clusters and mesh faces
%   initialClusters = { [1, 2, 3], [4, 5, 6] };
%   meshFaces = [1 2 3; 2 3 4; 3 4 5; 4 5 6];
%   boundaryClusters = getClusterBoundary(initialClusters, meshFaces);
%
%   % Example 2: Updating clusters after modifying the mesh
%   modifiedFaces = [1 2 3; 2 3 7; 3 7 8; 7 8 6];
%   updatedClusters = getClusterBoundary(initialClusters, modifiedFaces);
%
% **Notes**
% ----------
%   - The function assumes that 'allFaces' contains valid vertex indices corresponding
%     to the vertices in the mesh.
%   - Clusters should be non-overlapping for accurate boundary determination.
%   - The function updates the input 'clusters' by replacing each cluster with its
%     boundary vertices, which may reduce the number of vertices in each cluster.
%   - Ensure that the mesh is properly defined and free of degenerate faces to avoid
%     incorrect boundary calculations.
%
% ----------
%   Alex Teghipco // alex.teghipco@uci.edu // 11/28/18

% Obtain a unique list of all vertices present in the mesh faces
vertList = unique(allFaces);

% Iterate over each cluster to determine its boundary vertices
for clusteri = 1:length(clusters)
    % Vertices inside the current cluster
    vertInside = clusters{clusteri};

    % Vertices outside the current cluster
    vertOutside = setdiff(vertList, vertInside);

    % Identify faces that have at least one vertex inside the cluster
    faceX = ismember(allFaces(:,1), vertInside);
    faceY = ismember(allFaces(:,2), vertInside);
    faceZ = ismember(allFaces(:,3), vertInside);
    faceXYZ = faceX | faceY | faceZ;  % Logical OR to combine conditions
    faceInsideIdx = find(faceXYZ);
    facesInside = allFaces(faceInsideIdx, :);

    % From the faces inside the cluster, find those that have at least one vertex outside
    faceoutsideX = ismember(facesInside(:,1), vertOutside);
    faceoutsideY = ismember(facesInside(:,2), vertOutside);
    faceoutsideZ = ismember(facesInside(:,3), vertOutside);
    faceoutsideXYZ = faceoutsideX | faceoutsideY | faceoutsideZ;  % Logical OR to combine conditions

    % Indices of faces that are on the boundary of the cluster
    faceoutsideIdx = find(faceoutsideXYZ);

    % Faces that lie on the boundary of the cluster
    facesInsideBorderOutside = facesInside(faceoutsideIdx, :);

    % Update the current cluster with its boundary vertices
    clusters{clusteri} = unique(facesInsideBorderOutside);
end
