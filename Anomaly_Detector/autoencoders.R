feature_names = colnames(train_idle)
source("grid_params.R")

model_idle <- best_idle
print(best_idle@model$model_summary)

model_stream <- best_stream
print(best_stream@model$model_summary)

write.csv(best_stream@model$model_summary,paste0("Results/model_summary/stream/model_summary_",bin_blk,"_stream",".csv"))
write.csv(best_idle@model$model_summary,paste0("Results/model_summary/idle/model_summary_",bin_blk,"_idle",".csv"))
stream_imp <- model_stream@model$variable_importances[1:10,]
write.csv(stream_imp,paste0("Results/imp/var_imp_",bin_blk,"_stream",".csv"))
idle_imp <- model_idle@model$variable_importances[1:10,]
write.csv(idle_imp,paste0("Results/imp/var_imp_",bin_blk,"_idle",".csv"))

model_stream2 = as.data.frame(h2o.anomaly(model_stream, train_stream.hex, per_feature=F))
model_stream2$bla <- sort(model_stream2$Reconstruction.MSE)
# model_stream$label_no <- streaming_data$t_label
ggplot(data = model_stream2,aes(y =bla,x=c(1:nrow(model_stream2)))) + geom_point() +ylim(0,0.01) # eRROR = 0.005



stream_limit_upper <- quantile(model_stream2$Reconstruction.MSE,probs = 0.75) + 1.5* IQR(model_stream2$Reconstruction.MSE)
stream_limit_low <- quantile(model_stream2$Reconstruction.MSE,probs = 0.01) #+ 1.5* IQR(model_stream2$Reconstruction.MSE)

model_idle2 = as.data.frame(h2o.anomaly(model_idle, train_idle.hex, per_feature=F))
model_idle2$bla <- sort(model_idle2$Reconstruction.MSE)
# model_stream$label_no <- streaming_data$t_label
ggplot(data = model_idle2,aes(y =bla,x=c(1:nrow(model_idle2)))) + geom_point() +ylim(0,0.01) # eRROR = 0.005

idle_limit_upper <- quantile(model_idle2$Reconstruction.MSE,probs = 0.75) #+ 1.5* IQR(model_idle2$Reconstruction.MSE)
idle_limit_low <- quantile(model_idle2$Reconstruction.MSE,probs = 0.01) #+ 1.5* IQR(model_idle2$Reconstruction.MSE)

stream_limit_low_seq <- c()
stream_limit_upper_seq <- c()
idle_limit_upper_seq <- c()
idle_limit_low_seq <- c()
j=seq(0.0, 1, by = 0.05)

for(k in j){
  stream_limit_upper_seq <- c(stream_limit_upper_seq,quantile(model_stream2$Reconstruction.MSE,probs = k) + 1.5* IQR(model_stream2$Reconstruction.MSE))
  stream_limit_low_seq <- c(stream_limit_low_seq,quantile(model_stream2$Reconstruction.MSE,probs = 0.01)) #+ 1.5* IQR(model_stream2$Reconstruction.MSE))
  idle_limit_upper_seq <- c(idle_limit_upper_seq,quantile(model_idle2$Reconstruction.MSE,probs = k)) #+ 1* IQR(model_idle2$Reconstruction.MSE)
  idle_limit_low_seq <- c(idle_limit_low_seq,quantile(model_idle2$Reconstruction.MSE,probs = 0.01)) #+ 1.5* IQR(model_idle2$Reconstruction.MSE)
}

 # stream_limit_upper <- quantile(model_stream2$Reconstruction.MSE,probs = 0.75) + 1.5* IQR(model_stream2$Reconstruction.MSE)
 # idle_limit_upper <- quantile(model_idle2$Reconstruction.MSE,probs = 0.75) #+ 1.5* IQR(model_idle2$Reconstruction.MSE)

source("anomaly_set.R")
source("random_set_idle.R")
source("random_set_stream.R")
source("random_mixed.R")
source("ddos_set.R")
source("tplink.R")
source("dlink_mirai.R")
source("mirai_att1.R")
source("mirai_att2.R")
source("mirai_att1_new.R")
source("mirai_att2_new.R")
# source("dlink_mirai_normal_code.R")