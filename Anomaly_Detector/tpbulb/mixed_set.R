library(ROCR)
model_tpbulb_mixed = as.data.frame(h2o.anomaly(model_tpbulb, mixed.hex, per_feature=F))
model_tpbulb_mixed$bla_stream <- sort(model_tpbulb_mixed$Reconstruction.MSE)
# model_tpbulb_mixed$label_no <- randoming_data$t_label
ggplot(data = model_tpbulb_mixed,aes(y =bla_stream,x=c(1:nrow(model_tpbulb_mixed)))) + geom_point() +ylim(0,0.05) # eRROR = 0.005

model_tpbulb_mixed$t_label <- labels[[4]]
model_tpbulb_mixed <- model_tpbulb_mixed %>% mutate(anomaly = ifelse((Reconstruction.MSE >=tpbulb_limit_upper | Reconstruction.MSE <= tpbulb_limit_low),1,0 ),
                                                    actual_anomaly = ifelse(!grepl("normal",t_label),1,0)
                                                    )

check4 <- table(model_tpbulb_mixed$anomaly,model_tpbulb_mixed$actual_anomaly)
print(check4)
accuracy_random_mixed = (check4[1]+check4[4])/(check4[1]+check4[4]+check4[2]+check4[3])
print(paste0("Accuracy of mixed set = ",accuracy_random_mixed*100))

sensitivity_random_mixed <- sensitivity(check4)
specificity_random_mixed <- specificity(check4)

print(paste0("specificity of random mixed set = " , specificity_random_mixed))
print(paste0("sensitivity of random mixed set = " , sensitivity_random_mixed))

check5 <- table(model_tpbulb_mixed$t_label,model_tpbulb_mixed$anomaly)
print(check5)

write.csv(check4,paste0("Results/confusion_matrix/mixed_set/",bin_blk,".csv"))
write.csv(check5,paste0("Results/confusion_matrix/mixed_set/",bin_blk,"_labels_matrix.csv"))


prediction_obj <- prediction(model_tpbulb_mixed$anomaly,model_tpbulb_mixed$actual_anomaly)
plot_precall(prediction_obj = prediction_obj,plot_name = paste0("/mixed_set/",bin_blk))


mean_mse <- model_tpbulb_mixed %>%
  group_by(anomaly) %>%
  summarise(mean = mean(Reconstruction.MSE))

model_tpbulb_mixed <- model_tpbulb_mixed %>%  tibble::rownames_to_column()
ggplot(model_tpbulb_mixed, aes(x = as.numeric(rowname), y = Reconstruction.MSE, color = as.factor(anomaly))) +
  geom_point(alpha = 0.3) +
  geom_hline(data = mean_mse, aes(yintercept = mean, color = as.factor(anomaly))) +
  scale_color_brewer(palette = "Set1") +
  labs(x = "instance number",
       color = "Class")+ylim(0,0.2)
ggsave(filename = paste0("Results/Anomaly_Plots/mixed_set/",bin_blk,"_random_mixed.png"))


######----------------__#########
sensitivity_random_mixed_seq <- c()
specificity_random_mixed_seq <- c()
for(k in 1:length(j)){
  model_tpbulb3 <- model_tpbulb_mixed %>% mutate(anomaly = ifelse((Reconstruction.MSE >=tpbulb_limit_upper_seq[k] | Reconstruction.MSE <= tpbulb_limit_low ),1,0 ))
  
  table(model_tpbulb3$anomaly)
  model_tpbulb3_actualanom <- model_tpbulb_mixed$actual_anomaly
  
  check3 <- table(model_tpbulb3$anomaly,model_tpbulb3_actualanom)
  print(check3)
  sensitivity_random_mixed_seq <- c(sensitivity_random_mixed_seq,sensitivity(check3))
  specificity_random_mixed_seq <- c(specificity_random_mixed_seq,specificity(check3))
  # plot(sensitivity_random_mixed,specificity_random_mixed)
  
  
}
# sort(specificity_random_mixed_seq)
# plot(sort(specificity_random_mixed_seq),sort(sensitivity_random_mixed_seq),type="l",col=as.factor(j))

ss_plot <- data.frame(specificity=specificity_random_mixed_seq,sensitivity=sensitivity_random_mixed_seq,j)
ggplot(ss_plot,aes(specificity,sensitivity,color=as.factor(j)))+geom_point()
ggsave(filename = paste0("Results/ROC_Seq_Plots/",bin_blk,"_random_mixed.png"))