getRegion_loop = function(x,y){

  ## Error checking
  n=length(x)
  if(length(y)!=n) stop('x and y must have the same length!')

  ## Explicit loop
  result = vector(length=n,mode='integer')
  for(i in 1:n){
      result[i] = checkRegion(x[i],y[i])
  }
  
  return(result)
}

getRegion_vec = function(x,y){
  ## Error checking
  n=length(x)
  if(length(y)!=n) stop('x and y must have the same length!')
                        
  apply(matrix(c(x,y),ncol=2),1,function(z) checkRegion(z[1],z[2]))
}

## R function to check the region of a single point
checkRegion = function(x,y){
  if(x > 0){
    if(y > 0){ # x>0, y>0
      ifelse(y>1-x,1,5)
    } else{ # x > 0, y<0
      ifelse(y>x-1,8,4)
    } 
  } else{
    if(y > 0){ #x<0, y>0
      ifelse(y>x+1,2,6)
    } else{ #x <0, y<0
      ifelse(y>-x-1,7,3)
    }
  }
}

## Vectorized, but does 8*n comparisons
getRegion_all = function(x,y){
  1*{x>0 & y>0 & y>{1-x}} +
  5*{x>0 & y>0 & y<{1-x}} +
    
  2*{x<0 & y>0 & y>{x+1}} +
  6*{x<0 & y>0 & y<{x+1}} +
    
  3*{x<0 & y<0 & y<{-x-1}} +
  7*{x<0 & y<0 & y>{-x-1}} +
    
  4*{x>0 & y<0 & y<{x-1}} +
  8*{x>0 & y<0 & y>{x-1}}
    
}
