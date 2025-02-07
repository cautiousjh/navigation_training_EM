function [fig_bar, x_ticks, fig_err, fig_dot] = jh_bar(data, varargin)

% input parsing
parser = inputParser;
addOptional(parser, 'err', [], @(x) isvector(x)&isnumeric(x) )
addOptional(parser, 'sample', [], @iscell)
addParameter(parser, 'Color',[.6 .6 .6])
addParameter(parser, 'FaceAlpha', 1)

addParameter(parser, 'Width',0.8)
addParameter(parser, 'Offset', 0)
addParameter(parser, 'Style', 'both')  % 'pos', 'neg'

addParameter(parser, 'DrawError',true)
addParameter(parser, 'ColorError',[])
addParameter(parser, 'LineWidth',1.1) % 1.1
addParameter(parser, 'LineWidthError',.8)

addParameter(parser, 'DrawMean',false)
addParameter(parser, 'DrawMeanLine',false)

addParameter(parser, 'DrawPoint',true)
addParameter(parser, 'DrawPointLine',false)
addParameter(parser, 'DotDensity',0.2)
addParameter(parser, 'PointSize',7)
addParameter(parser, 'PointAlpha',0.5)

addParameter(parser, 'DrawStats',false)
addParameter(parser, 'StatType','param')
addParameter(parser, 'Stats',[])

addParameter(parser, 'Divider', 0)

parse(parser, varargin{:})


bar_width = parser.Results.Width;
x_offset = parser.Results.Offset;
dot_density = parser.Results.DotDensity;
color = parser.Results.Color;
face_alpha = parser.Results.FaceAlpha;
color_error = parser.Results.ColorError; 
line_width = parser.Results.LineWidth;
line_width_error = parser.Results.LineWidthError;
is_draw_error = parser.Results.DrawError;
is_draw_mean = parser.Results.DrawMean;
is_draw_mean_line = parser.Results.DrawMeanLine;
is_draw_point = parser.Results.DrawPoint;
is_draw_point_line = parser.Results.DrawPointLine;
point_size = parser.Results.PointSize;
point_alpha = parser.Results.PointAlpha;
is_draw_stat = parser.Results.DrawStats;
stat_type = parser.Results.StatType;
stats = parser.Results.Stats;
divider = parser.Results.Divider;
style = parser.Results.Style;


if isempty(color_error)
    color_error = [.2 .2 .2];
end

%%
if iscell(data)
    [avg,err] = jh_mean_err(data);
    sample = data;
elseif isvector(data)
    avg = data;
    err = parser.Results.err;
    sample = parser.Results.sample;
end
%%
hold on

x_pos_list = 1:length(avg);
for i = 1:length(avg)-1
    if divider ~=0 && mod(i,divider)==0
        x_pos_list(i+1:end) = x_pos_list(i+1:end) + 0.5;
    end
end
x_pos_list = x_pos_list + x_offset;
x_ticks = x_pos_list;
xticks(x_ticks);

% bar
fig_bar = {};
fig_err = {};
for graph_i = 1:length(avg)
    if isnan(avg(graph_i));  continue; end

    % bar
    fig = bar(x_pos_list(graph_i), avg(graph_i), bar_width);
    fig.EdgeColor = [0 0 0];
    fig.FaceAlpha = face_alpha;
    fig.LineWidth = line_width; fig.EdgeColor =  [0 0 0]; [.35 .35 .35]; 
    if iscell(color)
        fig.FaceColor = color{graph_i};
    else
        fig.FaceColor = color;
    end
    fig_bar{graph_i} = fig;

    % partial hide
    switch style
        case 'pos'  % Right side only
            x_left = x_pos_list(graph_i) - bar_width/2 - 0.05;
            x_right = x_pos_list(graph_i);
            X = [x_left x_right x_right x_left];
            Y = [0 0 avg(graph_i)+0.05 avg(graph_i)+0.05];
            patch(X, Y, [1 1 1],'EdgeColor','none');
        case 'neg'  % Left side only
            x_left = x_pos_list(graph_i);
            x_right = x_pos_list(graph_i) + bar_width/2 + 0.05;
            X = [x_left x_right x_right x_left];
            Y = [0 0 avg(graph_i)+0.05 avg(graph_i)+0.05];
            patch(X, Y, [1 1 1],'EdgeColor','none');
    end
    
            


end

% error 
switch style
    case 'pos'
        x = x_pos_list + bar_width/4;
    case 'neg'
        x = x_pos_list - bar_width/4;
    otherwise
        x = x_pos_list;
end
fig_err = errorbar(x, avg, err,'marker','square', 'capsize',0);
fig_err.Color = color_error; fig_err.LineStyle = 'none'; fig_err.LineWidth = line_width_error;  
fig_err.MarkerFaceColor = 'none'; fig_err.MarkerSize = 5; fig_err.MarkerEdgeColor = [.25 .25 .25]; 
if ~is_draw_error; fig_err.Color = 'none'; end
if ~is_draw_mean; fig_err.MarkerEdgeColor = 'none'; end

