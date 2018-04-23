fetchdata <- function(dbnum,filenames){
#setwd("~/Documents/anomaly_detection/")
require(RSQLite)
require(dplyr)
require(caret)
require(Information)
driver <- dbDriver("SQLite")
dbname <- filenames[dbnum]
#Establish Connection 
conn <- dbConnect(driver,dbname=paste0(getwd(),"../../tplink_bulb_dataset/",dbname))

tab <- dbListTables(conn)
tab

packet_features <- dbGetQuery(conn,paste0("select * from ", tab[2])) 
packet_features2 <- dbGetQuery(conn,paste0("select * from ", tab[3])) 
packet_features3 <- dbGetQuery(conn,paste0("select * from ", tab[4])) 

# packet_features <- packet_features %>% left_join(packet_features2, by=c("t_mac","t_label", "c_blk_sz","f_time_window" )) %>% left_join(packet_features3, by=c("t_mac","t_label", "c_blk_sz","f_time_window" ))

packet_features <- cbind(packet_features, packet_features2 %>% select(-t_mac,-t_label,-c_blk_sz,-f_time_window),packet_features3 %>% select(-t_mac,-t_label,-c_blk_sz,-f_time_window))

#Get devices under consideration
packet_features <- packet_features %>% filter(grepl("tplink",t_label,ignore.case = T)) %>%
                                  mutate(anomaly = ifelse(grepl("normal",t_label,ignore.case = T),0,1)
                                                          # t_label = ifelse(t_label == "dlink_dosSlowloris","dlink_attackSlowloris",t_label)
                                                           )


pack_check <- packet_features %>% select(-t_mac,-t_label,-c_blk_sz)


try_woe <- create_infotables(data = pack_check,y = "anomaly",parallel = F)



imp_vars <- try_woe$Summary
imp_vars <- imp_vars %>% filter(IV > 0.5) 

f_time <- packet_features$f_time_window

packet_features <- packet_features %>% select(imp_vars$Variable,"t_mac","t_label","f_time_window")

rm(pack_check)

return_list <- list(imp_vars,packet_features,f_time)

return(return_list)

}
