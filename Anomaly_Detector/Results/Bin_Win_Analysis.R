library(ggplot2)
library(dplyr)

anomaly <- read.csv("Results/anomaly.csv",stringsAsFactors = F) %>% mutate(type = "anomaly") %>% rename("fpr" = "fnr")
stream <- read.csv("Results/stream.csv",stringsAsFactors = F) %>% mutate(type = "stream")
idle <- read.csv("Results/idle.csv",stringsAsFactors = F)%>% mutate(type = "idle")
mixed <- read.csv("Results/mixed.csv",stringsAsFactors = F)%>% mutate(type = "mixed")
nestcam_ddos <- read.csv("Results/ddos.csv",stringsAsFactors = F)%>% mutate(type = "nestcam_ddos")
tplink_ddos<- read.csv("Results/tplink_ddos.csv",stringsAsFactors = F)%>% mutate(type = "tplink_ddos")
mirai_data <- read.csv("Results/mirai_attack_frame.csv",stringsAsFactors = F)%>% mutate(type = "mirai")
#setwd("/Results")
all_data <- rbind(anomaly,stream,idle,mixed,nestcam_ddos,tplink_ddos,mirai_data) %>% mutate(X = NULL)

all_data <- all_data  %>% mutate(bin = substring(filename, regexpr("bnl[0-9]{2}", filename),regexpr("bks[0-9]{2}", filename)-2),
                                                   block = substring(filename, regexpr("bks[0-9]{2}", filename),regexpr(".db", filename)-1))

all_data2 <- all_data %>% mutate(type = as.factor(type),bin = as.factor(bin),block=as.factor(block))
all_data2 <- all_data2 %>% select(-filename) %>%  group_by(type,block) %>% summarize(acc = median(Accuracy)*100, fpr = median(fpr)*100,sensitivity=median(sensitivity)*100,specificity=median(specificity)*100) %>% ungroup() 

anom_data <- all_data2 %>% filter(type=="anomaly") %>% rename("fnr" = "fpr")
stream_data <- all_data2 %>% filter(type=="stream")
idle_data <- all_data2 %>% filter(type=="idle")
mixed_data <- all_data2 %>% filter(type=="mixed")
nestcam_data<- all_data2 %>% filter(type=="nestcam_ddos")
tplink_data<- all_data2 %>% filter(type=="tplink_ddos")
mirai_data <- all_data2 %>% filter(type=="mirai")

anom_data <- anom_data[with(anom_data, order(as.numeric(gsub("bks", "", block)))), ]
stream_data <- stream_data[with(stream_data, order(as.numeric(gsub("bks", "", block)))), ]
idle_data <- idle_data[with(idle_data, order(as.numeric(gsub("bks", "", block)))), ]
mixed_data <- mixed_data[with(mixed_data, order(as.numeric(gsub("bks", "", block)))), ]
nestcam_data <- nestcam_data[with(nestcam_data, order(as.numeric(gsub("bks", "", block)))), ]
tplink_data <- tplink_data[with(tplink_data, order(as.numeric(gsub("bks", "", block)))), ]
mirai_data <- mirai_data[with(mirai_data, order(as.numeric(gsub("bks", "", block)))), ]

ggplot(data = all_data2, aes(x = block,y = acc, col = type)) +geom_line(aes(group=1))

ggplot(data = anom_data, aes(x = block,y = acc)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Anomaly Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/anomaly_block_med",".png"))
# dev.off()
ggplot(data = stream_data, aes(x = block,y = acc)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Stream Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/stream_block_med",".png"))
ggplot(data = idle_data, aes(x = block,y = acc)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Idle Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/idle_block_med",".png"))
ggplot(data = mixed_data, aes(x = block,y = acc)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="Mixed Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/mixed_block_med",".png"))
ggplot(data = nestcam_data, aes(x = block,y = acc)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="NESTCAM_DDOS Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/nestcam_block_med",".png"))
ggplot(data = tplink_data, aes(x = block,y = acc)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="TPLink_DDOS Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/tplink_block_med",".png"))
ggplot(data = mirai_data, aes(x = block,y = acc)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="TPLink_DDOS Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/mirai_block_med",".png"))


