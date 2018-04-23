require(RSQLite)
require(dplyr)
require(caret)

model_mirai_normal = as.data.frame(h2o.anomaly(model_stream, mirai_normal.hex, per_feature=F))
model_mirai_normal_idle = as.data.frame(h2o.anomaly(model_idle, mirai_normal.hex, per_feature=F))
model_mirai_normal_idle <- model_mirai_normal_idle %>% rename(Reconstruction.MSE_idle = Reconstruction.MSE)

model_mirai_normal <- cbind(model_mirai_normal,model_mirai_normal_idle)

model_mirai_normal$bla_stream <- sort(model_mirai_normal$Reconstruction.MSE)
# model_mirai_normal$label_no <- anomalying_data$t_label
ggplot(data = model_mirai_normal,aes(y =bla_stream,x=c(1:nrow(model_mirai_normal)))) + geom_point() +ylim(0,0.05) # eRROR = 0.005


#Thresh stream = 0.02 thresh idle = 0.01 



model_mirai_normal_idle$bla_idle <- sort(model_mirai_normal_idle$Reconstruction.MSE)
# model_mirai_normal$label_no <- anomalying_data$t_label
ggplot(data = model_mirai_normal_idle,aes(y =bla_idle,x=c(1:nrow(model_mirai_normal_idle)))) + geom_point() +ylim(0,0.1) # eRROR = 0.005





model_mirai_normal <- model_mirai_normal %>% mutate(anomaly = ifelse((Reconstruction.MSE >=stream_limit_upper | Reconstruction.MSE <=stream_limit_low) & (Reconstruction.MSE_idle >=idle_limit_upper | Reconstruction.MSE_idle <= idle_limit_low ),1,0 ))
model_mirai_normal$t_label <- "normal"

model_mirai_normal <- model_mirai_normal %>% mutate(actual_anomaly = 0)


check <- table(model_mirai_normal$anomaly)
check2 <- table(model_mirai_normal$t_label,model_mirai_normal$anomaly)
print(check2)
check_acc <- table(model_mirai_normal$anomaly,model_mirai_normal$actual_anomaly)

# sensitivity_dlink_mirai_normal = ifelse(!any(model_mirai_normal$anomaly==0),0,sensitivity(check_acc))
# specificity_dlink_mirai_normal = ifelse(!any(model_mirai_normal$anomaly==0),0,specificity(check_acc))
# sensitivity_dlink_ddos = sensitivity(check_acc)
# specificity_dlink_ddos = specificity(check_acc)

# print(paste0("specificity of dlink mirai_normal set = " , specificity_dlink_mirai_normal))
# print(paste0("sensitivity of dlink mirai_normal set = " , sensitivity_dlink_mirai_normal))
# 
# matrix_name <- substring(filenames[i], regexpr("bnl[0-9]{2}", filenames[i]),regexpr(".db", filenames[i])-1)
# write.csv(check2,paste0("Results/confusion_matrix/dlink_mirai/",matrix_name,".csv"))
# 
# 
# if(!is.na(check[2])){
#   accuracy_mirai_normal = (check2[3]+check2[2])/(check2[1]+check2[2]+check2[3]+check2[4])
# }
# if(is.na(check[2])){
#   accuracy_mirai_normal = check[1]/check[1]
# }
# 
# fpr_mirai_normal <- check2[1]/(check[1]+check[2])
# print(paste0("Accuracy of mirai_normal = ",accuracy_mirai_normal*100))
# 
# 
# 
# prediction_obj <- prediction(model_mirai_normal$anomaly,model_mirai_normal$actual_anomaly)
# plot_precall(prediction_obj = prediction_obj,plot_name = paste0("/dlink_mirai/",substring(filenames[i], regexpr("bnl[0-9]{2}", filenames[i]),regexpr(".db", filenames[i])-1)))
# 
# 
# 
# mean_mse <- model_mirai_normal %>%
#   group_by(anomaly) %>%
#   summarise(mean = mean(Reconstruction.MSE))
# 
# model_mirai_normal <- model_mirai_normal %>%  tibble::rownames_to_column()
# ggplot(model_mirai_normal, aes(x = as.numeric(rowname), y = Reconstruction.MSE, color = as.factor(anomaly))) +
#   geom_point(alpha = 0.3) +
#   geom_hline(data = mean_mse, aes(yintercept = mean, color = as.factor(anomaly))) +
#   scale_color_brewer(palette = "Set1") +
#   labs(x = "instance number",
#        color = "Class")
# ggsave(filename = paste0("Results/Anomaly_Plots/",bin_blk,"_dlink_mirai_normal.png"))
# 
# 
# 
# 





