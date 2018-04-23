source("grid_params.R")

model_zigbee <- best_zigbee
print(best_zigbee@model$model_summary)
write.csv(best_zigbee@model$model_summary,paste0("Results/model_summary/model_",bin_blk,"_zigbee.csv"))

zigbee_imp <- model_zigbee@model$variable_importances[1:10,]
write.csv(zigbee_imp,paste0("Results/imp/var_imp_",bin_blk,"_zigbee",".csv"))

model_zigbee2 = as.data.frame(h2o.anomaly(model_zigbee, train_normal.hex, per_feature=F))
model_zigbee2$bla <- sort(model_zigbee2$Reconstruction.MSE)
# model_stream$label_no <- streaming_data$t_label
ggplot(data = model_zigbee2,aes(y =bla,x=c(1:nrow(model_zigbee2)))) + geom_point() +ylim(0,0.01) # eRROR = 0.005

zigbee_limit_upper <- quantile(model_zigbee2$Reconstruction.MSE,probs = 0.95) + 1.5* IQR(model_zigbee2$Reconstruction.MSE)
zigbee_limit_low <- quantile(model_zigbee2$Reconstruction.MSE,probs = 0.01) #+ 1.5* IQR(model_zigbee2$Reconstruction.MSE)

zigbee_limit_upper_seq <- c()
# zigbee_limit_low_seq <- c()
j=seq(0.5, 1, by = 0.05)

for(k in j){
  zigbee_limit_upper_seq <- c(zigbee_limit_upper_seq,quantile(model_zigbee2$Reconstruction.MSE,probs = k)) #+ 1* IQR(model_zigbee2$Reconstruction.MSE)
  # zigbee_limit_low_seq <- c(zigbee_limit_low_seq,quantile(model_zigbee2$Reconstruction.MSE,probs = 0.01)) #+ 1.5* IQR(model_zigbee2$Reconstruction.MSE)
}

source("attack_set.R")
source("mixed_set.R")
