# Functional code base for masteRmind game in preparation for 
# R programming workshop to take place August 24, 2018.
#
# Updated: August 23, 2018 
# Author: James Henderson (jbhender@umich.edu)

# Create a dictionary of eight colors: ---------------------------------------
std_dict = c( R='Red', Gr='Green', Bu='Blue', Y='Yellow',
              Go='Gold', O='Orange', Ba='Black', W='White' )

# Alternately set names after creation: --------------------------------------
std_dict = c( 'Red', 'Green', 'Blue', 'Yellow', 
              'Gold', 'Orange', 'Black', 'White' )

names(std_dict) = c('R', 'Gr', 'Bu', 'Y', 'Go', 'O', 'Ba', 'W')

# Check the class and length: ------------------------------------------------
class(std_dict)
length(std_dict)
