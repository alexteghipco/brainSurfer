function [clusters, clusterLen] = getClusters(verts, allFaces)
% Identifies and groups connected vertex clusters within a mesh overlay
%
%   This function processes a set of thresholded vertices and mesh faces to identify
%   connected clusters of vertices. Each cluster represents a contiguous region within
%   the overlay, based on the connectivity defined by the mesh faces. The output is a
%   cell array where each cell contains the vertices belonging to a specific cluster,
%   along with a corresponding vector detailing the size of each cluster.
%
% **Mandatory Arguments**
% -----------------------
%   verts     - (Vector) A vector containing the indices of vertices in the thresholded
%               overlay. These vertices define the regions of interest that will be
%               clustered based on their connectivity within the mesh.
%               - Example: verts = [1, 2, 3, 5, 8, 13, 21];
%
%   allFaces  - (F x 3 Matrix) A matrix defining the mesh faces, where each row contains
%               three vertex indices that form a triangular face. This matrix defines the
%               connectivity of the mesh and is used to determine which vertices are
%               adjacent to each other.
%               - Example:
%                 allFaces = [
%                     1, 2, 3;
%                     2, 3, 4;
%                     3, 4, 5;
%                     5, 6, 7;
%                     8, 9, 10;
%                     ...
%                 ];
%
% **Output**
% ----------
%   clusters   - (Cell Array) A cell array where each cell contains a vector of vertex
%                indices that belong to a specific connected cluster within the overlay.
%                - Example:
%                  clusters{1} = [1, 2, 3, 4, 5];
%                  clusters{2} = [8, 9, 10];
%
%   clusterLen - (Vector) A vector containing the number of vertices in each cluster.
%                Each element corresponds to the length of the respective cell in
%                `clusters`.
%                - Example:
%                  clusterLen = [5, 3];
%
% **Function Call Examples**
% --------------------------
%   % Example 1: Identifying clusters in a simple mesh
%   verts = [1, 2, 3, 5, 8, 13, 21];
%   allFaces = [
%       1, 2, 3;
%       2, 3, 4;
%       3, 4, 5;
%       5, 6, 7;
%       8, 9, 10;
%       10, 11, 12;
%       13, 14, 15;
%       15, 16, 17;
%       21, 22, 23
%   ];
%   [clusters, clusterLen] = getClusters(verts, allFaces);
%   % Expected Output:
%   % clusters{1} = [1, 2, 3, 5];
%   % clusters{2} = [8];
%   % clusters{3} = [13];
%   % clusters{4} = [21];
%   % clusterLen = [4, 1, 1, 1];
%
%   % Example 2: Handling overlapping and non-overlapping clusters
%   verts = [1, 2, 3, 4, 5, 6, 7, 8, 9];
%   allFaces = [
%       1, 2, 3;
%       3, 4, 5;
%       5, 6, 7;
%       7, 8, 9;
%       2, 3, 10;  % Vertex 10 is not in verts
%       5, 6, 11   % Vertex 11 is not in verts
%   ];
%   [clusters, clusterLen] = getClusters(verts, allFaces);
%   % Expected Output:
%   % clusters{1} = [1, 2, 3, 4, 5, 6, 7, 8, 9];
%   % clusterLen = [9];
%
% **Notes**
% ----------
%   - The function assumes that the mesh is composed of triangular faces. Non-triangular
%     meshes may lead to unexpected behavior or incorrect cluster identification.
%
%   - Input Validation:
%     - Ensure that `verts` is a non-empty vector containing valid vertex indices present
%       in `allFaces`.
%     - Verify that `allFaces` is an F x 3 matrix with positive integer values representing
%       valid vertex indices.
%
%   - The function initializes the clustering process with the first vertex in `verts` and
%     iteratively explores connected vertices based on the mesh connectivity until all
%     vertices in `verts` are assigned to clusters.
%
%   - The output `clusters` is organized such that each cell corresponds to a unique cluster,
%     and `clusterLen` provides a quick reference to the size of each cluster.
%
% -------------------------------------------------------------------------
%
%   Algorithm Overview:
%   -------------------
%   1. Initialize a copy of the input vertices (`dataVert`) and extract all unique
%      vertices from `allFaces` (`allVert`).
%
%   2. Set up the `clusters` cell array to store identified clusters, starting with the
%      first vertex in `dataVert`.
%
%   3. Iteratively explore connected vertices:
%      a. Remove vertices from the current `area` that are not in `dataVert` (i.e., those
%         that do not meet the threshold).
%      b. Assign the remaining vertices in `area` to the current cluster.
%      c. Identify all faces that are adjacent to the current `area` and expand `area` to
%         include their vertices.
%      d. Remove vertices already assigned to the current cluster from `area`.
%
%   4. Repeat the process until all vertices in `dataVert` have been assigned to clusters.
%
%   5. Calculate `clusterLen` by determining the number of vertices in each cluster.
%
% **Author**
% -------
%   Alex Teghipco // alex.teghipco@uci.edu // Last Updated: 2024-12-01
%

% Make a copy of the input vertices
dataVert = verts;
allVert = unique(allFaces);

% Initialize the clusters cell array
clusteri = 1;
clusters{clusteri} = [];

% Start with the first vertex in the overlay
area = dataVert(1);

% Continue clustering until all vertices have been processed
while ~isempty(dataVert)

    % Expand the current cluster by exploring connected vertices
    while ~isempty(area)
        % Remove vertices from 'area' that are not in 'dataVert'
        [C, ia] = setdiff(area, dataVert);
        area(ia) = [];

        % Remove the current 'area' vertices from 'dataVert'
        [C, ia, ~] = intersect(dataVert, area);
        dataVert(ia) = [];

        % Assign the remaining 'area' vertices to the current cluster
        clusters{clusteri} = vertcat(clusters{clusteri}, area);

        % Find all faces that include any vertex in the current 'area'
        vertFaceX = ismember(allFaces(:,1), area);
        vertFaceY = ismember(allFaces(:,2), area);
        vertFaceZ = ismember(allFaces(:,3), area);
        vertFaceXYZ = vertFaceX | vertFaceY | vertFaceZ;
        vertFaceXYZIdx = find(vertFaceXYZ);

        % Expand 'area' to include all vertices from the adjacent faces
        area = unique(allFaces(vertFaceXYZIdx, :));

        % Ensure 'area' is a column vector
        if size(area, 1) < size(area, 2)
            area = area';
        end

        % Remove vertices already assigned to the current cluster
        [C, ia, ~] = intersect(area, clusters{clusteri});
        area(ia) = [];
    end

    % If there are remaining vertices, start a new cluster
    if ~isempty(dataVert)
        area = dataVert(1);
        clusteri = clusteri + 1;
        clusters{clusteri} = [];
    end
end

% Calculate the length of each cluster
clusterLen = cellfun(@length, clusters);
