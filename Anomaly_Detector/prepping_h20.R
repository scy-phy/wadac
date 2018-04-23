library(dplyr)
library(caret)
#Get Streaming data
streaming_data <- packet_features %>% filter(grepl("streaming",t_label,ignore.case=T))

#Remove constant columns 
# streaming_data <- streaming_data[, sapply(streaming_data, function(col) length(unique(col))) > 1]

#Get idle data

idle_data <- packet_features %>% filter(grepl("idle",t_label,ignore.case=T))

# idle_data <- idle_data[, sapply(idle_data, function(col) length(unique(col))) > 1]
# idle_data <- idle_data[,apply(idle_data, 2, var ,na.rm=T) != 0]

#Get anomaly data
anomaly_data <- packet_features %>% filter(!(grepl("streaming",t_label,ignore.case=T) | grepl("idle",t_label,ignore.case=T) ))
# anomaly_data <- anomaly_data[, sapply(anomaly_data, function(col) length(unique(col))) > 1]

#Training and testing for streaming data
set.seed(1234)
train_stream_index <- createDataPartition(streaming_data$t_label,times = 1,p=0.6, list = F)
train_stream <- streaming_data[train_stream_index,]  #%>% select(-t_mac,-t_label)
test_stream <-  streaming_data[-train_stream_index,] %>% select(-t_mac,-t_label)

#Training and testing for idle data
set.seed(1234)
train_idle_index <- createDataPartition(idle_data$t_label,times = 1,p=0.6, list = F)
train_idle <- idle_data[train_idle_index,] #%>% select(-t_mac,-t_label)
test_idle <-  idle_data[-train_idle_index,] %>% select(-t_mac,-t_label)

set.seed(1234)
mirai_normal_index <- createDataPartition(streaming_data$t_label,times = 1,p=0.6, list = F)
train_mirai <- mirai_normal[mirai_normal_index,]  #%>% select(-t_mac,-t_label)
train_mirai <- train_mirai[,which(colnames(train_mirai)%in%colnames(train_stream))]
test_mirai <-  mirai_normal[-mirai_normal_index,] %>% select(-t_mac,-t_label)
train_stream <- rbind(train_stream,train_mirai)


train_stream <- train_stream %>% select(-t_mac,-t_label)
train_idle <- train_idle %>% select(-t_mac,-t_label)
library(h2o)

#Initialize h2o instance
localH2O = h2o.init()
h2o.removeAll()

train_stream.hex<-as.h2o(train_stream, destination_frame="train_stream.hex")
test_stream.hex<-as.h2o(test_stream, destination_frame="test_stream.hex")

train_idle.hex<-as.h2o(train_idle, destination_frame="train_idle.hex")
test_idle.hex<-as.h2o(test_idle, destination_frame="test_idle.hex")

anoamly.hex <- as.h2o(anomaly_data,destination_frame = "anomaly.hex")

#random <- rbind(packet_features[-train_idle_index,] %>% mutate(anomaly = 0)%>% select(-t_mac,-t_label), packet_features[-train_stream_index,] %>% mutate(anomaly = 0)%>%select(-t_mac,-t_label),anomaly_data %>% select(-t_mac,-t_label)%>% mutate(anomaly = 1))
random_stream <- rbind(test_stream %>% mutate(anomaly = 0),anomaly_data %>% select(-t_mac,-t_label)%>% mutate(anomaly = 1))
random.hex <- as.h2o(random_stream,destination_frame = "random_stream.hex")

random_idle <- rbind(test_idle %>% mutate(anomaly = 0),anomaly_data[,which(colnames(anomaly_data)%in%colnames(test_idle))]%>% mutate(anomaly = 1))
random2.hex <- as.h2o(random_idle,destination_frame = "random_idle.hex")

if(length(colnames(random_stream))>length(colnames(random_idle))){
cols <- colnames(random_stream)
random_idle[, cols[!(cols %in% colnames(random_idle))]] <- 0
}

if(length(colnames(random_stream))<length(colnames(random_idle))){
  cols <- colnames(random_idle)
  random_stream[, cols[!(cols %in% colnames(random_stream))]] <- 0
}

random_mixed <- rbind(random_stream,random_idle,anomaly_data %>% select(-t_mac,-t_label) %>% mutate(anomaly=1))
random_mixed.hex <- as.h2o(random_mixed,destination_frame = "random_mixed.hex")



mirai_attack.hex <- as.h2o(mirai_attack %>% select(-t_label,-t_mac),destination_frame = "mirai_attack.hex")
mirai_normal.hex <- as.h2o(test_mirai,destination_frame = "mirai_normal.hex")
mirai_att1.hex <- as.h2o(mirai_att1%>% select(-t_label,-t_mac),destination_frame = "mirai_att1.hex")
mirai_att2.hex <- as.h2o(mirai_att2%>% select(-t_label,-t_mac),destination_frame = "mirai_att2.hex")
mirai_att1_new.hex <- as.h2o(mirai_att1_new%>% select(-t_label,-t_mac),destination_frame = "mirai_att1.hex")
mirai_att2_new.hex <- as.h2o(mirai_att2_new%>% select(-t_label,-t_mac),destination_frame = "mirai_att2.hex")
