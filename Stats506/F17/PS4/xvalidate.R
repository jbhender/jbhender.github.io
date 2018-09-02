## A cross validation function for a univariate GAM fit using mgcv 

xvalidate = function(df,folds=10,cores=1){
  # df - a data frame 
   n = nrow(df)
   start = seq(0,n,length.out={folds+1})
  
   do_fold = function(k){
     ind = {start[k]+1}:{start[k+1]} 
     df_in = df[-ind,]
     df_out = df[ind,]
     
     fit = mgcv::gam(y~s(x, bs='cr'), data=df_in, family=binomial(link='logit'))
     y_hat = {predict(fit,df_out,type='response') > .5}
     sum(y_hat == df_out$y)
   }
   if(cores == 1){
     n_right = 0
     for(k in 1:folds) n_right = n_right + do_fold(k)
   } else{
      n_right = foreach(k=1:folds, .packages='mgcv', .combine='+') %dopar% {
        do_fold(k)
      }
   }
   
   c('ErrorRate'= 1 - n_right/n)
}