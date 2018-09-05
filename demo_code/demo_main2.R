require(RSQLite)
require(dplyr)
require(caret)
require(Information)
require(keras)
# setwd("wadac/Anomaly_Detector/New_Code")
driver <- dbDriver("SQLite")
conn <- dbConnect(driver,dbname="db_sigs_bnl800_bks300.db")

tab <- dbListTables(conn)
tab

all_data1 <- dbGetQuery(conn,paste0("select * from ", tab[3])) 
all_data2 <- dbGetQuery(conn,paste0("select * from ", tab[4])) 

all_data = all_data1 %>% left_join(all_data2,by=c("t_mac", "t_label","c_blk_sz","f_time_fstframe","f_time_window"))

all_data <- all_data %>% mutate(Timestamp = as.POSIXct(f_time_fstframe,origin="1970-01-01",tz = Sys.timezone())) %>% select(-f_time_fstframe)

all_data <- all_data %>% mutate(anomaly = ifelse(grepl("normal",t_label,ignore.case = T),0,1))
all_data <- all_data %>% mutate(attack = ifelse(grepl("normal",t_label,ignore.case = T),0,ifelse(grepl("tcp",t_label),1,2)))


all_data <- Filter(function(x)(length(unique(x))>1), all_data)

#woe
all_data_woe = all_data %>% select(-t_label,-Timestamp,-f_time_window,-attack) 

try_woe <- create_infotables(data = all_data_woe,y = "anomaly",parallel = T)

plotFrame <- try_woe$Summary[order(-try_woe$Summary$IV), ]
plotFrame$Variable <- factor(plotFrame$Variable,
                             
                             levels = plotFrame$Variable[order(-plotFrame$IV)])

ggplot(plotFrame, aes(x = Variable, y = IV)) +
  geom_bar(width = .35, stat = "identity", color = "darkblue", fill = "dark green") +
  ggtitle("Information Value") +
  theme_bw() +
  theme(plot.title = element_text(size = 10)) +
  theme(axis.text.x = element_text(angle = 90))

cols_remove = as.character(plotFrame$Variable[which(plotFrame$IV<4)])
cols_keep = as.character(plotFrame$Variable[which(plotFrame$IV>=4)])
save(cols_keep,file = "demo2/cols_keep.RData")
all_data = all_data %>% select(cols_keep,Timestamp,t_label,anomaly,attack)
str(all_data)

ggplot(data=all_data,aes(x=Timestamp,y=f_fr_ds_tb_b1,color = as.factor(attack)))+geom_point() 
ggplot(data=all_data,aes(x=Timestamp,y=f_fr_ds_tb_b0,color = as.factor(attack)))+geom_point()
ggplot(data=all_data,aes(x=Timestamp,y=f_mn_ds_xs,color = as.factor(attack)))+geom_point()
ggplot(data=all_data,aes(x=Timestamp,y=c_c_dr_b0,color = as.factor(attack)))+geom_point()
ggplot(data=all_data,aes(x=Timestamp,y=f_fr_dr_dx,color = as.factor(attack)))+geom_point()+ylim(0,1) #This
ggplot(data=all_data,aes(x=Timestamp,y=f_sd_xs_dr_b0,color = as.factor(attack)))+geom_point()
ggplot(data=all_data,aes(x=Timestamp,y=f_sd_dr_xs,color = as.factor(attack)))+geom_point()
ggplot(data=all_data,aes(x=Timestamp,y=c_c_dr ,color = as.factor(attack)))+geom_point()##This
# ggplot(data=all_data,aes(x=Timestamp,y=f_mn_tg_ds_b0 ,color = as.factor(attack)))+geom_point()##This
# ggplot(data=all_data,aes(x=Timestamp,y=f_sd_tg_ds_b0 ,color = as.factor(attack)))+geom_point()##This




normal_data = all_data %>% filter(anomaly==0) %>% select(-t_label,-anomaly,-attack)
attack_data <- all_data %>% filter(anomaly==1)%>% select(-anomaly,-attack)





