
model_random2 = as.data.frame(h2o.anomaly(model_stream, random2.hex, per_feature=F))
model_random2$bla_stream <- sort(model_random2$Reconstruction.MSE)
# model_random2$label_no <- randoming_data$t_label
ggplot(data = model_random2,aes(y =bla_stream,x=c(1:nrow(model_random2)))) + geom_point() +ylim(0,0.05) # eRROR = 0.005





model_random2_idle = as.data.frame(h2o.anomaly(model_idle, random2.hex, per_feature=F))
model_random2_idle$bla_idle <- sort(model_random2_idle$Reconstruction.MSE)

model_random2_idle <- model_random2_idle %>% rename(Reconstruction.MSE_idle = Reconstruction.MSE)


# model_random2$label_no <- randoming_data$t_label
ggplot(data = model_random2_idle,aes(y =Reconstruction.MSE_idle,x=c(1:nrow(model_random2_idle)))) + geom_point() +ylim(0,0.05) # eRROR = 0.005




model_random2 <- cbind(model_random2,model_random2_idle)



model_random2 <- model_random2 %>% mutate(anomaly = ifelse((Reconstruction.MSE >=stream_limit_upper | Reconstruction.MSE <= stream_limit_low) & (Reconstruction.MSE_idle >=idle_limit_upper | Reconstruction.MSE_idle <= idle_limit_low ),1,0 ))

table(model_random2$anomaly)
model_random2_actualanom <- random_idle$anomaly

check3 <- table(model_random2$anomaly,model_random2_actualanom)
print(check3)
matrix_name <- substring(filenames[i], regexpr("bnl[0-9]{2}", filenames[i]),regexpr(".db", filenames[i])-1)
write.csv(check3,paste0("Results/confusion_matrix/idle_set/",matrix_name,".csv"))
sensitivity_random_idle <- sensitivity(check3)
specificity_random_idle <- specificity(check3)
# plot(sensitivity_random_idle,specificity_random_idle)






accuracy_random2 = (check3[1]+check3[4])/(check3[1]+check3[4]+check3[2]+check3[3])
fpr_random2 = check3[2]/(check3[2]+check3[4])
print(paste0("Accuracy of random set idle = ",accuracy_random2*100))
print(paste0("FPR of random set idle = ",fpr_random2*100))
print(paste0("specificity of random idle set = " , specificity_random_idle))
print(paste0("sensitivity of random idle set = " , sensitivity_random_idle))



prediction_obj <- prediction(model_random2$anomaly,model_random2_actualanom)
plot_precall(prediction_obj = prediction_obj,plot_name = paste0("/idle_set/",substring(filenames[i], regexpr("bnl[0-9]{2}", filenames[i]),regexpr(".db", filenames[i])-1)))


# dev.copy(png,"tesst.png")





mean_mse <- model_random2 %>%
  group_by(anomaly) %>%
  summarise(mean = mean(Reconstruction.MSE))

model_random2 <- model_random2 %>%  tibble::rownames_to_column()
ggplot(model_random2, aes(x = as.numeric(rowname), y = Reconstruction.MSE, color = as.factor(anomaly))) +
  geom_point(alpha = 0.3) +
  geom_hline(data = mean_mse, aes(yintercept = mean, color = as.factor(anomaly))) +
  scale_color_brewer(palette = "Set1") +
  labs(x = "instance number",
       color = "Class")
ggsave(filename = paste0("Results/Anomaly_Plots/",bin_blk,"_random_idle.png"))




#-------------#
sensitivity_random_idle_seq <- c()
specificity_random_idle_seq <- c()
for(k in 1:length(j)){
  model_random3 <- model_random2 %>% mutate(anomaly = ifelse((Reconstruction.MSE >=stream_limit_upper_seq[k] | Reconstruction.MSE <= stream_limit_low) & (Reconstruction.MSE_idle >=idle_limit_upper_seq[k] | Reconstruction.MSE_idle <= idle_limit_low ),1,0 ))

  table(model_random3$anomaly)
  model_random3_actualanom <- random_idle$anomaly

  check3 <- table(model_random3$anomaly,model_random3_actualanom)
  # print(check3)
  sensitivity_random_idle_seq <- c(sensitivity_random_idle_seq,sensitivity(check3))
  specificity_random_idle_seq <- c(specificity_random_idle_seq,specificity(check3))
  # plot(sensitivity_random_idle,specificity_random_idle)


}
# sort(specificity_random_idle_seq)
plot(sort(specificity_random_idle_seq),(sensitivity_random_idle_seq),type="l",col="blue")
ss_plot <- data.frame(specificity=specificity_random_idle_seq,sensitivity=sensitivity_random_idle_seq,j)
ggplot(ss_plot,aes(specificity,sensitivity,color=as.factor(j)))+geom_point()
ggsave(filename = paste0("Results/ROC_Seq_Plots/",bin_blk,"_random_idle.png"))
