model_anomaly = as.data.frame(h2o.anomaly(model_stream, anoamly.hex, per_feature=F))
model_anomaly$bla_stream <- sort(model_anomaly$Reconstruction.MSE)
# model_anomaly$label_no <- anomalying_data$t_label
ggplot(data = model_anomaly,aes(y =bla_stream,x=c(1:nrow(model_anomaly)))) + geom_point() +ylim(0,0.05) # eRROR = 0.005


#Thresh stream = 0.02 thresh idle = 0.01 


model_anomaly_idle = as.data.frame(h2o.anomaly(model_idle, anoamly.hex, per_feature=F))
model_anomaly_idle$bla_idle <- sort(model_anomaly_idle$Reconstruction.MSE)
# model_anomaly$label_no <- anomalying_data$t_label
ggplot(data = model_anomaly_idle,aes(y =bla_idle,x=c(1:nrow(model_anomaly_idle)))) + geom_point() +ylim(0,0.1) # eRROR = 0.005



model_anomaly_idle <- model_anomaly_idle %>% rename(Reconstruction.MSE_idle = Reconstruction.MSE)

model_anomaly <- cbind(model_anomaly,model_anomaly_idle)

model_anomaly <- model_anomaly %>% mutate(anomaly = ifelse((Reconstruction.MSE >=stream_limit_upper | Reconstruction.MSE <= stream_limit_low) & (Reconstruction.MSE_idle >=idle_limit_upper | Reconstruction.MSE_idle <= idle_limit_low ),1,0 ))
model_anomaly$normal <- 1
check <- table(model_anomaly$anomaly,model_anomaly$normal)
specificity_anomaly = (check[2]/sum(check)) 
print(paste0("specificity of anomaly set = " , specificity_anomaly))
sensitivity_anomaly = 0 # as no normal data in anomaly set, TN = 0 always 
print(paste0("sensitivity of anomaly set = " , sensitivity_anomaly))



if(!is.na(check[2])){
accuracy_attack = check[2]/(check[2]+check[1])
}
if(is.na(check[2])){
  accuracy_attack = check[1]/check[1]
}

fpr_attack <- check[1]/(check[1]+check[2])
print(paste0("Accuracy of attacks = ",accuracy_attack*100))









mean_mse <- model_anomaly %>%
  group_by(anomaly) %>%
  summarise(mean = mean(Reconstruction.MSE))

model_anomaly <- model_anomaly %>%  tibble::rownames_to_column()
ggplot(model_anomaly, aes(x = as.numeric(rowname), y = Reconstruction.MSE, color = as.factor(anomaly))) +
  geom_point(alpha = 0.3) +
  geom_hline(data = mean_mse, aes(yintercept = mean, color = as.factor(anomaly))) +
  scale_color_brewer(palette = "Set1") +
  labs(x = "instance number",
       color = "Class")
ggsave(filename = "Results/Anomaly_Plots/anomaly_set.png")





