function [metric_all, con_name_list, flag_name_list, roi_name_list] = ...
    func_get_pat_indiv_metric(data_all, fmri_info_all, beta_all, sess_i, roi_type)
%%
N_PERMUTE = 1000;
rng(1234)

con_name_list = {'enc-enc', 'ret-ret','enc-ret(same)','enc-ret(diff)'};

flag_name_list = {'all','moderate', 'correct1', 'correct', 'perfect1', 'perfect', ...
                  'moderate-not', 'correct-not','perfect-not', 'where-what', ...
                  'correct-where','correct-what'};


if strcmp(roi_type, 'ctx')
    roi_name_list = fmri_info_all{1}.seg_fit.ctx.roi_name_list;
elseif strcmp(roi_type, 'hpc')
    roi_name_list = fmri_info_all{1}.seg_fit.hpc.roi_name_list;
elseif strcmp(roi_type, 'hpc_ap')
    roi_name_list = {'Lt.CA23DG','Lt.CA1','Lt.Sub', 'Rt.CA23DG','Rt.CA1','Rt.Sub', 'Bi.CA23DG','Bi.CA1','Bi.Sub'};
    roi_name_list = [roi_name_list, cellfun(@(x) [x,'(head)'],roi_name_list,'uni',0), cellfun(@(x) [x,'(body)'],roi_name_list,'uni',0)];
end

con_eval_str_list = { 'arrayfun(@(x) x.enc, beta_all{sbj_i}.beta, ''uni'', 0)', ...
                      'arrayfun(@(x) x.ret, beta_all{sbj_i}.beta, ''uni'', 0)' };

metric_all = {}; %{con_i}{flag_i}{roi_i}{sbj_i}



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

    % correct - where
    flag1 = false(1,length(trials)); flag2 = flag1;
    flag1(acc>0.7) = true;
    flag2(acc<0.7 & acc_obj-acc_space<0.00001) = true;
    if sum(flag1)==0 || sum(flag2)==0; flag1 = false(1,length(trials)); flag2 = flag1; end
    flag1_sbj{end+1} = flag1; flag2_sbj{end+1} = flag2;

    % correct - what
    flag1 = false(1,length(trials)); flag2 = flag1;
    flag1(acc>0.7) = true;
    flag2(acc<0.7 & acc_obj-acc_space>0.00001) = true;
    if sum(flag1)==0 || sum(flag2)==0; flag1 = false(1,length(trials)); flag2 = flag1; end
    flag1_sbj{end+1} = flag1; flag2_sbj{end+1} = flag2;


    %
    flag1_list{sbj_i} = flag1_sbj;
    flag2_list{sbj_i} = flag2_sbj;
end


