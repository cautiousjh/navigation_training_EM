# Navigation training enhances episodic memory retrieval

#### Software requirements: MATLAB 2022a or higher

---

## Behavioral Analysis
The folders `code_behavior` and `data_behavior` contain codes and datasets which can reproduce the results.

1) First, run `code0_load_data.m` to calculate behavioral metrics.
2) Run `code1_spatial_training.m` to generate figures related to navigation training effects.
3) Run `code2_em_training.m` to generate figures related to episodic memory training effects.


## Neural Analysis
The folders `code_neural` and `data_neural` contain codes and datasets for neural analysis. 
The full data and code are not included here, but the full logic is provided in the codes.

### Code Description

Run these after completing the behavioral analysis:

1) Run `code_whole_training_correlations.m` to generate whole-brain correlations between behavioral and neural enhancements.
2) Run `code_roi_training_correlations.m` to analyze ROI-level correlations between behavioral and neural enhancements.

- `code_roi_process.m` processes whole-brain beta into ROI-level data, but segmentation data is omitted in this repository.\
Instead, processed data is provided in the same folder.


### Data Description
- `em_retrieval_beta_pre` contains beta estimates during the retrieval phase of the episodic memory task in the pre-training session.
- `em_retrieval_beta_post` contains beta estimates during the retrieval phase of the episodic memory task in the post-training session.
- `em_retrieval_beta_change` contains changes in beta estimates between the two sessions.
- `em_pattern_reinstate_change` contains changes in pattern reinstatement between the two sessions.


---
#### Additional code or data will be provided upon request to the corresponding author.
