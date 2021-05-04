function [alignedC] = clusterAlignment(c,varargin)
% [alignedC] = clusterAlignment(c,varargin)
% ------------------------------------------------------------------------
% Align cluster indices across different clustering solutions. 'c' is an n
% x p vector of n different clustering solutions. This script will
% iteratively go through each solution and get the overlap between cluster
% indices in that solution and the previous cluster, then rename indices
% based on the percentage of observations (eg voxels) that overlap between
% each possible pair of indices (ie from 'current' solution and 'prior'
% solution). In this way, clusters are matched to the clustering solution
% with the fewest clusters.
%
% Optional arguments: -----------------------------------------------------
%       'sortClusters': if 'true' this will sort input and output clusters
%       such that columns increase in # of clusters per solution
%
%       'renameClusters': if 'true' this will rename clusters within each
%       solution so that cluster indices linearly increase from 1
%
%       'alignOnly': if 'true' this will align clustering solutions that
%       all have the same number of clusters
%
% Alex Teghipco // alex.teghipco@uci.edu // NEWEST VERSION -- 11/7/19

method = 'hungarian';
options = struct('sortClusters','true','renameClusters','true','alignOnly','false');

% Read in the acceptable argument names
optionNames = fieldnames(options);

% Check the number of arguments passed
nArgs = length(varargin);
if round(nArgs/2)~=nArgs/2
    error('You are missing an argument name somewhere in your list of inputs')
end

% Assign supplied values to each argument in input
for pair = reshape(varargin,2,[]) %pair is {propName;propValue}
    inpName = pair{1}; % make case insensitive by using lower() here but this can be buggy
    if any(strcmp(inpName,optionNames))
        options.(inpName) = pair{2};
    else
        error('%s is not a recognized parameter name',inpName)
    end
end

% First, some cleanup of clustering solutions if user requests it
cclean = c;
for clusti = 1:size(cclean,1) % rename clusters so you know which solution is largest but not based on idx
    clustUn = unique(cclean(clusti,:));
    id = find(clustUn < 1);
    clustUn(id) = [];
    for clustuni = 1:length(clustUn)
        idx = find(cclean(clusti,:) == clustUn(clustuni));
        cclean(clusti,idx) = clustuni;
    end
end

switch options.renameClusters
    case 'true'
        c = cclean;
end