ggplot(data = anom_data, aes(x = block,y = fnr)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Anomaly Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/anomaly_med_fpr",".png"))
ggplot(data = stream_data, aes(x = block,y = fpr)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Stream Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/stream_med_fpr",".png"))
ggplot(data = idle_data, aes(x = block,y = fpr)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Idle Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/idle_med_fpr",".png"))
ggplot(data = mixed_data, aes(x = block,y = fpr)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="Mixed Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/mixed_med_fpr",".png"))
ggplot(data = nestcam_data, aes(x = block,y = fpr)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="NESTCAM_DDOS Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/nestcam_block_fpr",".png"))
ggplot(data = tplink_data, aes(x = block,y = fpr)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="TPLink_DDOS Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/tplink_block_fpr",".png"))
ggplot(data = mirai_data, aes(x = block,y = fpr)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="TPLink_DDOS Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/mirai_block_fpr",".png"))

# ggplot(data = anom_data, aes(x = block,y = sensitivity)) +geom_bar(fill = "brown",size = 1,width = 0.3) + labs(title="Anomaly Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
# ggsave(paste0("Results/Plots/anomaly_med_sensitivity",".png"))
ggplot(data = stream_data, aes(x = block,y = sensitivity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Stream Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/stream_med_sensitivity",".png"))
ggplot(data = idle_data, aes(x = block,y = sensitivity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Idle Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/idle_med_sensitivity",".png"))
ggplot(data = mixed_data, aes(x = block,y = sensitivity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="Mixed Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/mixed_med_sensitivity",".png"))
ggplot(data = nestcam_data, aes(x = block,y = sensitivity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="NESTCAM_DDOS Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/nestcam_block_sensitivity",".png"))
ggplot(data = tplink_data, aes(x = block,y = sensitivity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="TPLink_DDOS Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/tplink_block_sensitivity",".png"))
ggplot(data = mirai_data, aes(x = block,y = sensitivity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="TPLink_DDOS Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/mirai_block_sensitivity",".png"))



ggplot(data = anom_data, aes(x = block,y = specificity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Anomaly Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/anomaly_med_specificity",".png"))
ggplot(data = stream_data, aes(x = block,y = specificity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Stream Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/stream_med_specificity",".png"))
ggplot(data = idle_data, aes(x = block,y = specificity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Idle Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/idle_med_specificity",".png"))
ggplot(data = mixed_data, aes(x = block,y = specificity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="Mixed Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/mixed_med_specificity",".png"))
ggplot(data = nestcam_data, aes(x = block,y = specificity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="NESTCAM_DDOS Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/nestcam_block_specificity",".png"))
ggplot(data = tplink_data, aes(x = block,y = specificity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="TPLink_DDOS Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/tplink_block_specificity",".png"))
ggplot(data = mirai_data, aes(x = block,y = specificity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="TPLink_DDOS Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/mirai_block_specificity",".png"))






all_data3 <- all_data %>% mutate(type = as.factor(type),bin = as.factor(bin),block=as.factor(block))
all_data3 <- all_data3 %>% select(-filename) %>%  group_by(type,bin) %>% summarize(acc = median(Accuracy)*100, fpr = median(fpr)*100,sensitivity=median(sensitivity)*100,specificity=median(specificity)*100) %>% ungroup() 

anom_data <- all_data3 %>% filter(type=="anomaly") %>% rename("fnr" = "fpr")
stream_data <- all_data3 %>% filter(type=="stream")
idle_data <- all_data3 %>% filter(type=="idle")
mixed_data <- all_data3 %>% filter(type=="mixed")
nestcam_data<- all_data3 %>% filter(type=="nestcam_ddos")
tplink_data<- all_data3 %>% filter(type=="tplink_ddos")
mirai_data <- all_data3 %>% filter(type=="mirai")

anom_data <- anom_data[with(anom_data, order(as.numeric(gsub("bin", "", bin)))), ]
stream_data <- stream_data[with(stream_data, order(as.numeric(gsub("bin", "", bin)))), ]
idle_data <- idle_data[with(idle_data, order(as.numeric(gsub("bin", "", bin)))), ]
mixed_data <- mixed_data[with(mixed_data, order(as.numeric(gsub("bin", "", bin)))), ]
nestcam_data <- nestcam_data[with(nestcam_data, order(as.numeric(gsub("bin", "", bin)))), ]
tplink_data <- tplink_data[with(tplink_data, order(as.numeric(gsub("bin", "", bin)))), ]
mirai_data <- mirai_data[with(mirai_data, order(as.numeric(gsub("bin", "", bin)))), ]

ggplot(data = all_data3, aes(x = bin,y = acc, col = type)) +geom_line(aes(group=1))

ggplot(data = anom_data, aes(x = bin,y = acc)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Anomaly Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/anomaly_bin_med",".png"))
# dev.off()
ggplot(data = stream_data, aes(x = bin,y = acc)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Stream Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/stream_bin_med",".png"))
ggplot(data = idle_data, aes(x = bin,y = acc)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Idle Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/idle_bin_med",".png"))
ggplot(data = mixed_data, aes(x = bin,y = acc)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="Mixed Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/mixed_bin_med",".png"))
ggplot(data = nestcam_data, aes(x = bin,y = acc)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="NESTCAM_DDOS Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/nestcam_bin_med",".png"))
ggplot(data = tplink_data, aes(x = bin,y = acc)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="TPLink_DDOS Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/tplink_bin_med",".png"))


ggplot(data = anom_data, aes(x = bin,y = fnr)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Anomaly Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/anomaly_med_fpr",".png"))
ggplot(data = stream_data, aes(x = bin,y = fpr)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Stream Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/stream_med_fpr",".png"))
ggplot(data = idle_data, aes(x = bin,y = fpr)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Idle Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/idle_med_fpr",".png"))
ggplot(data = mixed_data, aes(x = bin,y = fpr)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="Mixed Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/mixed_med_fpr",".png"))
ggplot(data = nestcam_data, aes(x = bin,y = fpr)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="NESTCAM_DDOS Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/nestcam_bin_fpr",".png"))
ggplot(data = tplink_data, aes(x = bin,y = fpr)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="TPLink_DDOS Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/tplink_bin_fpr",".png"))


ggplot(data = anom_data, aes(x = bin,y = sensitivity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Anomaly Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/anomaly_med_sensitivity",".png"))
ggplot(data = stream_data, aes(x = bin,y = sensitivity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Stream Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/stream_med_sensitivity",".png"))
ggplot(data = idle_data, aes(x = bin,y = sensitivity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Idle Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/idle_med_sensitivity",".png"))
ggplot(data = mixed_data, aes(x = bin,y = sensitivity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="Mixed Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/mixed_med_sensitivity",".png"))
ggplot(data = nestcam_data, aes(x = bin,y = sensitivity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="NESTCAM_DDOS Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/nestcam_bin_sensitivity",".png"))
ggplot(data = tplink_data, aes(x = bin,y = sensitivity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="TPLink_DDOS Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/tplink_bin_sensitivity",".png"))



ggplot(data = anom_data, aes(x = bin,y = specificity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Anomaly Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/anomaly_med_specificity",".png"))
ggplot(data = stream_data, aes(x = bin,y = specificity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Stream Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/stream_med_specificity",".png"))
ggplot(data = idle_data, aes(x = bin,y = specificity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Idle Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/idle_med_specificity",".png"))
ggplot(data = mixed_data, aes(x = bin,y = specificity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="Mixed Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/mixed_med_specificity",".png"))
ggplot(data = nestcam_data, aes(x = bin,y = specificity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="NESTCAM_DDOS Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/nestcam_bin_specificity",".png"))
ggplot(data = tplink_data, aes(x = bin,y = specificity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="TPLink_DDOS Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/tplink_bin_specificity",".png"))




