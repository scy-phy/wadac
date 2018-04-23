library(randomForest)
library(caret)
library(dplyr)
i <- grep("bnl800_bks300.db",filenames,ignore.case = T)



packet_features <- list_files[[i]][[2]] 
attack_features_nestcam <- list_files2[[i]][[2]]
attack_features_tplink <- list_files3[[i]][[2]]
attack_features_nestcam <- attack_features_nestcam[,which(colnames(attack_features_nestcam) %in% colnames(packet_features))] 
attack_features_tplink <- attack_features_tplink[,which(colnames(attack_features_tplink) %in% colnames(packet_features))]

attack_features_mirai <- mirai_attack[,which(colnames(mirai_attack) %in% colnames(packet_features))]

attack_features <- rbind(attack_features_nestcam,attack_features_tplink,attack_features_mirai)
attack_features2 <- attack_features %>% filter(!grepl("normalactions",t_label,ignore.case=T) )
# attack_features2 <- attack_features2[,which(colnames(attack_features2) %in% colnames(packet_features))] 

anomaly_set <- packet_features %>% filter(!(grepl("streaming",t_label,ignore.case=T) | grepl("idle",t_label,ignore.case=T) ))
anomaly_set <- rbind(anomaly_set,attack_features2)

attack_list <- data.frame(num = c(1:7),attack = c("firmware","Slowloris","attacktelnet","Vulncheck","UDPFlood","ddos","mirai"))

anomaly_set <- anomaly_set %>% mutate(anom = ifelse(grepl("firmware",t_label),"firmware",
                                                          ifelse(grepl("Slowloris",t_label,ignore.case=T),"Slowloris",
                                                                 ifelse(grepl("attacktelnet",t_label,ignore.case=T),"attacktelnet",
                                                                        ifelse(grepl("VulnCheck",t_label,ignore.case=T),"VulnCheck",
                                                                               ifelse(grepl("UdpFlood",t_label,ignore.case=T),"UDPFlood","mirai")
                                                                        )
                                                                 )
                                                                 )
                                                          )) %>% mutate(t_label = as.factor(anom),anom=NULL,t_mac = NULL)




set.seed(1234)
train_anomaly_index <- createDataPartition(anomaly_set$t_label,times = 1,p=0.65, list = F)
train_anom <- anomaly_set[train_anomaly_index,] 
test_anom <-  anomaly_set[-train_anomaly_index,] 


mtry=floor(sqrt(ncol(train_anom)))
ntree = 1000

set.seed(1234)
rf_model<-train(t_label~.,data=train_anom,method="rf",
                trControl=trainControl(method="cv",number=10),
                prox=TRUE,allowParallel=TRUE)
print(rf_model)
best_model <- rf_model$finalModel
library(ggRandomForests)
gg_e <- gg_error(best_model)
plot(gg_e)
ggsave(paste0("Results/Plots/RF/RF_ntree_analysis",".png"))

test_anom$pred_label <- predict(best_model,newdata=test_anom,type = "response")
xtab <- table(test_anom$pred_label,test_anom$t_label)
ch <- confusionMatrix(xtab)
ch$overall

write.csv(ch$byClass,"Results/Plots/RF/by_class_measure.csv")
write.csv(ch$overall,"Results/Plots/RF/overall_measures.csv")
print(ch$table)
write.csv(ch$table,"Results/Plots/RF/confusion_matrix.csv")

imp_vars <- as.data.frame(best_model$importance)
imp_vars$Vars = rownames(imp_vars)
imp_vars <- imp_vars %>% mutate(Imp = round((MeanDecreaseGini/sum(MeanDecreaseGini))*100,3)) %>% select(-MeanDecreaseGini)
imp_vars <- imp_vars[with(imp_vars, order(-Imp)), ]
imp_vars <- imp_vars[1:10,]
# save.image(file= "after_supervised_400.RDA")

# setwd("/home/itrust/Desktop/IDS/try10/")
description_file <- read.csv(file = "description.csv",sep = ",", header = F,stringsAsFactors = F)
description_file <- description_file %>% mutate(V3 = paste0(V3,V4),V4 = NULL, V1 = trimws(V1,which=c("both"))) %>% rename("variable" = "V1") %>% mutate(variable_join = gsub("_b_","",variable))
var_imp <- imp_vars %>% rename("Variable"= "Vars")
var_imp <- var_imp %>% mutate(variable_join = gsub("_b[0-9]*","",Variable)) %>% left_join(description_file,by=c("variable_join"))
write.csv(var_imp,"Results/imp/supervised/supervised_var_imp.csv")

# anomaly_set <- anomaly_set %>% mutate(t_label= as.factor(t_label))
qplot(data = anomaly_set, x = f_mn_xs_dx_b0,y= t_label,colour = t_label, geom = "point")
ggsave(paste0("Results/Plots/RF/f_mn_xs_dx_b0_1",".png"))

# anomaly_set <- anomaly_set %>% mutate(t_label= as.factor(t_label))
qplot(data = anomaly_set, x = f_mn_xs_dr_b0 ,y= t_label,colour = t_label, geom = "point")
ggsave(paste0("Results/Plots/RF/f_mn_xs_dr_b0_2 ",".png"))

qplot(data = anomaly_set, x = c_c_cs,y= t_label,colour = t_label, geom = "point")
ggsave(paste0("Results/Plots/RF/c_c_cs_3",".png"))


qplot(data = anomaly_set, x = f_fr_cs_cx,y= t_label,colour = t_label, geom = "point")
ggsave(paste0("Results/Plots/RF/f_fr_cs_cx_4",".png"))

# anomaly_set <- anomaly_set %>% mutate(t_label= as.factor(t_label))
qplot(data = anomaly_set, x =  c_c_ds,y= t_label,colour = t_label, geom = "point")
ggsave(paste0("Results/Plots/RF/c_c_ds",".png"))


