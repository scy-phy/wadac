library(keras)
source("flags.R")
model_cam = keras_model_sequential()
input <-  layer_input(shape = ncol(x_train))
preds <-  input %>%
    layer_dense(units = FLAGS$dense_units1,activation = 'tanh') %>%
  layer_dense(units = FLAGS$dense_units2,activation = 'tanh') %>%
    layer_dense(units = FLAGS$dense_units1,activation = 'tanh') %>%
  layer_dense(units=ncol(x_train),activation = 'tanh')


model_cam = keras_model(input,preds) %>% compile(
  loss = 'mean_squared_logarithmic_error',
  optimizer = 'adam',
  #  lr = 0.01,
  metrics = 'mae'
)


checkpoint <- callback_model_checkpoint(
  filepath = "model_cam.hdf5", 
  save_best_only = TRUE, 
  period = 1,
  verbose = 1
)

early_stopping <- callback_early_stopping(patience = 10)

set.seed(1246)
hist = model_cam %>% fit(
  x = x_train, 
  y = x_train, 
  epochs = 300, 
  batch_size = 50,
  validation_data = list(x_test, x_test), 
  callbacks = list(checkpoint, early_stopping)
)

loss <- evaluate(model_cam, x = x_test, y = x_test)
loss


pred_train <- data.frame(predict(model_cam, x_train))
mse_train <- apply((x_train - pred_train)^2, 1, sum)

pred_test <- predict(model_cam, x_test)
mse_test <- apply((x_test - pred_test)^2, 1, sum)

# test = rbind(x_test,x_test_stream)
# pred_test <- predict(model_cam, test)
# mse_test <- apply((test - pred_test)^2, 1, sum)
# y_test  = c(rep(0,nrow(x_test)),rep(1,nrow(x_test_stream)))

# anom = as.matrix(anomaly_data %>% select(-t_label,-t_mac))
# pred_anom <- predict(model_cam, anom)
# mse_anom <- apply((anom - pred_anom)^2, 1, sum)



# 
# possible_k <- quantile(mse_train,probs = seq(0, 1, 0.1)) +1.5 * IQR(mse_train)
# precision <- sapply(possible_k, function(k) {
#   predicted_class <- as.numeric(mse_test > k)
#   sum(predicted_class == 1 & y_test == 1)/sum(predicted_class)
# })
# library(ggplot2)
# qplot(possible_k, precision, geom = "line") + labs(x = "Threshold", y = "Precision")+xlim(0,max(possible_k))
# 
# 
# recall <- sapply(possible_k, function(k) {
#   predicted_class <- as.numeric(mse_test > k)
#   sum(predicted_class == 1 & y_test == 1)/sum(y_test)
# })
# qplot(possible_k, recall, geom = "line") + labs(x = "Threshold", y = "Recall")
# 
# 
# 
# cost_per_verification <- 1
# 
# error <- sapply(possible_k, function(k) {
#   predicted_class <- as.numeric(mse_test > k)
#   sum(cost_per_verification * predicted_class + (predicted_class == 0) * y_test) 
# })
# 
# qplot(possible_k, error, geom = "line") + labs(x = "Threshold", y = "Lost Money")
# 
# possible_k[which.min(error)]
# possible_k[which.max(precision)]
# possible_k[which.max(recall)]

# k = possible_k[which.min(error)]

k=quantile(mse_train,probs = c(0.75))+IQR(mse_train)
x_axis = c(1:nrow(x_test))
ggplot(data= as.data.frame(x_test),aes(x = x_axis ,y = mse_test)) + geom_line()+geom_line(aes(y=k))+ylim(0,20)
# 

# attack_desc = get_desc(anomaly_data %>% select(-t_label,-t_mac))
desc_attack = get_desc(anomaly_data%>% select(-t_label,-t_mac))
attack_data = anomaly_data %>% select(-t_label,-t_mac) %>% normalization_minmax(desc_attack) %>% as.matrix()
pred_attack <- predict(model_cam, attack_data)
mse_attack <- apply((attack_data - pred_attack)^2, 1, sum)
x_axis = c(1:nrow(attack_data))
ggplot(data= as.data.frame(attack_data),aes(x = x_axis ,y = mse_attack)) + geom_point()+geom_line(aes(y=k))


# library(Metrics)
# auc(x_train, mse_train)
# auc(x_test, mse_test)
# 
# auc(x_train, mse_train)
# 

#Test for other attacks 
anom2 = rbind(nest_cam,tplink_cam)
# anom_desc = get_desc(anom2 %>% select(-t_label,-t_mac))
anom3 = anom2 %>% select(-t_label,-t_mac) %>% normalization_minmax(desc_normal) %>% as.matrix()
anom3[is.na(anom3)] <- 0
# anom3 = as.matrix(anom2 %>% select(-t_label,-t_mac))
pred_anom2 <- predict(model_cam, anom3)
mse_anom2 <- apply((anom3 - pred_anom2)^2, 1, sum)
x_axis = c(1:nrow(anom2))
df = data.frame(x_axis,mse_anom2)
ggplot(data= df,aes(x = x_axis ,y = mse_anom2)) + geom_line()+geom_line(aes(y=k)) +ylim(0,200)


#Test for mirai data: 
mirai_dat = rbind(mirai_att1,mirai_att2)
mirai_dat = mirai_dat[,which(colnames(mirai_dat) %in% colnames(train_dat))]

mirai_desc = get_desc(mirai_dat)
mirai = mirai_dat %>% normalization_minmax(desc_normal) %>% as.matrix()
mirai[is.na(mirai)] <- 0

# mirai = as.matrix(mirai_dat)
pred_mirai <- predict(model_cam, mirai)
mse_mirai <- apply((mirai - pred_mirai)^2, 1, sum)
x_axis = c(1:nrow(mirai_dat))
ggplot(data= as.data.frame(mirai_dat),aes(x = x_axis ,y = mse_mirai)) + geom_line()+geom_line(aes(y=k))



#Test for mixed data 
mix_set = rbind(test_dat[1:400,],anomaly_data[1:2000,] %>% select(-t_label,-t_mac),test_dat[401:800,],anomaly_data[2001:3000,] %>% select(-t_label,-t_mac),test_dat[800:nrow(test_dat),],tplink_cam %>% select(-t_label,-t_mac),nest_cam %>% select(-t_label,-t_mac))
# mix_desc = get_desc(mix_set)
mix_set2 = mix_set %>% normalization_minmax(desc_normal) %>% as.matrix()
mix_set2[is.na(mix_set2)] <- 0

pred_mix <- predict(model_cam, mix_set2)

mix_set$actual_label = c(rep(0,400),rep(1,2000),rep(0,400),rep(1,1000),rep(0,138),rep(1,nrow(tplink_cam)),rep(1,nrow(nest_cam)))
mix_set$pred_Label = ifelse(pred_mix > k,1,0)

mse_mirai <- apply((mix_set2 - pred_mix)^2, 1, sum)
x_axis = c(1:nrow(mix_set))
df = data.frame(x_axis,mse_mirai,mix_set$actual_label) %>% rename(actual_label = mix_set.actual_label)
ggplot(data= df,aes(x = x_axis ,y = mse_mirai,color = as.factor(actual_label))) + geom_point()+geom_line(aes(y=k))
