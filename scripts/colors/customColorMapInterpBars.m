function [colorMapInterp] = customColorMapInterpBars(colorMap,colorBins,interpDir)
% This script will create a customized colormap by interpolating between
% two colorBars given by colorMap
% Alex Teghipco // alex.teghipco@uci.edu // 11/28/18

colorMapInterp = ones(colorBins,colorBins,3);
switch interpDir
    case 'same'
        colorMapInterp(:,1,:) = colorMap(:,:,1);
        colorMapInterp(:,colorBins,:) = colorMap(:,:,2);
        
        for beti = 1:size(colorMapInterp,1)
            r(beti,:) = linspace(colorMap(beti,1,1), colorMap(beti,1,2),colorBins-2);
            g(beti,:) = linspace(colorMap(beti,2,1), colorMap(beti,2,2),colorBins-2);
            b(beti,:) = linspace(colorMap(beti,3,1), colorMap(beti,3,2),colorBins-2);
        end
        
        colorMapInterp(:,2:end-1,1) = r;
        colorMapInterp(:,2:end-1,2) = g;
        colorMapInterp(:,2:end-1,3) = b;
        
        %figure; imshow(colorMapInterp);
        
    case 'different'
        
        for beti = 1:size(colorMapInterp,1)
            for j = 1:3
                tmp1 = colorMap(:,j,1);
                tmp2 = repmat(colorMap(beti,j,2),size(tmp1));
                
                colorMapInterp(:,beti,j) = (tmp1+tmp2)./2;
            end
        end

end