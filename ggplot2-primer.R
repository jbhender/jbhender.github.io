## A very brief ggplot2 introduction ##
## Author: James Henderson (jbhender@umich.edu)
## Created: March 9, 2017

## set up workspace #
rm(list=ls())
path <- '~/Desktop/Rworkshop/chsi_dataset' 
setwd(path)
library(ggplot2)

## read in air quality data ##
airQuality <- read.table('./VunerablePopsAndEnvHealth.csv',stringsAsFactors = F,
                         sep=',',header=T)
dim(airQuality)

## read in demographic data ##
demo <- read.table('./Demographics.csv',stringsAsFactors = F,sep=',',header=T)
dim(demo)

# Be sure all counties are in the same order #
all.equal(airQuality$County_FIPS_Code,demo$County_FIPS_Code)

# Create a data frame with variables of interest #
indMI <- which(airQuality$CHSI_State_Abbr=='MI')
indOH <- which(airQuality$CHSI_State_Abbr=='OH')
indIN <- which(airQuality$CHSI_State_Abbr=='IN')
indIL <- which(airQuality$CHSI_State_Abbr=='IL')
indAll <- c(indMI,indOH,indIN,indIL)

countyData <- with(demo[indAll,],
                  data.frame(
                         'State'=CHSI_State_Abbr,
                         'County'=CHSI_County_Name,
                         'Population'=Population_Size,
                         'PctWhite'=White,
                         'PctPoverty'=Poverty
                    )
                )
countyData <- cbind(countyData,'ToxicChem'=airQuality$Toxic_Chem[indAll])

# Remove missing values #
with(countyData,table(ToxicChem < 0,State))

countyData <- countyData[-which(countyData$ToxicChem < 0),]
countyData$ToxicChem <- log(countyData$ToxicChem + 1)

# Create the plotting frame
p1 <- ggplot(data=countyData,aes(y=ToxicChem,x=PctPoverty,
                                 group=State,col=PctWhite,size=Population),
             title='County Level Toxic Chemicals Released / Year') 
p1

# Add additonal elements 
p1 + geom_point()
p2 <- p1 + facet_wrap(~State) + geom_point()

## Make the plot interactive using the plotly package ##
#install.packages('plotly')
library(plotly)
p2 <- ggplotly(p2)
p2

# Add the county name #
p3 <- p1 + facet_wrap(~State) + geom_point(aes(text=paste('Name:',County)))
ggplotly(p3)
