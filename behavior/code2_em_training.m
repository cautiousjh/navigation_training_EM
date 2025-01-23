%% exp vs. control


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flag_sbj = true(1,length(data_all));

is_residual = true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
func_get_target_metric = @(x) x.full.or; color = COLOR_EM;
% func_get_target_metric = @(x) x.full.and; color = COLOR_EM;
% func_get_target_metric = @(x) x.full.sum; color = COLOR_EM;
% func_get_target_metric = @(x) x.what.recog; color = COLOR_WORD;
% func_get_target_metric = @(x) x.what.when; color = COLOR_WORD;
% func_get_target_metric = @(x) x.where.recog; color = COLOR_SPATIAL;
% func_get_target_metric = @(x) x.where.when; color = COLOR_SPATIAL;
% func_get_target_metric = @(x) x.what_where; color = COLOR_EM;
% func_get_target_metric = @(x) x.conf.what.overall; color = COLOR_WORD;
% func_get_target_metric = @(x) x.conf.where.overall; color = COLOR_SPATIAL;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

metric_pre = func_get_em_metric_all(data_all, 1, 1:5);
metric_post = func_get_em_metric_all(data_all, 2, 1:5);

metric_pre = func_get_target_metric(metric_pre);
metric_post = func_get_target_metric(metric_post);

metric = metric_post - metric_pre;

color_exp = color;
color_ctrl = jh_color_modify(color_exp, 'saturation',0.5, 'value', 1);


% 4 bars
data = { metric_pre(group(flag_sbj)==1),metric_post(group(flag_sbj)==1),  ...
         metric_pre(group(flag_sbj)==0),metric_post(group(flag_sbj)==0) };
color = { color_exp; color_exp;  color_ctrl ; color_ctrl};

figure;
[fig_box,x_ticks] = jh_boxchart(data,'color',color, 'DrawPoint',true, 'DrawMedianLine',true, divider=2, DrawPointLine={[1,2],[3,4]});%

xticks(x_ticks)
xticklabels({' '})
jh_set_fig()


% 2 bars
data = {metric(group(flag_sbj)==1), metric(group(flag_sbj)==0)};
color = {color_exp ; color_ctrl};

figure;
fig_box = jh_boxchart(data,'color',color, 'DrawPoint',true);

xticks(1:2)
xticklabels({' '})

yline(0,':k','linewidth',1.5)
jh_set_fig('position',[10 3])


%% position-wise 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flag_sbj = true(1,length(data_all));

%%% for matching pre-accuracy
% func_metric_temp= @(x) x.full.and;
% metric = func_get_em_metric_all(data_all, 1, 1:5); 
% metric = func_metric_temp(metric);
% flag_sbj = metric < prctile(metric,75);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
func_get_target_metric = @(x) x.full.and; color = COLOR_EM; y_lim = [-.07 .28]; y_ticks = 0:.1:.2;
% func_get_target_metric = @(x) x.full.or; color = COLOR_EM; y_lim = [-.07 .23]; y_ticks = 0:.1:.2;
% func_get_target_metric = @(x) x.full.sum; color = COLOR_EM;
% func_get_target_metric = @(x) x.what.recog; color = COLOR_WORD;
% func_get_target_metric = @(x) x.what.when; color = COLOR_WORD; y_lim = [-.07 .28]; y_ticks = 0:.1:.2;
% func_get_target_metric = @(x) x.where.recog; color = COLOR_SPATIAL;
% func_get_target_metric = @(x) x.where.when; color = COLOR_SPATIAL; y_lim = [-.07 .23]; y_ticks = 0:.1:.2;
% func_get_target_metric = @(x) x.what_where; color = COLOR_EM;
% func_get_target_metric = @(x) x.conf.where.overall; color = COLOR_SPATIAL;
% func_get_target_metric = @(x) x.logrt.where.overall; color = COLOR_SPATIAL;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

color_exp = color;
color_ctrl = jh_color_modify(color_exp, 'alpha',0.4);


data = {};
data_pre = {}; data_post = {};
for pos = 1:5
    temp1 = func_get_em_metric_all(data_all(flag_sbj),1, pos);
    temp2 = func_get_em_metric_all(data_all(flag_sbj),2, pos);
    data{pos} = func_get_target_metric(temp2) - func_get_target_metric(temp1);

    data_pre{pos} = func_get_target_metric(temp1);
    data_post{pos} = func_get_target_metric(temp2);
end


data_exp = cellfun(@(x) x(group(flag_sbj)==1), data, 'uni', 0);
data_ctrl = cellfun(@(x) x(group(flag_sbj)==0), data, 'uni', 0);


figure;
hold on
[avg,err] = jh_mean_err(data_exp); color = color_exp;
fig_err = errorbar([1:length(avg)]-0.1, avg, err,'-square');
fig_err.Color = [color];  fig_err.LineWidth = 2;  
fig_err.MarkerFaceColor = color; fig_err.MarkerSize = 7; fig_err.MarkerEdgeColor = color;

[avg,err] = jh_mean_err(data_ctrl); color = color_ctrl;
fig_err = errorbar([1:length(avg)]+0.1, avg, err,'-square');
fig_err.Color = [color];   fig_err.LineWidth = 2;  
fig_err.MarkerFaceColor = color; fig_err.MarkerSize = 7; fig_err.MarkerEdgeColor = color;

xticks(1:5)
yline(0,'--k','linewidth',1.5)

ylim(y_lim)
yticks(y_ticks)

jh_set_fig(size=[7 6.5], fontsize=10, position=[14 3])


