# --------------------------- #
# Parallel computing in R 
# Example 4: iterators & foreach
# James Henderson
# --------------------------- #

## Example 4: Iterators and foreach options ##

## load libraries 
library(doParallel)
library(iterators)
library(doRNG)

#library(microbenchmark)
cl = makeCluster(2)
registerDoParallel(cl)

############################
### The iterator library ###
############################

# icount
foreach(i=icount(5),.combine='c') %do% {i}

# icountn for iterating over multiple parameters
foreach(i=icountn(c(2,5)),.combine='rbind') %do% {i}
foreach(i=icountn(c(1,3,2)),.combine='rbind') %do% {i}

# generic iterators
myList = list(c(1,2),c('a','b'),3:10)
foreach(i=iter(myList)) %do% {paste(i,collapse='')}
foreach(i=myList) %do% {paste(i,collapse='')}

# iterate options
Mat = matrix(rep(1:2,each=5),5,2)
foreach(r=iter(Mat,by='row'),.combine='c') %do% sum(r)
foreach(col=iter(Mat,by='col'),.combine='c') %do% sum(col)

# iter can be used for fine tune control
# each new evaluation of the expression after %dopar%
# is evaluated on nextElem(iterator)
Mat = matrix(rep(1:5,each=5),5,5)
xx = iter(Mat,by='col',chunksize = 2)
nextElem(xx)
nextElem(xx)
nextElem(xx)

foreach(subMat = iter(Mat,by='col',chunksize = 2)) %do% dim(subMat)

# iter can be explictly defined 
xx = iter(Mat,by='col',chunksize = 2)
foreach(subMat = xx) %do% dim(subMat)

#########################
### More with foreach ###
#########################

# bare function names can be used for .combine
foreach(i=1:2,.combine='c') %do% i
foreach(i=1:2,.combine=c) %do% i

# nested foreach loops
result = foreach(i=1:2,.combine='rbind') %:% 
  foreach(j=1:5,.combine='rbind') %do% {
    c(i,j)
  }
result

# simple interface for replicates
times(10) %dopar% rbinom(1,1,.5)

# initializing results
count1 = foreach(n=1:5,.combine='+') %dopar% n
count2 = foreach(n=1:5,.combine='+',.init=1e3) %dopar% n
count1; count2

## global variables with import / export ##
rm(list=ls())
var_global = 'I came from .GlobalEnv!'
ls()

# Explicitly include
foreach(n=1:2,.export=c('var_global'),.combine = 'union') %dopar% {ls()}
ls()

# Explicitly exclude
foreach(n=1:2,.noexport=c('var_global'),.combine='union') %dopar% {ls()}

# Examine default behavior
foreach(n=1:2,.combine='union') %dopar% {ls()}
foreach(n=1:2,.combine='union') %dopar% {
  message = sprintf('%s',var_global)
  ls()
}
ls()

## error handling ##

# default is to stop
foreach(n=1:100,.errorhandling='stop') %dopar% {
  if(n %% 10 == 0) {
    stop('Message about an error')
  } else{
    n
  }
}

# pass can be useful for debugging
out = 
foreach(n=1:100,.errorhandling = 'pass') %dopar% {
  if(n %% 10 == 0) {
    stop('Message about an error')
  } else{
    n
  }
}
class(out[[10]])
out[[10]]
# Get all errors
out[sapply(out,function(x) 'error' %in% class(x))]

# remove sometimes useful for niche problems
out = 
  foreach(n=1:100,.errorhandling = 'remove',.combine='c') %dopar% {
    if(n %% 10 == 0) {
      stop('Message about an error')
    } else{
      n
    }
  }

# remove errors
out = 
  foreach(n=1:100,.errorhandling = 'remove',.combine='c') %dopar% {
  if(n %% 10 == 0) {
    stop('Message about an error')
  } else{
    n
  }
}
length(out)
out[1:20]
sum({out %% 10} == 0)
