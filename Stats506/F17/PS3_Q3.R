## Find distances between airports by scraping the page below:
##
## https://www.world-airport-codes.com/distance/
##
## Here is the search pattern to find the distance from JFK to LGA
## https://www.world-airport-codes.com/distance/?a1=JFK&a2=LGA

.libPaths('~/Rlib')
#install.packages('rvest')
library(rvest)
library(data.table)
library(tidyverse)
library(stringr)
library(parallel)

# ----------------------------------------------------------------------
# The examples have been removed here.

# Extract the information we want from the resulting string
get_miles = function(txt){
  y = str_split(txt,'\\(')[[1]]
  z = str_split(y[2],' ')[[1]][1]
  as.numeric(z)
}

# Function to find the distance between two valid airport codes.
scrape_dist = function(a1, a2){
  
  url = sprintf('https://www.world-airport-codes.com/distance/?a1=%s&a2=%s',
                a1, a2)
  
  srch = read_html(url)
  txt =
    srch %>%
    html_node("strong") %>% # identified by viewing the source in a browser
    html_text() 
  get_miles(txt)
}


## Now we can loop over all airports in the NYCflights14 data.
if(!file.exists('flights14.RData')){
 nyc14 = fread('https://github.com/arunsrinivasan/flights/wiki/NYCflights14/flights14.csv')
  save(nyc14, file='./flights14.RData')
} else {
  load('./flights14.RData')
}

# unique destination codes
dest_codes = unique(nyc14$dest)

# call scrape_dist for a single fixed code vs a set of targets
get_dists = function(fixed, targets){
  dists = sapply(targets, function(target) scrape_dist(fixed, target))
  tibble(from=fixed, to=targets, dist=dists)
}
#get_dists('DTW', c('EWR','LGA','JFK'))

# Exexute outer loop in parallel.
inner_loop =  function(i){
  get_dists(dest_codes[i], dest_codes[{i+1}:length(dest_codes)])
}
#inner_loop(107)

# -------------------------------------------------------------------
# modify from here to get distance between origins and from
# origins to destinations
dest_codes = c('LGA','JFK','EWR',dest_codes)

df_dist = list()
for(i in 1:3){
  df_dist[[i]] = inner_loop(i)
}

# bind results of inner loop into a single data frame
df_dist_new = do.call(bind_rows, df_dist)

# load existing and combine
load('./AirportCodeDists.RData')
df_dist = bind_rows(df_dist_new, df_dist)

save(df_dist, file='./AirportCodeDists_all.RData')