%% get ROI
roi_all = {};
for roi_i = 1:length(roi_name_list)
    
    if roi_i <= 33
        n_vox = cellfun(@(x) ceil(sum(x.seg.hpc_organized.roi_list{roi_i}(:))/27), fmri_info_all);
        vox_cutoff = cellfun(@(x) sort(x.seg_fit.hpc.roi_list_abs{roi_i}(:),'descend'), fmri_info_all,'uni',0);
        vox_cutoff = cellfun(@(x,y) x(round(y)), vox_cutoff, mat2cell(n_vox',ones(1,length(n_vox)))' );
        roi = cellfun(@(x,y) x.seg_fit.hpc.roi_list_abs{roi_i} > y, ...
                            fmri_info_all, mat2cell(vox_cutoff',ones(1,length(vox_cutoff)))', 'uni', 0); 
        roi_hp = roi;
    elseif roi_i <= 66
        n_vox = cellfun(@(x) ceil(sum(x.seg.ctx_organized.roi_list{roi_i-33}(:))/27), fmri_info_all);
        vox_cutoff = cellfun(@(x) sort(x.seg_fit.ctx.roi_list_abs{roi_i-33}(:),'descend'), fmri_info_all,'uni',0);
        vox_cutoff = cellfun(@(x,y) x(round(y)), vox_cutoff, mat2cell(n_vox',ones(1,length(n_vox)))' );
        roi = cellfun(@(x,y) x.seg_fit.ctx.roi_list_abs{roi_i-33} > y, ...
                            fmri_info_all, mat2cell(vox_cutoff',ones(1,length(vox_cutoff)))', 'uni', 0); 
    else
        left_head = roi_all{8};     left_body = roi_all{9};
        right_head = roi_all{8+11}; right_body = roi_all{9+11};
        bi_head = roi_all{8+22};    bi_body = roi_all{9+22};
        roi = {roi_all{5}, roi_all{6}, roi_all{7}, roi_all{5+11}, roi_all{6+11}, roi_all{7+11}, roi_all{5+22}, roi_all{6+22}, roi_all{7+22}, ...
               cellfun(@(x,y) x&y, roi_all{5},left_head,'uni',0), ...
               cellfun(@(x,y) x&y, roi_all{6},left_head,'uni',0), ...
               cellfun(@(x,y) x&y, roi_all{7},left_head,'uni',0), ...
               cellfun(@(x,y) x&y, roi_all{5+11},right_head,'uni',0), ...
               cellfun(@(x,y) x&y, roi_all{6+11},right_head,'uni',0), ...
               cellfun(@(x,y) x&y, roi_all{7+11},right_head,'uni',0), ...
               cellfun(@(x,y) x&y, roi_all{5+22},bi_head,'uni',0), ...
               cellfun(@(x,y) x&y, roi_all{6+22},bi_head,'uni',0), ...
               cellfun(@(x,y) x&y, roi_all{7+22},bi_head,'uni',0), ...
               ...
               cellfun(@(x,y) x&~y, roi_all{5},left_head,'uni',0), ...
               cellfun(@(x,y) x&y, roi_all{6},left_head,'uni',0), ...
               cellfun(@(x,y) x&~y, roi_all{7},left_head,'uni',0), ...
               cellfun(@(x,y) x&~y, roi_all{5+11},right_head,'uni',0), ...
               cellfun(@(x,y) x&~y, roi_all{6+11},right_head,'uni',0), ...
               cellfun(@(x,y) x&~y, roi_all{7+11},right_head,'uni',0), ...
               cellfun(@(x,y) x&~y, roi_all{5+22},bi_head,'uni',0), ...
               cellfun(@(x,y) x&~y, roi_all{6+22},bi_head,'uni',0), ...
               cellfun(@(x,y) x&~y, roi_all{7+22},bi_head,'uni',0), ...
               };
        roi = roi{roi_i-66};
    end
    roi_all{roi_i} = roi;
end

%% get image

metric_all = {};  %{con_i}{flag_i}{roi_i}{sbj_i}

for con_i = 1:2
    con_name = con_name_list{con_i};

    for flag_i = 1:length(flag_name_list)
        for roi_i = 1:length(roi_name_list)
            metric_all{con_i}{flag_i}{roi_i} = [];

            for sbj_i = 1:length(data_all)       
                roi = roi_all{roi_i}{sbj_i};

                trials = data_all{sbj_i}.em.sess(sess_i).trials;    
                valid_trial = data_all{sbj_i}.em.sess(sess_i).valid_trial;
                valid_fmri_trial = data_all{sbj_i}.em.sess(sess_i).valid_fmri_trial;
                acc = arrayfun(@(x) mean(x.correct.obj_space_time), trials(valid_fmri_trial));
             
                flag_valid_trial = ismember(valid_trial, valid_fmri_trial);
    
                if sum(flag_valid_trial)==0
                    metric_all{con_i}{flag_i}{roi_i}(sbj_i) = nan;
                    continue
                end

                diff_run_flag = [];
                for run_i = 1:length(valid_fmri_trial)
                    for run_j = 1:length(valid_fmri_trial)
                        if floor((valid_fmri_trial(run_i)-1)/2) == floor((valid_fmri_trial(run_j)-1)/2)
                            diff_run_flag(run_i,run_j) = 0;
                        else
                            diff_run_flag(run_i,run_j) = 1;
                        end
                    end
                end
                diff_run_flag = logical(diff_run_flag);
            
                try
                    beta = eval(con_eval_str_list{con_i});
                    beta = beta(valid_fmri_trial);
        
                    flag1 = cellfun(@(x) x(valid_fmri_trial), flag1_list{sbj_i}, 'uni', 0);
                    flag2 = cellfun(@(x) x(valid_fmri_trial), flag2_list{sbj_i}, 'uni', 0);
                    flag1 = flag1{flag_i};
                    flag2 = flag2{flag_i};
    
    
                    if sum(flag1) == 0 
                        temp_metric = nan;
                    elseif sum(flag2) == 0
                        temp_img = beta(flag1==1);
                        temp_img = cellfun(@(x) x(roi==1), temp_img, 'uni',0);
    
                        temp_flag = diff_run_flag(flag1==1, flag1==1);
    
                        temp = corr(cell2mat(temp_img), 'rows','pairwise');
                        temp_metric = mean(temp(triu(ones(size(temp)),1) == 1 & temp_flag));
    
                    else
                        temp_img1 = beta(flag1==1);
                        temp_img2 = beta(flag2==1);
                        temp_img1 = cellfun(@(x) x(roi==1), temp_img1, 'uni',0);
                        temp_img2 = cellfun(@(x) x(roi==1), temp_img2, 'uni',0);
    
                        temp = corr(cell2mat(temp_img1), cell2mat(temp_img2), 'rows','pairwise');
                        temp_metric = mean(temp(:));
    
                    end
                catch
                    metric_all{con_i}{flag_i}{roi_i}(sbj_i) = nan;
                    continue
                end

                metric_all{con_i}{flag_i}{roi_i}(sbj_i) = temp_metric;
            end
        end
    end
end
metric_all1 = metric_all;

%% enc - ret 
metric_all = {};  %{con_i}{flag_i}{roi_i}{sbj_i}

for flag_i = 1:length(flag_name_list)
    for roi_i = 1:length(roi_name_list)
        metric_all{1}{flag_i}{roi_i} = [];
        metric_all{2}{flag_i}{roi_i} = [];

        for sbj_i = 1:length(data_all)        
            roi = roi_all{roi_i}{sbj_i};
            
            trials = data_all{sbj_i}.em.sess(sess_i).trials;    
            valid_trial = data_all{sbj_i}.em.sess(sess_i).valid_trial;
            valid_fmri_trial = data_all{sbj_i}.em.sess(sess_i).valid_fmri_trial;
            acc = arrayfun(@(x) mean(x.correct.obj_space_time), trials(valid_fmri_trial));
         
            flag_valid_trial = ismember(valid_trial, valid_fmri_trial);

            if sum(flag_valid_trial)==0
                metric_all{1}{flag_i}{roi_i}(sbj_i) = nan;
                metric_all{2}{flag_i}{roi_i}(sbj_i) = nan;
                continue
            end

            diff_run_flag = [];
            for run_i = 1:length(valid_fmri_trial)
                for run_j = 1:length(valid_fmri_trial)
                    if floor((valid_fmri_trial(run_i)-1)/2) == floor((valid_fmri_trial(run_j)-1)/2)
                        diff_run_flag(run_i,run_j) = 0;
                    else
                        diff_run_flag(run_i,run_j) = 1;
                    end
                end
            end
            diff_run_flag = logical(diff_run_flag);
        
            try
                %
                beta1 = eval(con_eval_str_list{1});
                beta1 = beta1(valid_fmri_trial);
                
                beta2 = eval(con_eval_str_list{2});
                beta2 = beta2(valid_fmri_trial);
    
                flag1 = cellfun(@(x) x(valid_fmri_trial), flag1_list{sbj_i}, 'uni', 0);
                flag2 = cellfun(@(x) x(valid_fmri_trial), flag2_list{sbj_i}, 'uni', 0);
                flag1 = flag1{flag_i};
                flag2 = flag2{flag_i};
    
    
                if sum(flag1) == 0 
                    temp_metric1 = nan;
                    temp_metric2 = nan;
                elseif sum(flag2) == 0
                    temp_img1 = beta1(flag1==1);
                    temp_img2 = beta2(flag1==1);
                    temp_img1 = cellfun(@(x) x(roi==1), temp_img1, 'uni',0);
                    temp_img2 = cellfun(@(x) x(roi==1), temp_img2, 'uni',0);
                    
                    temp = corr(cell2mat(temp_img1), cell2mat(temp_img2), 'rows','pairwise');
    
                    temp_flag = diff_run_flag(flag1==1, flag1==1);
    
                    temp_metric1 = mean(temp(eye(size(temp))==1));
                    temp_metric2 = mean(temp( temp_flag ));
    
                else
                    temp_img1 = beta1(flag1==1);
                    temp_img2 = beta2(flag1==1);
                    temp_img1 = cellfun(@(x) x(roi==1), temp_img1, 'uni',0);
                    temp_img2 = cellfun(@(x) x(roi==1), temp_img2, 'uni',0);         
                    temp_img1_1 = temp_img1; temp_img1_2 = temp_img2;
                    temp1 = corr(cell2mat(temp_img1), cell2mat(temp_img2), 'rows','pairwise');
    
                    temp_img1 = beta1(flag2==1);
                    temp_img2 = beta2(flag2==1);
                    temp_img1 = cellfun(@(x) x(roi==1), temp_img1, 'uni',0);
                    temp_img2 = cellfun(@(x) x(roi==1), temp_img2, 'uni',0);        
                    temp_img2_1 = temp_img1; temp_img2_2 = temp_img2;          
                    temp2 = corr(cell2mat(temp_img1), cell2mat(temp_img2), 'rows','pairwise');
    
                    temp_flag1 = diff_run_flag(flag1==1, flag1==1);
                    temp_flag2 = diff_run_flag(flag2==1, flag2==1);
    
                    temp_metric1 = mean(temp1(eye(size(temp1))==1)) - mean(temp2(eye(size(temp2))==1));
                    temp_metric2 = mean(temp1(temp_flag1)) - mean(temp2(temp_flag2));
    
                end
            catch
                metric_all{1}{flag_i}{roi_i}(sbj_i) = nan;
                metric_all{2}{flag_i}{roi_i}(sbj_i) = nan;
                continue
            end

            metric_all{1}{flag_i}{roi_i}(sbj_i) = temp_metric1;
            metric_all{2}{flag_i}{roi_i}(sbj_i) = temp_metric2;
        end
    end
end

metric_all2 = metric_all;

%% final save

metric_all = [metric_all1, metric_all2 ];



