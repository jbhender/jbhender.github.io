## IHPI Methods Seminar - March 10, 2017 ##
## This script demonstrates graphics and analysis options in base R ##

## Author: James Henderson (jbhender@umich.edu)
## Created: Feb 23, 2017
## Updated: March 9, 2017

## setup workspace ##
rm(list=ls())
path <- '~/Desktop/Rworkshop/chsi_dataset' # change to your `Rworkshop` folder 
setwd(path)

## load data ##
load('./lowBirthWeightData.RData')
ls()

## Histogram ##
hist(lowBirthWeightData$LBW)
# some common plotting options #
hist(lowBirthWeightData$LBW,main='Low Birth Weight',
     xlab='% Births < 2500 g',las=1,ylab='# of counties',col='blue')
## See ?par() for a more comprehensive list #

## Descriptive statistics ##
mean(lowBirthWeightData$LBW)
mean(lowBirthWeightData$LBW,na.rm=T)

median(lowBirthWeightData$LBW,na.rm=T)
quantile(lowBirthWeightData$LBW,c(.25,.5,.75),na.rm=T)

## Summary ##
summary(lowBirthWeightData$LBW)
summary(lowBirthWeightData)

## boxplot of county-level low-birth rate by state ##
boxplot(LBW~StateCode,data=lowBirthWeightData,las=2,ylab='% Births < 2500g')

## sort based on median county in state ##
medianLBW <- c() # medianLBW <- vector('numeric',length=50)
for(state in unique(lowBirthWeightData$StateCode)){
  medianLBW[state] <- with(lowBirthWeightData,
                        median(LBW[which(StateCode==state)],na.rm=T)
                      )
}
names(medianLBW)
o <- order(medianLBW)
medianLBW[o]

# reassign the StateCode factor so the levels are ordered
lowBirthWeightData$StateCode <- factor(lowBirthWeightData$StateCode,
                                    levels=names(medianLBW[o]))
boxplot(LBW~StateCode,data=lowBirthWeightData,las=2,ylab='% Births < 2500g')
head(lowBirthWeightData)

## Scatter plot ##
plot(lowBirthWeightData[['InfantMort']],lowBirthWeightData[['LBW']],
     las=1,ylab='% Births < 2500g',xlab='Infant Mortality / 1000 Births')

# assign each state a color 
colors <- rainbow(50)
names(colors) <- unique(lowBirthWeightData$StateCode)
col <- colors[match(lowBirthWeightData$StateCode,names(colors))]

plot(lowBirthWeightData[['InfantMort']],lowBirthWeightData[['LBW']],
     las=1,ylab='% Births < 2500g',xlab='Infant Mortality / 1000 Births',
     ylim=c(0,20),pch=16,col=col)

## Plot just MI and OH ##
indMI <- with(lowBirthWeightData,which(StateCode=='MI'))
indOH <- with(lowBirthWeightData,which(StateCode=='OH'))
ind <- c(indMI,indOH)
col2 <- c(rep('blue',length(indMI)),rep('red',length(indOH)))
with(lowBirthWeightData[ind,],
     plot(LBW,InfantMort,
     las=1,ylab='% Births < 2500g',xlab='Infant Mortality / 1000 Births',
     ylim=c(0,20),pch=16,col=col2)
)

## Add a legend ##
legend('topleft',legend=c('MI','OH'),col=c('blue','red'),pch=16)

## identify points on the plot ##
with(lowBirthWeightData[indMI,],
     plot(LBW,InfantMort,
          las=1,xlab='% Births < 2500g',ylab='Infant Mortality / 1000 Births',
          pch=16,col='grey',ylim=c(0,20),xlim=c(0,20))
)

# Identify points of interest 
ind <- with(lowBirthWeightData[indMI,],
              identify(LBW,InfantMort,County)
            )
notableCounties <- as.character(lowBirthWeightData$County[indMI][ind])

# Assign colors and symbols
col <- rep('lightgrey',length(indMI))
col[ind] <- 1:length(ind)

