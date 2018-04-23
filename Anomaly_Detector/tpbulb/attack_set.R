
tpbulb_attack = as.data.frame(h2o.anomaly(model_tpbulb, attack.hex, per_feature=F))
tpbulb_attack$bla_stream <- sort(tpbulb_attack$Reconstruction.MSE)
# tpbulb_attack$label_no <- anomalying_data$t_label
ggplot(data = tpbulb_attack,aes(y =bla_stream,x=c(1:nrow(tpbulb_attack)))) + geom_point() +ylim(0,0.05) # eRROR = 0.005



tpbulb_attack <- tpbulb_attack %>% mutate(anomaly = ifelse((Reconstruction.MSE >=tpbulb_limit_upper | Reconstruction.MSE <= tpbulb_limit_low),1,0 ))
tpbulb_attack$normal <- 1
check <- table(tpbulb_attack$anomaly,tpbulb_attack$normal)
# confusionMatrix(check)
specificity_anomaly = (check[2]/sum(check)) 
print(paste0("specificity of anomaly set = " , specificity_anomaly))
sensitivity_anomaly = 0 # as no normal data in anomaly set, TN = 0 always 
print(paste0("sensitivity of anomaly set = " , sensitivity_anomaly))

tpbulb_attack$t_label <- labels[[3]]
check_tpbulb_ddos <- table(tpbulb_attack$t_label,tpbulb_attack$anomaly) #4.9% missclassification
write.csv(check_tpbulb_ddos,paste0("Results/confusion_matrix/attack_set/cm_",bin_blk,"_tpbulb",".csv"))

if(!is.na(check[2])){
  accuracy_attack = check[2]/(check[2]+check[1])
}
if(is.na(check[2])){
  accuracy_attack = check[1]/check[1]
}

print(paste0("Accuracy of detecting attacks = ",accuracy_attack*100))




mean_mse <- tpbulb_attack %>%
  group_by(anomaly) %>%
  summarise(mean = mean(Reconstruction.MSE))

tpbulb_attack <- tpbulb_attack %>%  tibble::rownames_to_column()
ggplot(tpbulb_attack, aes(x = as.numeric(rowname), y = Reconstruction.MSE, color = as.factor(anomaly))) +
  geom_point(alpha = 0.3) +
  geom_hline(data = mean_mse, aes(yintercept = mean, color = as.factor(anomaly))) +
  scale_color_brewer(palette = "Set1") +
  labs(x = "instance number",
       color = "Class") +ylim(0,0.25)
ggsave(filename = paste0("Results/Anomaly_Plots/attack_set/",bin_blk,"_tpbulb",".pdf"))





