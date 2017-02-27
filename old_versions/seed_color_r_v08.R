#begin readme

#this r script is intended to collect, manage,and analyze the data produced by the imagej script
#seed_color_imagej_v9, it produces an output file that provides a description of each seed analyzed
#in a single table

#the sections of this script are:
#1. set working directory and load libraries
#2. create null data sets to house imported data
#3. import red data
#4. import green data
#5. import blue data
#6. import size data
#7. import mask color data, this is used to filter erroneous results
#8. join data sets
#9. export results

#author: Ian McNish, mcnis003@umn.edu
#institution: University of Minnesota
#last modified: 13-feb-2017

#end readme

#1. set working directory, load libraries, import data files ----
setwd("/Users/ianmcnish/Documents/imageanalysis/feb2017_founder_seeds/ImageJ/results")
library(sqldf)
red_result_files = list.files(pattern="*red_results.csv")
green_result_files = list.files(pattern="*green_results.csv")
blue_result_files = list.files(pattern="*blue_results.csv")
size_result_files = list.files(pattern="*size_results.csv")
mask_color_result_files = list.files(pattern="*mask_color_results.csv")

#2. create null data sets to house imported data ----  
red_data=NULL
green_data=NULL
blue_data=NULL
size_data=NULL
mask_color_data=NULL

#3. red data import----

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

#4. green data import----

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

#5. blue data import----

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

#6. size_data import----


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
keeps <- c("job","seed","Length.long.axis","Length.short.axis")
size_data=size_data[ , (names(size_data) %in% keeps)]
colnames(size_data)=c("seed_length","seed_width","job","seed")

#7. mask_color_data import----

mask_color_data=read.csv(mask_color_result_files[1])
mask_color_data$file=mask_color_result_files[1]

for (i in 2:length(mask_color_result_files)) {
  
  temp_data=read.csv(mask_color_result_files[i])
  temp_data$file=mask_color_result_files[i]
  mask_color_data=rbind(mask_color_data,temp_data)
  
}

mask_color_data$file2=sub("*.csv","",mask_color_data$file)
mask_color_data$job=sub("[a-z]*_[a-z]*_[a-z]*","",mask_color_data$file2)
mask_color_data$seed=mask_color_data$X
keeps <- c("job","seed","Mean")
mask_color_data=mask_color_data[ , (names(mask_color_data) %in% keeps)]
colnames(mask_color_data)=c("mask_mean_color","job","seed")

#8. join results----
join1=merge(red_data,green_data)
join2=merge(join1,blue_data)
join3=merge(join2,size_data)
seed_data=merge(join3,mask_color_data)

#10. produce result by plot----

# view histogram of mask color data, seeds with low values are likely misidentified seeds, remove these
hist(seed_data$mask_mean_color)
seed_data=sqldf("select * from seed_data where seed_data.mask_mean_color > 0.95")

plot_summaries=sqldf("
select
seed_data.job as plot,
avg(seed_data.red_mean) as red_mean,
avg(seed_data.green_mean) as green_mean,
avg(seed_data.blue_mean) as blue_mean,
avg(seed_data.seed_length) as length_mean,
avg(seed_data.seed_width) as width_mean

from seed_data

group by
seed_data.job
")

#9. write results----
#write.csv(seed_data,file = "seed_phenotypes.csv")
#write.csv(plot_summaries,file = "plot_summaries.csv")

plot_data=read.csv("/Users/ianmcnish/Documents/imageanalysis/feb2017_founder_seeds/plot_data.csv")
key=read.csv("/Users/ianmcnish/Documents/imageanalysis/feb2017_founder_seeds/founder_names.csv")



#add sample column to plot_summaries to merge with key file
plot_summaries$sample=sub("sample0*","",plot_summaries$plot)
plot_summaries_keyed=merge(plot_summaries,key)
plot_summaries_keyed=sqldf("select plot_id, red_mean, green_mean, blue_mean, length_mean, width_mean from plot_summaries_keyed")
all_plot_data=merge(plot_summaries_keyed,plot_data)

pca.analysis=prcomp(all_plot_data[,2:4])

pdf('/Users/ianmcnish/Documents/imageanalysis/feb2017_founder_seeds/pca_plot.pdf')
plot(pca.analysis$x,col=as.factor(all_plot_data$qualitative_hull_color),xlab="PC1",ylab="PC2",pch=16,cex.lab=1.5,cex.axis=1.5)
legend(-.06,.03,c("yellow","white","brown"),pch=16,col=c("blue","green","red"),box.lty=0)
dev.off()