% sample dots
if is_draw_point
    fig_dot = {};
    x_draw_all = {};
    y_draw_all = {};
    for graph_i = 1:length(sample)
        if isempty(sample{graph_i}); continue; end

        y_draw = sort(sample{graph_i});
        y_draw(isnan(y_draw)) = [];
        y_draw = round(y_draw,5);
        epsilon = 0.000001;
        y_unique = uniquetol(y_draw, epsilon); % machine epsilon issue
        num_repeated = arrayfun(@(x) sum((x-epsilon)<y_draw & (x+epsilon)>y_draw),y_unique); % machine epsilon issue
    
        x_draw = arrayfun(@(x) linspace(-fig_bar{graph_i}.BarWidth/2*dot_density, fig_bar{graph_i}.BarWidth/2*dot_density, x - mod(x,2)),num_repeated,'UniformOutput',false);
        x_draw(mod(num_repeated,2)==1) = cellfun(@(x) [x 0], x_draw(mod(num_repeated,2)==1),'UniformOutput',false);
        x_draw = cell2mat(reshape(x_draw,1,[])) + x_pos_list(graph_i) + bar_width/4;
    
        fig = scatter(x_draw, y_draw, point_size, 'k','filled');
        fig.MarkerFaceAlpha = point_alpha;
        fig_dot{graph_i} = fig;

        x_draw_all{graph_i} = x_draw;
        y_draw_all{graph_i} = y_draw;
    end

    if is_draw_point_line
        fig_line = plot(cell2mat(x_draw_all'),cell2mat(y_draw_all'),'color',[.25 .25 .25 point_alpha*0.5], 'linewidth',1);   
    end
end

% stats
if is_draw_stat
    range = ylim;
    range = diff(range);

    for graph_i = 1:length(sample)
        temp = sample{graph_i};
        if ~isempty(stats)
            p = stats(graph_i);
        elseif strcmp(stat_type, 'param')
            [~,p] = ttest(temp);
        elseif strcmp(stat_type, 'nonparam')
            try
                p = signrank(temp);
            catch
                p = 1;
            end
        end

        x = graph_i;
        
        if avg(graph_i) > 0
            y = avg(graph_i) + 1.05 * err(graph_i) + .05 * range;
        else
            y = avg(graph_i) - 1.05 * err(graph_i) - .05 * range;
        end
        mark = [];
        if p < .1; mark = '+'; end
        if p < .05; mark = '*'; end
        if p < .01; mark = '**'; end
        if p < .001; mark = '***'; end
        if p < .1
            text(x, y, mark, 'FontSize',13, 'HorizontalAlignment','center','VerticalAlignment','middle')
        end

    end
end

xlim([-.2 x_ticks(end)+.9])

%%
%%
%%
% author: Junghan Shin
% description
%       draw bar graph with ldata, errors and sample points
%       recommend to use with 'jh_mean_err'
% inputs
%   (required)
%       data : data to be drawn (each row will be grouped)
%   (recommended)
%       error: error to be drawn
%       sample: cell of data samples
%   (extra)
%       varargin: other parameters for bar graph
%   (manual argument pairs)
%       ~~, 'DotDensity', 0) : density of dots (0-1, 0.3 default)
% outputs
%       bar graph with errorbars and sample points
% example
%       jh_bar([1 2 3]);
%       jh_bar([1 2 3], [.1 .2 .1]);
%       jh_bar([1 2 3], [.1 .2 .1], {[0.9, 1.0, 1.1], [1.9, 2.0, 2.1], [2.9, 3.0, 3.1]});


% % input parsing
% switch nargin
%     case 1 % data given only
%         err = [];
%         sample = {};
%     case 2 % data and err given
%         err = varargin{1};
%         sample = {};
%         varargin = varargin(2:end);
%         if ~isnumeric(err)
%             error('invalid err values');
%         end
%     case 3 % data, err, and samples given
%         err = varargin{1};
%         sample = varargin{2};
%         varargin = varargin(3:end);
%         if ~isnumeric(err)
%             error('invalid err values (change it to array)');
%         end
%         if ~iscell(sample)
%             error('invalid sample values (change it to cell)');
%         end
%     otherwise
%         err = varargin{1};
%         sample = varargin{2};
%         varargin = varargin(3:end);
% end
% 
% idx = find(strcmp(cellfun(@lower,varargin,'UniformOutput',false),'dotdensity'));
% if ~isempty(idx)
%     dot_density = varargin{idx+1};
%     varargin(idx:idx+1) = [];
% else
%     dot_density = 0.3;
% end
% 
% %%
% % draw bar
% if isempty(varargin)
%     fig_bar = bar(data);
% else
%     fig_bar = bar(data,varargin{:});
% end
% hold on
% 
% % error bar
% if ~isempty(err)
%     fig_err = errorbar(data,err);
%     fig_err.Color = [0 0 0];
%     fig_err.LineStyle = 'none';
%     fig_err.LineWidth = 1;
% end
% 
% % sample dots
% fig_dot = [];
% for graph_i = 1:length(sample)
%     y_draw = sort(sample{graph_i});
%     y_draw(isnan(y_draw)) = [];
%     y_draw = round(y_draw,5);
%     epsilon = 0.000001;
%     y_unique = uniquetol(y_draw, epsilon); % machine epsilon issue
%     num_repeated = arrayfun(@(x) sum((x-epsilon)<y_draw & (x+epsilon)>y_draw),y_unique); % machine epsilon issue
% 
%     x_draw = arrayfun(@(x) linspace(-fig_bar.BarWidth/2*dot_density, fig_bar.BarWidth/2*dot_density, x - mod(x,2)),num_repeated,'UniformOutput',false);
%     x_draw(mod(num_repeated,2)==1) = cellfun(@(x) [x 0], x_draw(mod(num_repeated,2)==1),'UniformOutput',false);
%     x_draw = cell2mat(reshape(x_draw,1,[])) + graph_i;
% 
%     fig_dot_temp = scatter(x_draw, y_draw,'k','filled');
%     fig_dot_temp.MarkerFaceAlpha = 0.2;
%     fig_dot = [fig_dot fig_dot_temp];
% end
% 
% hold off 
% 
% fig_bar.FaceColor = 'flat';
% fig_bar.FaceColor = [127/256,127/256,127/256];
% fig_bar.EdgeColor = 'none';
% box off
% 
% set(gca,'LineWidth',1,'FontName','Helvetica','FontSize',12, 'FontWeight','bold')
%  