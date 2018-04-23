model_random = as.data.frame(h2o.anomaly(model_stream, random.hex, per_feature=F))
model_random$bla_stream <- sort(model_random$Reconstruction.MSE)
# model_random$label_no <- randoming_data$t_label
ggplot(data = model_random,aes(y =bla_stream,x=c(1:nrow(model_random)))) + geom_point() +ylim(0,0.05) # eRROR = 0.005





model_random_idle = as.data.frame(h2o.anomaly(model_idle, random.hex, per_feature=F))
model_random_idle$bla_idle <- sort(model_random_idle$Reconstruction.MSE)

model_random_idle <- model_random_idle %>% rename(Reconstruction.MSE_idle = Reconstruction.MSE)


# model_random$label_no <- randoming_data$t_label
ggplot(data = model_random_idle,aes(y =bla_idle,x=c(1:nrow(model_random)))) + geom_point() +ylim(0,0.05) # eRROR = 0.005




model_random <- cbind(model_random,model_random_idle)

model_random <- model_random %>% mutate(anomaly = ifelse((Reconstruction.MSE >=stream_limit_upper | Reconstruction.MSE <= stream_limit_low) & (Reconstruction.MSE_idle >=idle_limit_upper | Reconstruction.MSE_idle <= idle_limit_low ),1,0 ))

table(model_random$anomaly)
model_random_actualanom <- random_stream$anomaly

check2 <- table(model_random$anomaly,model_random_actualanom)
print(check2)
accuracy_random = (check2[1]+check2[4])/(check2[1]+check2[4]+check2[2]+check2[3])
fpr_random = check2[2]/(check2[2]+check2[4])
print(paste0("Accuracy of random set = ",accuracy_random*100))
print(paste0("FPR of random set stream = ",fpr_random*100))

matrix_name <- substring(filenames[i], regexpr("bnl[0-9]{2}", filenames[i]),regexpr(".db", filenames[i])-1)
write.csv(check2,paste0("Results/confusion_matrix/stream_set/",matrix_name,".csv"))



sensitivity_random_stream <- sensitivity(check2)
specificity_random_stream <- specificity(check2)

print(paste0("specificity of random stream set = " , specificity_random_stream))
print(paste0("sensitivity of random stream set = " , sensitivity_random_stream))


prediction_obj <- prediction(model_random$anomaly,model_random_actualanom)
plot_precall(prediction_obj = prediction_obj,plot_name = paste0("/stream_set/",substring(filenames[i], regexpr("bnl[0-9]{2}", filenames[i]),regexpr(".db", filenames[i])-1)))



mean_mse <- model_random %>%
  group_by(anomaly) %>%
  summarise(mean = mean(Reconstruction.MSE))

model_random <- model_random %>%  tibble::rownames_to_column()
ggplot(model_random, aes(x = as.numeric(rowname), y = Reconstruction.MSE, color = as.factor(anomaly))) +
  geom_point(alpha = 0.3) +
  geom_hline(data = mean_mse, aes(yintercept = mean, color = as.factor(anomaly))) +
  scale_color_brewer(palette = "Set1") +
  labs(x = "instance number",
       color = "Class")

ggsave(filename = paste0("Results/Anomaly_Plots/",bin_blk,"_random_stream.png"))
# ggsave(filename = "/home/itrust/Desktop/IDS/try10/Results/Anomaly_Plots/random_stream.png")

#--------------------________#

sensitivity_random_stream_seq <- c()
specificity_random_stream_seq <- c()
for(k in 1:length(j)){
  model_random3 <- model_random %>% mutate(anomaly = ifelse((Reconstruction.MSE >=stream_limit_upper | Reconstruction.MSE <= stream_limit_low) & (Reconstruction.MSE_idle >=idle_limit_upper | Reconstruction.MSE_idle <= idle_limit_low ),1,0 ))
  
  table(model_random3$anomaly)
  model_random3_actualanom <- random_stream$anomaly
  
  check3 <- table(model_random3$anomaly,model_random3_actualanom)
  print(check3)
  sensitivity_random_stream_seq <- c(sensitivity_random_stream_seq,sensitivity(check3))
  specificity_random_stream_seq <- c(specificity_random_stream_seq,specificity(check3))
  # plot(sensitivity_random_stream,specificity_random_stream)
  
  
}
# sort(specificity_random_stream_seq)
plot(sort(specificity_random_stream_seq),sort(sensitivity_random_stream_seq),type="point",col=as.factor(j))

ss_plot <- data.frame(specificity=specificity_random_stream_seq,sensitivity=sensitivity_random_stream_seq,j)
ggplot(ss_plot,aes(specificity,sensitivity,color=as.factor(j)))+geom_point()
ggsave(filename = paste0("Results/ROC_Seq_Plots/",bin_blk,"_random_stream.png"))
