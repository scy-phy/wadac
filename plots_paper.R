setwd("/home/itrust/iotscanner/scanner/ids/ip_camera_R_Analysis/Results/")
 
anom_data <- read.csv("anomaly.csv")

library(dplyr)
anom_data <- anom_data  %>% mutate(bin_name = substring(filename, regexpr("bnl[0-9]{2}", filename),regexpr("bks[0-9]{2}", filename)-2),
                                   block_name = substring(filename, regexpr("bks[0-9]{2}", filename),regexpr(".db", filename)-1))
anom_data <- anom_data %>% mutate(block = as.factor(as.numeric(sub("bks","",block_name))),bin = as.factor(as.numeric(sub("bnl","",bin_name))))

library(ggplot2)
ggplot(data = anom_data,aes(y=Accuracy,x=bin,group=block)) + geom_bar(stat="identity",aes(fill = block,alpha=block), position = "dodge") +theme_bw() + coord_cartesian(ylim=c(0.7,1 ))+ scale_y_continuous(breaks = c(0.7,0.75,0.8,0.85,0.9,0.95,1))+ scale_alpha_discrete(range = c(0.6, 1))+facet_grid(~block)
ggplot(data = anom_data,aes(y=Accuracy,x=bin,group=block)) + geom_bar(stat="identity",aes(fill = bin,alpha=bin), position = "dodge") +theme_bw() + coord_cartesian(ylim=c(0.7,1 ))+ scale_y_continuous(breaks = c(0.7,0.75,0.8,0.85,0.9,0.95,1))+ scale_alpha_discrete(range = c(0.6, 1))+facet_grid(~block)

ggplot(data = anom_data,aes(y=Accuracy,x=block)) + 
  geom_bar(stat="identity", position = "dodge") +theme_bw() + #ylim(0.7,1)+
  coord_cartesian(ylim=c(0.7,1 ))+ scale_y_continuous(breaks = c(0.7,0.75,0.8,0.85,0.9,0.95,1))+
  scale_alpha_discrete(range = c(0.5, 1))+facet_grid(~bin,labeller = label_both)+
  theme(text = element_text(size=26),legend.position =  "none") +xlab("block size")
ggsave("/home/itrust/Desktop/IDS/anom_cam_acc.pdf",width=10,height = 5,device=cairo_pdf)

mixed_data <- read.csv("mixed.csv")
mixed_data <- mixed_data  %>% mutate(bin = substring(filename, regexpr("bnl[0-9]{2}", filename),regexpr("bks[0-9]{2}", filename)-2),
                                     block = substring(filename, regexpr("bks[0-9]{2}", filename),regexpr(".db", filename)-1))
mixed_data <- mixed_data %>% mutate(block = as.factor(as.numeric(sub("bks","",block))),bin = as.factor(as.numeric(sub("bnl","",bin))))



ggplot(data = mixed_data,aes(y=Accuracy,x=block)) + 
  geom_bar(stat="identity", position = "dodge") + xlab("block size")+
  theme_bw() + coord_cartesian(ylim=c(0.7,1 ))+ scale_y_continuous(breaks = c(0.7,0.75,0.8,0.85,0.9,0.95,1))+
  scale_alpha_discrete(range = c(0.5, 1))+
  facet_grid(~bin,labeller = label_both)+
  theme(text = element_text(size=26))
ggsave("/home/itrust/Desktop/IDS/mixed_cam_accuracy.pdf",width=10,height = 5,device=cairo_pdf)

ggplot(data = mixed_data,aes(y=sensitivity,x=block)) + xlab("block size") + ylab("Sensitivity")+
  geom_bar(stat="identity", position = "dodge") +theme_bw() + 
  coord_cartesian(ylim=c(0.7,1 ))+ scale_y_continuous(breaks = c(0.7,0.75,0.8,0.85,0.9,0.95,1))+
  scale_alpha_discrete(range = c(0.5, 1))+facet_grid(~bin,labeller = label_both)+
  theme(text = element_text(size=26))
ggsave("/home/itrust/Desktop/IDS/mixed_cam_sensitivity.pdf",width=10,height = 5,device=cairo_pdf)

ggplot(data = mixed_data,aes(y=specificity,x=block)) + xlab("block size")+ylab("Specificity")+
  geom_bar(stat="identity", position = "dodge") +theme_bw() + 
  coord_cartesian(ylim=c(0.7,1 ))+ scale_y_continuous(breaks = c(0.7,0.75,0.8,0.85,0.9,0.95,1))+ 
  scale_alpha_discrete(range = c(0.5, 1))+facet_grid(~bin,labeller = label_both)+
  theme(text = element_text(size=26))
ggsave("/home/itrust/Desktop/IDS/mixed_cam_specificity.pdf",width=10,height = 5,device=cairo_pdf)



