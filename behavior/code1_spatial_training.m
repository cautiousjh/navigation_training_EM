
%% training curve

% parameters
%%%%%%%%%%%%%%%%%%%%%%%%%
flag = group==1;
% flag = group==0;

% flag = group==1 & spatial_metric_training >= nanmedian(spatial_metric_training); 
% flag = group==1 & spatial_metric_training <= nanmedian(spatial_metric_training);

metric = spatial_metric_sess_wise; y_lim = [0.65 1]; color = COLOR_SPATIAL; y_ticks = .6:.1:1;
%%%%%%%%%%%%%%%%%%%%%%%%%

data = cellfun(@(x) x(flag), metric(1:7), 'uni', 0);


figure;
hold on

for i = 1:length(data{1})
    plot(cellfun(@(x) x(i), data), color=[.2 .2 .2 .2], linewidth=1)
end

[avg,err] = jh_mean_err(data);
fig_err = errorbar([1:length(avg)]-0.1, avg, err,'-square');
fig_err.Color = [color 0.2];  fig_err.LineWidth = 2;  
fig_err.MarkerFaceColor = color; fig_err.MarkerSize = 8; fig_err.MarkerEdgeColor = color;

xticks(1:7); xlim([0.1 7.7])
yticks(y_ticks); ylim(y_lim)
jh_set_fig()


% temp stats
flag = group==1 & spatial_metric_training > nanmedian(spatial_metric_training); flag1=flag;
flag = group==1 & spatial_metric_training <= nanmedian(spatial_metric_training); flag2=flag;
data = cellfun(@(x) x, metric(1:7), 'uni', 0);

func_stats_compare(data{1}(flag1),data{1}(flag2))

%% training index (for one metric)

% parameters
%%%%%%%%%%%%%%%%%%%%%%%%%
flag = group==1;

metric = spatial_metric_training; metric_corr = spatial_metric_training_corr; 
%%%%%%%%%%%%%%%%%%%%%%%%%

data = {metric(flag)};  


% plot
figure;
fig_box = jh_boxchart(data,'color',COLOR_SPATIAL, 'DrawPoint',true);
% fig_box = jh_bar(data,'color',COLOR_SPATIAL, 'DrawPoint',true);

xticks(1); xticklabels({' '});

yline(0,'--k','linewidth',1.5)
jh_set_fig(scale=1.3)

func_stats_single(data{1})

%% group comparison - 2bars & 4bars

%%%%%%%%%%%%%%%%%%%%%%%%%
flag = group==1;

metric = spatial_metric_sess_wise;  y_ticks = 0.6:0.1:1; y_lim = [0.6 1]; y_ticks2 = -.2:.1:.2;
%%%%%%%%%%%%%%%%%%%%%%%%%

metric_sess8 = metric{8};
metric_sess1 = metric{1};
metric = metric_sess8 - metric_sess1;

color_exp = COLOR_SPATIAL;
color_ctrl = COLOR_SPATIAL_CTRL;


% 4 bars
data = { metric_sess1(group==1),metric_sess8(group==1), ...
         metric_sess1(group==0),metric_sess8(group==0) };
color = { color_exp; color_exp;  color_ctrl ; color_ctrl};

figure;
[fig_box, x_ticks] = jh_boxchart(data,'color',color, 'DrawPoint',true, 'DrawMedian',true, ...
                           'DrawMedianLine',true, 'DrawPointLine', {[1,2],[3,4]}, divider=2);

xticks(x_ticks)
xticklabels({' '})
yticks(y_ticks); ylim(y_lim)

jh_set_fig()


% 2 bars
data = {metric(group==1), metric(group==0)};
color = {color_exp ; color_ctrl};

figure;
fig_box = jh_boxchart(data,'color',color, 'DrawPoint',true);

xticks(1:2)
xticklabels({' '})

yline(0,'--k','linewidth',1.5)
yticks(y_ticks2)
jh_set_fig('position',[10 3])

% stats
func_stats_training(metric_sess1, metric_sess8, group, sex)


%% training index continuously

% parameters
prctile_list = 30:70;

flag = group == 1;
data = spatial_metric_training_cont(prctile_list);
data = cellfun(@(x) x(flag), data, 'uni', 0);
[avg,err] = jh_mean_err(data);

% plot
figure;
jh_shaded_plot(prctile_list,avg,err, COLOR_SPATIAL, 'linewidth',2.5);
ylim([0 0.27])
% jh_set_fig('size',[8.5 8])
jh_set_fig(scale=0.2)

cellfun(@signrank, data)


%% group comparison -continuously

% parameters
prctile_list = 30:70;

color_exp = COLOR_SPATIAL;
color_ctrl = COLOR_SPATIAL_CTRL;

% plot
flag = group == 1;
data = spatial_metric_sess_wise_cont(prctile_list);
data = cellfun(@(x) x{8} - x{1}, data, 'uni', 0);
data = cellfun(@(x) x(flag), data, 'uni', 0);
[avg,err] = jh_mean_err(data);
data1 = data;

figure;
jh_shaded_plot(prctile_list,avg,err, color_exp, 'linewidth',2.5);

hold on

flag = group == 0;
data = spatial_metric_sess_wise_cont(prctile_list);
data = cellfun(@(x) x{8} - x{1}, data, 'uni', 0);
data = cellfun(@(x) x(flag), data, 'uni', 0);
[avg,err] = jh_mean_err(data);
data2 = data;

jh_shaded_plot(prctile_list,avg,err, color_ctrl, 'linewidth',2.5);

ylim([-0.1 0.27])
yline(0,'--k','linewidth',1.5)

% xlim([24,76])
jh_set_fig(scale=0.2)

[~,p] = cellfun(@(x,y) ttest2(x,y), data1, data2)

%%