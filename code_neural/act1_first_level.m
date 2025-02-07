%% parameters 


sess_i = 1; % 1 or 2
opt_img = 1; % norm_smooth / norm_rough / indiv_rough
opt_fieldmap = 1; % no-correction / correction

opt_list = {[1 1 1] [1 2 1] [1 3 1] [2 1 1] [2 2 1] [2 3 1]};

log_file_name = ('log_whole1_first_level.mat');
log_progress = {};

for opt_i = 1:length(opt_list)
    sess_i = opt_list{opt_i}(1);
    opt_img = opt_list{opt_i}(2);
    opt_fieldmap = opt_list{opt_i}(3);
    log_progress{end+1} = [sess_i, opt_img, opt_fieldmap];
    save(log_file_name,'log_progress');

%%
sbj_list = split(num2str(1:32));

dir_working = pwd();
path_behav = '../data/data_processed_sbj';

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


run_start = 1;

dir_reg = sprintf('../data/data_regressors_em_sess%d', sess_i);
dir_first = sprintf('../%s/%s/1st_level',dir_result,dir_glm);
dir_organized = sprintf('../%s/%s/1st_level/_organized',dir_result, dir_glm);

file_name_qc = sprintf('../data/data_fmri_quality_control/sess%d.mat',sess_i);
load(file_name_qc); % bold_all, fd_all, move_all, rot_all

%% run - separate runs

err_list = cell(1,length(sbj_list));
parfor sbj_i = 1:length(sbj_list)
    cd(dir_working);

    sbj_name = sbj_list{sbj_i};
    err_list_temp = [];

    in_mat_file_name = fullfile(path_behav, [sbj_name '.mat']);
    data = load(in_mat_file_name);
    sbj = data.sbj;


    % run for each run
    for run_i = run_start:length(sbj.em.sess(sess_i).marker.marker_run)
        
        try
            err_list_temp(run_i) = 0;
            
            % output directory
            dir_out = fullfile(dir_first, sbj_name, num2str(run_i));
            dir_reg_out = fullfile(dir_first, sbj_name, 'reg');
            if exist(dir_out,'dir')
                rmdir(dir_out,'s')
                mkdir(dir_out)
            else
                mkdir(dir_out)
            end
            
            if ~exist(dir_reg_out, 'dir')
                mkdir(dir_reg_out)
            end

            % functional
            in_dir = fullfile(dir_fmri, sbj_name, dir_list_func{run_i});
            func = {jh_get_file_list(in_dir, target_reg_exp,'regexp')};
            task_reg = {fullfile(dir_reg, sprintf('%s_%s.mat',sbj_name, dir_list_func{run_i}))};
            
            
            % qc regressors
            move = move_all{sbj_i}{run_i};  move_diff = [zeros(1,size(move,2)); diff(move)];
            rot = rot_all{sbj_i}{run_i};    rot_diff = [zeros(1,size(rot,2)); diff(rot)];
            fd = fd_all{sbj_i}{run_i};

            cont_reg_temp = [move, rot, fd];

            
            % save regressors
            writematrix(cont_reg_temp, fullfile(dir_reg_out, sprintf('run%d.txt',run_i)), 'delimiter','tab');
            cont_reg = {fullfile(dir_reg_out, sprintf('run%d.txt',run_i))};
            
            batch = jh_fmri_first_level_analysis({dir_out}, func, task_reg, cont_reg, [], [], is_masking, 'none');
            jh_fmri_run_batch(batch);
            
        catch
            err_list_temp(run_i) = 1;
        end

        cd(dir_working);
    end

    
    err_list{sbj_i} = err_list_temp;
    
end

cd(dir_working);
save(fullfile(dir_first, 'log.mat'), 'err_list')



%% collect betas
if ~exist(dir_organized, 'dir')
    mkdir(dir_organized)
end

parfor sbj_i = 1:length(sbj_list)
    trials = data_all{sbj_i}.em.sess(sess_i).trials;    
    valid_trial = data_all{sbj_i}.em.sess(sess_i).valid_fmri_trial;

    enc_beta_sbj = {};
    ret_beta_sbj = {};

