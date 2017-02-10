setwd("/Users/ianmcnish/Documents/imageanalysis/Jan2017oatseedpics")
library(sqldf)
red_result_files = list.files(pattern="*red_results.csv")
green_result_files = list.files(pattern="*green_results.csv")
blue_result_files = list.files(pattern="*blue_results.csv")
size_result_files = list.files(pattern="*size_results.csv")

red_data=NULL
green_data=NULL
blue_data=NULL
size_data=NULL

##red data

red_data=read.csv(red_result_files[1])
red_data$file=red_result_files[1]

for (i in 2:length(red_result_files)) {
  
  temp_data=read.csv(red_result_files[i])
  temp_data$file=red_result_files[i]
  red_data=rbind(red_data,temp_data)
  
}

red_data$file2=sub("*.csv","",red_data$file)
red_data$job=sub("[a-z]*_[a-z]*","",red_data$file2)
red_data$red_mean=red_data$Mean
red_data$seed=red_data$X
keeps <- c("job","seed","red_mean")
red_data=red_data[ , (names(red_data) %in% keeps)]

##green data

green_data=read.csv(green_result_files[1])
green_data$file=green_result_files[1]

for (i in 2:length(green_result_files)) {
  
  temp_data=read.csv(green_result_files[i])
  temp_data$file=green_result_files[i]
  green_data=rbind(green_data,temp_data)
  
}

green_data$file2=sub("*.csv","",green_data$file)
green_data$job=sub("[a-z]*_[a-z]*","",green_data$file2)
green_data$green_mean=green_data$Mean
green_data$seed=green_data$X
keeps <- c("job","seed","green_mean")
green_data=green_data[ , (names(green_data) %in% keeps)]

##blue data

blue_data=read.csv(blue_result_files[1])
blue_data$file=blue_result_files[1]

for (i in 2:length(blue_result_files)) {
  
  temp_data=read.csv(blue_result_files[i])
  temp_data$file=blue_result_files[i]
  blue_data=rbind(blue_data,temp_data)
  
}

blue_data$file2=sub("*.csv","",blue_data$file)
blue_data$job=sub("[a-z]*_[a-z]*","",blue_data$file2)
blue_data$blue_mean=blue_data$Mean
blue_data$seed=blue_data$X
keeps <- c("job","seed","blue_mean")
blue_data=blue_data[ , (names(blue_data) %in% keeps)]


##size_data

size_data=read.csv(size_result_files[1])
size_data$file=size_result_files[1]

for (i in 2:length(size_result_files)) {
  
  temp_data=read.csv(size_result_files[i])
  temp_data$file=size_result_files[i]
  size_data=rbind(size_data,temp_data)
  
}

size_data$file2=sub("*.csv","",size_data$file)
size_data$job=sub("[a-z]*_[a-z]*","",size_data$file2)
size_data$seed=size_data$X.1
keeps <- c("job","seed","Area","Length.long.axis","Length.short.axis")
size_data=size_data[ , (names(size_data) %in% keeps)]

join1=sqldf("select red_data.job, red_data.seed, red_data.red_mean, green_data.green_mean from red_data left join green_data on red_data.job=green_data.job and red_data.seed=green_data.seed")
join1=merge(red_data,green_data)
join2=merge(join1,blue_data)
join3=merge(join2,size_data)

write.table(join3, file="seed_data.csv", sep=",")
