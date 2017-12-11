# Execution script for PS4, Q4e
# Stats 506, Fall 2017
# Author: James Henderson (jbhender@umich.edu)

# Libraries, data, and sources
library(mgcv); library(doParallel)
load('/home/jbhender/ps4q4/ps4_q4.RData')
source('/home/jbhender/ps4q4/xvalidate.R')

# Get command line arguments and assign as global variables
# Use to assign "cores" and "folds"
ca = commandArgs()
ca = ca[grep('=',ca)]
ca = strsplit(ca,'=')
lapply(ca,function(x) assign(x[1],as.numeric(x[2]), envir=.GlobalEnv))

# Warn and quit if problem.
if(sum(c('cores','folds') %in% ls())<2) stop("Please specify 'cores' and 'folds'.")

# Cluster setup
cl = makeCluster(cores)
registerDoParallel(cl)

# Compute xvalidation
xvalidate(sample_data,folds=folds,cores=cores)

# Cluster close
stopCluster(cl)

