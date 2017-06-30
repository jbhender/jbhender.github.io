#dyn.load('../src/C_Fib.so')
FibC <- function(n){
  ## Do some error checking
  if(n < 1) stop("n must be a positive integer!")

  if(n > 1){
    ## create an R object to store result
    out=vector(length=n,mode="integer")
    return(.C("C_FibC",as.integer(n),as.integer(out))[[2]])
  } else{
    return(as.integer(1))
  }
}

FibC_noCoerce = function(n){
 if(n < 1) stop("n must be a positive integer!")
  if(n > 1){
    return(.C("C_FibC",as.integer(n),out=vector(length=n,mode="integer")))
  } else{
    return(as.integer(1))
  }
}
