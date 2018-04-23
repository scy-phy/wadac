require(RSQLite)
require(dplyr)
require(caret)

model_mirai_attack = as.data.frame(h2o.anomaly(model_stream, mirai_attack.hex, per_feature=F))
model_mirai_attack_idle = as.data.frame(h2o.anomaly(model_idle, mirai_attack.hex, per_feature=F))
model_mirai_attack_idle <- model_mirai_attack_idle %>% rename(Reconstruction.MSE_idle = Reconstruction.MSE)

model_mirai_attack <- cbind(model_mirai_attack,model_mirai_attack_idle)

model_mirai_attack$bla_stream <- sort(model_mirai_attack$Reconstruction.MSE)
# model_mirai_attack$label_no <- anomalying_data$t_label
ggplot(data = model_mirai_attack,aes(y =bla_stream,x=c(1:nrow(model_mirai_attack)))) + geom_point() +ylim(0,0.05) # eRROR = 0.005


#Thresh stream = 0.02 thresh idle = 0.01 



model_mirai_attack_idle$bla_idle <- sort(model_mirai_attack_idle$Reconstruction.MSE)
# model_mirai_attack$label_no <- anomalying_data$t_label
ggplot(data = model_mirai_attack_idle,aes(y =bla_idle,x=c(1:nrow(model_mirai_attack_idle)))) + geom_point() +ylim(0,0.1) # eRROR = 0.005





model_mirai_attack <- model_mirai_attack %>% mutate(anomaly = ifelse((Reconstruction.MSE >=stream_limit_upper | Reconstruction.MSE <=stream_limit_low) & (Reconstruction.MSE_idle >=idle_limit_upper | Reconstruction.MSE_idle <= idle_limit_low ),1,0 ))
model_mirai_attack$t_label <- "mirai"

 model_mirai_attack <- model_mirai_attack %>% mutate(actual_anomaly =1)

 source("dlink_mirai_normal_code.R")
mirai <- rbind(model_mirai_attack,model_mirai_normal)



check <- table(mirai$anomaly)
check2 <- table(mirai$t_label,mirai$anomaly)
print(check2)
check_acc <- table(mirai$anomaly,mirai$actual_anomaly)
print(check_acc)
sensitivity_dlink_mirai_attack = ifelse(!any(mirai$anomaly==0),0,sensitivity(check_acc))
specificity_dlink_mirai_attack = ifelse(!any(mirai$anomaly==0),0,specificity(check_acc))
# sensitivity_dlink_ddos = sensitivity(check_acc)
# specificity_dlink_ddos = specificity(check_acc)

print(paste0("specificity of dlink mirai_attack set = " , specificity_dlink_mirai_attack))
print(paste0("sensitivity of dlink mirai_attack set = " , sensitivity_dlink_mirai_attack))

matrix_name <- substring(filenames[i], regexpr("bnl[0-9]{2}", filenames[i]),regexpr(".db", filenames[i])-1)
write.csv(check2,paste0("Results/confusion_matrix/dlink_mirai/",matrix_name,".csv"))


if(!is.na(check[2])){
  accuracy_mirai_attack = (check2[3]+check2[2])/(check2[1]+check2[2]+check2[3]+check2[4])
}
if(is.na(check[2])){
  accuracy_mirai_attack = check[1]/check[1]
}

fpr_mirai_attack <- check2[1]/(check[1]+check[2])
print(paste0("Accuracy of mirai_attack = ",accuracy_mirai_attack*100))



# prediction_obj <- prediction(mirai$anomaly,mirai$actual_anomaly)
# plot_precall(prediction_obj = prediction_obj,plot_name = paste0("/dlink_mirai/",substring(filenames[i], regexpr("bnl[0-9]{2}", filenames[i]),regexpr(".db", filenames[i])-1)))



mean_mse <- mirai %>%
  group_by(anomaly) %>%
  summarise(mean = mean(Reconstruction.MSE))

mirai <- mirai %>%  tibble::rownames_to_column()
ggplot(mirai, aes(x = as.numeric(rowname), y = Reconstruction.MSE, color = as.factor(anomaly))) +
  geom_point(alpha = 0.3) +
  geom_hline(data = mean_mse, aes(yintercept = mean, color = as.factor(anomaly))) +
  scale_color_brewer(palette = "Set1") +
  labs(x = "instance number",
       color = "Class")
ggsave(filename = paste0("Results/Anomaly_Plots/",bin_blk,"_dlink_mirai_attack.png"))









