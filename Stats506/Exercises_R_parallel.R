## Practice Exercises for Parallel Computing in R ##

# The script below illustrates 10-fold cross validation for a predictive model.
# These exercises are intended to let you practice parallelizing sequential code.
# 1. Write a function to perform the computations in the final for loop
# 2. Call your function in parallel using mclapply and verify the results.
# 3. Setup a 'doParallel' cluster and write a foreach loop to perform cross validation.
# 4. Change to 100-fold cross validation and compare timing of your parallel and sequential versions.


## packages
library(ggplot2); library(dplyr)
library(mgcv)

## simulation function ##
sim_data = function(n_cases){
  x  = runif(n_cases,-2*pi,2*pi)
  y = rbinom(n_cases,1,prob={1+sin(x)}/2)
  return(data.frame(y=y,x=x))
}

data = sim_data(1e3)
data = arrange(data,x)
data %>% ggplot(aes(x=x,y=y)) + geom_point()

# estimate the decision boundary using a smoothing spline and logistic regression
fit = gam(y~s(x),family=binomial(link='logit'),data=data)
data$yhat = predict(fit,data,type='response')
data %>% ggplot(aes(x=x,y=y)) + geom_point() + geom_line(aes(y=yhat),col='red')

# confusion matrix #
table(Predicted=data$yhat>.5,Observed=data$y==1)

# classification error
sum({data$yhat>.5 & data$y==0} | {data$yhat<.5 & data$y==1}) / nrow(data)
class_error = function(yhat,y){
  sum({yhat>.5 & y==0} | {yhat<.5 & y==1}) / length(y)
}
class_error(data$yhat,data$y)

# estimate the out of sample prediction error using 10-fold cross-validation
folds = 10
fold = 1:folds
samples = split(sample(1:nrow(data)),fold)

cv_error = c()
for(f in fold){
  fit = gam(y~s(x),family=binomial(link='logit'),data=data[samples[[f]],])
  yhat = predict(fit,data[samples[[f]],],type='response')
  cv_error[f] = class_error(yhat,data$y[samples[[f]]])
}
mean(cv_error)