# write plots to file #
pdf('./MichiganCounties-LowBirthRate-InfMort.pdf') #opens the plotting device
  with(lowBirthWeightData[indMI,],
       plot(LBW,InfantMort,
            las=1,xlab='% Births < 2500g',ylab='Infant Mortality / 1000 Births',
            pch=15,col=col,ylim=c(0,20),xlim=c(0,20))
  )
  # Assign position of label
  pos <- rep(2,length(ind))
  pos[which(notableCounties=='Wayne')] <- 4

  # Add labels
  with(lowBirthWeightData[indMI,],
       text(LBW[ind],InfantMort[ind],notableCounties,
            pos=pos,col=col[ind])
  )
dev.off() # turns off the plotting device



## regression
fit <- lm(InfantMort~LBW,data=lowBirthWeightData[indMI,])
class(fit)
summary(fit)

## Plot the regression line
with(lowBirthWeightData[indMI,],
     plot(LBW,InfantMort,
          las=1,xlab='% Births < 2500g',ylab='Infant Mortality / 1000 Births',
          pch=15,col=col,ylim=c(0,20),xlim=c(0,20))
)
abline(coef(fit),lwd=2) 
abline(h=c(3,12),col='darkblue',lty='dotted')

# Use predict to get a condince interval
newData <- data.frame(LBW=seq(0,20,length.out=1e3))
newData <- cbind(newData, predict(fit,newData,interval='confidence'))
lines(newData$LBW,newData$lwr,lty='dashed')
lines(newData$LBW,newData$upr,lty='dashed')

predInt <- predict(fit,newData,interval='prediction')
class(predInt)
newData <- cbind(newData,plwr=predInt[,'lwr'],pupr=predInt[,'upr'])
lines(newData$LBW,newData$plwr,col='blue',lty='dotted',lwd=2)
lines(newData$LBW,newData$pupr,col='blue',lty='dotted',lwd=2)

## You can access elements of fit by name or using convience functions ##
qqnorm(resid(fit)); qqline(resid(fit))
plot(fit$residuals~fitted(fit))

## Some classes also have a default plotting method ##
plot(fit)

## ANOVA summarizes an lm fit 
anova(fit)

## Multiple regression ##
fit2 <- lm(InfantMort ~ State + LBW, data=lowBirthWeightData)
anova(fit2)
round(coef(fit2),2)
round(summary(fit2)$coefficients,3)

fit3 <- lm(InfantMort ~ 0 + State*LBW, data=lowBirthWeightData)
anova(fit3)
#summary(fit3)

## Generalized linear models ##
with(lowBirthWeightData,table(LBWind,InfantMortInd))
plot(LBWind~LBW,data=lowBirthWeightData,pch=16,col=rgb(0,0,1,.5),las=1)

# Create a new variable with LBWind coded as 0 or 1
lowBirthWeightData$LBWindicator <- with(lowBirthWeightData,
                                        ifelse(LBWind==3,0,1)
                                    )

# Logistic regression #
plot(LBWindicator~LBW,data=lowBirthWeightData,pch=16,col=rgb(0,0,1,.5),las=1)

# Use glm to fit generalized linear models #
logitFit <- glm(LBWindicator~LBW,data=lowBirthWeightData,
                family=binomial(link='logit'))
summary(logitFit)

logitFit2 <- glm(LBWindicator~State+LBW,data=lowBirthWeightData,
                 family=binomial(link='logit'))
anova(logitFit2)

## Compare AIC ##
AIC(logitFit2); summary(logitFit2)$aic
AIC(logitFit)

## Plot the estimated probability for the first model
newData <- data.frame(LBW=seq(2,16,length.out=1e3))
newData <- cbind(newData,
                 estProb=predict(logitFit,newData,type='response',se.fit=T)
            )
names(newData)

plot(LBWindicator~LBW,data=lowBirthWeightData,pch=16,col=rgb(0,0,1,.5),
     las=1,yaxt='n',ylab='Prob(LBWind=3 | LBW)')
axis(2,seq(0,1,.25),las=1)
with(newData,lines(LBW,estProb.fit,lwd=3))
with(newData,
     lines(LBW,estProb.fit + qnorm(.975)*estProb.se.fit,lwd=2,col='grey')
     )
with(newData,
     lines(LBW,estProb.fit - qnorm(.975)*estProb.se.fit,lwd=2,col='grey')
     )


