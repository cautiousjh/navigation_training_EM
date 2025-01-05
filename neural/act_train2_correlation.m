
%% set behavioral variables

%%%%%%%%%%%%%% REFER code_em_behavior/code5_metrics_correlation

% session 1
behav_metric_sess1 = [sess1_behav_em_list, sess1_behav_spatial_list];
behav_metric_sess1_name_list = [sess1_behav_em_name_list,sess1_behav_spatial_name_list];

% training
data = [training_behav_em_list, training_behav_spatial_list];
label = [training_behav_em_name_list, training_behav_spatial_name_list];

behav_metric_training_exp = cellfun(@(x) x(group==1), data, 'uni', 0);
behav_metric_training_ctrl = cellfun(@(x) x(group==0), data, 'uni', 0);
behav_metric_training_exp_name_list = cellfun(@(x) ['exp_',x], label, 'uni', 0);
behav_metric_training_ctrl_name_list = cellfun(@(x) ['ctrl_',x], label, 'uni', 0);

% training, session 1 regressed out
aux_func_get_residual = @(mdl) mdl.Residuals.Raw;
func_get_residual = @(x,y) aux_func_get_residual(fitlm(x(:),y(:)));

data = [training_behav_em_list, training_behav_spatial_list];
data_cov = [training_cov_behav_em_list, training_cov_behav_spatial_list];
label = [training_behav_em_name_list, training_behav_spatial_name_list];

behav_metric_training_cov_exp  = cellfun(@(x,y) func_get_residual(x(group==1),y(group==1)), data_cov, data, 'uni',0);
behav_metric_training_cov_ctrl  = cellfun(@(x,y) func_get_residual(x(group==0),y(group==0)), data_cov, data, 'uni',0);

behav_metric_training_cov_exp_name_list = cellfun(@(x) ['exp_cov_',x], label, 'uni', 0);
behav_metric_training_cov_ctrl_name_list = cellfun(@(x) ['ctrl_cov_',x], label, 'uni', 0);

full_list = { {behav_metric_training_exp, behav_metric_training_exp_name_list, group == 1}, ...
              {behav_metric_training_ctrl, behav_metric_training_ctrl_name_list, group == 0}, ...
              {behav_metric_training_cov_exp, behav_metric_training_cov_exp_name_list, group == 1}, ...
              {behav_metric_training_cov_ctrl, behav_metric_training_cov_ctrl_name_list, group == 0}, ...
              };
% functions
aux_func_get_residual = @(mdl) mdl.Residuals.Raw;
func_get_residual = @(x,y) aux_func_get_residual(fitlm(x(:),y(:)));
func_get_residual_analytic = @(cov,data) data - [ones(size(data,1),1), cov] * ([ones(size(data,1),1), cov]\data);

%% parameters 

opt_list = { [1 1] [1 2] };
opt_list = { [1 1] };


for opt_i = 1:length(opt_list)
    opt_img = opt_list{opt_i}(1);
    opt_fieldmap = opt_list{opt_i}(2);


%%
sbj_list = split(num2str(1:33));

%
dir_working = pwd();
dir_sbj = '../data/data_processed_sbj';


%
con_name_list = {'enc_raw', 'ret_raw', 'enc_fix', 'ret_fix','enc_ctrl','ret_ctrl','enc_ctrl_fix','ret_ctrl_fix'};

flag_name_list = {'all','moderate','correct'};
dir_second_list = {'glm_act_all','glm_act_moderate', 'glm_act_correct'};

%
if opt_img == 1
    dir_glm = 'glm_em_norm_smooth_training';
    dir_glm1 = sprintf('glm_em_norm_smooth_sess%d',1);
    dir_glm2 = sprintf('glm_em_norm_smooth_sess%d',2);
elseif opt_img == 2
    dir_glm = 'glm_em_norm_rough_training';
    dir_glm1 = sprintf('glm_em_norm_rough_sess%d',1);
    dir_glm2 = sprintf('glm_em_norm_rough_sess%d',2);
end

%
if opt_fieldmap == 1
    dir_result = 'results';
elseif opt_fieldmap == 2
    dir_result = 'results_unwrapped';
end


dir_second_list_sess1 = cellfun(@(x) sprintf('../%s/%s/%s',dir_result,dir_glm1,x), dir_second_list, 'uni', 0);
dir_second_list = cellfun(@(x) sprintf('../%s/%s/%s',dir_result,dir_glm,x), dir_second_list, 'uni', 0);

dir_name_collect = '_organized';
dir_name_collect_neg = '_organized_neg';
dir_name_correlation = '_correlation';

cd(dir_working);



%% cleanup

for flag_i = 1:length(flag_name_list)
    dir_out = fullfile(dir_second_list{flag_i}, dir_name_correlation);
    if exist(dir_out,'dir')
        rmdir(dir_out, 's')
    end
