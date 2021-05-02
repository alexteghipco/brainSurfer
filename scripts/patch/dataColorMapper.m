function [cData] = dataColorMapper(data, varargin)
% This function is for thresholding some brain data (that we assume that
% you want to patch but that should be irrelevant).
%
% Mandatory arguments------------------------------------------------------ 
%
% data: data matrix or vector n x p where p corresponds to the number of
% different "brain maps" that need to be mapped onto colors.
%
% Output------------------------------------------------------------------- 
%
% cData: colors for each data point (n x p x 3).
%
% Optional (threshold) arguments-------------------------------------------
%
% All defaults refer to what will occur if the optional argument isn't
% passed in.
%
% 'colormap': an internal matlab colormap, or the name of any other
%       colormap redistributed with brainSurfer: 'jet', parula, hsv, hot,
%       cool, spring, summer, autumn, winter, gray, bone, copper, pink,
%       lines, colorcube, prism, spectral, RdYlBu, RdGy, RdBu, PuOr, PRGn,
%       PiYG, BrBG, YlOrRd, YlOrBr, YlGnBu, YlGn, Reds, RdPu, Purples,
%       PuRd, PuBuGn, PuBu, OrRd, oranges, greys, greens, GnBu, BuPu, BuGn,
%       blues, set3, set2, set1, pastel2, pastel1, paired, dark2, accent,
%       inferno, plasma, vega10, vega20b, vega20c, viridis, thermal,
%       haline, solar, ice, oxy, deep, dense, algae, matter, turbid, speed,
%       amp, tempo, balance, delta, curl, phase, perceptually distinct
%       (default is jet)
% 
% 'limits': two numbers that represent the limits of the colormap (default
%       is: [min(data) max(data)])
%
% 'opacity': a number between 0.00001 and 1 (larger numbers = less
%       transperancy; default is 1)
%
% 'colorSpacing': determines how colors are spaced in between the limits. 
%       'even': evenly spaced between limits (default)
%       'center on zero': the midpoint of the colorbar is forced to be zero
%       'center on threshold': the midpoint of the colorbar is forced to be
%       the thresholds you've applied to your data
%
% 'colorBins': number of color bins in the colorbar (default: 1000)
%   
% 'customColor': this is an l x 3 matrix of colors specifying a custom
%       colormap
%
% 'colorSpecial': this option can assign colors in special ways: 
%       'randomizeClusterColors': each cluster in data is assigned a random
%       color on colorbar
%
% 'invertColors': invert colorbar
%
% Call: 
% [oData] = dataThresh(data,'colormap','jet');
% [oData] = dataThresh(data,'pos','off','neg','off','vls','scl','sclLims',[-1 1],'thresh',[-2 2],'pMap',pVals,'pThresh',0.05,'operation','mean');

