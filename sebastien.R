# install.packages("synthpop")
# install.packages("combinat")

library(dplyr)
library(synthpop)
library(parallel)

################### Basic usage ########################
# Read dataset, cast sex to factor
df <- read.csv("./data/satgpa.csv") %>%
  mutate(sex = as.factor(sex)) %>%
  # select(-sat_sum)
  select(sex, hs_gpa, fy_gpa, sat_sum, sat_v, sat_m)

# Synthesize
syn_df <- syn(df)

# Summary
summary(syn_df)

# Diagnostics
utility.gen(syn_df, df)
utility.tables(syn_df, df)
multi.compare(syn_df, df, var = "sat_v", by = "sex")
multi.compare(syn_df, df, var = "sat_m", by = "sex")
multi.compare(syn_df, df, var = "hs_gpa", by = "sex")
multi.compare(syn_df, df, var = "fy_gpa", by = "sex")
multi.compare(syn_df,
              df,
              var = "sat_m",
              by = "sex",
              cont.type = "boxplot")

# Test whether any obs was replicated
replicated.uniques(syn_df, df)

# Look at correlations
cor_df <- df %>%
  mutate_all(as.numeric) %>%
  cor()

cor_syn <- syn_df$syn %>%
  mutate_all(as.numeric) %>%
  cor()

cor_diff <- cor_df - cor_syn
cor_SE <- cor_diff ** 2 %>% sum()

###################### Grid search #####################
# Get all permutations of 1:6, for the columns
permutations <- do.call(rbind.data.frame, permn(1:6))
names(permutations) <- paste0("s", 1:6)

# All known methods
methods <- data.frame(method = c("sample", "normrank", "ctree"))

params <- merge(permutations, methods, all = TRUE)

# Run different methods on the dataset
results <- lapply(seq_len(nrow(params)),
                  function(i) {
                    row <- params[i,]
                    SEs <- sapply(1:5, function(x) {
                      syn_df <- df %>%
                        mutate_all(as.numeric) %>%
                        syn(method = row$method,
                            visit.sequence = c(row$s1, row$s2, row$s3, row$s4, row$s5, row$s6))
                      
                      cor_df <- df %>%
                        mutate_all(as.numeric) %>%
                        cor()
                      cor_syn <- syn_df$syn %>%
                        mutate_all(as.numeric) %>%
                        cor()
                      cor_diff <- cor_df - cor_syn
                      cor_SE <- cor_diff ** 2 %>% sum()
                      cor_SE
                    }
                    )
                    mean(SEs)
                  })

# Parallel
# results <- mclapply(seq_len(nrow(params)),
#                   function(i) {
#                     row <- params[i,]
#                     SEs <- sapply(1:5, function(x) {
#                       syn_df <- df %>%
#                         mutate_all(as.numeric) %>%
#                         syn(method = row$method,
#                             visit.sequence = c(row$s1, row$s2, row$s3, row$s4, row$s5, row$s6))
#                       
#                       cor_df <- df %>%
#                         mutate_all(as.numeric) %>%
#                         cor()
#                       cor_syn <- syn_df$syn %>%
#                         mutate_all(as.numeric) %>%
#                         cor()
#                       cor_diff <- cor_df - cor_syn
#                       cor_SE <- cor_diff ** 2 %>% sum()
#                       cor_SE
#                     }
#                     )
#                     mean(SEs)
#                   })

# Join results
params$results <- as.numeric(results)