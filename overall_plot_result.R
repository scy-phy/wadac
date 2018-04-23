library(ggplot2)
library(dplyr)
# setwd("../")
setwd("/home/itrust/Desktop/IDS/")


dirs <- c("try5/Results","try6/Results","try7/Results","try8/Results","try9/Results")

overall_frame <- data.frame(type=c("1"),block=as.factor(1),bin= as.factor(1),acc = c(1),fpr = c(1))
for(i in dirs){
  setwd(paste0("/home/itrust/Desktop/IDS/",i))
  
  anomaly <- read.csv("anomaly.csv",stringsAsFactors = F) %>% mutate(type = "anomaly") %>% rename("fpr" = "fnr")
  stream <- read.csv("stream.csv",stringsAsFactors = F) %>% mutate(type = "stream")
  idle <- read.csv("idle.csv",stringsAsFactors = F)%>% mutate(type = "idle")
  mixed <- read.csv("mixed.csv",stringsAsFactors = F)%>% mutate(type = "mixed")
  all_data <- rbind(anomaly,stream,idle,mixed) %>% mutate(X = NULL)
  all_data <- all_data  %>% mutate(bin = substring(filename, regexpr("bnl[0-9]{2}", filename),regexpr("bks[0-9]{2}", filename)-2),
                                   block = substring(filename, regexpr("bks[0-9]{2}", filename),regexpr(".db", filename)-1))
  all_data2 <- all_data %>% mutate(type = as.factor(type),bin = as.factor(bin),block=as.factor(block))
  all_data3 <- all_data2 %>% select(-filename) %>%  group_by(type,block,bin) %>% summarize(acc = (Accuracy)*100, fpr = (fpr)*100)  
  print(class(all_data3))
  all_data3 <- as.data.frame(all_data3) 
  print(class(all_data3))
  print(head(all_data3))
  overall_frame <- rbind(overall_frame,all_data3)
  }


overall_frame <- overall_frame[-1,]


overall_frame <- overall_frame %>% group_by(type,block) %>% summarize(mean_acc = mean(acc),sd_acc = sd(acc),mean_fpr = mean(fpr),sd_fpr = sd(fpr))


anom_data <- overall_frame %>% filter(type=="anomaly") %>% rename("mean_fnr" = "mean_fpr","sd_fnr" = "sd_fpr")%>% mutate(block = as.character(block))
stream_data <- overall_frame %>% filter(type=="stream")
idle_data <- overall_frame %>% filter(type=="idle")
mixed_data <- overall_frame %>% filter(type=="mixed")

anom_data <- anom_data[with(anom_data, order(as.numeric(gsub("bks", "", block)))), ] 
stream_data <- stream_data[with(stream_data, order(as.numeric(gsub("bks", "", block)))), ]
idle_data <- idle_data[with(idle_data, order(as.numeric(gsub("bks", "", block)))), ]
mixed_data <- mixed_data[with(mixed_data, order(as.numeric(gsub("bks", "", block)))), ]


ggplot(data = all_data2, aes(x = block,y = acc, col = type)) +geom_line(aes(group=1))
# ggplot(data = all_data2, aes(x = bin,y = acc)) +geom_line(aes(group=1))

#bin_data = list(anom_data,stream_data,idle_data,mixed_data)
# 
# for(i in bin_data){
#   #png(paste0("/home/itrust/Desktop/IDS/try5/Results/Plots/",i,".png"))
#  p <-  ggplot(data = i, aes(x = bin,y = acc)) +geom_bar(stat="identitsy",fill = "brown",size = 1,width = 0.3) + labs(title="Anomaly Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
#   #ggsave(paste0("/home/itrust/Desktop/IDS/try5/Results/Plots/",i,".png"))
#   dev.copy(png,paste0("/home/itrust/Desktop/IDS/try5/Results/Plots/",i,".png"), width=4, height=4)
#   dev.off()
# }

