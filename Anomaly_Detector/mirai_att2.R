require(RSQLite)
require(dplyr)
require(caret)

model_mirai_att2 = as.data.frame(h2o.anomaly(model_stream, mirai_att2.hex, per_feature=F))
model_mirai_att2_idle = as.data.frame(h2o.anomaly(model_idle, mirai_att2.hex, per_feature=F))
model_mirai_att2_idle <- model_mirai_att2_idle %>% rename(Reconstruction.MSE_idle = Reconstruction.MSE)

model_mirai_att2 <- cbind(model_mirai_att2,model_mirai_att2_idle)

model_mirai_att2$bla_stream <- sort(model_mirai_att2$Reconstruction.MSE)
# model_mirai_att2$label_no <- anomalying_data$t_label
ggplot(data = model_mirai_att2,aes(y =bla_stream,x=c(1:nrow(model_mirai_att2)))) + geom_point() +ylim(0,0.05) # eRROR = 0.005


#Thresh stream = 0.02 thresh idle = 0.01 



model_mirai_att2_idle$bla_idle <- sort(model_mirai_att2_idle$Reconstruction.MSE)
# model_mirai_att2$label_no <- anomalying_data$t_label
ggplot(data = model_mirai_att2_idle,aes(y =bla_idle,x=c(1:nrow(model_mirai_att2_idle)))) + geom_point() +ylim(0,0.1) # eRROR = 0.005





model_mirai_att2 <- model_mirai_att2 %>% mutate(anomaly = ifelse((Reconstruction.MSE >=stream_limit_upper | Reconstruction.MSE <=stream_limit_low) & (Reconstruction.MSE_idle >=idle_limit_upper | Reconstruction.MSE_idle <= idle_limit_low ),1,0 ))
model_mirai_att2$t_label <- mirai_att2$t_label

model_mirai_att2 <- model_mirai_att2 %>% mutate(actual_anomaly =1)
table(model_mirai_att2$anomaly,model_mirai_att2$t_label)


# source("dlink_mirai_normal_code.R")
# mirai <- rbind(model_mirai_att2,model_mirai_normal)
# 
# 
# 
# check <- table(mirai$anomaly)
# check2 <- table(mirai$t_label,mirai$anomaly)
# print(check2)
# check_acc <- table(mirai$anomaly,mirai$actual_anomaly)
# print(check_acc)
# sensitivity_dlink_mirai_att2 = ifelse(!any(mirai$anomaly==0),0,sensitivity(check_acc))
# specificity_dlink_mirai_att2 = ifelse(!any(mirai$anomaly==0),0,specificity(check_acc))
# # sensitivity_dlink_ddos = sensitivity(check_acc)
# # specificity_dlink_ddos = specificity(check_acc)
# 
# print(paste0("specificity of dlink mirai_att2 set = " , specificity_dlink_mirai_att2))
# print(paste0("sensitivity of dlink mirai_att2 set = " , sensitivity_dlink_mirai_att2))
# 
# matrix_name <- substring(filenames[i], regexpr("bnl[0-9]{2}", filenames[i]),regexpr(".db", filenames[i])-1)
# write.csv(check2,paste0("Results/confusion_matrix/dlink_mirai/",matrix_name,".csv"))
# 
# 
# if(!is.na(check[2])){
#   accuracy_mirai_att2 = (check2[3]+check2[2])/(check2[1]+check2[2]+check2[3]+check2[4])
# }
# if(is.na(check[2])){
#   accuracy_mirai_att2 = check[1]/check[1]
# }
# 
# fpr_mirai_att2 <- check2[1]/(check[1]+check[2])
# print(paste0("Accuracy of mirai_att2 = ",accuracy_mirai_att2*100))
# 
# 
# 
# # prediction_obj <- prediction(mirai$anomaly,mirai$actual_anomaly)
# # plot_precall(prediction_obj = prediction_obj,plot_name = paste0("/dlink_mirai/",substring(filenames[i], regexpr("bnl[0-9]{2}", filenames[i]),regexpr(".db", filenames[i])-1)))
# 
# 
# 
# mean_mse <- mirai %>%
#   group_by(anomaly) %>%
#   summarise(mean = mean(Reconstruction.MSE))
# 
# mirai <- mirai %>%  tibble::rownames_to_column()
# ggplot(mirai, aes(x = as.numeric(rowname), y = Reconstruction.MSE, color = as.factor(anomaly))) +
#   geom_point(alpha = 0.3) +
#   geom_hline(data = mean_mse, aes(yintercept = mean, color = as.factor(anomaly))) +
#   scale_color_brewer(palette = "Set1") +
#   labs(x = "instance number",
#        color = "Class")
# ggsave(filename = paste0("Results/Anomaly_Plots/",bin_blk,"_dlink_mirai_att2.png"))
# 
# 







