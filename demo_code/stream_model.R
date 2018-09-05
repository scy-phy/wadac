library(keras)
source("flags.R")
model = keras_model_sequential()
input <-  layer_input(shape = ncol(x_train_stream))
preds <-  input %>%
  layer_dense(units = FLAGS$dense_units1,activation = 'tanh') %>%
  # layer_dense(units = FLAGS$dense_units2,activation = 'tanh') %>%
  # layer_dense(units = FLAGS$dense_units1,activation = 'tanh') %>%
  layer_dense(units=ncol(x_train_stream),activation = 'tanh')


model = keras_model(input,preds) %>% compile(
  loss = 'mean_squared_logarithmic_error',
  optimizer = 'adam',
  #  lr = 0.01,
  metrics = 'mae'
)


checkpoint <- callback_model_checkpoint(
  filepath = "model.hdf5", 
  save_best_only = TRUE, 
  period = 1,
  verbose = 1
)

early_stopping <- callback_early_stopping(patience = 10)

set.seed(1246)
hist = model %>% fit(
  x = x_train_stream, 
  y = x_train_stream, 
  epochs = 300, 
  batch_size = 50,
  validation_data = list(x_test_stream, x_test_stream), 
  callbacks = list(checkpoint, early_stopping)
)

loss <- evaluate(model, x = x_test_stream, y = x_test_stream)
loss


pred_train <- data.frame(predict(model, x_train_stream))
mse_train <- apply((x_train_stream - pred_train)^2, 1, sum)

pred_test <- predict(model, x_test_stream)
mse_test <- apply((x_test_stream - pred_test)^2, 1, sum)

test_streams = rbind(x_test_stream,x_test_idle)
pred_test <- predict(model, test_streams)
mse_test <- apply((test_streams - pred_test)^2, 1, sum)
y_test  = c(rep(0,nrow(x_test_stream)),rep(1,nrow(x_test_idle)))


possible_k <- quantile(mse_train,probs = seq(0, 1, 0.1)) +1.5 * IQR(mse_train)
precision <- sapply(possible_k, function(k) {
  predicted_class <- as.numeric(mse_test > k)
  sum(predicted_class == 1 & y_test == 1)/sum(predicted_class)
})
library(ggplot2)
qplot(possible_k, precision, geom = "line") + labs(x = "Threshold", y = "Precision")


recall <- sapply(possible_k, function(k) {
  predicted_class <- as.numeric(mse_test > k)
  sum(predicted_class == 1 & y_test == 1)/sum(y_test)
})
qplot(possible_k, recall, geom = "line") + labs(x = "Threshold", y = "Recall")



cost_per_verification <- 1

error <- sapply(possible_k, function(k) {
  predicted_class <- as.numeric(mse_test > k)
  sum(cost_per_verification * predicted_class + (predicted_class == 0) * y_test) 
})

qplot(possible_k, error, geom = "line") + labs(x = "Threshold", y = "Lost Money")

possible_k[which.min(error)]
possible_k[which.max(precision)]
possible_k[which.max(recall)]

k = possible_k[which.min(lost_money)]
x_axis = c(1:nrow(test_streams))
ggplot(data= as.data.frame(test_streams),aes(x = x_axis ,y = mse_test,color = as.factor(y_test))) + geom_line()+geom_line(aes(y=possible_k[which.max(recall)]))
# 
# library(Metrics)
# auc(x_train_stream, mse_train)
# auc(x_test_stream, mse_test)
