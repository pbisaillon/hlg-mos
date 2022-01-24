# hlg-mos

## Data

The data set contains 1000 observations. The 6 variables are

* sex: Gender of the student.
* sat_v: Verbal SAT percentile.
* sat_m: Math SAT percentile.
* sat_sum: Total of verbal and math SAT percentiles.
* hs_gpa: High school grade point average.
* fy_gpa: First year (college) grade point average.

## Synthetic dataset

The folder synthpop contains the code to generate a synthetic dataset using the presets of `synthpop`. The variable `sex` is treated as a factor. The generated synthetic dataset is saved to `synth_data.csv`. The jupyter-lab notebook `visualizations.ipynb` contains various measure of the statistical differences between the two datasets.