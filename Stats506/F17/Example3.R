# --------------------------- #
# Parallel computing in R 
# Example 3: Random Numbers
# James Henderson
# --------------------------- #

# load libraries #
library(parallel)

# point to personal pkg library if needed #
.libPaths('~/Rlib')
library(doParallel)
library(doRNG)

#### Example 3: reproducible permutation tests for gene set analysis using foreach 
#               and doRNG ####

##### !! This code is all taken from example 1 !! #####
## load data ##
foo = load('./YaleTNBC.RData')
AA = grep('AA',colnames(YaleTNBC))
EA = grep('EA',colnames(YaleTNBC))

# load gene sets #
bar = load('./c6.unsigned.RData')

# get row index for genes in each set  #
getInd = function(set,universe){
  x = match(set$names,universe)
  x[which(!is.na(x))]
}
c6.ind = mclapply(c6.unsigned,getInd,universe=rownames(YaleTNBC))

# a function to compute gene scores #
genescores = function(Mat,G1,G2){
  apply(Mat,1,function(x) t.test(x[G1],x[G2])$statistic)
}

# a parallel version of genescores #
genescoresParallel = function(Mat,G1,G2,mc.cores=2,mc.preschedule=TRUE){
  unlist(
   mclapply(1:nrow(Mat),function(row){t.test(Mat[row,G1],Mat[row,G2])$statistic},
	     mc.cores=mc.cores,mc.preschedule = mc.preschedule
           )
  )
}

## compute set scores #
setscore = function(setInd,gs){
  sum(gs[setInd])
}

# Evaluate significance of each set by comparing
# to set scores after permutation of group labels
doPermute_seq = function(sets,sampleMatrix,G1size){
  G1 = sample(ncol(sampleMatrix),G1size,replace=F)
  G2 = {1:ncol(sampleMatrix)}[-G1]
  
  gs = genescores(sampleMatrix,G1,G2)
  sapply(sets,setscore,gs=gs)
}

doPermute_par = function(sets,sampleMatrix,G1size,mc.cores=2){
  G1 = sample(ncol(sampleMatrix),G1size,replace=F)
  G2 = {1:ncol(sampleMatrix)}[-G1]
  
  gs = genescoresParallel(sampleMatrix,G1,G2,mc.cores=mc.cores)
  sapply(sets,setscore,gs=gs)
}

# Compute observed set scores
gs = genescores(YaleTNBC,AA,EA)
scores_obs = sapply(c6.ind,setscore,gs=gs)

##### !! End code taken from example 1 !! #####

## Example 3: run permutations in parallel using foreach ##
nPermute = 40

# set up a cluster
nCores = 8
cl = makeCluster(nCores)

# register the parallel backend
registerDoParallel(cl)

# Set path to personal library on all child processes
clusterEvalQ(cl,.libPaths('~/Rlib'))

cat('Starting run 1 ...\n')
# compute in parallel, return as list #
set.seed(89)
tm1 = system.time({
  scores_perm_1 = foreach(n=1:nPermute) %dorng% {
    doPermute_seq(c6.ind,YaleTNBC,length(AA))
  }
})

# print information about run 1
cat("Results 1: \n")
cat("\tTime:\n") 
print(tm1)
cat('\tclass(scores_perm_1):',class(scores_perm_1),'\n')
cat('\tdim(scores_perm_1):',dim(scores_perm_1),'\n') 

# compute in parallel return as set by permuation matrix
cat('Starting run 2 ...\n')
set.seed(89)
tm2 = system.time({
  scores_perm_2 = foreach(n=1:nPermute,.combine='cbind') %dorng% {
    doPermute_seq(c6.ind,YaleTNBC,length(AA))
  }
})

cat("Results 2: \n")
cat("\tTime:\n")
print(tm2)
cat('\tclass(scores_perm_2):',class(scores_perm_2),'\n')
cat('\tdim(scores_perm_2):',dim(scores_perm_2),'\n')

## shut down the cluster after use ##
cat('Shut down cluster.\n\n')
stopCluster(cl)

## Convert scores_perm_1 to a matrix ##
sp1 = do.call('cbind',scores_perm_1)

cat('Do the results match for runs 1 and 2?\n')
print(all.equal(sp1,scores_perm_2))
cat('# of numeric disagreements =',sum(sp1 != scores_perm_2),'\n')

## set up a new cluster ##
cat('Create new cluster.\n\n')
cl = makeCluster(8)
registerDoParallel(cl)
libs = clusterEvalQ(cl,.libPaths('~/Rlib'))

cat('Starting run 3 ...\n')
set.seed(89)
scores_perm_3 = foreach(n=1:nPermute,.combine='cbind',.packages='parallel') %dorng% {
   doPermute_par(c6.ind,YaleTNBC,length(AA),mc.cores=2)
}

cat('All equal for perm2 and perm3: \n')
cat(all.equal(scores_perm_2,scores_perm_3),'\n')

cat('Starting run 4 ...\n')
set.seed(89)
scores_perm_4 = foreach(n=1:nPermute,.combine='cbind',.packages='parallel') %dorng% {
  doPermute_par(c6.ind,YaleTNBC,length(AA),mc.cores=2)
}

cat('Check if runs 3 and 4 return the same results.\n')
cat(all.equal(scores_perm_3,scores_perm_4),'\n')


## Be careful that parallel expression returns desired value

cat('Run 5a ...\n')
scores_perm_5a = foreach(n=1:4,.combine='cbind',.packages='parallel') %dopar% {
  tm = system.time({doPermute_par(c6.ind,YaleTNBC,length(AA),mc.cores=2)})
  cat('Loop',n,tm,'\n')
}
cat('Class of scores_perm_5a:',class(scores_perm_5a),'\n')

cat('Run 5b ...\n')
scores_perm_5b = foreach(n=1:4,.packages='parallel') %dopar% { 
  tm = system.time({scores=doPermute_par(c6.ind,YaleTNBC,length(AA),mc.cores=2)})
  list(scores=scores,time=tm)
}

cat(names(scores_perm_5b[[1]]),'\n')
stopCluster(cl)