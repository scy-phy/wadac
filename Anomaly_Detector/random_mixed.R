
model_random_mixed = as.data.frame(h2o.anomaly(model_stream, random_mixed.hex, per_feature=F))
model_random_mixed$bla_stream <- sort(model_random_mixed$Reconstruction.MSE)
# model_random_mixed$label_no <- randoming_data$t_label
ggplot(data = model_random_mixed,aes(y =bla_stream,x=c(1:nrow(model_random_mixed)))) + geom_point() +ylim(0,0.05) # eRROR = 0.005





model_random_mixed_idle = as.data.frame(h2o.anomaly(model_idle, random_mixed.hex, per_feature=F))
model_random_mixed_idle$bla_idle <- sort(model_random_mixed_idle$Reconstruction.MSE)

model_random_mixed_idle <- model_random_mixed_idle %>% rename(Reconstruction.MSE_idle = Reconstruction.MSE)


# model_random_mixed$label_no <- randoming_data$t_label
ggplot(data = model_random_mixed_idle,aes(y =bla_idle,x=c(1:nrow(model_random_mixed_idle)))) + geom_point() +ylim(0,0.05) # eRROR = 0.005




model_random_mixed <- cbind(model_random_mixed,model_random_mixed_idle)

model_random_mixed <- model_random_mixed %>% mutate(anomaly = ifelse((Reconstruction.MSE >=stream_limit_upper | Reconstruction.MSE <= stream_limit_low) & (Reconstruction.MSE_idle >=idle_limit_upper | Reconstruction.MSE_idle <= idle_limit_low ),1,0 ))

table(model_random_mixed$anomaly)
model_random_mixed_actualanom <- random_mixed$anomaly

check4 <- table(model_random_mixed$anomaly,model_random_mixed_actualanom)
print(check4)
accuracy_random_mixed = (check4[1]+check4[4])/(check4[1]+check4[4]+check4[2]+check4[3])
fpr_random_mixed = check4[2]/(check4[2]+check4[4])
print(paste0("Accuracy of random set idle = ",accuracy_random_mixed*100))
print(paste0("FPR of random set idle = ",fpr_random_mixed*100))

sensitivity_random_mixed <- sensitivity(check4)
specificity_random_mixed <- specificity(check4)

print(paste0("specificity of random mixed set = " , specificity_random_mixed))
print(paste0("sensitivity of random mixed set = " , sensitivity_random_mixed))

matrix_name <- substring(filenames[i], regexpr("bnl[0-9]{2}", filenames[i]),regexpr(".db", filenames[i])-1)
write.csv(check4,paste0("Results/confusion_matrix/mixed_set/",matrix_name,".csv"))



prediction_obj <- prediction(model_random_mixed$anomaly,model_random_mixed_actualanom)
plot_precall(prediction_obj = prediction_obj,plot_name = paste0("/mixed_set/",substring(filenames[i], regexpr("bnl[0-9]{2}", filenames[i]),regexpr(".db", filenames[i])-1)))




mean_mse <- model_random_mixed %>%
  group_by(anomaly) %>%
  summarise(mean = mean(Reconstruction.MSE))

model_random_mixed <- model_random_mixed %>%  tibble::rownames_to_column()
ggplot(model_random_mixed, aes(x = as.numeric(rowname), y = Reconstruction.MSE, color = as.factor(anomaly))) +
  geom_point(alpha = 0.3) +
  geom_hline(data = mean_mse, aes(yintercept = mean, color = as.factor(anomaly))) +
  scale_color_brewer(palette = "Set1") +
  labs(x = "instance number",
       color = "Class")
ggsave(filename = paste0("Results/Anomaly_Plots/",bin_blk,"_random_mixed.png"))


######----------------__#########
sensitivity_random_mixed_seq <- c()
specificity_random_mixed_seq <- c()
for(k in 1:length(j)){
  model_random3 <- model_random_mixed %>% mutate(anomaly = ifelse((Reconstruction.MSE >=stream_limit_upper_seq[k] | Reconstruction.MSE <= stream_limit_low) & (Reconstruction.MSE_idle >=idle_limit_upper_seq[k] | Reconstruction.MSE_idle <= idle_limit_low ),1,0 ))
  
  table(model_random3$anomaly)
  model_random3_actualanom <- random_mixed$anomaly
  
  check3 <- table(model_random3$anomaly,model_random3_actualanom)
  print(check3)
  sensitivity_random_mixed_seq <- c(sensitivity_random_mixed_seq,sensitivity(check3))
  specificity_random_mixed_seq <- c(specificity_random_mixed_seq,specificity(check3))
  # plot(sensitivity_random_mixed,specificity_random_mixed)
  
  
}
# sort(specificity_random_mixed_seq)
plot(sort(specificity_random_mixed_seq),sort(sensitivity_random_mixed_seq),type="l",col=as.factor(j))

ss_plot <- data.frame(specificity=specificity_random_mixed_seq,sensitivity=sensitivity_random_mixed_seq,j)

mixed_roc[,paste0("specificity_",bin_blk)] <-  specificity_random_mixed_seq
mixed_roc[,paste0("sensitivity_",bin_blk)] <-  sensitivity_random_mixed_seq

ggplot(ss_plot,aes(specificity,sensitivity,group=1))+geom_point()+geom_line() +theme_bw()+scale_y_continuous(breaks = c(0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1))+scale_x_continuous(breaks = c(0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1))
# +theme(
#   panel.background = element_rect(fill = "transparent",colour = NA), # or theme_blank()
#   panel.grid.minor = element_blank(), 
#   panel.grid.major = element_blank(),
#   plot.background = element_rect(fill = "transparent",colour = NA)
# )
ggsave(filename = paste0("Results/ROC_Seq_Plots/",bin_blk,"_random_mixed.pdf"))
