library(dplyr)
library(caret)

normal_traffic <- packet_features %>% filter(grepl("normal",t_label))
attack_traffic <- packet_features %>% filter(!grepl("normal",t_label))

scaled.normal <- as.data.frame(scale(normal_traffic %>% select(-t_label,-t_mac)))
scaled.normal[is.na(scaled.normal)] <- 0
colMeans(scaled.normal,na.rm = T)
apply(scaled.normal,2,sd)
scaled.normal$t_label <- normal_traffic$t_label


scaled.attack <- as.data.frame(scale(attack_traffic %>% select(-t_label,-t_mac)))
scaled.attack[is.na(scaled.attack)] <- 0
colMeans(scaled.attack)
apply(scaled.attack,2,sd)
scaled.attack$t_label <- attack_traffic$t_label


set.seed(1234)
train_normal_index <- createDataPartition(scaled.normal$t_label,times = 1,p=0.7, list = F)
train.normal <- scaled.normal[train_normal_index,]
test.normal <- scaled.normal[-train_normal_index,]


mixed_set <- rbind(scaled.attack,test.normal)
labels = list(train_label=train.normal$t_label,test_label=test.normal$t_label,attack_label=scaled.attack$t_label,mixed_label=mixed_set$t_label)

train.normal$t_label <- NULL
test.normal$t_label <- NULL
scaled.attack$t_label <- NULL
mixed_set$t_label <- NULL

library(h2o)

#Initialize h2o instance
localH2O = h2o.init()
h2o.removeAll()

train_normal.hex<-as.h2o(train.normal, destination_frame="train_normal.hex")
test_normal.hex<-as.h2o(test.normal, destination_frame="test_normal.hex")

attack.hex <- as.h2o(scaled.attack,destination_frame = "attack.hex")
mixed.hex <- as.h2o(mixed_set,destination_frame = "mixed.hex")


