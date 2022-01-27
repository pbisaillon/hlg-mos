# install.packages("synthpop")
# install.packages("combinat")
# install.packages("emdist")

library(dplyr)
library(synthpop)
library(parallel)
library(combinat)
library(emdist)

################### Basic usage ########################
# Read dataset, cast sex to factor
df <- read.csv("./data/satgpa.csv") %>%
  mutate(sex = as.factor(sex)) %>%
  # select(-sat_sum)
  select(sex, hs_gpa, fy_gpa, sat_sum, sat_v, sat_m)

# Synthesize
syn <- syn(df)

###################### Grid search #####################
# Get all permutations of 1:6, for the columns
permutations <- do.call(rbind.data.frame, permn(1:6))
names(permutations) <- paste0("s", 1:6)

# All known methods
methods <- data.frame(method = c("sample", "normrank", "ctree", "cart",))

hyperparams <- merge(permutations, methods, all = TRUE)

# Parallel
results <- mclapply(seq_len(nrow(hyperparams)),
                    function(i) {
                      row <- params[i,]
                      scores <- sapply(1:5, function(x) {
                        syn_df <- df %>%
                          mutate_all(as.numeric) %>%
                          syn(method = row$method,
                              visit.sequence = c(row$s1, row$s2, row$s3, row$s4, row$s5, row$s6))
                        
                        emd(as.matrix(df), as.matrix(syn_df$syn), dist = "euclidean")
                        
                        # cor_df <- df %>%
                        #   mutate_all(as.numeric) %>%
                        #   cor()
                        # cor_syn <- syn_df$syn %>%
                        #   mutate_all(as.numeric) %>%
                        #   cor()
                        # cor_diff <- cor_df - cor_syn
                        # cor_SE <- cor_diff ** 2 %>% sum()
                        # cor_SE
                      }
                      )
                      mean(scores)
                    })

# Join results
params$results <- as.numeric(results)