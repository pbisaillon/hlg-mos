# install.packages("synthpop")

library(dplyr)
library(synthpop)

# Read dataset, cast sex to factor
df <- read.csv("./data/satgpa.csv") %>%
  mutate(sex = as.factor(sex)) %>%
  select(-sat_sum)

# Synthesize
syn_df <- syn(df)

# Diagnostics
utility.gen(syn_df, df)
utility.tables(syn_df, df)
multi.compare(syn_df, df, var = "sat_v", by = "sex")
multi.compare(syn_df, df, var = "sat_m", by = "sex")
multi.compare(syn_df, df, var = "hs_gpa", by = "sex")
multi.compare(syn_df, df, var = "fy_gpa", by = "sex")
multi.compare(syn_df, df, var = "sat_m", by="sex", cont.type = "boxplot")