source("desc_normalize.R")
apply(normal_data,2,range)
sep_index = round(nrow(normal_data)*0.8)
train_dat = normal_data[1:sep_index,] %>% select(-Timestamp)
# write.csv(train_dat,"train.csv")
test_dat = normal_data[(sep_index+1):nrow(normal_data),]%>% select(-Timestamp)


desc_normal_train = get_desc(train_dat)
save(desc_normal_train,file="demo2/desc_normal_train.RData")
x_train <- train_dat %>%
  normalization_minmax(desc_normal_train) %>%
  as.matrix()
desc_all = get_desc(all_data %>% select(-anomaly,-Timestamp,-t_label))
all_check = all_data%>% select(-anomaly,-Timestamp,-t_label) %>% normalization_minmax(desc_all) %>% as.matrix()

desc_normal_test = get_desc(test_dat)
x_test <- test_dat %>%
  normalization_minmax(desc_normal_test) %>%
  as.matrix()


desc_attack = get_desc(attack_data %>% select(-Timestamp,-t_label))
attack_test <- attack_data %>% select(-Timestamp,-t_label) %>% normalization_minmax(desc_attack) %>% as.matrix()

library(keras)
source("flags2.R")
model_cam = keras_model_sequential()
input <-  layer_input(shape = ncol(x_train))
preds <-  input %>%
  layer_dense(units = FLAGS$dense_units1,activation = 'tanh') %>% 
   layer_dense(units = FLAGS$dense_units2,activation = 'tanh') %>%
   layer_dense(units = FLAGS$dense_units1,activation = 'tanh') %>%
   # layer_activity_regularization(l1=0.05,l2=0.05) %>%
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
  filepath = "demo2/model_cam.hdf5", 
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
  callbacks = list(checkpoint, early_stopping),
  seed=1246
)


loss <- evaluate(model_cam, x = x_test, y = x_test)
loss

pred_train <- data.frame(predict(model_cam, x_train))
mse_train <- apply((x_train - pred_train)^2, 1, sum)
save(mse_train,file="demo2/mse_train.RData")
k=quantile(mse_train,probs = c(0.90))+1.5*IQR(mse_train)
train_dat = train_dat %>% mutate(timestamp = normal_data$Timestamp[1:sep_index],mse = mse_train)
ggplot(train_dat,aes(x = timestamp, y = mse)) + geom_point() + geom_line(aes(y=k))


pred_test <- predict(model_cam, x_test)
mse_test <- apply((x_test - pred_test)^2, 1, sum)
test_dat = test_dat %>% mutate(timestamp = normal_data$Timestamp[(sep_index+1):nrow(normal_data)],mse = mse_test)
ggplot(test_dat,aes(x = timestamp, y = mse)) + geom_point()  + geom_line(aes(y=k))
length(test_dat$mse[which(test_dat$mse>k)])
length(test_dat$mse[which(test_dat$mse<k)])/nrow(test_dat)

pred_attack <- predict(model_cam, attack_test)
mse_attack <- apply((attack_test - pred_attack)^2, 1, sum)
attack_data_out = attack_data %>% mutate(mse = mse_attack)
ggplot(attack_data_out,aes(x = Timestamp, y = mse)) + geom_point()  + geom_line(aes(y=k))
length(attack_data_out$mse[which(attack_data_out$mse>k)])/nrow(attack_data)
length(attack_data_out$mse[which(attack_data_out$mse<=k)])
# 1/2833

# pred_all <- predict(model_cam,all_check)
# mse_all <- apply((all_check - pred_all)^2, 1, sum)
# all_data = all_data %>% mutate(mse = mse_all) %>% mutate(anom = as.factor(ifelse(mse>k,1,0)))
# ggplot(all_data,aes(x = Timestamp, y = mse,color=anom)) + geom_point()  + geom_line(aes(y=k))
# length(all_data$mse[which(all_data$mse<=k)])/nrow(all_data)

model_demo=model_cam
save_model_hdf5(model_cam,"demo2/model_demo.hdf5")

