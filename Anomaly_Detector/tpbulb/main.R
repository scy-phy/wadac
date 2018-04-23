library(RSQLite)
library(dplyr)
library(caret)
library(Information)
library(ROCR)
library(ggRandomForests)
setwd(paste0(getwd(),"/tpbulb"))
source("dbFetch.R")
source("plot_precall_roc.R") ## Remove precall plot 

filenames <- c()
filenames <- c(filenames,list.files("../../tplink_bulb_dataset",pattern= "*.db"))

# filenames <- filenames[6]
# filenames <- filenames[-3]
list_files <- list()


for(i in 1:length(filenames)){
  print(i)
  print(filenames[i])
  list_files[i] <- list(fetchdata(i,filenames))
}

print(length(list_files))

# filenames <- filenames[1]

# check <- list_files[[6]][[2]]
# check2 <- list_files[[2]]

random_frame_mixed <- data.frame(filename = c("filename"),Accuracy = c(0.0),sensitivity=0,specificity=0,stringsAsFactors = F)
anomaly_frame <- data.frame(filename = c("filename"),Accuracy = c(0.0),sensitivity=0,specificity=0,stringsAsFactors = F)
# filenames <- filenames[grepl("",filenames,ignore.case = T)]


for(i in 1:length(filenames)){
  print(filenames[i])
  packet_features <- list_files[[i]][[2]]
  
  source("prepping_h20.R")
  bin_blk <- substring(filenames[i], regexpr("bnl[0-9]{2}", filenames[i]),regexpr(".db", filenames[i])-1)
  source("autoencoders.R")
  anomaly_att <- c(filenames[i],accuracy_attack,sensitivity_anomaly,specificity_anomaly)
  anomaly_rand_mixed <- c(filenames[i],accuracy_random_mixed,sensitivity_random_mixed,specificity_random_mixed)
  
  anomaly_frame <- rbind(anomaly_frame,anomaly_att)
  random_frame_mixed <- rbind(random_frame_mixed,anomaly_rand_mixed)
  h2o.removeAll()
  # model_random$f_time_window <- random$f_time_window
  # sum(model_random$f_time_window[which(model_random$anomaly==1 & model_random_actualanom==0)])
  # 
}

anomaly_frame <- anomaly_frame[-1,] 
anomaly_frame$specificity[which(is.na(anomaly_frame$specificity))] <- 1
random_frame_mixed <- random_frame_mixed[-1,]



write.csv(anomaly_frame,"Results/anomaly.csv")
write.csv(random_frame_mixed,"Results/mixed.csv")


source("Bin_Win_Analysis.R")
setwd("../")
