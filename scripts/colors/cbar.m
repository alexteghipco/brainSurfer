% cbar() - Display full or partial colorbar, choose numeric range 
%
% Usage:
%    >> cbar
%    >> cbar(type)
%    >> cbar(type,colors)
%    >> cbar(axhandle,colors)
%    >> cbar(axhandle,colors, minmax)
%
% Inputs:
%  type      - 'vert','horiz', or 0 -> default {'vert')
%  axhandle  - handle of axes to place colormap in
%  colors    - vector of colormap indices to display, 
%              or number n -> display colors [1:end-n]
%  minmax    - [min, max] range of values to label on colorbar 
%
% Author: Colin Humphries, CNL / Salk Institute, Feb. 1998 
%
% See also: colorbar()

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) Colin Humphries, CNL / Salk Institute, Feb. 1998 
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: cbar.m,v $
% Revision 1.1  2002/04/05 17:36:45  jorn
% Initial revision
%

% 12-13-98 added minmax arg -Scott Makeig
% 01-25-02 reformated help & license, added links -ad 

function [handle]=cbar(arg,colors,minmax)

if nargin < 2
  colors = 0;
end
if nargin < 1
  arg = 'vert';
  ax = [];
else
  if isempty(arg)
    arg = 0;
  end
  if arg == 0
    ax = [];
    arg = 'vert';
  else
    if isstr(arg)
      ax = [];
    else
      ax = arg;
      arg = [];
    end
  end
end

if nargin>2
  if size(minmax,1) ~= 1 | size(minmax,2) ~= 2
    help cbar
    fprintf('cbar() : minmax arg must be [min,max]\n');
    return
  end
end


%obj = findobj('tag','cbar','parent',gcf);
%if ~isempty(obj) & ~isempty(arg)
%  arg = [];
%  ax = obj;
%end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Choose colorbar position
%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (length(colors) == 1) & (colors == 0)
  t = caxis;
else
  t = [0 1];
end
if ~isempty(arg)
  if strcmp(arg,'vert')  
    cax = gca;
    pos = get(cax,'Position');
    stripe = 0.04; 
    edge = 0.01;
    space = .02;

%    set(cax,'Position',[pos(1) pos(2) pos(3)*(1-stripe-edge-space) pos(4)])
%    rect = [pos(1)+(1-stripe-edge)*pos(3) pos(2) stripe*pos(3) pos(4)];

    set(cax,'Position',[pos(1) pos(2) pos(3) pos(4)])
    rect = [pos(1)+pos(3)+space pos(2) stripe*pos(3) pos(4)];
    ax = axes('Position', rect);
  elseif strcmp(arg,'horiz')
    cax = gca;
    pos = get(cax,'Position');
    stripe = 0.075; 
    space = .1;  
    set(cax,'Position',...
        [pos(1) pos(2)+(stripe+space)*pos(4) pos(3) (1-stripe-space)*pos(4)])
    rect = [pos(1) pos(2) pos(3) stripe*pos(4)];
    ax = axes('Position', rect);
  end
else
  pos = get(ax,'Position');
  if pos(3) > pos(4)
    arg = 'horiz';
  else
    arg = 'vert';
  end
end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Draw colorbar using image()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

map = colormap;
n = size(map,1);

if length(colors) == 1
  if strcmp(arg,'vert')
    image([0 1],t,[1:n-colors]');
    set(ax,'xticklabelmode','manual')
    set(ax,'xticklabel',[],'YAxisLocation','right')
      
  else
    image(t,[0 1],[1:n-colors]);
    set(ax,'yticklabelmode','manual')
    set(ax,'yticklabel',[],'YAxisLocation','right')
  end
  set(ax,'Ydir','normal','YAxisLocation','right')

else % length > 1

  if max(colors) > n
    error('Color vector excedes size of colormap')
  end
  if strcmp(arg,'vert')
    image([0 1],t,[colors]');
    set(ax,'xticklabelmode','manual')
    set(ax,'xticklabel',[])
  else
    image([0 1],t,[colors]);
    set(ax,'yticklabelmode','manual')
    set(ax,'yticklabel',[],'YAxisLocation','right')
  end  
  set(ax,'Ydir','normal','YAxisLocation','right')
end

%%%%%%%%%%%%%%%%%%%%%%%%%
% Adjust cbar ticklabels
%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin > 2 
  Cax = get(ax,'Ylim');
  CBTicks = [Cax(1):(Cax(2)-Cax(1))/4:Cax(2)]; % caxis tick positions
  CBLabels = [minmax(1):(minmax(2)-minmax(1))/4:minmax(2)]; % tick labels
  dec = floor(log10(max(abs(minmax)))); % decade of largest abs value
  CBLabels = ([minmax]*[1.0 .75 .50 .25 0.0; 0.0 .25 .50 .75 1.0]);
  if dec<1
    CBLabels = round(CBLabels*10^(1-dec))*10^(dec-1);
  elseif dec == 1
    CBLabels = round(CBLabels*10^(2-dec))*10^(dec-2);
  else
    CBLabels = round(CBLabels);
  end
% minmax
% CBTicks
% CBLabels

  if strcmp(arg,'vert')
    set(ax,'Ytick',CBTicks);
    set(ax,'Yticklabel',CBLabels);
  else
    set(ax,'Xtick',CBTicks);
    set(ax,'Xticklabel',CBLabels);
  end
end
handle = ax;

%%%%%%%%%%%%%%%%%%
% Adjust cbar tag
%%%%%%%%%%%%%%%%%%

set(ax,'tag','cbar')
