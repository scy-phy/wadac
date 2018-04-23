library(ggplot2)
library(dplyr)

anomaly <- read.csv("Results/anomaly.csv",stringsAsFactors = F) %>% mutate(type = "anomaly")
mixed <- read.csv("Results/mixed.csv",stringsAsFactors = F)%>% mutate(type = "mixed")
#setwd("/Results")
all_data <- rbind(anomaly,mixed) %>% mutate(X = NULL)

all_data <- all_data  %>% mutate(bin = substring(filename, regexpr("bnl[0-9]{2}", filename),regexpr("bks[0-9]{2}", filename)-2),
                                                   block = substring(filename, regexpr("bks[0-9]{2}", filename),regexpr(".db", filename)-1))

all_data2 <- all_data %>% mutate(type = as.factor(type),bin = as.factor(bin),block=as.factor(block))
all_data2 <- all_data2 %>% select(-filename) %>%  group_by(type,block) %>% summarize(acc = median(Accuracy)*100, sensitivity=median(sensitivity)*100,specificity=median(specificity)*100) %>% ungroup() 

anom_data <- all_data2 %>% filter(type=="anomaly") 
mixed_data <- all_data2 %>% filter(type=="mixed")

anom_data <- anom_data[with(anom_data, order(as.numeric(gsub("bks", "", block)))), ]
mixed_data <- mixed_data[with(mixed_data, order(as.numeric(gsub("bks", "", block)))), ]

ggplot(data = all_data2, aes(x = block,y = acc, col = type)) +geom_line(aes(group=1))

ggplot(data = anom_data, aes(x = block,y = acc)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Anomaly Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/anomaly_block_med",".png"))
# dev.off()
ggplot(data = mixed_data, aes(x = block,y = acc)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="Mixed Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/mixed_block_med",".png"))

# ggplot(data = anom_data, aes(x = block,y = fnr)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Anomaly Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
# ggsave(paste0("Results/Plots/anomaly_med_fpr",".png"))
# ggplot(data = mixed_data, aes(x = block,y = fpr)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="Mixed Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
# ggsave(paste0("Results/Plots/mixed_med_fpr",".png"))


 # ggplot(data = anom_data, aes(x = block,y = sensitivity)) +geom_bar(fill = "brown",size = 1,width = 0.3) + labs(title="Anomaly Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
# ggsave(paste0("Results/Plots/anomaly_med_sensitivity",".png"))
ggplot(data = mixed_data, aes(x = block,y = sensitivity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="Mixed Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/mixed_med_sensitivity",".png"))


ggplot(data = anom_data, aes(x = block,y = specificity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Anomaly Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/anomaly_med_specificity",".png"))
ggplot(data = mixed_data, aes(x = block,y = specificity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="Mixed Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/mixed_med_specificity",".png"))





all_data3 <- all_data %>% mutate(type = as.factor(type),bin = as.factor(bin),block=as.factor(block))
all_data3 <- all_data3 %>% select(-filename) %>%  group_by(type,bin) %>% summarize(acc = median(Accuracy)*100, sensitivity=median(sensitivity)*100,specificity=median(specificity)*100) %>% ungroup() 

anom_data <- all_data3 %>% filter(type=="anomaly")
mixed_data <- all_data3 %>% filter(type=="mixed")

anom_data <- anom_data[with(anom_data, order(as.numeric(gsub("bin", "", bin)))), ]
mixed_data <- mixed_data[with(mixed_data, order(as.numeric(gsub("bin", "", bin)))), ]

ggplot(data = all_data3, aes(x = bin,y = acc, col = type)) +geom_line(aes(group=1))

ggplot(data = anom_data, aes(x = bin,y = acc)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Anomaly Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/anomaly_bin_med",".png"))
# dev.off()
ggplot(data = mixed_data, aes(x = bin,y = acc)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="Mixed Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/mixed_bin_med",".png"))




ggplot(data = anom_data, aes(x = bin,y = sensitivity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Anomaly Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/anomaly_med_sensitivity",".png"))
ggplot(data = mixed_data, aes(x = bin,y = sensitivity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="Mixed Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/mixed_med_sensitivity",".png"))



ggplot(data = anom_data, aes(x = bin,y = specificity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3) + labs(title="Anomaly Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/anomaly_med_specificity",".png"))
ggplot(data = mixed_data, aes(x = bin,y = specificity)) +geom_bar(stat="identity",fill = "brown",size = 1,width = 0.3)+ labs(title="Mixed Set")+ theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0)) 
ggsave(paste0("Results/Plots/mixed_med_specificity",".png"))