%     clear glm beta_raw  beta  hdr
    
    if isempty(valid_trial)
        beta_raw = [];
        beta = [];
        hdr = [];
    end
    
    for trial_i = valid_trial
        run_i = ceil(trial_i/2);
        in_path = fullfile(dir_first, sbj_list{sbj_i}, num2str(run_i));

        % set file names
        if mod(trial_i,2) == 1
            enc_file_name = sprintf('beta_%04d.nii',3);
            ret_file_name = sprintf('beta_%04d.nii',12);
            enc_fix_file_name = sprintf('beta_%04d.nii',1);
            ret_fix_file_name = sprintf('beta_%04d.nii',10);
            
            word_enc_file_name = sprintf('beta_%04d.nii',5);
            word_ret_file_name = sprintf('beta_%04d.nii',8);
            word_enc_fix_file_name = sprintf('beta_%04d.nii',4);
            word_ret_fix_file_name = sprintf('beta_%04d.nii',7);
        else
            enc_file_name = sprintf('beta_%04d.nii',24);
            ret_file_name = sprintf('beta_%04d.nii',33);
            enc_fix_file_name = sprintf('beta_%04d.nii',22);
            ret_fix_file_name = sprintf('beta_%04d.nii',31);
            
            word_enc_file_name = sprintf('beta_%04d.nii',26);
            word_ret_file_name = sprintf('beta_%04d.nii',29);
            word_enc_fix_file_name = sprintf('beta_%04d.nii',25);
            word_ret_fix_file_name = sprintf('beta_%04d.nii',28);
        end
        ctrl_enc_file_name = sprintf('beta_%04d.nii',18);
        ctrl_ret_file_name = sprintf('beta_%04d.nii',21);
        ctrl_enc_fix_file_name = sprintf('beta_%04d.nii',16);
        ctrl_ret_fix_file_name = sprintf('beta_%04d.nii',19);
        
        % load files
        temp_raw = struct();
        temp = struct();
        
        func_load_file = @(fname) double(niftiread(fullfile(in_path, fname)));
        temp_raw.enc = func_load_file(enc_file_name);
        temp_raw.ret = func_load_file(ret_file_name);
        temp_raw.enc_fix = func_load_file(enc_fix_file_name);
        temp_raw.ret_fix = func_load_file(ret_fix_file_name);
        
        temp_raw.ctrl_enc = func_load_file(ctrl_enc_file_name);
        temp_raw.ctrl_ret = func_load_file(ctrl_ret_file_name);
        temp_raw.ctrl_enc_fix = func_load_file(ctrl_enc_fix_file_name);
        temp_raw.ctrl_ret_fix = func_load_file(ctrl_ret_fix_file_name);
        
        temp_raw.word_enc = func_load_file(word_enc_file_name);
        temp_raw.word_ret = func_load_file(word_ret_file_name);
        temp_raw.word_enc_fix = func_load_file(word_enc_fix_file_name);
        temp_raw.word_ret_fix = func_load_file(word_ret_fix_file_name);

        temp_list = dir(fullfile(in_path, 'beta*'));
        temp_raw.baseline = func_load_file(sprintf('beta_%04d.nii', length(temp_list)));
        
        % contrast images
        temp.enc = temp_raw.enc - temp_raw.enc_fix;
        temp.ret = temp_raw.ret - temp_raw.ret_fix;
        
        temp.enc_ctrl = temp_raw.enc - temp_raw.ctrl_enc;
        temp.ret_ctrl = temp_raw.ret - temp_raw.ctrl_ret;
        
        temp.enc_ctrl_fix = (temp_raw.enc - temp_raw.enc_fix) - (temp_raw.ctrl_enc - temp_raw.ctrl_enc_fix);
        temp.ret_ctrl_fix = (temp_raw.ret - temp_raw.ret_fix) - (temp_raw.ctrl_ret - temp_raw.ctrl_ret_fix);
        
        temp.word_enc = temp_raw.word_enc - temp_raw.word_enc_fix;
        temp.word_ret = temp_raw.word_ret - temp_raw.word_ret_fix;
        
        % save
        beta_raw(trial_i) = temp_raw;
        beta(trial_i) = temp;
        
        temp = niftiinfo(fullfile(in_path, enc_file_name));
        temp.Datatype = 'double';
        temp.Description = '';
        hdr(trial_i) = temp;
    end
    
    glm = struct();
    glm.beta_raw = beta_raw;
    glm.beta = beta;
    glm.hdr = hdr;
    
%     save(fullfile(dir_organized, sprintf('%s.mat',sbj_list{sbj_i})), 'glm')
    func_parsave_glm(fullfile(dir_organized, sprintf('%s.mat',sbj_list{sbj_i})), glm)
    fprintf('\n%d\n',sbj_i)
end


end




%%
