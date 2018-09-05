rem_ind = which(train_dat$mse>k)

x_train = x_train[-rem_ind,]


library(keras)
source("flags.R")
model_cam = keras_model_sequential()
input <-  layer_input(shape = ncol(x_train))
preds <-  input %>%
  layer_dense(units = FLAGS$dense_units1,activation = 'tanh') %>% 
  layer_dense(units = FLAGS$dense_units2,activation = 'tanh') %>%
  layer_dense(units = FLAGS$dense_units1,activation = 'tanh') %>%
  layer_activity_regularization(l1=0.1) %>%
  # layer_dense(units = FLAGS$dense_units2,activation = 'tanh') %>%
  # layer_dense(units = FLAGS$dense_units1,activation = 'tanh') %>%
  layer_dense(units=ncol(x_train),activation = 'tanh')


model_cam = keras_model(input,preds) %>% compile(
  loss = 'mean_squared_error',
  optimizer = 'adam',
  #  lr = 0.01,
  metrics = "mean_squared_error"
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
k=quantile(mse_train,probs = c(0.75))+1.5*IQR(mse_train)
out_train_dat = train_dat[-rem_ind,] %>% mutate(timestamp = train_dat$timestamp[-rem_ind],mse = mse_train)
ggplot(out_train_dat,aes(x = timestamp, y = mse)) + geom_point() + geom_line(aes(y=k))
