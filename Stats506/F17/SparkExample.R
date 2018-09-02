## install Sparklyr and Spark
#install.packages(sparklyr)
library(sparklyr)
#spark_install(version = "2.1.0")

# load some other libraries
library(dplyr)
library(nycflights13)
library(ggplot2)

# create a local connection for testing
sc = spark_config(master="local")

# copy data into Spark
flights <- copy_to(sc, flights, "flights")
airlines <- copy_to(sc, airlines, "airlines")
src_tbls(sc)

# Use carrier and distance to predict if a flight delayed at least 30 minutes will make up 5 minutes or more in route.

## 
dd30 = flights %>% 
  filter(dep_delay >= 15) %>%
  select(dep_delay, arr_delay, carrier,
         distance, dest) %>%
  mutate(delay_diff = arr_delay - dep_delay,
         mu5 = delay_diff <= -5,
         AAind = 1L*carrier=='AA')
dd30


# create a local copy of the data and 
# copy it into R's working memory.  
dd30_rlocal = dd30 %>% collect()

# create a temporary table within the Spark connection. 

sdf_register(dd30, 'dd30_spark')

# force the table to be cached in memory using `tbl_cache`.
tbl_cache(sc, 'dd30_spark')

## Do some local comutations on reduced data set
# compute marginal probabilities by carrier
mu_tab = dd30_rlocal %>% 
group_by(carrier) %>%
summarize(n=n(), avg_dist=round(mean(distance)), p=round(mean(mu5),2)) %>%
arrange(desc(p))
mu_tab %>% ggplot(aes(x=avg_dist, y=p)) + geom_text(aes(label=carrier))

# Fit a glm to the entire dataset
fit_local = glm(mu5 ~ distance,
                data=dd30_rlocal,family=binomial())
summary(fit_local)
exp(coef(fit_local))

###  Use Spark's distributed machine learning library for the anlayses.

## create testing and training split
dd30_split = tbl(sc, 'dd30_spark') %>%
  sdf_partition(training = 0.75, test = 0.25, seed = 1042)


# train 
fit = dd30_split$training %>%
  ml_logistic_regression(mu5 ~ distance)

# test
test = sdf_predict(fit, dd30_spark$test) 
test_local = test %>% collect()

mean(test_local$prediction)
