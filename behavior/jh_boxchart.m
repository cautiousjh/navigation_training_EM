function [fig, x_ticks, fig_dot] = jh_boxchart(data, varargin)

% input parsing
parser = inputParser;
addParameter(parser, 'Width',0.65)
addParameter(parser, 'Offset', 0)
addParameter(parser, 'Style', 'both')  % 'pos', 'neg'

addParameter(parser, 'DotDensity',0.2)
addParameter(parser, 'Color',[.6 .6 .6])
addParameter(parser, 'FaceAlpha', 1)%.8)
addParameter(parser, 'DrawError',false)
addParameter(parser, 'DrawMean',false)
addParameter(parser, 'DrawMeanLine',false)
addParameter(parser, 'DrawMedian',false)
addParameter(parser, 'DrawMedianLine',false)
addParameter(parser, 'DrawPoint',false)
addParameter(parser, 'DrawPointLine',{})
addParameter(parser, 'PointLineColor',[.25 .25 .25])
addParameter(parser, 'PointSize',7)
addParameter(parser, 'PointAlpha',0.45)
addParameter(parser, 'Divider', 0)
parse(parser, varargin{:})

bar_width = parser.Results.Width;
x_offset = parser.Results.Offset;
dot_density = parser.Results.DotDensity;
color = parser.Results.Color;
face_alpha = parser.Results.FaceAlpha;
is_draw_error = parser.Results.DrawError;
is_draw_mean = parser.Results.DrawMean;
is_draw_mean_line = parser.Results.DrawMeanLine;
is_draw_median = parser.Results.DrawMedian;
is_draw_median_line = parser.Results.DrawMedianLine;
is_draw_point = parser.Results.DrawPoint;
index_point_line = parser.Results.DrawPointLine;
point_line_color = parser.Results.PointLineColor;
point_size = parser.Results.PointSize;
point_alpha = parser.Results.PointAlpha;
divider = parser.Results.Divider;
style = parser.Results.Style;

line_width_box = 1.1;

hold on

% setups - highlight color
if iscell(color)
%     color_border = cellfun(@(x) jh_color_modify(x, 'saturation',1.5), color, 'uni', 0);
else
    color = repmat({color}, 1, length(data));
%     color_border = {jh_color_modify(color, 'saturation',1.5)};
end

%%
% refine data
% data = cellfun(@(x) x(:), data,'uni',0);
% outliers = cellfun(@(x) isoutlier(x, 'quartiles'), data, 'uni', 0);
[avg,err] = jh_mean_err(data);
medians = cellfun(@median, data);

x_pos_list = 1:length(avg);
for i = 1:length(avg)-1
    if divider ~=0 && mod(i,divider)==0
        x_pos_list(i+1:end) = x_pos_list(i+1:end) + 0.5;
    end
end
x_pos_list = x_pos_list + x_offset;
x_ticks = x_pos_list;
xticks(x_ticks) 

% boxplot
fig_box = {};
for graph_i = 1:length(data)
    if isempty(data{graph_i}); continue; end
    fig = boxchart(repmat(x_pos_list(graph_i),1,length(data{graph_i})), data{graph_i});
    fig.MarkerColor = [.2 .2 .2]; fig.MarkerStyle = '+';
    fig.LineWidth = line_width_box; fig.BoxLineColor = [0 0 0]; [.35 .35 .35]; %fig.BoxEdgeColor = [0 0 0]; [.35 .35 .35]; 
    fig.BoxFaceAlpha = face_alpha;
    fig.BoxFaceColor = color{graph_i}; fig.WhiskerLineColor = color{graph_i};
    fig.BoxWidth = bar_width;

%     fig.BoxFaceColor = color(graph_i,:); fig.WhiskerLineColor = color(graph_i,:); fig.BoxFaceAlpha = 0.65;
%     fig.LineWidth = 2; fig.BoxLineColor = color_border{graph_i};

    if is_draw_point
        fig.MarkerStyle = 'none';
    else
        fig.MarkerColor = color{graph_i}; 
        fig.MarkerStyle = '+'; 
    end

    fig_box{graph_i} = fig;


    % partial hide
    switch style
        case 'pos'  % Right side only
            x_left = x_pos_list(graph_i) - bar_width/2 - 0.05;
            x_right = x_pos_list(graph_i);
            X = [x_left x_right x_right x_left];
            Y = [0 0 avg(graph_i)+0.05 avg(graph_i)+0.05];
            patch(X, Y, [1 1 1],'EdgeColor','none');
        case 'neg'  % Left side only
            x_left = x_pos_list(graph_i) + 0.02;
            x_right = x_pos_list(graph_i) + bar_width/2 + 0.05;
            X = [x_left x_right x_right x_left];
            Y = [0 0 avg(graph_i)+0.05 avg(graph_i)+0.05];
            temp = max(data{graph_i}); Y = [0 0 temp+0.5 temp+0.5];
            patch(X, Y, [1 1 1],'EdgeColor','none');
    end

