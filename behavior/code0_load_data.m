%% set parameters
sbj_list = split(num2str(1:32));
path_behav = '../data/data_processed_sbj/';

num_spatial_context = 5;

aux_func_get_residual = @(mdl) mdl.Residuals.Raw;
func_get_residual = @(x,y) aux_func_get_residual(fitlm(x(:),y(:)));

COLOR_BORDER = [.7 .7 .7];

COLOR_SPATIAL = [50 205 50] / 255; 
COLOR_WORD = [142/256, 184/256, 245/256];
COLOR_EM = [255 116 108] / 255;    

COLOR_SPATIAL_CTRL = jh_color_modify(COLOR_SPATIAL, 'saturation',0.1);
COLOR_WORD_CTRL = jh_color_modify(COLOR_WORD, 'saturation',0.1);
COLOR_EM_CTRL = jh_color_modify(COLOR_EM, 'saturation',0.1);

%% load behavior data
data_all = {};
for sbj_i = 1:length(sbj_list)
    data = load(fullfile(path_behav,[sbj_list{sbj_i} '.mat']));
    data_all{sbj_i} = data.sbj;
end

age = cellfun(@(x) x.age, data_all);
sex = cellfun(@(x) x.sex, data_all);
group = cellfun(@(x) x.type,data_all);

num_sbj = length(data_all);


% demographics
fprintf('\n\n[SUBJECT SUMMARY]\n');

age_temp = age; sex_temp = sex;
fprintf('ALL \n');
fprintf('%d subjects (%d male, %d female)\n', length(age_temp), sum(sex_temp==1), sum(sex_temp==0))
fprintf('age: %.2f (sd: %.2f)\n\n', mean(age_temp), std(age_temp))

age_temp = age(group==1); sex_temp = sex(group==1);
fprintf('EXP \n');
fprintf('%d subjects (%d male, %d female)\n', length(age_temp), sum(sex_temp==1), sum(sex_temp==0))
fprintf('age: %.2f (sd: %.2f)\n\n', mean(age_temp), std(age_temp))

age_temp = age(group==0); sex_temp = sex(group==0);
fprintf('CONTROL \n');
fprintf('%d subjects (%d male, %d female)\n', length(age_temp), sum(sex_temp==1), sum(sex_temp==0))
fprintf('age: %.2f (sd: %.2f)\n\n', mean(age_temp), std(age_temp))

%% get navigation metrics

spatial_metric_sess_wise = func_get_spatial_metric_sess_wise(data_all, 'acc_coin');
spatial_metric_sess_wise_raw = func_get_spatial_metric_sess_wise(data_all, 'err_coin');

[spatial_metric_training, spatial_metric_training_cov] = ...
    func_get_spatial_metric_training(data_all, 'acc_coin','slope',1,7);
[spatial_metric_training_corr, spatial_metric_training_cov_corr] = ...
    func_get_spatial_metric_training(data_all, 'acc_coin','corr',1,7);


[spatial_metric_training_coin_order, spatial_metric_training_cov_coin_order] = ...
    arrayfun(@(i) func_get_spatial_metric_training(data_all, 'acc_coin','slope',1,7,i), 1:8, 'uni', 0);

[spatial_metric_training_corr_coin_order, spatial_metric_training_corr_cov_coin_order] = ...
    arrayfun(@(i) func_get_spatial_metric_training(data_all, 'acc_coin','corr',1,7,i), 1:8, 'uni', 0);

spatial_metric_sess_wise_coin_order = ...
    arrayfun(@(i) func_get_spatial_metric_sess_wise(data_all, 'acc_coin',i), 1:8, 'uni', 0);

%% get EM metrics

em_metric_sess1 = func_get_em_metric_all(data_all, 1, 1:5);
em_metric_sess2 = func_get_em_metric_all(data_all, 2, 1:5);


