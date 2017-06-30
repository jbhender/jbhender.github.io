## Function to compute Fibonocci sequence ##
Fib = function(n){
  if(n<1) stop("n must be a positive integer!")

  if(n > 1){
   out=vector(length=n,mode="integer")
   out[1] = out[2] = 1
   for(i in 3:n){
     out[i] =  out[i-1]+out[i-2]
    }
    return(out)
  } else{
    return(as.integer(1))
  }
  
}