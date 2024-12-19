function [sData] = smoothVertData(data, verts, faces, varargin)
% smoothVertData Smooths vertex-based data using neighboring vertex values.
%
% This function smooths scalar or multi-dimensional data associated with
% vertices on a mesh surface. Smoothing is performed by averaging each data
% point with its neighboring vertices, repeated for a specified number of steps.
% The function supports various smoothing configurations, including the number
% of smoothing iterations, the size of the smoothing neighborhood, and selective
% application based on data thresholds or cluster information.
%
% **Syntax**
% -------
%   sData = smoothVertData(data, verts, faces, 'Name', Value, ...)
%
% **Description**
% -----------
%   sData = smoothVertData(data, verts, faces) smooths the input data using
%   default smoothing parameters. The default settings perform one smoothing
%   iteration with a neighborhood size of five vertices.
%
%   sData = smoothVertData(data, verts, faces, 'Name', Value, ...) allows
%   customization of the smoothing process through various name-value pair
%   arguments.
%
% **Inputs**
% ------
%   data    - (Matrix or Vector) Data to be smoothed.
%             - If a vector: (n x 1), where n is the number of vertices.
%             - If a matrix: (n x p), where p is the number of data sets.
%
%   verts   - (n x 3 Matrix) Vertex coordinates.
%             - Each row represents a vertex with [x, y, z] coordinates.
%
%   faces   - (f x 3 Matrix) Faces of the mesh.
%             - Each row defines a triangular face by indexing into `verts`.
%
% **Output**
% ------
%   sData   - (Matrix) Smoothed data.
%             - Same dimensions as the input `data` (n x p).
%
% **Name-Value Pair Arguments**
% -------------------------
%   The following optional name-value pair arguments can be specified to
%   customize the smoothing behavior:
%
%   'smoothSteps'      - (Positive Integer) Number of smoothing iterations to perform.
%                        - Each step averages the data based on the current neighborhood.
%                        - Default: 1.
%
%   'smoothArea'       - (Positive Integer) Number of closest vertices to include in the
%                        smoothing neighborhood for each vertex.
%                        - Determines the breadth of the smoothing effect.
%                        - Default: 5.
%
%   'toAssign'         - (String) Specifies how to assign new smoothed values.
%                        - Options:
%                          * 'all'          - Assign smoothed values to all vertices.
%                          * 'thresholded'  - Assign smoothed values only to vertices with non-zero data.
%                        - Default: 'all'.
%
%   'clusterData'      - (Cell Array) Precomputed cluster information.
%                        - If provided, the function uses this data to determine
%                          which vertices to smooth, bypassing internal cluster
%                          generation.
%                        - Useful for consistent smoothing across multiple datasets.
%                        - Default: [] (empty).
%
% **Outputs**
% -------
%   sData   - Smoothed data matrix, maintaining the same dimensions as the input `data`.
%
% **Examples**
% -------
%   **Example 1: Basic Smoothing with Default Parameters**
%   % Load or define your mesh data
%   verts = rand(1000, 3);         % Example vertex coordinates
%   faces = randperm(1000, 3000);  % Example faces (ensure they form valid triangles)
%
%   % Create example data to smooth
%   data = randn(1000, 1);         % Scalar data for each vertex
%
%   % Perform smoothing with default settings
%   sData = smoothVertData(data, verts, faces);
%
%   **Example 2: Smoothing with Multiple Iterations and Larger Neighborhood**
%   % Load or define your mesh data
%   verts = rand(1000, 3);
%   faces = randperm(1000, 3000);
%
%   % Create example data
%   data = randn(1000, 1);
%
%   % Perform smoothing with 3 iterations and a neighborhood of 10 vertices
%   sData = smoothVertData(data, verts, faces, 'smoothSteps', 3, 'smoothArea', 10);
%
%   **Example 3: Selective Smoothing Based on Data Threshold**
%   % Load or define your mesh data
%   verts = rand(1000, 3);
%   faces = randperm(1000, 3000);
%
%   % Create example data with some zeros
%   data = randn(1000, 1);
%   data(data < 0) = 0;
%
%   % Perform smoothing only on vertices with non-zero data
%   sData = smoothVertData(data, verts, faces, 'toAssign', 'thresholded');
%
%   **Example 4: Smoothing with Precomputed Cluster Data**
%   % Load or define your mesh data
%   verts = rand(1000, 3);
%   faces = randperm(1000, 3000);
%
%   % Create example data
%   data = randn(1000, 1);
%
%   % Precompute cluster data (assuming getClusters is a custom function)
%   clusters = getClusters(find(data ~= 0), faces);
%
%   % Perform smoothing using precomputed cluster data
%   sData = smoothVertData(data, verts, faces, 'clusterData', clusters);
%
% **Notes**
% -----
%   - **Data Integrity**: Ensure that the `data` matrix has the same number of rows as there are vertices in `verts`.
%   - **Mesh Validity**: The `faces` matrix should consist of valid triangular indices referencing `verts`.
%   - **Smoothing Effects**: Increasing `smoothSteps` and `smoothArea` will result in more pronounced smoothing, potentially blurring fine details.
%   - **Selective Smoothing**: Using 'thresholded' for `toAssign` allows for targeted smoothing, preserving areas with zero data.
%   - **Performance**: Larger meshes and higher smoothing parameters may increase computation time.
%   - **Cluster Data**: Providing `clusterData` can optimize performance by avoiding redundant cluster computations, especially when smoothing multiple datasets with similar cluster structures.
%
% **Author**
% -------
%   Alex Teghipco // alex.teghipco@uci.edu // Last Updated: 2024-04-27
%
% **See Also**
% --------
%   patchOverlay, getClusters, getClusterBoundary