clustLen = max(cclean,[],2);
[~,sIdx] = sort(clustLen);
c = c(sIdx,:); % reorganize clustering solutions by their size
switch options.alignOnly
    case 'true'
        for soli = 1:size(c,1) % loop over solutions and align to the first solution
            currSol = c(soli,:);
            if soli == 1
                alignedC(soli,:) = currSol; % setup output
            else
                solPrev = c(soli-1,:);
                % now get % overlap between each pair of clusters
                c1 = unique(currSol);
                c2 = unique(solPrev);
                % but first, sanity check clusters
                if length(c1) ~= length(c2) || sum(c1 == c2) ~= length(c1) % check to make sure these can be aligned
                    errordlg(['Houston we have a problem...solution ' num2str(soli) ' does not have as many clusters as solution 1']);
                end
                
                for i = 1:length(c1)
                    id1 = find(currSol == c1(i));
                    for j = 1:length(c2)
                        id2 = find(solPrev == c2(j));
                        [C,ia,ib] = intersect(id1,id2);
                        %oP(i,j) = length(C) / (length(id1) + length(id2));
                        oP(i,j) = length(C);
                    end
                end
                %[assignment,cost] = munkres([1-oP]);
                [scaledData] = scaleData(oP,0,1,[]);
                [assignment,cost] = munkres([1-scaledData]);
                key(:,1) = c1';
                for i = 1:size(assignment,1)
                    key(i,2) = find(assignment(i,:) == 1);
                end
                
                % now get IDs and reassign...
                for i = 1:length(c1)
                    vId{i} = find(currSol == key(i,1));
                end
                for i = 1:length(c1)
                    alignedC(soli,vId{i}) = key(i,2);
                end
            end
        end
        
    case 'false'
        switch method
            case 'old'
                % start main loop
                for clusti = 1:size(c,1) % loop over clustering solutions
                    alignedC(clusti,:) = c(clusti,:); % setup output
                    if clusti ~= 1 % skip the first clustering solution because everything gets aligned to it
                        solUnCurr = unique(alignedC(clusti,:)); % get unique clusters from current solution
                        solUnPrev = unique(alignedC(clusti-1,:)); % get unique clusters from prior solution
                        [newIdx,ia] = setdiff(solUnCurr,solUnPrev); % find which cluster index from current solution is missing from prior solution
                        
                        % now we will get the % overlap (wrt voxels or observations),
                        % between indices in current solution and prior solution and
                        % rewrite them to match
                        for soli2 = 1:length(solUnCurr) % now loop over cluster indices in current solution
                            idx2 = find(alignedC(clusti,:) == solUnCurr(soli2)); % find all observations matching that index
                            for soli = 1:length(solUnPrev) % loop over cluster indices in prior solution
                                idx = find(alignedC(clusti-1,:) == solUnPrev(soli)); % find all observations matching index
                                [oIdx,ia,ib] = intersect(idx,idx2); % find how many voxels of this index match the index you're on from prior solution
                                oP(soli2,soli) = length(oIdx);%/size(c,2); % turn it into a percentage and track it
                            end
                        end
                        
                        % turn into %
                        for i = 1:size(oP,1)
                            for j = 1:size(oP,2)
                                oPP(i,j) = oP(i,j)/sum(oP(i,:));
                            end
                        end
                        
                        % loop over percentage overlap and find best match for new clusters
                        reKey(:,1) = solUnCurr; % first column of reKey are the unique indices from current solution and second column are the new indices matched based on overlap with prior solution
                        for soli2 = 1:size(oPP,1)
                            [bestMatch, bestMatchIdx] = max(oPP(soli2,:));
                            reKey(soli2,2) = solUnPrev(bestMatchIdx);
                        end
                        
                        % find which cluster index should be assigned to the 'new' cluster
                        [~, dupIdx] = unique(reKey(:,2));
                        dupIdx = setdiff(1:size(reKey(:,2), 1), dupIdx);
                        dupIdx = reKey(dupIdx,2); % this finds which cluster is duplicated
                        
                        for dupi = 1:length(dupIdx) % there might be multiple duplicates so loop over each
                            dupIdx2 = find(reKey(:,2) == dupIdx(dupi)); % indices of the duplicates
                            if dupi == 1 % first duplicate can get the 'new cluster'
                                [minV,minIdx] = min(oPP(dupIdx2,dupIdx(dupi))); % of the duplicates in this case, find the cluster that shows worst overlap
                                try
                                    reKey(dupIdx2(minIdx),2) = newIdx(1); % that cluster gets the 'new' cluster index from current solution
                                catch
                                    disp(['Failed at cluster ' num2str(clusti) ' and duplicate index ' num2str(dupi)]);
                                end
                            else
                                % remaining duplicates can get random assignments from
                                % remaining clusters
                                rem = setdiff(unique(reKey(:,1)),unique(reKey(:,2)));
                                reKey(dupIdx2(1),2) = rem(1);
                            end
                        end
                        
                        % save out/rename the new indices
                        for rki = 1:size(reKey,1)
                            vIdx{rki} = find(alignedC(clusti,:) == reKey(rki,1));
                        end
                        for rki = 1:length(vIdx)
                            alignedC(clusti,vIdx{rki}) = reKey(rki,2);
                        end
                        clear reKey
                    end
                end
            case 'hungarian'
                for soli = 1:size(c,1) % loop over solutions and align to the first solution
                    currSol = c(soli,:);
                    if soli == 1
                        alignedC(soli,:) = currSol; % setup output
                    else
                        %solPrev = c(soli-1,:);
                        solPrev = alignedC(soli-1,:);
                        
                        % now get % overlap between each pair of clusters
                        c1 = unique(currSol);
                        c2 = unique(solPrev);
     
                        for i = 1:length(c1)
                            id1 = find(currSol == c1(i));
                            for j = 1:length(c2)
                                id2 = find(solPrev == c2(j));
                                [C,ia,ib] = intersect(id1,id2);
                                oP(i,j) = length(C) / (length(id1) + length(id2));
                                %oP(i,j) = length(C);
                            end
                        end
                        
                        % normalize oP
                        %oP = [oP'./sum(oP')]';
                        [assignment,~] = munkres([1-oP]);
                        
                        key(:,1) = c1';
                        for i = 1:size(assignment,1)
                            tmp = find(assignment(i,:) == 1);
                            if ~isempty(tmp)
                                key(i,2) = tmp;
                            end
                        end
                       
                        %% new ; col1 = new k; col2 = oldk
%                         for i = 1:length(c1)
%                             vId{i} = find(currSol == key(i,1));
%                         end
%                                 
%                         for i = 1:length(c1)
%                             if key(i,2) == 0
%                                 alignedC(soli,vId{i}) = key(i,1);
%                             else
%                                 alignedC(soli,vId{i}) = key(i,2);
%                             end
%                         end
                        
                        %% old
                        id = find(key(:,2) == 0);
                        try
                            key(id,2) = setdiff(c1,c2);
                        catch
                            asd = setdiff(c1,c2);
                            key(id,2) = min(asd);
                        end
                        
                        % now get IDs and reassign...
                        for i = 1:length(c1)
                            vId{i} = find(currSol == key(i,1));
                        end
                        for i = 1:length(c1)
                            alignedC(soli,vId{i}) = key(i,2);
                        end
                    end
                    clear key key1 key2 assignment oP C ia ib id id2 currSol vId solPrev
                end
        end
end

% revert solutions into initial order if sorting is unnecessary
switch options.sortClusters
    case 'false'
        alignedC = alignedC(sIdx,:);
end