end


% error bar
switch style
    case 'pos'
        x = x_pos_list + bar_width/4;
    case 'neg'
        x = x_pos_list - bar_width/4;
    otherwise
        x = x_pos_list;
end
fig_err = errorbar(x, avg, err,'marker','square');
fig_err.Color = [.25 .25 .25]; fig_err.LineStyle = 'none'; fig_err.LineWidth = 1;  
fig_err.MarkerFaceColor = 'none'; fig_err.MarkerSize = 5; fig_err.MarkerEdgeColor = [.25 .25 .25]; 
if ~is_draw_error; fig_err.Color = 'none'; end
if ~is_draw_mean; fig_err.MarkerEdgeColor = 'none'; end

% fig_err = errorbar(x_pos_list, medians, [],'marker','square');
% fig_err.Color = [.25 .25 .25]; fig_err.LineStyle = 'none'; fig_err.LineWidth = 1;  
% fig_err.MarkerFaceColor = 'none'; fig_err.MarkerSize = 5; fig_err.MarkerEdgeColor = [.25 .25 .25]; 
% if ~is_draw_median; fig_err.MarkerEdgeColor = 'none'; end

% line
if is_draw_mean_line
    fig_err.MarkerSize = 6.5;
    if divider ~= 0
        for i = 1:divider:length(x_pos_list)
            fig_line = plot(x_pos_list(i:(i+divider-1)), avg(i:(i+divider-1)));
            fig_line.Color = [.25 .25 .25]; fig_line.LineWidth = 1;
        end
    end
end

if is_draw_median_line
    if divider ~= 0
        for i = 1:divider:length(x_pos_list)
            fig_line = plot(x_pos_list(i:(i+divider-1)), medians(i:(i+divider-1)));
            fig_line.Color = [.25 .25 .25]; fig_line.LineWidth = 1;
        end
    end
end

% sample dots
if is_draw_point
    fig_dot = {};
    x_draw_all = {};
    y_draw_all = {};
    for graph_i = 1:length(data)
        if isempty(data{graph_i}) 
            fig_dot{graph_i} = [];
            x_draw_all{graph_i} = [];
            y_draw_all{graph_i} = [];
            continue; 
        end

        y_draw = sort(data{graph_i});
        y_draw(isnan(y_draw)) = [];
%         y_draw(isoutlier(y_draw,'quartiles')) = [];
        y_draw = round(y_draw,5);
        epsilon = 0.000001;
        y_unique = uniquetol(y_draw, epsilon); % machine epsilon issue
        num_repeated = arrayfun(@(x) sum((x-epsilon)<y_draw & (x+epsilon)>y_draw),y_unique); % machine epsilon issue
    
        x_draw = arrayfun(@(x) linspace(-fig_box{graph_i}.BoxWidth/2*dot_density, fig_box{graph_i}.BoxWidth/2*dot_density, x - mod(x,2)),num_repeated,'UniformOutput',false);
        x_draw(mod(num_repeated,2)==1) = cellfun(@(x) [x 0], x_draw(mod(num_repeated,2)==1),'UniformOutput',false);
        x_draw = cell2mat(reshape(x_draw,1,[])) + x_pos_list(graph_i) + bar_width/4;
    
        fig = scatter(x_draw, y_draw, point_size, 'k','filled');
        fig.MarkerFaceAlpha = point_alpha;
        fig_dot{graph_i} = fig;

        x_draw_all{graph_i} = x_draw;
        y_draw_all{graph_i} = y_draw;
    end

    if ~isempty(index_point_line)
        if islogical(index_point_line)
            target = find(cellfun(@isempty, data));
            target = [0, target, length(data)+1];
            index_point_line = {};
            for i = 1:length(target)-1
                index_point_line{i} = (target(i)+1) : (target(i+1)-1);
            end
        end
        if ~iscell(index_point_line)
            index_point_line = {index_point_line};
        end
        for i = 1:length(index_point_line)
            target = index_point_line{i};
            x_data = cell2mat(x_draw_all(target)');
            y_data = cell2mat(y_draw_all(target)');
            fig_line = plot(x_data, y_data,'color',[point_line_color point_alpha*0.5], 'linewidth',1);   
        end
    end

end

xlim([-.2 x_ticks(end)+1.2])
xlim([-.2 x_ticks(end)+.9])
