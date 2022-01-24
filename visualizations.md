```python
import pandas as pd
import seaborn as sns
from scipy.stats import wasserstein_distance
sns.set_theme(style="ticks")
```

    /home/phil/.pyenv/versions/3.7.2/lib/python3.7/site-packages/pandas/compat/__init__.py:97: UserWarning: Could not import the lzma module. Your installed Python is incomplete. Attempting to use lzma compression will result in a RuntimeError.
      warnings.warn(msg)



```python
#Load CSV file in a dataframe
df = pd.read_csv('./data/satgpa.csv')
dfsynth = pd.read_csv('./synthpop/synth_data.csv')
```

# Visual inspection


```python
sns.pairplot(df, hue = "sex")
```




    <seaborn.axisgrid.PairGrid at 0x7f704546fa90>




    
![png](visualizations_files/visualizations_3_1.png)
    



```python
sns.pairplot(dfsynth, hue = "sex")
```




    <seaborn.axisgrid.PairGrid at 0x7f704074e4e0>




    
![png](visualizations_files/visualizations_4_1.png)
    



```python

print(f"Distance between sex is {wasserstein_distance(df['sex'].tolist(), dfsynth['sex'].tolist()):.3f}")
print(f"Distance between sat_v is {wasserstein_distance(df['sat_v'].tolist(), dfsynth['sat_v'].tolist()):.3f}")
print(f"Distance between sat_m is {wasserstein_distance(df['sat_m'].tolist(), dfsynth['sat_m'].tolist()):.3f}")
print(f"Distance between sat_sum is {wasserstein_distance(df['sat_sum'].tolist(), dfsynth['sat_sum'].tolist()):.3f}")
print(f"Distance between hs_gpa is {wasserstein_distance(df['hs_gpa'].tolist(), dfsynth['hs_gpa'].tolist()):.3f}")
print(f"Distance between fy_gpa is {wasserstein_distance(df['fy_gpa'].tolist(), dfsynth['fy_gpa'].tolist()):.3f}")
```

    Distance between sex is 0.010
    Distance between sat_v is 0.285
    Distance between sat_m is 0.405
    Distance between sat_sum is 0.587
    Distance between hs_gpa is 0.016
    Distance between fy_gpa is 0.019


### Comparing conditonal distributions


```python
dfc = df[df['sex'] == 1]
dfsynthc = dfsynth[dfsynth['sex'] == 1]

print(f"Distance between sex is {wasserstein_distance(dfc['sex'].tolist(), dfsynthc['sex'].tolist()):.3f}")
print(f"Distance between sat_v is {wasserstein_distance(dfc['sat_v'].tolist(), dfsynthc['sat_v'].tolist()):.3f}")
print(f"Distance between sat_m is {wasserstein_distance(dfc['sat_m'].tolist(), dfsynthc['sat_m'].tolist()):.3f}")
print(f"Distance between sat_sum is {wasserstein_distance(dfc['sat_sum'].tolist(), dfsynthc['sat_sum'].tolist()):.3f}")
print(f"Distance between hs_gpa is {wasserstein_distance(dfc['hs_gpa'].tolist(), dfsynthc['hs_gpa'].tolist()):.3f}")
print(f"Distance between fy_gpa is {wasserstein_distance(dfc['fy_gpa'].tolist(), dfsynthc['fy_gpa'].tolist()):.3f}")
```

    Distance between sex is 0.000
    Distance between sat_v is 0.288
    Distance between sat_m is 0.363
    Distance between sat_sum is 0.786
    Distance between hs_gpa is 0.014
    Distance between fy_gpa is 0.055



```python
dfc = df[df['sex'] == 2]
dfsynthc = dfsynth[dfsynth['sex'] == 2]

print(f"Distance between sex is {wasserstein_distance(dfc['sex'].tolist(), dfsynthc['sex'].tolist()):.3f}")
print(f"Distance between sat_v is {wasserstein_distance(dfc['sat_v'].tolist(), dfsynthc['sat_v'].tolist()):.3f}")
print(f"Distance between sat_m is {wasserstein_distance(dfc['sat_m'].tolist(), dfsynthc['sat_m'].tolist()):.3f}")
print(f"Distance between sat_sum is {wasserstein_distance(dfc['sat_sum'].tolist(), dfsynthc['sat_sum'].tolist()):.3f}")
print(f"Distance between hs_gpa is {wasserstein_distance(dfc['hs_gpa'].tolist(), dfsynthc['hs_gpa'].tolist()):.3f}")
print(f"Distance between fy_gpa is {wasserstein_distance(dfc['fy_gpa'].tolist(), dfsynthc['fy_gpa'].tolist()):.3f}")
```

    Distance between sex is 0.000
    Distance between sat_v is 0.375
    Distance between sat_m is 0.486
    Distance between sat_sum is 0.641
    Distance between hs_gpa is 0.036
    Distance between fy_gpa is 0.043


## Are there any entries that are the same in both datasets?


```python

```
