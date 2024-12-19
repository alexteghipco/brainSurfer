function [growVerts, allThreshVerts, growVertTracker] = growMap(growVerts, growSteps, allThreshVerts, allFaces)
% Expands or Contracts Vertex Sets on a Mesh Over Specified Steps
%
%   This function iteratively grows or shrinks clusters of vertices on a mesh by
%   adding neighboring vertices (growth) or removing border vertices (contraction)
%   over a defined number of steps. It updates the sets of vertices and tracks the
%   changes throughout the process.
%
% **Mandatory Arguments**
% -----------------------
%   growVerts      - (Cell array) A cell array where each cell contains a vector of vertex
%                    indices representing the initial clusters to grow or shrink.
%                    Example: growVerts{1} = [1, 2, 3]; growVerts{2} = [4, 5, 6];
%
%   growSteps      - (Integer) The number of growth or contraction steps to perform.
%                    - Positive values indicate growth (expansion of vertex clusters).
%                    - Negative values indicate contraction (shrinking of vertex clusters).
%                    - Zero implies no growth or contraction; the function returns the
%                      initial state.
%
%   allThreshVerts - (Vector) A vector containing the initial set of threshold vertices.
%                    These vertices define the current boundary of the map and are updated
%                    as vertices are grown or contracted.
%
%   allFaces       - (F x 3 matrix) A matrix defining the mesh faces, where each row contains
%                    three vertex indices that form a triangular face.
%                    Example:
%                      allFaces = [
%                          1, 2, 3;
%                          4, 5, 6;
%                          ...
%                      ];
%
% **Output**
% ----------
%   growVerts       - (Cell array) The updated cell array of vertex clusters after performing
%                     the specified growth or contraction steps. Each cell corresponds to
%                     a cluster, containing the vertex indices that belong to it.
%
%   allThreshVerts  - (Vector) The updated vector of threshold vertices after the growth or
%                     contraction process. These vertices represent the new boundaries of
%                     the map.
%
%   growVertTracker - (Cell array) A cell array tracking all vertices that have been
%                     added (in the case of growth) or removed (in the case of contraction)
%                     for each cluster throughout the process. This helps in monitoring
%                     the changes made during each step.
%
% **Function Call Examples**
% --------------------------
%   % Example 1: Growing vertex clusters by 3 steps
%   initialGrowVerts = { [1, 2, 3], [4, 5, 6] };
%   initialThreshVerts = [1, 2, 3, 4, 5, 6];
%   meshFaces = [
%       1, 2, 3;
%       2, 3, 7;
%       3, 7, 8;
%       4, 5, 6;
%       5, 6, 9;
%       6, 9, 10
%   ];
%   [updatedGrowVerts, updatedThreshVerts, growTracker] = growMap(initialGrowVerts, 3, initialThreshVerts, meshFaces);
%
%   % Example 2: Contracting vertex clusters by 2 steps
%   initialGrowVerts = { [7, 8], [9, 10] };
%   initialThreshVerts = [7, 8, 9, 10];
%   meshFaces = [
%       1, 2, 3;
%       2, 3, 7;
%       3, 7, 8;
%       4, 5, 6;
%       5, 6, 9;
%       6, 9, 10
%   ];
%   [updatedGrowVerts, updatedThreshVerts, growTracker] = growMap(initialGrowVerts, -2, initialThreshVerts, meshFaces);
%
% **Author**
% -------
%   Alex Teghipco // alex.teghipco@uci.edu // Last Updated: 2024-12-01
%
% **Notes**
% ----------
%   - The function operates on each cluster independently, allowing for multiple regions
%     to be grown or contracted simultaneously.
%
%   - The mesh is assumed to be composed of triangular faces. Non-triangular meshes may
%     lead to unexpected behavior.
%
%   - Input Validation:
%     - It is recommended to ensure that `growVerts` is a cell array, `allFaces` is an
%       F x 3 matrix with valid vertex indices, and `growSteps` is an integer before
%       invoking the function to prevent runtime errors.
%
%   - The function does not handle cases where `growSteps` is zero explicitly beyond returning
%     the initial `growVertTracker`. 


if growSteps >= 0
    gs = 'pos';
    growVertTracker = growVerts;
elseif growSteps < 0
    gs = 'neg';
    growVertTracker = cell(size(growVerts));
end

growSteps = abs(growSteps);
%growVertsB = growVerts;
 
while growSteps > 0
    for clusteri = 1:length(growVerts)
        if strcmpi(gs,'pos')
            % get all faces that contain the vertices you want to grow
            % (i.e., boundary of the map)
            vertX = ismember(allFaces(:,1),growVerts{clusteri});
            vertY = ismember(allFaces(:,2),growVerts{clusteri});
            vertZ = ismember(allFaces(:,3),growVerts{clusteri});
            vertXYZ = vertX+vertY+vertZ;
            vertXYZIdx = find(vertXYZ ~= 0);
            
            % now take all of those faces and find whichever ones contain
            % vertices inside the map (i.e., not just the boundary)
            growVertFaces = allFaces(vertXYZIdx,:);
            vertX2 = ismember(growVertFaces(:,1),allThreshVerts);
            vertY2 = ismember(growVertFaces(:,2),allThreshVerts);
            vertZ2 = ismember(growVertFaces(:,3),allThreshVerts);
            vertXYZ2 = vertX2+vertY2+vertZ2;
            vertXYZ2Idx = find(vertXYZ2 >= 1);
            
            growVerts{clusteri} = vertcat(growVerts{clusteri},unique(allFaces(vertXYZIdx(vertXYZ2Idx),:)));
            growVerts{clusteri} = unique(growVerts{clusteri});
            [C,ia] = setdiff(growVerts{clusteri},allThreshVerts);
            growVerts{clusteri} = growVerts{clusteri}(ia);
            
            growVertTracker{clusteri} = vertcat(growVertTracker{clusteri},growVerts{clusteri});
            allThreshVerts = vertcat(allThreshVerts, growVerts{clusteri});
            
        elseif strcmpi(gs,'neg')
            [C,ia,ib] = intersect(growVerts{clusteri},allThreshVerts); % find border in your data
            allThreshVerts(ib) = []; % remove it
            growVertTracker{clusteri} = vertcat(growVertTracker{clusteri},growVerts{clusteri}(ia)); % track what you've removed
            
            % get everything that borders the boundary that just got
            % removed...first identify the faces for that boundary
            growTmp = growVerts{clusteri}(ia);
            vertX = ismember(allFaces(:,1),growTmp);
            vertY = ismember(allFaces(:,2),growTmp);
            vertZ = ismember(allFaces(:,3),growTmp);
            vertXYZ = vertX+vertY+vertZ;
            vertXYZIdx = find(vertXYZ ~= 0);
            
            % now take all of those faces and find whichever ones contain
            % vertices inside the map
            growVertFaces = allFaces(vertXYZIdx,:);
            vertX2 = ismember(growVertFaces(:,1),allThreshVerts);
            vertY2 = ismember(growVertFaces(:,2),allThreshVerts);
            vertZ2 = ismember(growVertFaces(:,3),allThreshVerts);
            vertXYZ2 = vertX2+vertY2+vertZ2;
            vertXYZ2Idx = find(vertXYZ2 >= 1);
            
            brdr = unique(allFaces(vertXYZIdx(vertXYZ2Idx),:));
            growVerts{clusteri} = setdiff(brdr,growVertTracker{clusteri}); % remove anything you've already removed 
        end
    end
    growSteps = growSteps - 1;
end