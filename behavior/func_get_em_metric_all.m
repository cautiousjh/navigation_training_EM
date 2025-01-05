
function [metric, metric_indiv_all] = func_get_em_metric_all(data_all, sess_i, pos, elim_trials)
%% parameters
if nargin == 2
    pos = [1,2,3,4,5];
    elim_trials = [];
elseif nargin == 3
    elim_trials = [];
end

%% accuracy metrics for every individuals

metric_indiv_all = {};
for sbj_i = 1:length(data_all)
    sbj = data_all{sbj_i}.em.sess(sess_i);

    metric = struct();
    trial_idx = 0;
    for trial_i = 1:length(sbj.trials)
        if ~ismember(trial_i, sbj.valid_trial) || ismember(trial_i, elim_trials)
            continue
        end
        trial = sbj.trials(trial_i);
        trial_idx = trial_idx + 1;

        % full EM
        metric.full.and(trial_idx) = mean( trial.correct.obj_space_time(pos) );
        metric.full.sum(trial_idx) = mean( [trial.correct.obj_time(pos), trial.correct.space_time(pos)] );
        metric.full.or(trial_idx) = mean( trial.correct.obj_time(pos) | trial.correct.space_time(pos) );
        metric.full.tri(trial_idx) = mean( [trial.correct.obj_time(pos), trial.correct.space_time(pos), trial.correct.obj_space(pos)] );
        metric.full.recog(trial_idx) = mean( [trial.correct.obj(pos), trial.correct.space(pos)] );
                
        % what-related
        metric.what.recog(trial_idx) = mean( trial.correct.obj(pos) );
        metric.what.when(trial_idx) = mean( trial.correct.obj_time(pos) );

        % where-related
        metric.where.recog(trial_idx) = mean( trial.correct.space(pos) );
        metric.where.when(trial_idx) = mean( trial.correct.space_time(pos) );

        temp = correct_where(~correct_both) - correct_what(~correct_both);
        if isempty(temp); temp = nan; else; temp = mean(temp); end
        metric.where_bias(trial_idx) = temp;

        % confidence
        temp_conf = trial.conf_obj(pos); temp_correct = trial.correct.obj_time(pos)==1;
        temp_conf_what = temp_conf; temp_correct_what = temp_correct;
        metric.conf.what.overall(trial_idx) = mean(temp_conf);
        metric.conf.what.correct(trial_idx) = mean(temp_conf(temp_correct));
        metric.conf.what.incorrect(trial_idx) = mean(temp_conf(~temp_correct));
        metric.conf.what.n_correct(trial_idx) = sum(temp_correct);
        metric.conf.what.n_incorrect(trial_idx) = sum(~temp_correct);

    end

    metric_indiv_all{sbj_i} = metric;

end

%% combined metric

metric = struct();

% accuracies
metric.full.and = cellfun(@(x) nanmean(x.full.and), metric_indiv_all);
metric.full.sum = cellfun(@(x) nanmean(x.full.sum), metric_indiv_all);
metric.full.or = cellfun(@(x) nanmean(x.full.or), metric_indiv_all);
metric.full.tri = cellfun(@(x) nanmean(x.full.tri), metric_indiv_all);
metric.full.recog = cellfun(@(x) nanmean(x.full.recog), metric_indiv_all);

metric.what.recog = cellfun(@(x) nanmean(x.what.recog), metric_indiv_all);
metric.what.when = cellfun(@(x) nanmean(x.what.when), metric_indiv_all);

metric.where.recog = cellfun(@(x) nanmean(x.where.recog), metric_indiv_all);
metric.where.when = cellfun(@(x) nanmean(x.where.when), metric_indiv_all);

% other measures
metric.what_where = cellfun(@(x) nanmean(x.what_where), metric_indiv_all);
metric.n_incorrect = cellfun(@(x) sum(x.n_incorrect), metric_indiv_all);
metric.where_bias.point = cellfun(@(x) nansum(x.where_bias .* x.n_incorrect) / sum(x.n_incorrect), metric_indiv_all);

% confidence
metric.conf.where.overall = cellfun(@(x) nanmean(x.conf.where.overall), metric_indiv_all);
metric.conf.where.correct = cellfun(@(x) nansum(x.conf.where.correct.* x.conf.where.n_correct) / nansum(x.conf.where.n_correct), metric_indiv_all);
metric.conf.where.incorrect = cellfun(@(x) nansum(x.conf.where.incorrect.* x.conf.where.n_incorrect) / nansum(x.conf.where.n_incorrect), metric_indiv_all);
metric.conf.where.diff = metric.conf.where.correct - metric.conf.where.incorrect;
metric.conf.where.n_correct = cellfun(@(x) nansum(x.conf.where.n_correct), metric_indiv_all);
metric.conf.where.n_incorrect = cellfun(@(x) nansum(x.conf.where.n_incorrect), metric_indiv_all);


%%

