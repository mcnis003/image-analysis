setwd("/Users/ianmcnish/Documents/imageanalysis/Jan2017oatseedpics")
library(sqldf)
temp = list.files(pattern="*.csv")

data=NULL

data=read.csv(temp[1])
data$file=temp[1]

for (i in 2:length(temp)) {
  
  tempdata=read.csv(temp[i])
  tempdata$file=temp[i]
  data=rbind(data,tempdata)
  
  
}

data$file2=sub("*.csv","",data$file)
data$job=sub("[a-z]*_[a-z]*","",data$file2)
data$color=sub("[0-9]*","",data$file2)

red=sqldf("select job, mean as red from data where color = 'red_results'")
green=sqldf("select job, mean as green from data where color = 'green_results'")
blue=sqldf("select job, mean as blue from data where color = 'blue_results'")

join1=merge(red,green)
join2=merge(join1,blue)

join2$distance=sqrt(join2$red^2+join2$green^2+join2$blue^2)