end


%% direct correlation 

% run
setting_list = combvec(1:length(full_list), 1:length(flag_name_list), 1:length(con_name_list));

parfor setting_i = 1:size(setting_list,2)
    cd(dir_working);
    list_i = setting_list(1,setting_i);
    flag_i = setting_list(2,setting_i);
    con_i = setting_list(3,setting_i);

    behav_metric = full_list{list_i}{1};
    behav_metric_name_list = full_list{list_i}{2};
    behav_flag = full_list{list_i}{3};
    
    dir_out = [];

    if list_i==1 || list_i==2
        dir_organized = fullfile(dir_second_list{flag_i},dir_name_collect, con_name_list{con_i});
    
        file_list = arrayfun(@(x) fullfile(dir_organized, sprintf('%d.nii', x)), find(behav_flag), 'uni', 0);
        valid_flag_neural = cellfun(@(x) exist(x,'file'), file_list) ~=0;
        file_list = file_list(valid_flag_neural);
        beta_list = cellfun(@(x) niftiread(x), file_list, 'uni',0);

        beta = cat(4,beta_list{:});
        beta_flat = reshape(beta, prod(size(beta,1:3)), size(beta,4));

    elseif list_i == 3 || list_i == 4
        if list_i == 3
            dir_name_collect_cov = '_organized_cov_exp';
        elseif list_i == 4
            dir_name_collect_cov = '_organized_cov_ctrl';
        end
        
        dir_organized = fullfile(dir_second_list{flag_i},dir_name_collect, con_name_list{con_i});    
        file_list = arrayfun(@(x) fullfile(dir_organized, sprintf('%d.nii', x)), find(behav_flag), 'uni', 0);
        valid_flag_neural = cellfun(@(x) exist(x,'file'), file_list) ~=0;
        file_list = file_list(valid_flag_neural);
        beta_list = cellfun(@(x) niftiread(x), file_list, 'uni',0);

        beta = cat(4,beta_list{:});
        beta_flat = reshape(beta, prod(size(beta,1:3)), size(beta,4));
        hdr = niftiinfo(file_list{1});
        hdr.Datatype = 'double';

        dir_organized_cov = fullfile(dir_second_list{flag_i}, dir_name_correlation, con_name_list{con_i}, dir_name_collect_cov);
        file_list_out = arrayfun(@(x) fullfile(dir_organized_cov, sprintf('%d.nii', x)), find(behav_flag), 'uni', 0);
        file_list_out = file_list_out(valid_flag_neural);

        if ~exist(dir_organized_cov,'dir')
            mkdir(dir_organized_cov);

            dir_organized_sess1 = fullfile(dir_second_list_sess1{flag_i},dir_name_collect, con_name_list{con_i});
            file_list_sess1 = arrayfun(@(x) fullfile(dir_organized_sess1, sprintf('%d.nii', x)), find(behav_flag), 'uni', 0);
            file_list_sess1 = file_list_sess1(valid_flag_neural);
            beta_list_sess1 = cellfun(@(x) niftiread(x), file_list_sess1, 'uni',0);
    
            beta_sess1 = cat(4,beta_list_sess1{:});
            beta_flat_sess1 = reshape(beta_sess1, prod(size(beta_sess1,1:3)), size(beta_sess1,4));
            
            beta_cov = {};
            for i = 1:length(beta_flat)
                x = beta_flat_sess1(i,:)';
                y = beta_flat(i,:)';
                flag = ~isnan(x) & ~isnan(y);
                nan_template = nan(length(x),1);
                if sum(flag) == 0
                    beta_cov{i} = nan_template;
                else
                    temp = nan_template;
                    temp(flag) = func_get_residual_analytic(x(flag), y(flag));
                    beta_cov{i} = temp;
                end
            end
            beta_flat = cell2mat(beta_cov)';
            beta = reshape(beta_flat, size(beta));

            for sbj_i = 1:size(beta,4)
                niftiwrite(beta(:,:,:,sbj_i), file_list_out{sbj_i}, hdr);
            end

            file_list = file_list_out;

        else
            file_list = file_list_out;
            beta_list = cellfun(@(x) niftiread(x), file_list, 'uni',0);    
            beta = cat(4,beta_list{:});
            beta_flat = reshape(beta, prod(size(beta,1:3)), size(beta,4));

        end

    end

    % for each behavior
    for behav_i = 1:length(behav_metric_name_list)

        try
            % set directory
            dir_name_behav = behav_metric_name_list{behav_i};

            dir_out = fullfile(dir_second_list{flag_i}, dir_name_correlation, con_name_list{con_i}, dir_name_behav);
            if ~exist(dir_out,'dir')
                mkdir(dir_out)
            end

            % get behavioral
            behav = behav_metric{behav_i};
            behav_name = behav_metric_name_list{behav_i};
            behav(~valid_flag_neural) = [];
            behav = behav(:);

            flag = ~isnan(behav);

            % run
            temp = fopen(fullfile(dir_out, sprintf('__n = %d',sum(flag))),'w'); fclose(temp);

            if sum(flag) >= 7
                % correlation 
                [r,p] = corr(beta_flat(:,flag)', behav(flag));
                r = reshape(r, size(beta,1:3));
                p = reshape(p, size(beta,1:3));
                hdr = niftiinfo(file_list{1});
                hdr.Datatype = 'double';

                % save
                temp_fid = fopen(fullfile(dir_working, dir_out, '_file_list.txt'),'w'); 
                temp_list = cellfun(@(x) fullfile(dir_working, x), file_list(flag), 'uni', 0); 
                for i = 1:length(temp_list); fprintf(temp_fid, '%s\n', temp_list{i}); end
                fclose(temp_fid);
                
                temp_fid = fopen(fullfile(dir_working, dir_out, '_behav.txt'),'w'); 
                temp_list = behav(flag);
                for i = 1:length(temp_list); fprintf(temp_fid, '%f\n', temp_list(i)); end
                fclose(temp_fid);
                

                niftiwrite(r, fullfile(dir_out, '_r_raw'), hdr,'compressed',true)
                niftiwrite(-log10(p), fullfile(dir_out, '_p_raw'), hdr,'compressed',true)

                temp = -log10(p); temp(r<0) = -temp(r<0); 
                niftiwrite(temp, fullfile(dir_out, '_p_raw_signed'), hdr,'compressed',true)

                temp = r; temp(p<0.05) = 0; niftiwrite(temp, fullfile(dir_out, '_r_cutoff_0_05'), hdr,'compressed',true)
                temp = r; temp(p<0.01) = 0; niftiwrite(temp, fullfile(dir_out, '_r_cutoff_0_01'), hdr,'compressed',true)
                temp = r; temp(p<0.1) = 0; niftiwrite(temp, fullfile(dir_out, '_r_cutoff_0_1'), hdr,'compressed',true)
                temp = r; temp(p>=0.05 | r<0) = 0; niftiwrite(temp, fullfile(dir_out, '_r_cutoff_0_05_pos'), hdr,'compressed',true)
                temp = r; temp(p>=0.01 | r<0) = 0; niftiwrite(temp, fullfile(dir_out, '_r_cutoff_0_01_pos'), hdr,'compressed',true)
                temp = r; temp(p>=0.1 | r<0) = 0; niftiwrite(temp, fullfile(dir_out, '_r_cutoff_0_1_pos'), hdr,'compressed',true)
                temp = r; temp(p>=0.05 | r>0) = 0; niftiwrite(temp, fullfile(dir_out, '_r_cutoff_0_05_neg'), hdr,'compressed',true)
                temp = r; temp(p>=0.01 | r>0) = 0; niftiwrite(temp, fullfile(dir_out, '_r_cutoff_0_01_neg'), hdr,'compressed',true)
                temp = r; temp(p>=0.1 | r>0) = 0; niftiwrite(temp, fullfile(dir_out, '_r_cutoff_0_1_neg'), hdr,'compressed',true)

            else
                niftiwrite(nan, fullfile(dir_out, '_r_raw'), 'compressed',true)
                niftiwrite(nan, fullfile(dir_out, '_p_raw'), 'compressed',true)
                niftiwrite(nan, fullfile(dir_out, '_p_raw_signed'), 'compressed',true)
                niftiwrite(nan, fullfile(dir_out, '_r_cutoff_0_05'), 'compressed',true)
                niftiwrite(nan, fullfile(dir_out, '_r_cutoff_0_01'), 'compressed',true)
                niftiwrite(nan, fullfile(dir_out, '_r_cutoff_0_1'), 'compressed',true)
                niftiwrite(nan, fullfile(dir_out, '_r_cutoff_0_05_pos'), 'compressed',true)
                niftiwrite(nan, fullfile(dir_out, '_r_cutoff_0_01_pos'), 'compressed',true)
                niftiwrite(nan, fullfile(dir_out, '_r_cutoff_0_1_pos'), 'compressed',true)
                niftiwrite(nan, fullfile(dir_out, '_r_cutoff_0_05_neg'), 'compressed',true)
                niftiwrite(nan, fullfile(dir_out, '_r_cutoff_0_01_neg'), 'compressed',true)
                niftiwrite(nan, fullfile(dir_out, '_r_cutoff_0_1_neg'), 'compressed',true)
            end

            
        catch
            try
            catch
%                 rmdir(dir_out);
            end
        end
    end

    disp(setting_i)

end



%%
end
