#include <Rcpp.h>
using namespace Rcpp;

// This is a template for a function defined below.
int my_sample(NumericVector prob);

// [[Rcpp::export]]
IntegerMatrix simObs(IntegerVector state0,
                     int nSteps, int nStates, NumericMatrix P){

  // Iniatilze
  int i,j, state;
  NumericVector prob(nStates); 
  
  // Create obs container and default states
  IntegerMatrix obs(nSteps+1,state0.length());
  IntegerVector states(nStates);
  
  for(j=0; j<state0.length(); j++)
  { 
    state = state0(j);
    obs(0,j)=state;
    for(i=0; i<nSteps; i++)
    {
      prob = P(state,_); //copies values to prob
      //Rcout << prob << std::endl;
      state = my_sample(prob);
      obs(i+1,j)=state;
    }
  }
  return obs;
}

int my_sample(NumericVector prob){
  double u=unif_rand(); 
  double p = prob(0);
  int i=0;
  while(p < u)
    {
      i++;
      p += prob(i);
    }
  return i;
}  

// You can embed code to be run in R for testing 
/*** R
nStates = 3
states = 0:{nStates-1}
nObs = 100
nSteps = 10
P = matrix(c(.5 ,.5,  0,
             .25,.5,.25,
0,.5, .5),
nStates,nStates,byrow=TRUE) # matrix of transition probabilities P[i,j] 
  
## Generate some data ##
  Obs = simObs(sample(0:2,10,replace=TRUE),4,3,P)
  colnames(Obs) = paste0('ID',1:ncol(Obs))
  rownames(Obs) = paste0('Step',1:nrow(Obs))
*/
