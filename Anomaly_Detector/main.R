library(RSQLite)
library(dplyr)
library(caret)
library(Information)
library(ROCR)
library(ggRandomForests)
source("plot_precall_roc.R")
source("dbFetch.R")

filenames <- c()
filenames <- c(filenames,list.files("../camera_db",pattern= "*.db"))

list_files <- list()
list_files2 <- list()
list_files3 <- list()
list_files4 <- list()
list_files5 <- list()
list_files6 <- list()
list_files7 <- list()
list_files8 <- list()
list_files9 <- list()
for(i in 1:length(filenames)){
  print(i)
  list_files[i] <- list(fetchdata(i,filenames))
  list_files2[i] <- list(fetchtrain2_data(i,filenames))
  list_files3[i] <- list(fetchtrain3(i,filenames))
  list_files4[i] <- list(fetch_mirai_attack(i,filenames))
  list_files5[i] <- list(fetch_mirai_normal(i,filenames))
  list_files6[i] <- list(fetch_mirai_att1(i,filenames))
  list_files7[i] <- list(fetch_mirai_att2(i,filenames))
  list_files8[i] <- list(fetch_mirai_att1_new(i,filenames))
  list_files9[i] <- list(fetch_mirai_att2_new(i,filenames))
  }

cat("All data read and stored as dataframes")

random_frame <- data.frame(filename = c("filename"),Accuracy = c(0.0),fpr = c(0),sensitivity=0,specificity=0,stringsAsFactors = F)
random_frame2 <- data.frame(filename = c("filename"),Accuracy = c(0.0),fpr = c(0),sensitivity=0,specificity=0,stringsAsFactors = F)
random_frame_mixed <- data.frame(filename = c("filename"),Accuracy = c(0.0),fpr = c(0),sensitivity=0,specificity=0,stringsAsFactors = F)
anomaly_frame <- data.frame(filename = c("filename"),Accuracy = c(0.0),fpr = c(0),sensitivity=0,specificity=0,stringsAsFactors = F)
ddos_frame <- data.frame(filename = c("filename"),Accuracy = c(0.0),fpr = c(0),sensitivity=0,specificity=0,stringsAsFactors = F)
tplink_ddos_frame <- data.frame(filename = c("filename"),Accuracy = c(0.0),fpr = c(0),sensitivity=0,specificity=0,stringsAsFactors = F)
# filenames <- filenames[grepl("",filenames,ignore.case = T)]
mirai_normal_frame <- data.frame(filename = c("filename"),Accuracy = c(0.0),fpr = c(0),sensitivity=0,specificity=0,stringsAsFactors = F)
mirai_attack_frame <- data.frame(filename = c("filename"),Accuracy = c(0.0),fpr = c(0),sensitivity=0,specificity=0,stringsAsFactors = F)

pct=seq(0,1, by=0.05)

mixed_roc <- data.frame(pct=pct)


for(i in 1:length(filenames)){
  print(filenames[i])
  packet_features <- list_files[[i]][[2]]
  nest_cam <- list_files2[[i]][[1]]
  tplink_cam <- list_files3[[i]][[1]]
  mirai_attack <- list_files4[[i]]
  mirai_normal <- list_files5[[i]]
  mirai_att1 <- list_files6[[i]]
  mirai_att1_new <- list_files8[[i]]
  mirai_att2 <- list_files7[[i]]
  mirai_att2_new <- list_files9[[i]]
  nest_cam <- nest_cam[,which(colnames(nest_cam)%in%colnames(packet_features))]
  tplink_cam <- tplink_cam[,which(colnames(tplink_cam)%in%colnames(packet_features))]
  nest_cam <- nest_cam %>% mutate(t_label=ifelse(t_label=="nestcam_normalactions","nestCam_liveStreaming","Error"))
  tplink_cam <- tplink_cam %>% mutate(t_label=ifelse(t_label=="tplinkcam_normalactions","tplink_liveStreaming","Error"))
  packet_features <- rbind(packet_features,nest_cam,tplink_cam)
  source("prepping_h20.R")
  bin_blk <- substring(filenames[i], regexpr("bnl[0-9]{2}", filenames[i]),regexpr(".db", filenames[i])-1)
  source("autoencoders.R")
  anomaly_att <- c(filenames[i],accuracy_attack,fpr_attack,sensitivity_anomaly,specificity_anomaly)
  anomaly_rand <- c(filenames[i],accuracy_random,fpr_random,sensitivity_random_stream,specificity_random_stream )
  anomaly_rand2 <- c(filenames[i],accuracy_random2,fpr_random2,sensitivity_random_idle,specificity_random_idle)
  anomaly_rand_mixed <- c(filenames[i],accuracy_random_mixed,fpr_random_mixed,sensitivity_random_mixed,specificity_random_mixed)
  ddos <- c(filenames[i],accuracy_ddos,fpr_ddos,sensitivity_nestcam_ddos,specificity_nestcam_ddos)
  tplink_ddos <- c(filenames[i],accuracy_ddos_tp,fpr_ddos_tp,sensitivity_tplink_ddos,specificity_tplink_ddos)
  dlink_mirai_att <- c(filenames[i],accuracy_mirai_attack,fpr_mirai_attack,sensitivity_dlink_mirai_attack,specificity_dlink_mirai_attack)
  # dlink_mirai_norm <- c(filenames[i],accuracy_mirai_normal,fpr_mirai_normal,sensitivity_dlink_mirai_normal,specificity_dlink_mirai_normal)
  
  anomaly_frame <- rbind(anomaly_frame,anomaly_att)
  random_frame <- rbind(random_frame,anomaly_rand)
  random_frame2 <- rbind(random_frame2,anomaly_rand2)
  random_frame_mixed <- rbind(random_frame_mixed,anomaly_rand_mixed)
  ddos_frame <- rbind(ddos_frame,ddos)
  tplink_ddos_frame <- rbind(tplink_ddos_frame,tplink_ddos)
  mirai_attack_frame <-  rbind(mirai_attack_frame,dlink_mirai_att)
  # mirai_normal_frame <-  rbind(mirai_normal_frame,dlink_mirai_norm)
  h2o.removeAll()
  # model_random$f_time_window <- random$f_time_window
  # sum(model_random$f_time_window[which(model_random$anomaly==1 & model_random_actualanom==0)])
  # 
}

anomaly_frame <- anomaly_frame[-1,] %>% rename("fnr"="fpr")
random_frame <- random_frame[-1,]
random_frame2 <- random_frame2[-1,]
random_frame_mixed <- random_frame_mixed[-1,]
ddos_frame <- ddos_frame[-1,]
tplink_ddos_frame <- tplink_ddos_frame[-1,]
mirai_attack_frame <- mirai_attack_frame[-1,]
# mirai_normal_frame <- mirai_normal_frame[-1,]

write.csv(anomaly_frame,"Results/anomaly.csv")
write.csv(random_frame,"Results/stream.csv")
write.csv(random_frame2,"Results/idle.csv")
write.csv(random_frame_mixed,"Results/mixed.csv")
write.csv(ddos_frame,"Results/ddos.csv")
write.csv(tplink_ddos_frame,"Results/tplink_ddos.csv")
write.csv(mirai_attack_frame,"Results/mirai_attack_frame.csv")
# write.csv(mirai_normal_frame,"Results/mirai_normal_frame.csv")

source("Results/Bin_Win_Analysis.R")
# setwd("/home/itrust/Desktop/IDS/try10/")
source("supervised_attack.R")
