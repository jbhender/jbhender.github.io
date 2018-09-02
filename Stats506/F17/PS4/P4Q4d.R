# Execution script for PS4, Q4d
# Stats 506, Fall 2017
# Author: James Henderson (jbhender@umich.edu)

# Libraries, data, and sources
library(mgcv); library(doParallel)
load('/home/jbhender/ps4q4/ps4_q4.RData')
source('/home/jbhender/ps4q4/xvalidate.R')

# Cluster setup
ncores = 2
cl = makeCluster(ncores)
registerDoParallel(cl)

# Compute xvalidation
xvalidate(sample_data,folds=10,cores=ncores)

# Cluster close
stopCluster(cl)

