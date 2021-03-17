setwd("C:/Users/silas/kDrive/Projects/BA/python/Pipeline")
library('ggplot2')
#import data
data<- read.csv("pipeline.csv", header = 1)
names(data) <- c('Name', 'Diameter', 'capacity', 'pressure', 'source')

#fit linear model with log transformation
lm1 <- lm(log(capacity)~Diameter, data)
summary(lm1)

#model capacity for given diameters
pipes=c(300, 900, 1050, 600,750, 1200, 1300, 500)

newdat<- data.frame(Diameter=pipes)

#compose data frame of predicted capacities
capacities=data.frame(capacity=predict(lm1, newdata = newdat), Diameter=pipes)

#unit calculations
capacities$capacity=((capacities$capacity*1E9)/8760)*38.3 #MJ/hr
capacities$capacity=capacities$capacity/3600 #MJ/s = mW

#export to csv
write.csv(capacities, "pipe_capacities.csv")