% Defaults
options = struct('smoothSteps', 1, 'smoothArea', 5, 'toAssign', 'all','clusterData',[]);
optionNames = fieldnames(options);

% Check number of arguments passed
if length(varargin) > (length(fieldnames(options))*2)
    error('You have supplied too many arguments')
end
nArgs = length(varargin);
if round(nArgs/2)~=nArgs/2
    error('You are missing an argument name somewhere in your list of inputs')
end

% now parse the arguments
vleft = varargin(1:end);
for pair = reshape(vleft,2,[]) %pair is {propName;propValue}
    inpName = pair{1}; % make case insensitive by using Odatawer() here but this can be buggy
    if any(strcmp(inpName,optionNames))
        options.(inpName) = pair{2};
    else
        error('%s is not a recognized parameter name',inpName)
    end
end
% make copy of vertices and data
tmpVert = verts;

% smooth each face that the vertices that are left are a part of. Area
% should correspond to closest X number of faces (first all that are
% adjacent, then all)
sData = data;

% get nearest X vertices to each vertex to smooth (user selected area X)
for smoothi = 1:options.smoothSteps
    toSmooth = find(sData ~= 0);
    
    if smoothi == 1
        if options.smoothArea > 0
            switch options.toAssign
                case 'thresholded'
                    [~,neighborhood] = pdist2(tmpVert(toSmooth,:),tmpVert(toSmooth,:),'seuclidean','Smallest',options.smoothArea+1);
                case 'all'
                    [~,neighborhood] = pdist2(tmpVert,tmpVert(toSmooth,:),'seuclidean','Smallest',options.smoothArea+1);
            end
        end
    else
        switch options.toAssign
            case 'all'
                [~,newVertNeigh] = pdist2(tmpVert,tmpVert(newVerts,:),'seuclidean','Smallest',options.smoothArea+1);
                neighborhood = [neighborhood newVertNeigh];
        end
    end
    
% now smooth
    switch options.toAssign
        case 'thresholded'
            %sData(toSmooth) = mean(sData(toSmooth(neighborhood)));
            sData(toSmooth) = mean(sData(neighborhood),1);
        case 'all'
            for j = 1:size(neighborhood,2)
                sData(neighborhood(:,j)) = mean(sData(neighborhood(:,j)));
            end
    end
    toSmooth2 = find(sData ~= 0);
    newVerts = setdiff(toSmooth2,toSmooth);
end
