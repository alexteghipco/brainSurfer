function [growVerts,allThreshVerts,growVertTracker] = growMap(growVerts,growSteps,allThreshVerts,allFaces)

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