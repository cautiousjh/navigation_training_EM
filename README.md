# Navigation training enhances episodic memory retrieval

#### Software requirements: MATLAB 2022a or higher

---

## Behavioral Analysis
The folders `code_behavior` and `data_behavior` contain codes and datasets which can reproduce the results.

- First, run `code0_load_data.m` to calculate behavioral metrics.
- Run `code1_spatial_training.m` to generate figures related to navigation training effects.
- Run `code2_em_training.m` to generate figures related to episodic memory training effects.


## Neural Analysis
The folders `code_neural` and `data_neural` contain codes and datasets for neural analysis. 
The full data and code are not included here.

### Code Description

Run these after completing the behavioral analysis.

- Run `code_neural_training_whole_brain.m` to generate whole-brain correlations between behavioral and neural enhancements. Codes for ANOVA are omitted here.
- Run `code_neural_training_roi.m` to generate ROI-level correlations between behavioral and neural enhancements.

- `for_ref_process_neural_roi.m` and corresponding function files are codes for processing whole-brain beta into ROI-level data, but segmentation data is omitted in this repository. Instead, processed data is provided in the same folder.


### Data Description
- `em_retrieval_beta_smooth_pre` contains beta estimates during the retrieval phase of the episodic memory task in the pre-training session.
- `em_retrieval_beta_smooth_post` contains beta estimates during the retrieval phase of the episodic memory task in the post-training session.
- `em_retrieval_beta_smooth_change` contains changes in beta estimates between the two sessions.
- `em_pattern_reinstate_change` contains changes in pattern reinstatement between the two sessions.


---
#### Additional code or data will be provided upon request to the corresponding author.
