library(randomForest)
library(caret)
library(dplyr)
unique(attack_data$t_label)

set.seed(1234)
train_attack_index <- createDataPartition(attack_data$t_label,times = 1,p=0.7, list = F)
train_attack <- attack_data[train_attack_index,] 
test_attack <-  attack_data[-train_attack_index,] 


mtry=floor(sqrt(ncol(train_attack)))
ntree = 1000
train_attack = train_attack %>% mutate(t_label=as.factor(t_label))
set.seed(1234)
rf_model<-train(t_label~.,data=train_attack %>% select(-Timestamp),method="rf",
                trControl=trainControl(method="cv",number=10),
                prox=TRUE,allowParallel=TRUE)


print(rf_model)
best_model <- rf_model$finalModel
library(ggRandomForests)
gg_e <- gg_error(best_model)
plot(gg_e)+xlim(0,15)

save(best_model,file = "demo2/supervised_model.RData")

test_attack$pred_label <- predict(best_model,newdata=test_attack,type = "response")
xtab <- table(test_attack$pred_label,test_attack$t_label)
ch <- confusionMatrix(xtab)
ch$overall


imp_vars <- as.data.frame(best_model$importance)
imp_vars$Vars = rownames(imp_vars)
imp_vars <- imp_vars %>% mutate(Imp = round((MeanDecreaseGini/sum(MeanDecreaseGini))*100,3)) %>% select(-MeanDecreaseGini)
imp_vars <- imp_vars[with(imp_vars, order(-Imp)), ]


ggplot(data = train_attack, aes(x=Timestamp,y =  f_sd_dr_xs,color=t_label))+geom_point()
ggplot(data = train_attack, aes(x=Timestamp,y = f_mn_ds_xs,color=t_label))+geom_point()
ggplot(data = train_attack, aes(x=Timestamp,y = f_sd_xs_dr_b0,color=t_label))+geom_point()
ggplot(data = train_attack, aes(x=Timestamp,y = c_c_dr_b0,color=t_label))+geom_point()
ggplot(data = test_attack, aes(x=Timestamp,y = f_fr_dr_dx,color=pred_label))+geom_point()
ggplot(data = test_attack, aes(x=Timestamp,y = c_c_dr,color=pred_label))+geom_point()
ggplot(data = test_attack, aes(x=Timestamp,y = f_fr_ds_tb_b0,color=pred_label))+geom_point()
ggplot(data = test_attack, aes(x=Timestamp,y = f_fr_ds_tb_b1,color=pred_label))+geom_point()

