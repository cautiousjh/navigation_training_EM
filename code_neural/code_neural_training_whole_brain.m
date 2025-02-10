
%% set behavioral variables

behav_metric = {func_get_residual(spatial_metric_sess_wise{1},spatial_metric_training)};
behav_metric_name_list = {'training_spatial_cov'};
behav_flag = group==1;

% functions
aux_func_get_residual = @(mdl) mdl.Residuals.Raw;
func_get_residual = @(x,y) aux_func_get_residual(fitlm(x(:),y(:)));
func_get_residual_analytic = @(cov,data) data - [ones(size(data,1),1), cov] * ([ones(size(data,1),1), cov]\data);

%% parameters
dir_organized_pre = '../data_neural/em_retrieval_beta_smooth_pre';
dir_organized_post = '../data_neural/em_retrieval_beta_smooth_post';
dir_organized_change = '../data_neural/em_retrieval_beta_smooth_change';

dir_out_base = '../out';

%% direct correlation 

% get beta & regress-out
file_list = arrayfun(@(x) fullfile(dir_organized_change, sprintf('%d.nii', x)), find(behav_flag), 'uni', 0);
valid_flag_neural = cellfun(@(x) exist(x,'file'), file_list) ~=0;
file_list = file_list(valid_flag_neural);
beta_list = cellfun(@(x) niftiread(x), file_list, 'uni',0);

beta = cat(4,beta_list{:});
beta_flat = reshape(beta, prod(size(beta,1:3)), size(beta,4));
hdr = niftiinfo(file_list{1});
hdr.Datatype = 'double';

file_list_sess1 = arrayfun(@(x) fullfile(dir_organized_pre, sprintf('%d.nii', x)), find(behav_flag), 'uni', 0);
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


% for each behavior
for behav_i = 1:length(behav_metric_name_list)

    % set directory
    dir_name_behav = behav_metric_name_list{behav_i};

    dir_out = fullfile(dir_out_base, dir_name_behav);
    if ~exist(dir_out,'dir')
        mkdir(dir_out)
    end

    % get behavioral
    behav = behav_metric{behav_i};
    behav_name = behav_metric_name_list{behav_i};
    behav = behav(behav_flag);
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
        temp_fid = fopen(fullfile(dir_out, '_file_list.txt'),'w'); 
        temp_list = cellfun(@(x) fullfile(x), file_list(flag), 'uni', 0); 
        for i = 1:length(temp_list); fprintf(temp_fid, '%s\n', temp_list{i}); end
        fclose(temp_fid);
        
        temp_fid = fopen(fullfile(dir_out, '_behav.txt'),'w'); 
        temp_list = behav(flag);
        for i = 1:length(temp_list); fprintf(temp_fid, '%f\n', temp_list(i)); end
        fclose(temp_fid);
        

        niftiwrite(r, fullfile(dir_out, '_r_raw'), hdr,'compressed',true)
        niftiwrite(-log10(p), fullfile(dir_out, '_p_raw'), hdr,'compressed',true)

        temp = -log10(p); temp(r<0) = -temp(r<0); 
        niftiwrite(temp, fullfile(dir_out, '_p_raw_signed'), hdr,'compressed',true)

        temp = r; temp(p>=0.05) = 0; niftiwrite(temp, fullfile(dir_out, '_r_cutoff_0_05'), hdr,'compressed',true)
        temp = r; temp(p>=0.01) = 0; niftiwrite(temp, fullfile(dir_out, '_r_cutoff_0_01'), hdr,'compressed',true)
        temp = r; temp(p>=0.1) = 0; niftiwrite(temp, fullfile(dir_out, '_r_cutoff_0_1'), hdr,'compressed',true)
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

end





%%
