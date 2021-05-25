function [sData] = smoothVertData(data, verts, faces, varargin)
% This function is for smoothing data based on the values of its
% neighboring vertices.
%
% Mandatory arguments------------------------------------------------------
%
% data: data matrix or vector n x 1 where n refers to vertex indices.
%
% verts: n x 3 matrix or vector of vertex coordinates (x, y and z in that
% order)
%
% faces: f x 3 faces associated with vertex data
%
% Output-------------------------------------------------------------------
%
% sData: smoothed data (n x p).
%
% Optional (threshold) arguments-------------------------------------------
%
% All defaults refer to what will occur if the optional argument isn't
% passed in.
%
% 'smoothSteps': number of times to repeat smoothing procedure (i.e.,
% smoothness "kernel"; default: 1)
%
% 'smoothArea': this is the number of closest vertices in euclidean
% distance that will be used to smooth each data point (default: 1)
%
% 'smoothThreshold': determines whether smoothing will only be applied to
% vertices that meet the thresholds that have been applied to the data
% (i.e., 'above') or to vertices below threshold. You might want to do the
% latter to shrink your map (default: 'above').
%
% 'smoothType': 'neighbors' or 'neighborhood' (default: 'neighbors').
%
% 'clustData': if you already have cluster data you can pass it in here and
% then we won't have to re-generate it.
%
% Call:
% [sData] = smoothPatch(data, verts, faces, 'smoothSteps', 1)
% [sData] = smoothPatch(data, verts, faces, 'smoothSteps', 1, 'smoothArea', 1, 'smoothThreshold', 'above', 'smoothType', 'neighbors','clusterData',clustData)

% Defaults
%options = struct('smoothSteps', 1, 'smoothArea', 5, 'smoothThreshold', 'above', 'toAssign', 'all','clusterData',[]);
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

%% new script
% tmpFace = faces;
% 
% % identify which vertices to smooth based on your argument
% switch options.smoothThreshold
%     case 'above'
%         % above means we will be smoothing only vertices that meet all
%         % of the various thresholds we've gone through so far.
%         % This means the border of the thresholded area will contract.
%         % You will be smoothing vertices with some value greater than
%         % zero, with thresholded values that are all zeros.
%         toSmooth = find(data ~= 0);
%         
%     case 'border'
%         % Smoothes border of thresholded vertices. You will be
%         % smoothing vertices on the edge of thresholded values, which
%         % are all zeros. This will drive the mean of these edge voxels
%         % down.
%         if isempty(options.clusterData)
%             disp('Getting clusters from within the smoothing function...this will take some time...')
%             disp('The more unthresholded vertices you have, the longer this will take...')
%             tmp = find(data ~= 0);
%             [options.clusterData, ~] = getClusters(tmp, faces);
%         end
%         dataClust = getClusterBoundary(options.clusterData, faces);
%         toSmooth = vertcat(dataClust{:});
%         idx = find(data(toSmooth) == 0);
%         toSmooth(idx) = [];
% end

% smooth each face that the vertices that are left are a part of. Area
% should correspond to closest X number of faces (first all that are
% adjacent, then all)
sData = data;

% this is older code that was first based on distance to vertices on the
% same/adjacent faces, then by euclidean distance between non-adjacent
% vertices. 
%
% switch options.smoothType
%     case 'neighbors'
%         for smoothi = 1:options.smoothSteps
%             for i = 1:length(toSmooth)
%                 clear toS
%                 tmp = find(tmpFace == toSmooth(i));
%                 [inc,tmp2] = ind2sub(size(tmpFace),tmp);
%                 toS = unique(tmpFace(inc,:));
%                 
%                 [~,neighborhood] = pdist2(tmpVert,tmpVert(toSmooth(i),:),'euclidean','Smallest',options.smoothArea);
%                 toS = unique(neighborhood);
%                 
% % This is older version of the above code. The above code only looks at
% neighborhood distance and differs from below code because it's in a
% loop...
% %                 if options.smoothArea > length(toS)-1
% %                     lef = setdiff(toSmooth,toS);
% %                     [~,neighborhood] = pdist2(tmpVert(lef,:),tmpVert(toSmooth(i),:),'euclidean','Smallest',options.smoothArea-length(toS)+1);
% %                     toS = unique([toS; lef(neighborhood)]); % this used to be seuclidean
% %                     
% %                 elseif options.smoothArea < length(toS)-1
% %                     fcs = setdiff(unique(tmpFace(inc,:)),toSmooth(i));
% %                     [~,neighborhood] = pdist2(tmpVert(fcs,:),tmpVert(toSmooth(i),:),'euclidean','Smallest',options.smoothArea);
% %                     toS = unique([fcs(lef(neighborhood)); toSmooth(i)]);
% %                 end
% 
%                  sData(toS) = mean(sData(toS));
%             end
%         end
% end

% % get nearest X vertices to each vertex to smooth (user selected area X)
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
    
%switch options.smoothType
%    case 'neighbors'
% now smooth
    switch options.toAssign
        case 'thresholded'
            sData(toSmooth) = mean(sData(toSmooth(neighborhood)));
        case 'all'
            for j = 1:size(neighborhood,2)
                sData(neighborhood(:,j)) = mean(sData(neighborhood(:,j)));
            end
    end
    toSmooth2 = find(sData ~= 0);
    newVerts = setdiff(toSmooth2,toSmooth);
end