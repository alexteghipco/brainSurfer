function [colorMapInterp] = customColorMapInterp(colorMap,colorBins)
% This script will create a customized colormap by interpolating between colors provided in colorMap using the number of bins provided by colorBins.
% Alex Teghipco // alex.teghipco@uci.edu // 11/28/18

betweenNum = round(colorBins/(size(colorMap,1) - 1));
for beti = 1:(size(colorMap,1)-1)
    if beti == (size(colorMap,1)-1)
        %betweenNumRound(beti) = colorBins - sum(betweenNumRound(1:beti-1));
        betweenNumRound(beti) = colorBins - sum(betweenNum(1:beti-1));
    else
        betweenNumRound(beti) = betweenNum;
    end
end

for beti = 1:(size(betweenNumRound,2))
    R{beti} = linspace(colorMap(beti,1),colorMap(beti+1,1),betweenNumRound(beti));  %// Red from 1 to 0
    B{beti} = linspace(colorMap(beti,2),colorMap(beti+1,2),betweenNumRound(beti));  %// Blue from 0 to 1
    G{beti} = linspace(colorMap(beti,3),colorMap(beti+1,3),betweenNumRound(beti));   %// Green all zero
end

R = horzcat(R{:});
B = horzcat(B{:});
G = horzcat(G{:});
colorMapInterp = vertcat(R,B,G)';
%colorMapInterp = flipud(colorMapInterp);
