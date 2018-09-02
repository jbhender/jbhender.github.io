# --------------------------- #
# Parallel computing in R 
# Example 0: Basics
# James Henderson
# --------------------------- #

## load libraries ##
library(parallel)

## load data ##
foo = load('./YaleTNBC.Rdata')
AA = grep('AA',colnames(YaleTNBC))
EA = grep('EA',colnames(YaleTNBC))

#### Example 0: computing a difference in means ####

### Version 1 - for loop ###
t1 = system.time({
 fold_change1 = rep(NA,nrow(YaleTNBC))
 for(i in 1:nrow(YaleTNBC)){
   fold_change1[i] = mean(YaleTNBC[i,AA]) - mean(YaleTNBC[i,EA])
 }
})

### Version 2 - an apply function ###
t2 = system.time({
  fold_change2 = sapply(1:nrow(YaleTNBC),
                        function(i){mean(YaleTNBC[i,AA])-mean(YaleTNBC[i,EA])}
                        )
})

# Version 2a: above we use a functional, here we use an explicit named function.
fc_func = function(i) mean(YaleTNBC[i,AA]) - mean(YaleTNBC[i,EA])
t2a = system.time({
  fold_change2a = sapply(1:nrow(YaleTNBC),fc_func)
 })

## version 3 - a different apply approach ##
t3 = system.time({
    fold_change3 = apply(YaleTNBC[,AA],1,mean) - apply(YaleTNBC[,EA],1,mean)
    })

## Compare timings of these options
rbind(t1,t2,t2a,t3)

## Version 4 - parallel approaches ##
t4 = system.time({
  fold_change4 = mclapply(1:nrow(YaleTNBC),fc_func)
})

## Results are returned as list
class(fold_change1)
class(fold_change4)
fold_change4 = unlist(fold_change4)
class(fold_change4)

# Check and increase number of cores used #
getOption("mc.cores", 2L)
detectCores()

## Version 5 - More cores ##
t5 = system.time({
    fold_change = mclapply(1:nrow(YaleTNBC),fc_func,mc.cores=4)
})

print(rbind(t1,t2,t3,t4,t5))

## An example of parallelism gone wrong ##
#help(mc.preschedule)
t6 = system.time({
  fold_change = mclapply(1:nrow(YaleTNBC),fc_func,mc.cores=2,mc.preschedule = FALSE)
})
t6
