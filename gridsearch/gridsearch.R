# install.packages(c("synthpop", "combinat", "emdist", "tidyverse"))

library(dplyr)
library(synthpop)
library(parallel)
library(combinat)
library(emdist)
library(pbmcapply)

################### Basic usage ########################
# Read dataset, cast sex to factor
df <- read.csv("./data/satgpa.csv") %>%
  mutate(sex = as.factor(sex)) %>%
  # select(-sat_sum)
  select(sex, hs_gpa, fy_gpa, sat_sum, sat_v, sat_m)

# Synthesize
syn <- syn(df)

replicated.uniques(syn, df)$no.replications

###################### Grid search #####################
# Get all permutations of 1:6, for the columns
permutations <- do.call(rbind.data.frame, permn(1:6))
names(permutations) <- paste0("s", 1:6)

# All known methods
methods <- data.frame(method = c("cart"))

hyperparams <- merge(permutations, methods, all = TRUE)

# Repeat
hyperparams <- hyperparams[rep(seq_len(nrow(hyperparams)), each = 3), ]

# Shuffle
hyperparams <- hyperparams[sample(nrow(hyperparams)),]

# Parallel
results <- pbmclapply(seq_len(nrow(hyperparams)),
                    function(i) {
                      row <- hyperparams[i,]
                      syn_df <- df %>%
                        mutate_all(as.numeric) %>%
                        syn(method = row$method,
                            visit.sequence = c(row$s1, row$s2, row$s3, row$s4, row$s5, row$s6))
                      list(
                        emd(as.matrix(df), as.matrix(syn_df$syn), dist = "euclidean"),
                        replicated.uniques(syn_df, df)$no.replications
                      )},
                    mc.cores = 4)

em <- sapply(results, function(x) x[[1]])
matches <- sapply(results, function(x) x[[2]])

# Join results
sequence_results <- hyperparams
sequence_results$em <- em
sequence_results$matches <- matches

# Save
write.csv(sequence_results, "./visit_sequences.csv", row.names = FALSE)

# Have a quick look at the top scores
top_scores <- sequence_results %>%
  select(-matches, -method) %>%
  group_by(s1, s2, s3, s4, s5, s6) %>%
  summarise(mean_em = mean(em)) %>%
  ungroup() %>%
  arrange(mean_em) %>%
  head()

###################### Grid search #####################
# Get all permutations of 1:6, for the columns
sequence <- c(4, 5, 2, 6, 1, 3)

# All known methods
# Don't work: bagging, survctree, lognorm, sqrtnorm, cubertnorm, logreg, polyreg, polr, pmm, passive, nested, satcat
methods <- c("ctree", "cart", "rf", "ranger", "norm", "normrank", "sample")

# Repeat
methods <- rep(methods, 10)

# Shuffle
methods <- methods[sample(length(methods))]

# Parallel
results <- pbmclapply(methods,
                      function(method) {
                        print(method)
                        syn_df <- df %>%
                          mutate_all(as.numeric) %>%
                          syn(method = method,
                              visit.sequence = sequence,
                              minnumlevels = 2)
                        list(
                          em = emd(as.matrix(df), as.matrix(syn_df$syn), dist = "euclidean"),
                          matches = replicated.uniques(syn_df, df)$no.replications
                        )},
                      mc.cores = 2)

em <- sapply(results, function(x) x[["em"]])
matches <- sapply(results, function(x) x[["matches"]])

# Join results
method_results <- data.frame(
  method = methods,
  em = em,
  matches = matches
)

# Save
write.csv(method_results, "./methods.csv", row.names = FALSE)

# Have a quick look at the top scores
top_scores <- method_results %>%
  group_by(method) %>%
  summarise(mean_em = mean(em), mean_matches = mean(matches)) %>%
  ungroup() %>%
  arrange(mean_em)