function cbars = createBrainColorbar(colormapSG, ticksSG, varargin)
% createBrainColorbar Creates simple colorbars for brain visualizations
% Parse inputs
p = inputParser;
addRequired(p, 'colormapSG');
addRequired(p, 'ticksSG');
addParameter(p, 'FontSize', 8);
addParameter(p, 'BarWidth', 0.015);
parse(p, colormapSG, ticksSG, varargin{:});
cbars = struct();

% Store the current axes handle
mainAx = gca;

% Left colorbar if present
if isfield(colormapSG, 'left') && ~isempty(colormapSG.left.map)
    % Create new axes that share the same parent as the main axes
    ax1 = axes('Parent', get(mainAx, 'Parent'), ...
               'Position', get(mainAx, 'Position'), ...
               'Visible', 'off', ...
               'HandleVisibility', 'off');
    % Link the axes properties for rotation
    linkprop([mainAx, ax1], {'View', 'XLim', 'YLim', 'ZLim', 'CameraPosition', 'CameraTarget', 'CameraUpVector', 'CameraViewAngle'});
    
    colormap(ax1, colormapSG.left.map);
    cbars.left = colorbar(ax1);
    cbars.left.Position(3) = p.Results.BarWidth;
    
    % Map ticks to the colorbar range
    ticks = ticksSG.left.ticks;
    tick_min = min(ticks);
    tick_max = max(ticks);
    normalized_ticks = (ticks - tick_min) / (tick_max - tick_min);
    
    % Create labels
    labels = arrayfun(@(x) sprintf('%.4f', x), ticksSG.left.labels, 'UniformOutput', false);
    
    % Set properties
    cbars.left.Ticks = normalized_ticks;
    cbars.left.TickLabels = labels;
    cbars.left.FontSize = p.Results.FontSize;
    cbars.left.TickLength = 0;
    
    title(cbars.left, 'Left');
end

% Right colorbar if present
if isfield(colormapSG, 'right') && ~isempty(colormapSG.right.map)
    ax2 = axes('Parent', get(mainAx, 'Parent'), ...
               'Position', get(mainAx, 'Position'), ...
               'Visible', 'off', ...
               'HandleVisibility', 'off');
    % Link the axes properties for rotation
    linkprop([mainAx, ax2], {'View', 'XLim', 'YLim', 'ZLim', 'CameraPosition', 'CameraTarget', 'CameraUpVector', 'CameraViewAngle'});
    
    colormap(ax2, colormapSG.right.map);
    cbars.right = colorbar(ax2);
    cbars.right.Position(3) = p.Results.BarWidth;
    
    % Map ticks to the colorbar range
    ticks = ticksSG.right.ticks;
    tick_min = min(ticks);
    tick_max = max(ticks);
    normalized_ticks = (ticks - tick_min) / (tick_max - tick_min);
    
    % Create labels
    labels = arrayfun(@(x) sprintf('%.4f', x), ticksSG.right.labels, 'UniformOutput', false);
    
    % Set properties
    cbars.right.Ticks = normalized_ticks;
    cbars.right.TickLabels = labels;
    cbars.right.FontSize = p.Results.FontSize;
    cbars.right.TickLength = 0;
    
    title(cbars.right, 'Right');
    
    % Position it to the right of the left colorbar if it exists
    if isfield(cbars, 'left')
        leftPos = cbars.left.Position;
        rightPos = cbars.right.Position;
        rightPos(1) = leftPos(1) + 2*leftPos(3);
        cbars.right.Position = rightPos;
    end
end

% Make sure the main axes is active
axes(mainAx);
end