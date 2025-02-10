
%% parameters

type_space = 'indiv';
% type_space = 'norm';

type_roi = 'hpc';
% type_roi = 'ctx';


type_neural = 'act';
% type_neural = 'pat';


%
COLOR_EM = [255/256,143/256,120/256];
COLOR_SPATIAL = [159/256,204/256,78/256];
COLOR_WORD = [122/256,164/256,255/256];
COLOR_BORDER = [.7 .7 .7];

num_spatial_context = 5;

aux_func_get_residual = @(mdl) mdl.Residuals.Raw;
func_get_residual = @(x,y) aux_func_get_residual(fitlm(x(:),y(:)));

sbj_list = split(num2str(1:32));
dir_sbj = '../data/data_processed_sbj';
% func_load_data(dir_sbj, sbj_list);

% flag = group==1;


%% load metrics

if strcmp(type_space, 'indiv')
    load(sprintf('DATA_ORGANIZED_%s_%s_indiv.mat',type_roi,type_neural))
elseif strcmp(type_space, 'norm')
    load(sprintf('DATA_ORGANIZED_%s_norm.mat',type_neural))
end

if strcmp(type_neural, 'act')
    neural_metric_sess1 = act_metric_sess1;
    neural_metric_sess2 = act_metric_sess2;
    con_name_list = con_name_act_list;
    flag_name_list = flag_name_list;
    roi_name_list = roi_name_list;

elseif strcmp(type_neural, 'pat')
    neural_metric_sess1 = pat_metric_sess1;
    neural_metric_sess2 = pat_metric_sess2;
    con_name_list = con_name_pat_list;
    flag_name_list = flag_name_list;
    roi_name_list = roi_name_list;

elseif strcmp(type_neural, 'signal_change')
    neural_metric_sess1 = signal_change_metric_sess1;
    neural_metric_sess2 = signal_change_metric_sess2;
    con_name_list = con_name_act_list;
    flag_name_list = flag_name_list;
    roi_name_list = roi_name_list;
end

neural_metric_training = cellfun(@(x1,y1) cellfun(@(x2,y2) cellfun(@(x3,y3) y3-x3, x2,y2,'uni',0), x1,y1, 'uni',0),...
                            neural_metric_sess1, neural_metric_sess2,'uni',0);

neural_metric = neural_metric_training;

%%
aux_func_get_residual = @(mdl) mdl.Residuals.Raw;
func_get_residual = @(x,y) aux_func_get_residual(fitlm(x(:),y(:)));

corr_type = 'pearson';
corr_type = 'spearman';

%% correlation plot - single

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
con_i = 2;
flag_i = 1;

data_behav = spatial_metric_training; data_behav_cov = spatial_metric_sess_wise{1}; is_residual = true; color = COLOR_EM; color_line = [1 .3 .3] ; shade_alpha = 0.15;

roi_list = 7; fig_size = [12,8]; 


% roi_list = 1:3; fig_size = [12,8]; % big ROIs
% roi_list = 5:7; fig_size = [12,8]; % subregions
% roi_list = 8:11; fig_size = [12,8]; % HBT

opt_side = 3;   % 1 2 3  LRB  LR

if opt_side ~= 4
    roi_list = roi_list + (opt_side-1)*11;
end

flag = group==1;

neural_metric = neural_metric_training;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if is_residual
    data_behav = func_get_residual(data_behav_cov(flag), data_behav(flag));
else
    data_behav = data_behav(flag);
end

for roi_i = 1:length(roi_list)

   
    roi = roi_list(roi_i);
    if opt_side ~= 4
        data_training = neural_metric{con_i}{flag_i}{roi}(flag);
        data_cov = neural_metric_sess1{con_i}{flag_i}{roi}(flag);
    else
        roi1 = roi_list(roi_i);
        roi2 = roi_list(roi_i) + 11;
        data_training = neural_metric{con_i}{flag_i}{roi1}(flag) + neural_metric{con_i}{flag_i}{roi2}(flag);
        data_cov = neural_metric_sess1{con_i}{flag_i}{roi1}(flag) + neural_metric_sess1{con_i}{flag_i}{roi2}(flag);
        data_training  = data_training / 2;
        data_cov = data_cov / 2;
    end

    if is_residual
        data_neural = func_get_residual(data_cov, data_training);
    else
        data_neural = data_training;
    end


    data1 = data_behav;
    data2 = data_neural;

    figure;
    [r2,p2] = jh_regress(data1, data2,'off','type','spearman');
    if p2 < 0.1
        [r1,p1] = jh_regress(data1, data2,'on', ...
                            'MarkerColor', color,'markeralpha',1, ...
                            'ShadeColor', color, 'ShadeAlpha', shade_alpha ,'linecolor', color_line );
    else
        [r1,p1] = jh_regress(data1, data2,'on', ...
                            'MarkerColor', color,'markeralpha',1, ...
                            'ShadeColor', color, 'ShadeAlpha', shade_alpha  );
    end

    jh_set_fig(size=[6 5.5], fontsize=11)
    
    xticks([-.2 0 .2])
    title_str1 = sprintf('Pearson r = %.3f (p = %.3f)',r1,p1);
    if p1 < 0.05; title_str1 = [title_str1,'*']; end
    title_str2 = sprintf('Spearman r = %.3f (p = %.3f)',r2,p2);
    if p2 < 0.05; title_str2 = [title_str2,'*']; end
    title_str = {title_str1, title_str2};
    fprintf('\n%s\n',roi_name_list{roi})
    fprintf('%s\n', title_str{:})
end

