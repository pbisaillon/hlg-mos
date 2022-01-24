library("synthpop")
#Looking original data
data <- read.csv(file = '../data/satgpa.csv')

#Chaning sex to factor



#default parameters
# minnumlevels = 3 indicates that a numeric variable should exceed to be treated as numeric
# this ensures that sex is not treated as numeric
synth_data <- syn(data, minnumlevels=2)

#Save to dick
write.syn(synth_data,file = "synth_data", filetype = "csv")