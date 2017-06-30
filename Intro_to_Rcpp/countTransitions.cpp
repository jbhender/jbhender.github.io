#include <Rcpp.h>
using namespace Rcpp;

// Count transitions between finite states from 'Obs' with each
// column the observed states per unit

// [[Rcpp::export]]
List countTransitions(IntegerMatrix Obs, int nStates) {

  // Iniatilize containers, counters, and temporaries
  IntegerMatrix N(nStates,nStates); //Stores transition counts
  IntegerVector counts(nStates);    //Counts for each state prior to final
  N.fill(0);
  int i,j;
  int nSteps = Obs.nrow() - 1; 
  int from, to; 
  
  for(j=0; j<Obs.ncol(); j++)
  {
    for(i=0; i<nSteps; i++)
    {
      from = Obs(i,j);
      to = Obs(i+1,j);
      N(from,to)++; 
      
      // Increment Counts
      counts(from)++; 
    }
  }
  
  // Estimate of transition matrix
  NumericMatrix Est(nStates,nStates);
  for(i=0; i<nStates; i++)
  {
    for(j=0; j<nStates; j++)
    {
      //Integers must be cast to numeric type "double"
      Est(i,j)=(double)N(i,j)/(double)counts(i); 
    }
  }
  
  //Create a list for return
  List out;
  out["Transitions"]=N;
  out["Counts"]=counts;
  out["P_est"]=Est; 

  return out; 
}
