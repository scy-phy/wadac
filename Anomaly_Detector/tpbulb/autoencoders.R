source("grid_params.R")

model_tpbulb <- best_tp
print(best_tp@model$model_summary)
write.csv(best_tp@model$model_summary,paste0("Results/model_summary/model_summary_",bin_blk,".csv"))

tpbulb_imp <- model_tpbulb@model$variable_importances[1:10,]
write.csv(tpbulb_imp,paste0("Results/imp/var_imp_",bin_blk,"_tpbulb",".csv"))

model_tpbulb2 = as.data.frame(h2o.anomaly(model_tpbulb, train_normal.hex, per_feature=F))
model_tpbulb2$bla <- sort(model_tpbulb2$Reconstruction.MSE)
# model_stream$label_no <- streaming_data$t_label
ggplot(data = model_tpbulb2,aes(y =bla,x=c(1:nrow(model_tpbulb2)))) + geom_point() +ylim(0,0.01) # eRROR = 0.005

tpbulb_limit_upper <- quantile(model_tpbulb2$Reconstruction.MSE,probs = 0.75) #+ 1.5* IQR(model_tpbulb2$Reconstruction.MSE)
tpbulb_limit_low <- quantile(model_tpbulb2$Reconstruction.MSE,probs = 0.01) #+ 1.5* IQR(model_tpbulb2$Reconstruction.MSE)

tpbulb_limit_upper_seq <- c()
# tpbulb_limit_low_seq <- c()
j=seq(0.5, 1, by = 0.05)

for(k in j){
  tpbulb_limit_upper_seq <- c(tpbulb_limit_upper_seq,quantile(model_tpbulb2$Reconstruction.MSE,probs = k)) #+ 1* IQR(model_tpbulb2$Reconstruction.MSE)
  # tpbulb_limit_low_seq <- c(tpbulb_limit_low_seq,quantile(model_tpbulb2$Reconstruction.MSE,probs = 0.01)) #+ 1.5* IQR(model_tpbulb2$Reconstruction.MSE)
}

source("attack_set.R")
source("mixed_set.R")
