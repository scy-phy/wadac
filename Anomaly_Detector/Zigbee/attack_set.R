
zigbee_attack = as.data.frame(h2o.anomaly(model_zigbee, attack.hex, per_feature=F))
zigbee_attack$bla_stream <- sort(zigbee_attack$Reconstruction.MSE)
# zigbee_attack$label_no <- anomalying_data$t_label
ggplot(data = zigbee_attack,aes(y =bla_stream,x=c(1:nrow(zigbee_attack)))) + geom_point() +ylim(0,0.05) # eRROR = 0.005



zigbee_attack <- zigbee_attack %>% mutate(anomaly = ifelse((Reconstruction.MSE >=zigbee_limit_upper | Reconstruction.MSE <= zigbee_limit_low),1,0 ))
zigbee_attack$normal <- 1
check <- table(zigbee_attack$anomaly,zigbee_attack$normal)
# confusionMatrix(check)
specificity_anomaly = ifelse(is.na(check[2]),1,(check[2]/sum(check)) )
print(paste0("specificity of anomaly set = " , specificity_anomaly))
sensitivity_anomaly = 0 # as no normal data in anomaly set, TN = 0 always 
print(paste0("sensitivity of anomaly set = " , sensitivity_anomaly))

zigbee_attack$t_label <- labels[[3]]
check_zigbee_ddos <- table(zigbee_attack$t_label,zigbee_attack$anomaly) #4.9% missclassification
write.csv(check_zigbee_ddos,paste0("Results/confusion_matrix/attack_set/cm_",bin_blk,"_zigbee",".csv"))

if(!is.na(check[2])){
  accuracy_attack = check[2]/(check[2]+check[1])
}
if(is.na(check[2])){
  accuracy_attack = check[1]/check[1]
}

print(paste0("Accuracy of detecting attacks = ",accuracy_attack*100))




mean_mse <- zigbee_attack %>%
  group_by(anomaly) %>%
  summarise(mean = mean(Reconstruction.MSE))

zigbee_attack <- zigbee_attack %>%  tibble::rownames_to_column()
ggplot(zigbee_attack, aes(x = as.numeric(rowname), y = Reconstruction.MSE, color = as.factor(anomaly))) +
  geom_point(alpha = 0.3) +
  geom_hline(data = mean_mse, aes(yintercept = mean, color = as.factor(anomaly))) +
  scale_color_brewer(palette = "Set1") +
  labs(x = "instance number",
       color = "Class") +ylim(0,0.25)
ggsave(filename = paste0("Results/Anomaly_Plots/attack_set/",bin_blk,"_zigbee",".pdf"))