# ggplot(data = anom_data, aes(x = block,y = acc)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Anomaly Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
# ggsave(paste0("/home/itrust/Desktop/IDS/try5/Results/Plots/anomaly_block_med",".png"))
# #dev.off()
# ggplot(data = stream_data, aes(x = block,y = acc)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Stream Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
# ggsave(paste0("/home/itrust/Desktop/IDS/try5/Results/Plots/stream_block_med",".png"))
# ggplot(data = idle_data, aes(x = block,y = acc)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Idle Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
# ggsave(paste0("/home/itrust/Desktop/IDS/try5/Results/Plots/idle_block_med",".png"))
# ggplot(data = mixed_data, aes(x = block,y = acc)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="Mixed Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
# ggsave(paste0("/home/itrust/Desktop/IDS/try5/Results/Plots/mixed_block_med",".png"))
# 
# 
# ggplot(data = anom_data, aes(x = block,y = fnr)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Anomaly Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
# ggsave(paste0("/home/itrust/Desktop/IDS/try5/Results/Plots/anomaly_med_fpr",".png"))
# ggplot(data = stream_data, aes(x = block,y = fpr)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Stream Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
# ggsave(paste0("/home/itrust/Desktop/IDS/try5/Results/Plots/stream_med_fpr",".png"))
# ggplot(data = idle_data, aes(x = block,y = fpr)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Idle Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
# ggsave(paste0("/home/itrust/Desktop/IDS/try5/Results/Plots/idle_med_fpr",".png"))
# ggplot(data = mixed_data, aes(x = block,y = fpr)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="Mixed Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
# ggsave(paste0("/home/itrust/Desktop/IDS/try5/Results/Plots/mixed_med_fpr",".png"))


# window_data <- all_data %>% select(-filename) %>% filter(bin == "bnl10")
# anom_window <- window_data %>% filter(type=="anomaly")
# stream_window <- window_data %>% filter(type=="stream")
# idle_window <- window_data %>% filter(type=="idle")
# mixed_window <- window_data %>% filter(type=="mixed")
# 
# ggplot(data = anom_window, aes(x = block,y = Accuracy)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Anomaly Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
# ggsave(paste0("/home/itrust/Desktop/IDS/try5/Results/Plots/anomaly_block_acc",".png"))
# ggplot(data = stream_window, aes(x = block,y = Accuracy)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Stream Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
# ggsave(paste0("/home/itrust/Desktop/IDS/try5/Results/Plots/stream_block_acc",".png"))
# ggplot(data = idle_window, aes(x = block,y = Accuracy)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Idle Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
# ggsave(paste0("/home/itrust/Desktop/IDS/try5/Results/Plots/idle_block_acc",".png"))
# ggplot(data = mixed_window, aes(x = block,y = Accuracy)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="Mixed Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
# ggsave(paste0("/home/itrust/Desktop/IDS/try5/Results/Plots/mixed_block_acc",".png"))
# 
# 
# ggplot(data = anom_window, aes(x = block,y = fpr)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Anomaly Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
# ggsave(paste0("/home/itrust/Desktop/IDS/try5/Results/Plots/anomaly_block_fpr",".png"))
# ggplot(data = stream_window, aes(x = block,y = fpr)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Stream Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
# ggsave(paste0("/home/itrust/Desktop/IDS/try5/Results/Plots/stream_block_fpr",".png"))
# ggplot(data = idle_window, aes(x = block,y = fpr)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Idle Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
# ggsave(paste0("/home/itrust/Desktop/IDS/try5/Results/Plots/idle_block_fpr",".png"))
# ggplot(data = mixed_window, aes(x = block,y = fpr)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="Mixed Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
# ggsave(paste0("/home/itrust/Desktop/IDS/try5/Results/Plots/mixed_block_fpr",".png"))
# setwd("/home/itrust/Desktop/IDS/try5/")
# 
# # save.image("fin.RDA")
# 
