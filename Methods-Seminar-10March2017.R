## IHPI Methods Seminar - March 10, 2017 ##
#! Develop a standard header for your R scripts
#!  so you can quickly recall what it does in the future.

## This script introduces R and shows how to read and write data ##
## Author: James Henderson (jbhender@umich.edu)
## Created: Feb 9, 2017
## Updated: Feb 23, Mar 8, 2017

## these are comments, comments make scripts readable 
#! This comment style is used with notes intended for you  

## Download data from ##
# https://www.healthdata.gov/dataset/community-health-status-indicators-chsi-combat-obesity-heart-disease-and-cancer

###############
### About R ###
###############

# make sure you are starting with a fresh workspace #
rm(list=ls()) # rm deletes items from environments
ls() # list items in the global environment

# The search path specifies environments where R looks for objects # 
search()
tail(ls('package:base'))
# head() and tail() show just the fist or last bits of an object 

#! two ways to get see help files for R functions 
help(rm)
?ls()

# create an object with a path to our data set#
path <- '~/Desktop/Rworkshop/chsi_dataset' #! useful if changed later

# view and change working directory #
setwd(path)
getwd()
dir(path) # view contents of path

#########################
### Working with data ###
#########################

## read in data stored in a csv file ##
dataFile <- sprintf('%s/LEADINGCAUSESOFDEATH.csv',path)
leadDeath <- read.table(file=dataFile,sep=',',header=T)
#! I generally use camelCase for names of objects.

## get some information about leadDeath ##
class(leadDeath)
dim(leadDeath)   ## for objects with at least 2 dimensions
names(leadDeath) ## see the names of all variables in leadDeath

sprintf   ## view the code called by a function by omitting the ()
head(read.table)

## You can define your own functions in R.
#! Use functions to avoid repeated use of the same code blocks. 
dim2 <- function(obj){
  # This function returns either the dimensions of an object or its length
  # if it is unidimensional. 
  if(is.null(dim(obj))){
    return(length(obj))
  } else{
    return(dim(obj))
  }
}

dim2(leadDeath)
dim(leadDeath$CHSI_State_Name)
dim2(leadDeath$CHSI_State_Name)

# dim vs length
class(leadDeath$CHSI_State_Name); length(leadDeath$CHSI_State_Name)
dim(leadDeath$CHSI_State_Name)
dim2(leadDeath$CHSI_State_Name)

class(leadDeath); dim(leadDeath)
length(leadDeath)

# search for variables names containing a specific string #
grep('State',names(leadDeath))
names(leadDeath)[c(1,4,5)]
match('CHSI_State_Name',names(leadDeath))

## extract a specific variable from leadDeath ##
states <- leadDeath$CHSI_State_Name
length(states) ## for objects with a single dimension
class(states)
levels(states) # get the levels of a factor; see also ?relevel()
unique(states) # get the unique values

## changes states to characer class ##
states <- as.character(states)
class(states)

#! R stores objects by value, so changing states does not feed back to leadDeath
class(leadDeath$CHSI_State_Name)
statesFactor <- unique(leadDeath$CHSI_State_Name)

## We use [] for indexing vectors, matrices and (sometimes) data frames
firstState=states[1] # equal as assignment
firstState
firstState='Alaska'
firstState
states[1]
#! Use <- for assignment since '=' should be symmetric

## Left to right assignment allowed but bad style ##
states[length(states)] -> lastState

## tell read.table not to interpret strings as factors 
dataFile2 <- sprintf('%s/MEASURESOFBIRTHANDDEATH.csv',path)
birthDeath <- read.table(file=dataFile2,sep=',',header=T,stringsAsFactors=FALSE)

## Extract columns of interest ##

# by index
lowBirthWeightData <- birthDeath[,c(3,4,5,7,8)]
head(lowBirthWeightData)
# Negative indexing 
head(lowBirthWeightData[,-c(3,5)])

# by name
lowBirthWeightData <- birthDeath[,c('CHSI_County_Name','CHSI_State_Name',
                                    'CHSI_State_Abbr','LBW','LBW_Ind')]

# Create a new data-frame using 'with' 
lowBirthWeightData <- with(birthDeath,data.frame(County=CHSI_County_Name,
                                                 State=CHSI_State_Name,
                                                 StateCode=CHSI_State_Abbr,
                                                 LBW=LBW,LBWind=LBW_Ind,
                                                 InfantMort=Infant_Mortality,
                                                 InfantMortInd=
                                                   Infant_Mortality_Ind))
lowBirthWeightData[1:4,]

## lapply and sapply are for lists -- data.frames are lists 
lBWD_class <- lapply(lowBirthWeightData,class)
class(lBWD_class)
lBWD_class[1]; lBWD_class[[1]]
sapply(lowBirthWeightData,class)

# In R, the missing value charachter is NA
na.ind <- with(lowBirthWeightData,which(LBW < 0))
lowBirthWeightData_original <- lowBirthWeightData
# na.ind <- which(lowBirthWeightData$LBW < 0)
lowBirthWeightData$LBW[na.ind] <- NA

head(lowBirthWeightData_original)
head(lowBirthWeightData)

## A functional approach 
replaceNA <- function(input){
  input[which(input < 0)] <- NA
  return(input)
}

for(i in 4:7){
  lowBirthWeightData[,i] <- replaceNA(lowBirthWeightData[,i])
}


# saving data to file to read into R later #
save(lowBirthWeightData,file='./lowBirthWeightData.RData')

# write data to csv file for export and sharing with others
write.csv(lowBirthWeightData,file='./lowBirthWeightData.csv',row.names=F,
          quote=F)


## Packages ##
if(FALSE) install.packages('foreign')
help(read.xport) #! We get an error because we didn't tell R where to look
head(foreign::read.xport) #! The package::function notation fixes this

library(foreign) #! This makes all functions in the package avaialable by name.
help(read.xport)
