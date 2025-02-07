%% parameters 


sess_i = 1; % 1 or 2
opt_img = 1; % norm_smooth / norm_rough 
opt_fieldmap = 1; % no-correction / correction

opt_list = {[1 1 1] [2 1 1] };

log_file_name = ('log_whole2_second_level.mat');
log_progress = {};

for opt_i = 1:length(opt_list)
    sess_i = opt_list{opt_i}(1);
    opt_img = opt_list{opt_i}(2);
    opt_fieldmap = opt_list{opt_i}(3);
    log_progress{end+1} = [sess_i, opt_img, opt_fieldmap];
    save(log_file_name,'log_progress');

%%
sbj_list = split(num2str(1:33));

%
dir_working = pwd();
dir_sbj = '../data/data_processed_sbj';


%
con_name_list = {'enc_raw', 'ret_raw', 'enc_fix', 'ret_fix','enc_ctrl','ret_ctrl','enc_ctrl_fix','ret_ctrl_fix','word_enc','word_ret'};
flag_name_list = {'all','moderate', 'correct1', 'correct', 'perfect1', 'perfect', 'moderate-not', 'correct-not','perfect-not', 'where-what'};
dir_second_list = {'glm_act_all','glm_act_moderate', 'glm_act_correct1', 'glm_act_correct', ...
                   'glm_act_perfect1', 'glm_act_perfect', ...
                   'glm_compare_moderate', 'glm_compare_correct','glm_compare_perfect', ...
                   'glm_compare_where' };


con_eval_str_list = { 'arrayfun(@(x) x.enc, beta_all{sbj_i}.beta_raw, ''uni'', 0)', ...
                      'arrayfun(@(x) x.ret, beta_all{sbj_i}.beta_raw, ''uni'', 0)', ...
                      'arrayfun(@(x) x.enc, beta_all{sbj_i}.beta, ''uni'', 0)', ...
                      'arrayfun(@(x) x.ret, beta_all{sbj_i}.beta, ''uni'', 0)', ...
                      'arrayfun(@(x) x.enc_ctrl, beta_all{sbj_i}.beta, ''uni'', 0)', ...
                      'arrayfun(@(x) x.ret_ctrl, beta_all{sbj_i}.beta, ''uni'', 0)', ...
                      'arrayfun(@(x) x.enc_ctrl_fix, beta_all{sbj_i}.beta, ''uni'', 0)', ...
                      'arrayfun(@(x) x.ret_ctrl_fix, beta_all{sbj_i}.beta, ''uni'', 0)', ...
                      'arrayfun(@(x) x.word_enc, beta_all{sbj_i}.beta, ''uni'', 0)', ...
                      'arrayfun(@(x) x.word_ret, beta_all{sbj_i}.beta, ''uni'', 0)' };

%
if sess_i == 1
    dir_list_func = {'1','2','3','4'};
elseif sess_i == 2
    dir_list_func = {'1','2','3'};
end
%
if opt_img == 1
    dir_glm = sprintf('glm_em_norm_smooth_sess%d',sess_i); is_masking = true;
elseif opt_img == 2
    dir_glm = sprintf('glm_em_norm_rough_sess%d',sess_i); is_masking = true;
elseif opt_img == 3
    dir_glm = sprintf('glm_em_indiv_rough_sess%d',sess_i); is_masking = false;
end
%
if opt_fieldmap == 1
    dir_result = 'results';
    dir_fmri = sprintf('../data/data_fmri_sess%d_preprocessed',sess_i);
elseif opt_fieldmap == 2
    dir_result = 'results_unwrapped';
    dir_fmri = sprintf('../data/data_fmri_sess%d_preprocessed_corrected',sess_i);
end
%
if opt_fieldmap == 1
    if opt_img == 1
        target_reg_exp = '.*swraf.*';
    elseif opt_img == 2
        target_reg_exp = '.*\\wraf.*';
    elseif opt_img == 3
        target_reg_exp = '.*\\raf.*';
    end
elseif opt_fieldmap == 2
    if opt_img == 1
        target_reg_exp = '.*swuaf.*';
    elseif opt_img == 2
        target_reg_exp = '.*\\wuaf.*';
    elseif opt_img == 3
        target_reg_exp = '.*\\uaf.*';
    end
end



