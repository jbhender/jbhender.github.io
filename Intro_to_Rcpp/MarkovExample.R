## Use Rcpp to count transitons of a finite state Markov chain ##

library(Rcpp); library(microbenchmark)

## create functions using sourceCppp ##
sourceCpp("simObs.cpp")
sourceCpp("countTransitions.cpp")

## parameters for generating data ##
nStates = 3
states = 0:{nStates-1}
nObs = 100
nSteps = 10
P = matrix(c(.5 ,.5,  0,
             .25,.5,.25,
               0,.5, .5),
           nStates,nStates,byrow=TRUE) # matrix of transition probabilities P[i,j] 

## Generate some data ##
Obs = simObs(sample(0:2,100,replace=TRUE),4,3,P)
colnames(Obs) = paste0('ID',1:ncol(Obs))
rownames(Obs) = paste0('Step',1:nrow(Obs))

## Compute transitions
Est = countTransitions(Obs,nStates)

## An R Version ##
countTr = function(x,nStates=3){
  x=factor(x,levels=0:{nStates-1})
  table(x[-1],x[-length(x)])
}
countTransitions_R = function(Obs,nStates){
  t(matrix(apply(apply(Obs,2,countTr,nStates=nStates),1,sum),nStates,nStates))  
}

## Are these functions equivalent ? ##
all.equal(Est$Transitions,countTransitions_R(Obs,nStates))

## Compare timings ##
mb = microbenchmark(countTransitions(Obs,nStates),countTransitions_R(Obs,nStates))
print(mb,digits=2)
