function [scaledData] = scaleData(array,x,y,incZero)
% [scaledData] = scaleData(array,x,y,incZer)
%
% Scale data in array to range [x,y]. If incZero is 'false', zeros will not
% be included in range estimates.
% Alex Teghipco // alex.teghipco@uci.edu

[l,p] = size(array);
if l>1 && p>1
    array = array(:);
    reTouch = 'true';
else
    reTouch = 'false';
end

switch incZero
    case 'false'
        aId = 1:length(array);
        zId = find(array == 0);
        tmp = array; 
        tmp(zId) = [];
        
        m = min(tmp);
        range = max(tmp) - m;
        tmp = (tmp - m) / range;
        
        % Then scale to [x,y]:
        range2 = y - x;
        scaledData1 = (tmp*range2) + x;
        scaledData = zeros(size(aId));
        [C,ia] = setdiff(aId,zId);
        scaledData(ia) = scaledData1;
        
    case 'true'
        % Normalize to [0, 1]:
        m = min(array);
        range = max(array) - m;
        array = (array - m) / range;
        
        % Then scale to [x,y]:
        range2 = y - x;
        scaledData = (array*range2) + x;
end

if strcmp(reTouch,'true')
   scaledData = reshape(scaledData,[l,p]);
end