anom_tp <- read.csv("/home/itrust/iotscanner/scanner/ids/tplink_bulb_R_Analysis/Results/anomaly.csv")

anom_tp <- anom_tp  %>% mutate(bin_name = substring(filename, regexpr("bnl[0-9]{2}", filename),regexpr("bks[0-9]{2}", filename)-2),
                               block_name = substring(filename, regexpr("bks[0-9]{2}", filename),regexpr(".db", filename)-1))
anom_tp <- anom_tp %>% mutate(block = as.factor(as.numeric(sub("bks","",block_name))),bin = as.factor(as.numeric(sub("bnl","",bin_name))))

# labels_grid = c("100"= "bin length = 100","200"= "bin length = 200","400"= "bin length = 400","800"= "bin length = 800","1600"= "bin length = 1600")

ggplot(data = anom_tp,aes(y=Accuracy,x=block,group=block)) + xlab("block size") +
  geom_bar(stat="identity", position = "dodge") +theme_bw() + 
  coord_cartesian(ylim=c(0.7,1 ))+ scale_y_continuous(breaks = c(0.7,0.75,0.8,0.85,0.9,0.95,1))+
   scale_alpha_discrete(range = c(0.5, 1))+facet_grid(~bin,labeller = label_both)+
  theme(text = element_text(size=26))
ggsave("/home/itrust/Desktop/IDS/anom_tp_accuracy.pdf",width=10,height = 5,device=cairo_pdf)

mixed_tp <- read.csv("/home/itrust/iotscanner/scanner/ids/tplink_bulb_R_Analysis/Results/mixed.csv")
mixed_tp <- mixed_tp  %>% mutate(bin = substring(filename, regexpr("bnl[0-9]{2}", filename),regexpr("bks[0-9]{2}", filename)-2),
                                 block = substring(filename, regexpr("bks[0-9]{2}", filename),regexpr(".db", filename)-1))
mixed_tp <- mixed_tp %>% mutate(block = as.factor(as.numeric(sub("bks","",block))),bin = as.factor(as.numeric(sub("bnl","",bin))))

ggplot(data = mixed_tp,aes(y=Accuracy,x=block,group=block)) + xlab("block size")+
  geom_bar(stat="identity", position = "dodge") +
  theme_bw() + coord_cartesian(ylim=c(0.7,1 ))+ scale_y_continuous(breaks = c(0.7,0.75,0.8,0.85,0.9,0.95,1))+
   scale_alpha_discrete(range = c(0.5, 1))+
  facet_grid(~bin,labeller = label_both)+
  theme(text = element_text(size=26))
ggsave("/home/itrust/Desktop/IDS/mixed_tp_accuracy.pdf",width=10,height = 5,device=cairo_pdf)

ggplot(data = mixed_tp,aes(y=sensitivity,x=block,group=block)) + xlab("block size")+ ylab("Sensitivity")+
  geom_bar(stat="identity", position = "dodge") +theme_bw() + 
  coord_cartesian(ylim=c(0.55,1 ))+ scale_y_continuous(breaks = c(0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95,1))+
  scale_alpha_discrete(range = c(0.4, 1))+facet_grid(~bin,labeller = label_both)+
  theme(text = element_text(size=26))
ggsave("/home/itrust/Desktop/IDS/mixed_tp_sensitivity.pdf",width=10,height = 5,device=cairo_pdf)

ggplot(data = mixed_tp,aes(y=specificity,x=block,group=block)) +xlab("block size")+ ylab("Specificity")+
  geom_bar(stat="identity", position = "dodge",linetype="solid") +theme_bw() + 
  coord_cartesian(ylim=c(0.7,1 ))+ scale_y_continuous(breaks = c(0.7,0.75,0.8,0.85,0.9,0.95,1))+ 
  scale_alpha_discrete(range = c(0.5, 1))+facet_grid(~bin,labeller = label_both)+
  theme(text = element_text(size=26))
ggsave("/home/itrust/Desktop/IDS/mixed_tp_specificity.pdf",width=10,height = 5,device=cairo_pdf)







mixed_roc <- read.csv("/home/itrust/Desktop/IDS/try10/mixed_roc.csv")

roc_data <- data.frame()
roc_data <- rbind(roc_data,data.frame(pct=mixed_roc$pct,bin_block=rep("800_200",21),sensitivity=mixed_roc$sensitivity_bnl800_bks200,specificity=mixed_roc$specificity_bnl800_bks200))
roc_data <- rbind(roc_data,data.frame(pct=mixed_roc$pct,bin_block=rep("800_300",21),sensitivity=mixed_roc$sensitivity_bnl800_bks300,specificity=mixed_roc$specificity_bnl800_bks300))
roc_data <- rbind(roc_data,data.frame(pct=mixed_roc$pct,bin_block=rep("800_400",21),sensitivity=mixed_roc$sensitivity_bnl800_bks400,specificity=mixed_roc$specificity_bnl800_bks400))
roc_data <- rbind(roc_data,data.frame(pct=mixed_roc$pct,bin_block=rep("800_500",21),sensitivity=mixed_roc$sensitivity_bnl800_bks500,specificity=mixed_roc$specificity_bnl800_bks500))
roc_data <- roc_data %>% mutate(bin_block=as.factor(bin_block))

