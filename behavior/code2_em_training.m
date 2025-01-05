%% exp vs. control


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flag_sbj = true(1,length(data_all));
% flag_sbj = true(1,length(data_all));

is_residual = false;
is_residual = true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
func_get_target_metric = @(x) x.full.and; color = COLOR_EM;
% func_get_target_metric = @(x) x.full.or; color = COLOR_EM;
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flag_sbj = true(1,length(data_all));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

metric_pre = metric_pre(flag_sbj);
metric_post = metric_post(flag_sbj);

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


