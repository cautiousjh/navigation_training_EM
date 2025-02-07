function [metric_all, con_name_list, flag_name_list, roi_name_list] = ...
    func_get_act_indiv_metric(data_all, fmri_info_all, beta_all, sess_i, roi_type)
%%

con_name_list = {'enc_raw', 'ret_raw', 'enc_fix', 'ret_fix','enc_ctrl','ret_ctrl','enc_ctrl_fix','ret_ctrl_fix','word_enc','word_ret'};

% flag_name_list = {'all','moderate', 'correct1', 'correct', 'perfect1', 'perfect', 'moderate-not', 'correct-not','perfect-not', 'where-what'};
% flag_name_list = {'all','moderate', 'correct1', 'correct', 'perfect1', 'perfect'};
flag_name_list = {'all','moderate', 'correct1', 'correct', 'perfect1', 'perfect', ...
                  'moderate-not', 'correct-not','perfect-not', 'where-what', ...
                  'correct-where','correct-what'};


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



%% get image 

img_all = {};  %{con_i}{sbj_i}{flag_i}
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
                img_all{con_i}{sbj_i} = {};
                continue
            end
        
            beta = eval(con_eval_str_list{con_i});
            beta = beta(valid_fmri_trial);            
%             hdr = beta_all{sbj_i}.hdr(valid_fmri_trial(1));

            flag1 = cellfun(@(x) x(valid_fmri_trial), flag1_list{sbj_i}, 'uni', 0);
            flag2 = cellfun(@(x) x(valid_fmri_trial), flag2_list{sbj_i}, 'uni', 0);
            img_sbj = {};
            for flag_i = 1:length(flag1)            
                if sum(flag1{flag_i})==0
                    temp = [];
                elseif sum(flag2{flag_i}) == 0
                    temp = nanmean(cat(4,beta{flag1{flag_i}}),4);
                else
                    temp = nanmean(cat(4,beta{flag1{flag_i}}),4) - nanmean(cat(4,beta{flag2{flag_i}}),4);
                end
                img_sbj{flag_i} = temp;
            end
            
            img_all{con_i}{sbj_i} = img_sbj;
        catch
            img_all{con_i}{sbj_i} = {};
            continue
        end
    end
end

%% get ROI
if strcmp(roi_type, 'ctx')
    roi_name_list = fmri_info_all{1}.seg_fit.ctx.roi_name_list;
elseif strcmp(roi_type, 'hpc')
    roi_name_list = fmri_info_all{1}.seg_fit.hpc.roi_name_list;
elseif strcmp(roi_type, 'hpc_ap')
    roi_name_list = fmri_info_all{1}.seg_fit.hpc.roi_name_list;
end


roi_all = {};
for roi_i = 1:length(roi_name_list)
    
    if strcmp(roi_type, 'ctx')
        n_vox = cellfun(@(x) ceil(sum(x.seg.ctx_organized.roi_list{roi_i}(:))/27), fmri_info_all);
        vox_cutoff = cellfun(@(x) sort(x.seg_fit.ctx.roi_list_abs{roi_i}(:),'descend'), fmri_info_all,'uni',0);
        vox_cutoff = cellfun(@(x,y) x(round(y)), vox_cutoff, mat2cell(n_vox',ones(1,length(n_vox)))' );
        roi = cellfun(@(x,y) x.seg_fit.ctx.roi_list_abs{roi_i} > y, ...
                            fmri_info_all, mat2cell(vox_cutoff',ones(1,length(vox_cutoff)))', 'uni', 0); 
        
    elseif strcmp(roi_type, 'hpc') || strcmp(roi_type,'hpc_ap')
        n_vox = cellfun(@(x) ceil(sum(x.seg.hpc_organized.roi_list{roi_i}(:))/27), fmri_info_all);
        vox_cutoff = cellfun(@(x) sort(x.seg_fit.hpc.roi_list_abs{roi_i}(:),'descend'), fmri_info_all,'uni',0);
        vox_cutoff = cellfun(@(x,y) x(round(y)), vox_cutoff, mat2cell(n_vox',ones(1,length(n_vox)))' );
        roi = cellfun(@(x,y) x.seg_fit.hpc.roi_list_abs{roi_i} > y, ...
                            fmri_info_all, mat2cell(vox_cutoff',ones(1,length(vox_cutoff)))', 'uni', 0); 
    end

    roi_all{roi_i} = roi;
end

if strcmp(roi_type,'hpc_ap')
    roi_name_list = {'Lt.CA23DG','Lt.CA1','Lt.Sub', 'Rt.CA23DG','Rt.CA1','Rt.Sub', 'Bi.CA23DG','Bi.CA1','Bi.Sub'};
    roi_name_list = [roi_name_list, cellfun(@(x) [x,'(ant)'],roi_name_list,'uni',0), cellfun(@(x) [x,'(post)'],roi_name_list,'uni',0)];
    roi_name_list = roi_name_list(:);

%     roi_map_sub = repmat([4,5,6, 15,16,17, 26,27,28],3,1); 
    roi_map_sub = repmat([5,6,7, 16,17,18, 27,28,29],3,1); 
    roi_map_sub = roi_map_sub(:);

    roi_map_ap = repmat([23,30,33],1,9);

    roi_copy = {};
    for sbj_i = 1:length(roi_all{1})
        for roi_i = 1:length(roi_all)
            roi_copy{sbj_i}{roi_i} = find(roi_all{roi_i}{sbj_i});
        end
    end

    roi_all = {};
    for roi_i = 1:length(roi_name_list)
        i = roi_map_sub(roi_i);
        j = roi_map_ap(roi_i);
        roi = cellfun(@(x) x{i}(  ismember(x{i},x{j}) ), roi_copy, uni=0);
        roi_all{roi_i} = roi;
    end

end

%% get metric

metric_all = {}; %{con_i}{flag_i}{roi_i}{sbj_i}

for con_i = 1:length(con_name_list)
    for flag_i = 1:length(flag_name_list)
        for roi_i = 1:length(roi_name_list)
            metric_all{con_i}{flag_i}{roi_i} = [];
            
            roi = roi_all{roi_i};


            for sbj_i = 1:length(data_all)
                if isempty(img_all{con_i}{sbj_i}) || isempty(img_all{con_i}{sbj_i}{flag_i})
                    metric_all{con_i}{flag_i}{roi_i}(sbj_i) = nan;
                    continue
                end

                metric_all{con_i}{flag_i}{roi_i}(sbj_i) = nanmean(img_all{con_i}{sbj_i}{flag_i}(roi{sbj_i}));

            end
        end
    end
end