dir_first = sprintf('../%s/%s/1st_level/_organized',dir_result,dir_glm);
dir_second_list = cellfun(@(x) sprintf('../%s/%s/%s',dir_result,dir_glm,x), dir_second_list, 'uni', 0);
dir_name_collect = '_organized';
cd(dir_working);

%% load beta - it can be more efficient (pre-loading & run), but didn't do that

beta_all = {};
parfor sbj_i = 1:length(sbj_list)
    cd(dir_working);
    data = load(fullfile(dir_first,[sbj_list{sbj_i} '.mat']));
    beta_all{sbj_i} = data.glm;
end

%% load behavioral data

% {data_all, age, sex, group, num_sbj}; 
func_load_data(dir_sbj, sbj_list);

% {obj, obj_time, space, space_time, obj_space, obj_space_time};
func_get_acc_em(data_all, sess_i);


%% set flag
flag1_list = {};
flag2_list = {};
for sbj_i  = 1:length(data_all)
    flag1_sbj = {};
    flag2_sbj = {};

    trials = data_all{sbj_i}.em.sess(sess_i).trials;    
    valid_trial = data_all{sbj_i}.em.sess(sess_i).valid_trial;
    valid_fmri_trial = data_all{sbj_i}.em.sess(sess_i).valid_fmri_trial;

    correct_all = arrayfun(@(x) x.correct, data_all{sbj_i}.em.sess(sess_i).trials (valid_fmri_trial));
    acc = arrayfun(@(x) mean(x.obj_space_time), correct_all);
    acc_obj = arrayfun(@(x) mean(x.obj_time), correct_all);
    acc_space = arrayfun(@(x) mean(x.space_time), correct_all);

    % all
    flag1 = false(1,length(trials)); flag2 = flag1;
    flag1(valid_fmri_trial) = true;
    flag1_sbj{end+1} = flag1; flag2_sbj{end+1} = flag2;

    % moderate min trial 2
    flag1 = false(1,length(trials)); flag2 = flag1;
    flag1(acc>0.5) = true;
    if sum(flag1) < 2; flag1 = flag2; end
    flag1_sbj{end+1} = flag1; flag2_sbj{end+1} = flag2;

    % correct min trial 1
    flag1 = false(1,length(trials)); flag2 = flag1;
    flag1(acc>0.7) = true;
    if sum(flag1) < 1; flag1 = flag2; end
    flag1_sbj{end+1} = flag1; flag2_sbj{end+1} = flag2;

    % correct min trial 2
    flag1 = false(1,length(trials)); flag2 = flag1;
    flag1(acc>0.7) = true;
    if sum(flag1) < 2; flag1 = flag2; end
    flag1_sbj{end+1} = flag1; flag2_sbj{end+1} = flag2;

    % perfect min trial 1
    flag1 = false(1,length(trials)); flag2 = flag1;
    flag1(acc>0.9) = true;
    if sum(flag1) < 1; flag1 = flag2; end
    flag1_sbj{end+1} = flag1; flag2_sbj{end+1} = flag2;

    % perfect min trial 2
    flag1 = false(1,length(trials)); flag2 = flag1;
    flag1(acc>0.9) = true;
    if sum(flag1) < 2; flag1 = flag2; end
    flag1_sbj{end+1} = flag1; flag2_sbj{end+1} = flag2;

    % moderate - not
    flag1 = false(1,length(trials)); flag2 = flag1;
    flag1(acc>0.5) = true;
    flag2(acc<0.5) = true;
    if sum(flag1) < 1; flag1 = false(1,length(trials)); flag2 = flag1; end
    flag1_sbj{end+1} = flag1; flag2_sbj{end+1} = flag2;

    % correct - not
    flag1 = false(1,length(trials)); flag2 = flag1;
    flag1(acc>0.7) = true;
    flag2(acc<0.7) = true; 
    if sum(flag1) < 1; flag1 = false(1,length(trials)); flag2 = flag1; end
    flag1_sbj{end+1} = flag1; flag2_sbj{end+1} = flag2;

    % perfect - not
    flag1 = false(1,length(trials)); flag2 = flag1;
    flag1(acc>0.9) = true;
    flag2(acc<0.9) = true;
    if sum(flag1) < 1; flag1 = false(1,length(trials)); flag2 = flag1; end
    flag1_sbj{end+1} = flag1; flag2_sbj{end+1} = flag2;

    % where - what
    flag1 = false(1,length(trials)); flag2 = flag1;
    flag1(acc<0.7 & acc_obj-acc_space<0.00001) = true;
    flag2(acc<0.7 & acc_obj-acc_space>0.00001) = true;
    if sum(flag1)==0 || sum(flag2)==0; flag1 = false(1,length(trials)); flag2 = flag1; end
    flag1_sbj{end+1} = flag1; flag2_sbj{end+1} = flag2;

    %
    flag1_list{sbj_i} = flag1_sbj;
    flag2_list{sbj_i} = flag2_sbj;
