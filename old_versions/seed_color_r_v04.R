#this r script is intended to collect, manage, and analyze the data produced by the imagej script seed_color_imagej_v8
#this script is incomplete

#author: Ian McNish, mcnis003@umn.edu
#institution: University of Minnesota
#last modified: 7-feb-2017

#set working directory, load libraries, import data files ----
setwd("/Users/ianmcnish/Documents/imageanalysis/feb2017_founder_seeds")
library(sqldf)
red_result_files = list.files(pattern="*red_results.csv")
green_result_files = list.files(pattern="*green_results.csv")
blue_result_files = list.files(pattern="*blue_results.csv")
size_result_files = list.files(pattern="*size_results.csv")

#import data files created by seed_color_imagej_vn.txt ----  
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


seed_data=read.csv("join3.csv")

write.table(join3, file="seed_data.csv", sep=",")

genotype_data=read.csv("founder_genotypes.csv", as.is = T, check.names = F,quote=)
founder_names=read.csv("founder_names.csv")

drops <- c("alleles")
genotype_data=genotype_data[,!(names(genotype_data) %in% drops)]

genotype_lines=colnames(genotype_data)
genotype_lines=genotype_lines[4:length(genotype_lines)]


seed_data$Sample=sub("sample","",seed_data$job)
seed_data$Sample=sub("0*","",seed_data$Sample)

seed_data=sqldf("select * from seed_data left join founder_names on seed_data.Sample=founder_names.sample")

write.csv(seed_data,file = "founder_seed_phenotypes.csv")

length_anova=aov(Length_long_axis~Name, data=seed_data)
summary(length_anova)
width_anova=aov(Length_short_axis~Name, data=seed_data)
summary(width_anova)
red_anova=aov(red_mean~Name, data=seed_data)
summary(red_anova)
green_anova=aov(green_mean~Name, data=seed_data)
summary(green_anova)
blue_anova=aov(blue_mean~Name, data=seed_data)
summary(blue_anova)

qf(0.975,254,27034)

qt(0.975,df=300)

seed_data$Name=paste("'",seed_data$Name,"'",sep="")

phenotype_lines=unique(seed_data$Name)

both_lines=intersect(phenotype_lines,genotype_lines)


all_lines=unique(c(genotype_lines,phenotype_lines))


drop_lines=all_lines[!(all_lines %in% both_lines)]


seed_data_clean=seed_data[seed_data$Name %in% both_lines, ]

genotype_data_clean=genotype_data[,!(names(genotype_data) %in% drop_lines)]


drops <- c("sample")
seed_data=seed_data[,!(names(seed_data) %in% drops)]

seed_data=sqldf("select seed_data_clean.Name, avg(seed_data_clean.red_mean) as red_mean,avg(seed_data_clean.green_mean) as green_mean,avg(seed_data_clean.blue_mean) as blue_mean,avg(seed_data_clean.Length_long_axis) as length_mean,avg(seed_data_clean.Length_short_axis) as width_mean from seed_data group by seed_data_clean.Name")

library(rrBLUP)

gwas_out <- GWAS(seed_data_clean, genotype_data_clean, fixed=NULL, K=NULL, n.PC=0, min.MAF=0.05, n.core=1, P3D=TRUE, plot=T)


plot(seed_data$red_mean,seed_data$green_mean,pch=16)
abline(0,1)

plot(seed_data$red_mean,seed_data$blue_mean,pch=16)
abline(0,1)

plot(seed_data$green_mean,seed_data$blue_mean,pch=16)
abline(0,1)

hist(seed_data$red_mean)
sd(seed_data$red_mean)

hist(seed_data$green_mean)
sd(seed_data$green_mean)

hist(seed_data$blue_mean)
sd(seed_data$blue_mean)

library(scatterplot3d)

scatterplot3d(seed_data$red_mean,seed_data$green_mean,seed_data$blue_mean)

plot(seed_data$Length_short_axis,seed_data$Length_long_axis)

hist(seed_data$red_mean)
hist(seed_data$green_mean)
hist(seed_data$blue_mean)
hist(seed_data$Length_long_axis)
hist(seed_data$Length_short_axis)
