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
syn <- syn(df)


###################### Partial matches #################

# Setup
num_cols <- length(df)
columns_names <- names(df)

base_df <- df
base_df$index <- seq_len(nrow(df))

syn_df <- syn$syn
syn_df$syn_index <- seq_len(nrow(syn_df))

levels_at_match <- data.frame(
  index=integer(),
  syn_index=integer(),
  match_level=integer()
)

for (x in 6:1) {
  # Find all combinations of columns of x length
  combos <- combn(columns_names, x, simplify = FALSE)
  # For each combination, find all inner joins
  matches <- lapply(combos,
                      function(combo) {
                        m <- merge(base_df, syn_df, by = combo)
                        if (nrow(m) == 0) return(NULL)
                        m <- m[, c("index", "syn_index")]
                        m$match_level <- x
                        m
                      }
  )
  # Combine the successful inner joins
  matches <- unique(do.call(rbind, matches))
  # Append them to the tracking dataset
  levels_at_match <- rbind(levels_at_match, matches)
  # Remove the indexes that were matched, to make future inner joins faster
  base_df <- base_df[!base_df$index %in% matches$index, ]
}

# Prepare data for graphing
uniques <- unique(levels_at_match[, c("index", "match_level")])
cummulative_counts <- list()
for (x in 6:1) {
  cummulative_counts[x] <- nrow(unique(uniques[uniques$match_level >= x, ]))
}

cummulative_counts <- data.frame(match_level = 1:6, n = unlist(cummulative_counts))
# Rebase as percentages
cummulative_counts$n <- 100 * cummulative_counts$n / nrow(df)
cummulative_counts$perc <- paste0(cummulative_counts$n, "%")

fig <- plot_ly(
  x = cummulative_counts$match_level,
  y = cummulative_counts$n,
  text = cummulative_counts$perc,
  type = "bar") %>%
  layout(title = "Partial matches of original data (SAT)",
         xaxis = list(title = "Columns to match"),
         yaxis = list(title = "Percentage of rows matched"))

fig




##################### Standard tests ####################

# Summary
summary(syn)

# Diagnostics
utility.gen(syn, df)
utility.tables(syn, df)
multi.compare(syn, df, var = "sat_v", by = "sex")
multi.compare(syn, df, var = "sat_m", by = "sex")
multi.compare(syn, df, var = "hs_gpa", by = "sex")
multi.compare(syn, df, var = "fy_gpa", by = "sex")
multi.compare(syn,
              df,
              var = "sat_m",
              by = "sex",
              cont.type = "boxplot")

# Test whether any obs was replicated
replicated.uniques(syn, df)

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