roc_data <- roc_data %>% mutate(specificity = specificity)
# roc_data <- roc_data[c(1:21),]

ggplot(roc_data)+
  geom_line(aes(x=specificity,y=sensitivity,color=bin_block,linetype=bin_block),size=1.3)+
  geom_point(aes(x=specificity,y=sensitivity,color=bin_block,shape=bin_block),size=4) +  coord_trans(y="log10") +
  # xlim(0.7,1)+
  theme_bw()+
  theme(legend.key = element_rect(), 
                legend.background = element_rect(colour = 'black', fill = 'white'),
                legend.position = c(0.4,0.3), 
                legend.box.just = "left",aspect.ratio = 0.7,text = element_text(size=26)
        , legend.title = element_text("Bin_Block",size = 22))
ggsave("/home/itrust/Desktop/IDS/ROC_Seq.pdf",width=10,height = 5,device=cairo_pdf) 


zigbee_anom <- read.csv("/home/itrust/iotscanner/scanner/ids/Zigbee_R_Analysis/Results/anomaly.csv")
zigbee_mixed <- read.csv("/home/itrust/iotscanner/scanner/ids/Zigbee_R_Analysis/Results/mixed.csv",stringsAsFactors = F)


zigbee_mixed <- zigbee_mixed  %>% mutate(block = substring(filename, regexpr("bk[0-9]{2}", filename),regexpr(".db", filename)-1))
zigbee_mixed <- zigbee_mixed %>% mutate(block = as.factor(as.numeric(sub("bk","",block))))

ggplot(zigbee_mixed)+geom_col(aes(x=block,y=Accuracy),width=0.7,position = "dodge",colour="white")+xlab("block size")+
  scale_y_continuous(breaks = c(0.7,0.75,0.8,0.85,0.9,0.95,1))+coord_cartesian(ylim=c(0.7,1 ))+
  theme_bw()+
  theme(text=element_text(size=26))+
  theme(legend.position="none",aspect.ratio = 0.6) 
ggsave("/home/itrust/Desktop/IDS/mixed_zigbee_acc.pdf",width=10,height = 5,device=cairo_pdf)

ggplot(zigbee_mixed)+geom_col(aes(x=block,y=sensitivity),width=0.7)+ylab("Sensitivity")+xlab("block size")+
  coord_cartesian(ylim=c(0.7,1 ))+ scale_y_continuous(breaks = c(0.7,0.75,0.8,0.85,0.9,0.95,1))+
  theme_bw()+
  theme(text=element_text(size=26))+
  theme(legend.position="none",aspect.ratio = 0.6)
ggsave("/home/itrust/Desktop/IDS/mixed_zigbee_sensitivity.pdf",width= 10,height = 5,device=cairo_pdf)



ggplot(zigbee_mixed)+geom_col(aes(x=block,y=specificity),width=0.7)+ylab("Specificity")+xlab("block size")+
  coord_cartesian(ylim=c(0.7,1 ))+ scale_y_continuous(breaks = c(0.7,0.75,0.8,0.85,0.9,0.95,1))+
  theme_bw()+
  theme(text=element_text(size=26),aspect.ratio = 0.6)+
  theme(legend.position="none")
ggsave("/home/itrust/Desktop/IDS/mixed_zigbee_specificity.pdf",width= 10,height = 5,device=cairo_pdf)



runtime <- read.csv("~/Desktop/IDS/runtime_feature_extractor_alt.csv",stringsAsFactors = F)
# means <- apply(runtime,2,mean)
# sds <-  apply(runtime,2,sd)
# max <- apply(runtime,2,max)
# err_plot <- data.frame(cbind(means,sds,max))
# err_plot$bin = c(10,50,100,200,300,400,500,800,1600)
min.mean.sd.max <- function(x) {
  r <- c(min(x), mean(x) - sd(x), mean(x), mean(x) + sd(x), max(x))
  names(r) <- c("ymin", "lower", "middle", "upper", "ymax")
  r
}
ggplot(data=runtime,aes(y=Time,x = as.factor(bin_length)))+ stat_summary(fun.data = min.mean.sd.max, geom = "boxplot")+
  # geom_jitter(position=position_jitter(width=.2), size=3) +
   ylab("Mean runtime [ms]")+ylim(13,21)+
  xlab("Bin Length [packets]")+ 
  theme_bw()+theme(text = element_text(size=26))
ggsave("/home/itrust/Desktop/IDS/exec_time.pdf",width=10,height = 5,device=cairo_pdf) 

