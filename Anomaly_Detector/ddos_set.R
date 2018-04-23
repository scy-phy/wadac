require(RSQLite)
require(dplyr)
require(caret)
require(Information)
driver <- dbDriver("SQLite")


dbname <- filenames[i]
conn <- dbConnect(driver,dbname=paste0("/home/itrust/Desktop/IDS/sweta_nestcam/",dbname))

tab <- dbListTables(conn)
tab

attack_features <- dbGetQuery(conn,paste0("select * from ", tab[2])) 
attack_features2 <- dbGetQuery(conn,paste0("select * from ", tab[3])) 
attack_features3 <- dbGetQuery(conn,paste0("select * from ", tab[4])) 

attack_features <- cbind(attack_features, attack_features2 %>% select(-t_mac,-t_label,-c_blk_sz,-f_time_window),attack_features3 %>% select(-t_mac,-t_label,-c_blk_sz,-f_time_window))

attack_features <- attack_features %>% filter(grepl("dlink",t_label,ignore.case = T) | grepl("tplink",t_label,ignore.case = T) | grepl("Nestcam",t_label,ignore.case = T) |
                                                grepl("Netatmo",t_label,ignore.case = T))



attack_features <- attack_features[which(colnames(attack_features)%in%colnames(packet_features))]
attack_features <- attack_features[-which(attack_features$t_label=="nestcam_normalactions"),]
attack_nestcam <- list_files2[[i]][[2]]
attack_nestcam <- attack_nestcam[which(colnames(attack_nestcam)%in%colnames(packet_features))]
attack_features <- rbind(attack_features,attack_nestcam)

attack_ddos.hex <- as.h2o(attack_features,destination_frame = "attack_ddos.hex")

# 
# normal_features <- attack_features %>% filter(t_label=="nestcam_normalactions")
# check <- normal_features[1:3,]
# bla <- packet_features[grep("nestCam_liveStreaming",packet_features$t_label,ignore.case = T)[1:3],]
# check <- rbind(check,bla)
# check2 <- rbind(normal_features[1:3,],test_idle_netCam[1:3,],test_stream_netCam[1:3,])
# 
# mean_1 <- apply(normal_features[,-c(1:2)],2,function(x) mean(x,na.rm = T))
# bla2 <- packet_features[grep("nestCam_liveStreaming",packet_features$t_label,ignore.case = T),]
# mean_2 <- apply(bla2[,-c(60:61)],2,function(x) mean(x,na.rm = T))
# check3 <- rbind(mean_1,mean_2)
#-------------------------__#

model_ddos = as.data.frame(h2o.anomaly(model_stream, attack_ddos.hex, per_feature=F))
model_ddos_idle = as.data.frame(h2o.anomaly(model_idle, attack_ddos.hex, per_feature=F))
model_ddos_idle <- model_ddos_idle %>% rename(Reconstruction.MSE_idle = Reconstruction.MSE)

model_ddos <- cbind(model_ddos,model_ddos_idle)

model_ddos$bla_stream <- sort(model_ddos$Reconstruction.MSE)
# model_ddos$label_no <- anomalying_data$t_label
ggplot(data = model_ddos,aes(y =bla_stream,x=c(1:nrow(model_ddos)))) + geom_point() +ylim(0,0.05) # eRROR = 0.005


#Thresh stream = 0.02 thresh idle = 0.01 



model_ddos_idle$bla_idle <- sort(model_ddos_idle$Reconstruction.MSE)
# model_ddos$label_no <- anomalying_data$t_label
ggplot(data = model_ddos_idle,aes(y =bla_idle,x=c(1:nrow(model_ddos_idle)))) + geom_point() +ylim(0,0.1) # eRROR = 0.005





model_ddos <- model_ddos %>% mutate(anomaly = ifelse((Reconstruction.MSE >=stream_limit_upper | Reconstruction.MSE <=stream_limit_low) & (Reconstruction.MSE_idle >=idle_limit_upper | Reconstruction.MSE_idle <= idle_limit_low ),1,0 ))
model_ddos$t_label <- attack_features$t_label




check <- table(model_ddos$anomaly)
check2 <- table(model_ddos$t_label,model_ddos$anomaly)
print(check2)

model_ddos <- model_ddos %>% mutate(actual_anomaly = ifelse(grepl("normalactions",t_label,ignore.case = T),0,1))
check_acc <- table(model_ddos$anomaly,model_ddos$actual_anomaly)

specificity_nestcam_ddos = ifelse(!any(model_ddos$anomaly==0),0,specificity(check_acc)) #(check2[5]+check2[6]+check2[7])/(check2[5]+check2[6]+check2[7]+check2[1]+check2[2]+check2[3])
sensitivity_nestcam_ddos =  ifelse(!any(model_ddos$anomaly==0),0,sensitivity(check_acc))#check2[4]/(check2[4]+check2[8])



print(paste0("specificity of nestcam ddos set = " , specificity_nestcam_ddos))
print(paste0("sensitivity of nestcam ddos set = " , sensitivity_nestcam_ddos))

matrix_name <- substring(filenames[i], regexpr("bnl[0-9]{2}", filenames[i]),regexpr(".db", filenames[i])-1)
write.csv(check2,paste0("Results/confusion_matrix/nestcam_ddos/",matrix_name,".csv"))



if(!is.na(check[2])){
  accuracy_ddos = (check2[5]+check2[6]+check2[7]+check2[4])/sum(check2)
}
if(is.na(check[2])){
  accuracy_ddos = check[1]/check[1]
}

fpr_ddos <- check[1]/(check[1]+check[2])
print(paste0("Accuracy of DDoS = ",accuracy_ddos*100))



prediction_obj <- prediction(model_ddos$anomaly,model_ddos$actual_anomaly)
plot_precall(prediction_obj = prediction_obj,plot_name = paste0("/nestcam_ddos/",substring(filenames[i], regexpr("bnl[0-9]{2}", filenames[i]),regexpr(".db", filenames[i])-1)))




mean_mse <- model_ddos %>%
  group_by(anomaly) %>%
  summarise(mean = mean(Reconstruction.MSE))

model_ddos <- model_ddos %>%  tibble::rownames_to_column()
ggplot(model_ddos, aes(x = as.numeric(rowname), y = Reconstruction.MSE, color = as.factor(anomaly))) +
  geom_point(alpha = 0.3) +
  geom_hline(data = mean_mse, aes(yintercept = mean, color = as.factor(anomaly))) +
  scale_color_brewer(palette = "Set1") +
  labs(x = "instance number",
       color = "Class")

ggsave(filename = paste0("Results/Anomaly_Plots/",bin_blk,"_netcam_ddos.png"))







