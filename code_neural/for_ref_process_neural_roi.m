
%% load segmentations

sbj_list = split(num2str(1:32));
sess_i = 1;
file_path_fmri = sprintf('../data/data_fmri_organized_overall_sess%d',sess_i);

fmri_info_all = {};
parfor (sbj_i = 1:length(sbj_list),7)
    data = load(fullfile(file_path_fmri,[sbj_list{sbj_i} '.mat']));
    fmri_info_all{sbj_i} = data.sbj;
end
fmri_info_all1 = fmri_info_all;

%
sess_i = 2;
file_path_fmri = sprintf('../data/data_fmri_organized_overall_sess%d',sess_i);

fmri_info_all = {};
parfor (sbj_i = 1:length(sbj_list),7)
    data = load(fullfile(file_path_fmri,[sbj_list{sbj_i} '.mat']));
    fmri_info_all{sbj_i} = data.sbj;
end
fmri_info_all2 = fmri_info_all;

%% EPI to T1 mapping
roi_name_list = fmri_info_all{1}.seg_fit.hpc.roi_name_list;

fprintf('\n\n')
for roi_i = 1:length(roi_name_list)

    fmri_info_all = fmri_info_all1;
    n_vox = cellfun(@(x) ceil(sum(x.seg.hpc_organized.roi_list{roi_i}(:))/27), fmri_info_all);
    vox_cutoff = cellfun(@(x) sort(x.seg_fit.hpc.roi_list_abs{roi_i}(:),'descend'), fmri_info_all,'uni',0);
    vox_cutoff = cellfun(@(x,y) x(round(y)), vox_cutoff, mat2cell(n_vox',ones(1,length(n_vox)))' );
    roi1 = cellfun(@(x,y) x.seg_fit.hpc.roi_list_abs{roi_i} > y, ...
                        fmri_info_all, mat2cell(vox_cutoff',ones(1,length(vox_cutoff)))', 'uni', 0); 

    fmri_info_all = fmri_info_all2;
    n_vox = cellfun(@(x) ceil(sum(x.seg.hpc_organized.roi_list{roi_i}(:))/27), fmri_info_all);
    vox_cutoff = cellfun(@(x) sort(x.seg_fit.hpc.roi_list_abs{roi_i}(:),'descend'), fmri_info_all,'uni',0);
    vox_cutoff = cellfun(@(x,y) x(round(y)), vox_cutoff, mat2cell(n_vox',ones(1,length(n_vox)))' );
    roi2 = cellfun(@(x,y) x.seg_fit.hpc.roi_list_abs{roi_i} > y, ...
                        fmri_info_all, mat2cell(vox_cutoff',ones(1,length(vox_cutoff)))', 'uni', 0); 
    
    roi = (cellfun(@(x) sum(x(:)), roi1) + cellfun(@(x) sum(x(:)), roi2))/2 ;

    fprintf('%10s %.2f ± %.2f\n', roi_name_list{roi_i}, mean(roi), std(roi))

end
fprintf('\n\n')

%% parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dir_result = 'results';       opt_fieldmap = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

roi_opt = 2;

%% load indiv betas

sess_i = 1;
dir_glm = sprintf('glm_em_indiv_rough_sess%d',sess_i);
dir_first = sprintf('../%s/%s/1st_level/_organized',dir_result,dir_glm);

beta_all = {};
parfor (sbj_i = 1:length(sbj_list),11)
% for sbj_i = 1:length(sbj_list)
    data = load(fullfile(dir_first,[sbj_list{sbj_i} '.mat']));
    beta_all{sbj_i} = data.glm;
end
beta_indiv_all1 = beta_all;

%
sess_i = 2;
dir_glm = sprintf('glm_em_indiv_rough_sess%d',sess_i);
dir_first = sprintf('../%s/%s/1st_level/_organized',dir_result,dir_glm);

beta_all = {};
parfor (sbj_i = 1:length(sbj_list),11)
% for sbj_i = 1:length(sbj_list)
    data = load(fullfile(dir_first,[sbj_list{sbj_i} '.mat']));
    beta_all{sbj_i} = data.glm;
end
beta_indiv_all2 = beta_all;


%% setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
roi_type = 'ctx';
roi_type = 'hpc';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% activation - indiv space
sess_i = 1;
[act_metric_sess1, con_name_act_list, flag_name_list, roi_name_list] = ...
 func_get_act_indiv_metric(data_all, fmri_info_all1, beta_indiv_all1, sess_i, roi_type);
 
sess_i = 2;
[act_metric_sess2, con_name_act_list, flag_name_list, roi_name_list] = ...
 func_get_act_indiv_metric(data_all, fmri_info_all2, beta_indiv_all2, sess_i, roi_type);

save(sprintf('DATA_ORGANIZED_%s_%s.mat',roi_type,'act_indiv'), ...
    'con_name_act_list','flag_name_list','roi_name_list', ...
    'act_metric_sess1','act_metric_sess2' ...
     )

%% pattern similarity - indiv space
sess_i = 1;
[pat_metric_sess1, con_name_pat_list, flag_name_list, roi_name_list] = ...
 func_get_pat_indiv_metric(data_all, fmri_info_all1, beta_indiv_all1, sess_i, roi_type);
 
sess_i = 2;
[pat_metric_sess2, con_name_pat_list, flag_name_list, roi_name_list] = ...
 func_get_pat_indiv_metric(data_all, fmri_info_all2, beta_indiv_all2, sess_i, roi_type);

save(sprintf('DATA_ORGANIZED_%s_%s.mat',roi_type,'pat_indiv'), ...
    'con_name_pat_list','flag_name_list','roi_name_list', ...
    'pat_metric_sess1','pat_metric_sess2' ...
     )