end



%% save image

% img_all = {};  %{con_i}{sbj_i}{flag_i}
for con_i = 1:length(con_name_list)
    con_name = con_name_list{con_i};
        
    for sbj_i = 1:length(data_all)        
        try
            trials = data_all{sbj_i}.em.sess(sess_i).trials;    
            valid_trial = data_all{sbj_i}.em.sess(sess_i).valid_trial;
            valid_fmri_trial = data_all{sbj_i}.em.sess(sess_i).valid_fmri_trial;
            acc = arrayfun(@(x) mean(x.correct.obj_space_time), trials(valid_fmri_trial));
         
            flag_valid_trial = ismember(valid_trial, valid_fmri_trial);

            if sum(flag_valid_trial)==0
                continue
            end
        
            beta = eval(con_eval_str_list{con_i});
            beta = beta(valid_fmri_trial); 
            hdr = beta_all{sbj_i}.hdr(valid_fmri_trial(1));

            flag1 = cellfun(@(x) x(valid_fmri_trial), flag1_list{sbj_i}, 'uni', 0);
            flag2 = cellfun(@(x) x(valid_fmri_trial), flag2_list{sbj_i}, 'uni', 0);
            for flag_i = 1:length(flag1)            
                if sum(flag1{flag_i})==0 % flag1 zero
                    continue
                elseif sum(flag2{flag_i}) == 0 % flag 1 nonzero  flag2 zero
                    temp = nanmean(cat(4,beta{flag1{flag_i}}),4);
                else % flag1 nonzero  flag2 nonzero
                   temp = nanmean(cat(4,beta{flag1{flag_i}}),4) - nanmean(cat(4,beta{flag2{flag_i}}),4);
                end

                dir_temp = fullfile(dir_second_list{flag_i},dir_name_collect, con_name);
                if ~exist(dir_temp,'dir')
                    mkdir(dir_temp)
                end

                % save
                niftiwrite(temp, fullfile(dir_temp, sprintf('%d.nii', sbj_i)), hdr);
            end

        catch
            continue
        end
    end
end

%% run second level
setting_list = combvec(1:length(con_name_list),1:length(flag_name_list));

parfor setting_i = 1:size(setting_list,2)
    con_i = setting_list(1,setting_i);
    flag_i = setting_list(2,setting_i);
    fprintf('\n\n\n RUNNING: con %d flag %d\n\n\n', con_i, flag_i);

    cd(dir_working);

    dir_organized = fullfile(dir_second_list{flag_i},dir_name_collect, con_name_list{con_i});
    dir_out = fullfile(dir_second_list{flag_i}, con_name_list{con_i});
    if ~exist(dir_out,'dir')
        mkdir(dir_out)
    end

    file_list = arrayfun(@(x) fullfile(dir_organized, sprintf('%d.nii', x)), 1:length(sbj_list), 'uni', 0);
    valid_flag = cellfun(@(x) exist(x,'file'), file_list) ~=0;
    file_list(~valid_flag) = [];

    batch = jh_fmri_batch_ttest1(file_list, dir_out);
    jh_fmri_run_batch(batch);
    cd(dir_working);


    % calculate clusters
    jh_fmri_cluster_correction(dir_out, 0.005, 10, 'pos', true);    cd(dir_working)
%     jh_fmri_cluster_correction(dir_out, 0.005, 10, 'neg', true);    cd(dir_working)
    jh_fmri_cluster_correction(dir_out, 0.001, 10, 'pos', true);    cd(dir_working)
%     jh_fmri_cluster_correction(dir_out, 0.001, 10, 'neg', true);    cd(dir_working)
end


%%

end

%%
f = fopen('success_act2.txt','w'); fclose(f);