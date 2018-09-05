library(tidyr)
library(keras)
library(dplyr)
library(purrr)
library(caret)
library(ggridges)

setwd("New_Code/")
source("desc_normalize.R")
###DATA ANALYSIS
apply(packet_features,2,range)
apply(packet_features,2,unique)


#See density plots for each var with all data
packet_features %>%
  gather(variable, value, -t_mac,-t_label,-f_time_window) %>%
  ggplot(aes(y = as.factor(variable), 
             fill = as.factor(t_label), 
             x = percent_rank(value))) +
  geom_density_ridges()

#See density plots for each var with streaming and attack data
packet_features %>% filter(!grepl("idle",t_label,ignore.case=T)) %>%
  gather(variable, value, -t_mac,-t_label,-f_time_window) %>%
  ggplot(aes(y = as.factor(variable), 
             fill = as.factor(t_label), 
             x = percent_rank(value))) +
  geom_density_ridges()

#See density plots for each var with idle and attack data
packet_features %>% filter(!grepl("streaming",t_label,ignore.case=T)) %>%
  gather(variable, value, -t_mac,-t_label,-f_time_window) %>%
  ggplot(aes(y = as.factor(variable), 
             fill = as.factor(t_label), 
             x = percent_rank(value))) +
  geom_density_ridges()



packet_features2 = packet_features %>% mutate(anomaly = ifelse(grepl("streaming",t_label,ignore.case=T) | grepl("idle",t_label,ignore.case=T),0,1))


###DATA PREP 

streaming_data <- packet_features %>% filter(grepl("streaming",t_label,ignore.case=T))

#Get idle data
idle_data <- packet_features %>% filter(grepl("idle",t_label,ignore.case=T))

#Get anomaly data
anomaly_data <- packet_features %>% filter(!(grepl("streaming",t_label,ignore.case=T) | grepl("idle",t_label,ignore.case=T) ))

#Training and testing for streaming data
set.seed(1234)
train_stream_index <- createDataPartition(streaming_data$t_label,times = 1,p=0.6, list = F)
train_stream <- streaming_data[train_stream_index,]  %>% select(-t_mac,-t_label)
test_stream <-  streaming_data[-train_stream_index,] %>% select(-t_mac,-t_label)

#Training and testing for idle data
set.seed(1234)
train_idle_index <- createDataPartition(idle_data$t_label,times = 1,p=0.6, list = F)
train_idle <- idle_data[train_idle_index,] %>% select(-t_mac,-t_label)
test_idle <-  idle_data[-train_idle_index,] %>% select(-t_mac,-t_label)



normal_data = packet_features %>% filter(grepl("streaming",t_label,ignore.case=T) | grepl("idle",t_label,ignore.case=T))

#Test with combined data 
set.seed(1234)
train_index = createDataPartition(normal_data$t_label,times = 1,p=0.6, list = F)
train_dat = normal_data[train_index,]%>% select(-t_mac,-t_label)
test_dat = normal_data[-train_index,]%>% select(-t_mac,-t_label)

# check_packets_train = packet_features2[train_index,] %>% filter()

##Normalize data
desc_stream <- train_stream %>% 
  get_desc()

x_train_stream <- train_stream %>%
  normalization_minmax(desc_stream) %>%
  as.matrix()

x_test_stream <- test_stream %>%
  normalization_minmax(desc_stream) %>%
  as.matrix()

y_train_stream <- streaming_data$t_label[train_stream_index[,1]]
y_test_stream <- streaming_data$t_label[-train_stream_index[,1]]


desc_idle <- train_idle %>% 
  get_desc()
x_train_idle <- train_idle %>%
  normalization_minmax(desc_idle) %>%
  as.matrix()
x_test_idle <- test_idle %>%
  normalization_minmax(desc_idle) %>%
  as.matrix()
y_train_idle <- idle_data$t_label[train_idle_index[,1]]
y_test_idle <- idle_data$t_label[-train_idle_index[,1]]


desc_normal = get_desc(train_dat)
x_train <- train_dat %>%
  normalization_minmax(desc_normal) %>%
  as.matrix()

x_test <- test_dat %>%
  normalization_minmax(desc_normal) %>%
  as.matrix()



# model = keras_model_sequential()
# 
# model %>% #layer_activation("softmax",input_shape=c(40)) %>%
#   layer_dense(units = 28,input_shape=ncol(x_train_stream)) %>%
#   layer_dense(units = 23,activation = 'tanh') %>%
#    layer_dense(units = 28,activation = 'tanh') %>%
#   layer_dense(units=ncol(x_train_stream),activation = 'tanh')
# 
# 
# # sgd <- optimizer_sgd(lr = 0.01)
# # adagrad <- optimizer_adagrad(lr=0.01)
# # nadam <- optimizer_nadam(lr=0.001)
# # adadelta = optimizer_adadelta()
# model %>% compile(
#   loss = 'mean_squared_logarithmic_error',
#   optimizer = 'adam',
#   #  lr = 0.01,
#   metrics = 'mae'
# )
# 
# 
# checkpoint <- callback_model_checkpoint(
#   filepath = "model.hdf5", 
#   save_best_only = TRUE, 
#   period = 1,
#   verbose = 1
# )
# 
# early_stopping <- callback_early_stopping(patience = 10)
# 
# set.seed(1246)
# hist = model %>% fit(
#   x = x_train_stream, 
#   y = x_train_stream, 
#   epochs = 500, 
#   batch_size = 32,
#   validation_data = list(x_test_stream, x_test_stream), 
#   callbacks = list(checkpoint, early_stopping)
# )
# 
# 
# 
# 
# 
# 
# model_idle = keras_model_sequential()
# 
# model_idle %>% #layer_activation("softmax",input_shape=c(40)) %>%
#   layer_dense(units = 30,input_shape=ncol(x_train_stream)) %>%
#   layer_dense(units = 28,activation = 'tanh') %>%
#   layer_dense(units = 30,activation = 'tanh') %>%
#   layer_dense(units=ncol(x_train_stream),activation = 'tanh')
# 
# 
# # sgd <- optimizer_sgd(lr = 0.01)
# # adagrad <- optimizer_adagrad(lr=0.01)
# # nadam <- optimizer_nadam(lr=0.001)
# # adadelta = optimizer_adadelta()
# model_idle %>% compile(
#   loss = 'mean_squared_logarithmic_error',
#   optimizer = 'adam',
#   #  lr = 0.01,
#   metrics = 'mae'
# )
# 
# 
# checkpoint <- callback_model_checkpoint(
#   filepath = "model_idle.hdf5", 
#   save_best_only = TRUE, 
#   period = 1,
#   verbose = 1
# )
# 
# early_stopping <- callback_early_stopping(patience = 10)
# 
# 
# hist_idle = model_idle %>% fit(
#   x = x_train_idle, 
#   y = x_train_idle, 
#   epochs = 500, 
#   batch_size = 32,
#   validation_data = list(x_test_idle, x_test_idle), 
#   callbacks = list(checkpoint, early_stopping)
# )
# 
# 
# # history = model %>% fit(
# #   train_matrix,
# #   train_labels,
# #   epochs=500,
# #   batch_size = nrow(train_data)/2,
# #   validation_data = list(test_matrix,test_labels),
# #   verbose=1
# # )
# # 
# 
