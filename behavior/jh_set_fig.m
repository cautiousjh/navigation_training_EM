function [] = jh_set_fig(varargin)

parser = inputParser;
addOptional(parser, 'fig', gcf)
addParameter(parser, 'Position',[3 3])
addParameter(parser, 'FontName','Helvetica')
addParameter(parser, 'FontWeight','Normal') % bold
addParameter(parser, 'IsCopy',true)

addParameter(parser, 'Size', 'opt') %[8 8]
addParameter(parser, 'FontSize',11) % 11
addParameter(parser, 'LineWidth',1.4)

addParameter(parser, 'Scale',1)

parse(parser, varargin{:})
fig = parser.Results.fig;
font_name = parser.Results.FontName;
font_size = parser.Results.FontSize;
font_weight = parser.Results.FontWeight;
line_width = parser.Results.LineWidth;
is_copy = parser.Results.IsCopy;
scale = parser.Results.Scale;
fig_size = parser.Results.Size;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MODE = 'PAPER'; font_weight = 'normal'; line_width = 1.2;
% MODE = 'PRESENTATION'; font_weight = 'bold'; font_size=11; line_width = 1.4;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


axes = findobj(fig, 'type', 'axes');
fig.Units = 'centimeters';
ax = axes(1);

if ismember('Scale', parser.UsingDefaults)
    if ~isempty(findall(ax,'type','Bar'))   
        scale = 0.9;
        scale = 1.2;
    elseif ~isempty(findall(ax,'type','BoxChart'))
        scale = 1.2;
    else 
    end
end

if ismember('Size', parser.UsingDefaults)
    ax.Units = 'centimeters';

    margin_left = 1.1;
    margin_right = .15;
    margin_down = 1;        margin_down = 2;
    margin_up = .15;
    
    x_lim = get(ax, 'XLim');
    ax_width = diff(x_lim) * scale;
    ax_height = 8;
    
    fig.Position = [parser.Results.Position, ...
        ax_width + margin_left + margin_right, ax_height + margin_down + margin_up];
    
    ax.Position = [margin_left, margin_down, ax_width - margin_right, ax_height - margin_up ];

else
    fig.Position = [parser.Results.Position, fig_size];
end



for i = 1:length(axes)
    set(axes(i),'LineWidth',line_width,'FontName',font_name,'FontSize',font_size, ...
        'FontWeight',font_weight, 'box', 'off', 'TitleFontSizeMultiplier',0.9, 'Layer','top')    
%     set(axes(1),'LooseInset', get(axes(1),'TightInset'), 'XLim',x_lim)
%     set(axes(i),'LooseInset', max(get(axes(i),'TightInset'), 0.08)); 
end
% if length(axes)==1; set(axes(1),'LooseInset', max(get(axes(1),'TightInset'), 0.08)); end




if is_copy
%     pause(0.5)
%     annotation('rectangle',[0 0 1 1],'Color','w');
    ylabel(' ')
    copygraphics(gcf, 'ContentType','vector')
    % copygraphics(gcf, 'ContentType','image')
end