fetchdata <- function(dbnum,filenames){
require(RSQLite)
require(dplyr)
require(caret)
require(Information)
driver <- dbDriver("SQLite")
dbname <- filenames[dbnum]
conn <- dbConnect(driver,dbname=paste0(getwd(),"../../zigbee_dataset/",dbname))

tab <- dbListTables(conn)
tab

packet_features <- dbGetQuery(conn,paste0("select * from ", tab[2])) 

# packet_features <- packet_features %>% left_join(packet_features2, by=c("t_mac","t_label", "c_blk_sz","f_time_window" )) %>% left_join(packet_features3, by=c("t_mac","t_label", "c_blk_sz","f_time_window" ))


#Get devices under consideration
packet_features <- packet_features %>% rename(t_label = t_mac_label) %>% mutate(anomaly = ifelse(grepl("normal",t_label,ignore.case = T),0,1)
                                                          # t_label = ifelse(t_label == "dlink_dosSlowloris","dlink_attackSlowloris",t_label)
                                                           )


pack_check <- packet_features %>% select(-t_mac,-t_label,-c_s_bk,-t_mac_hex)


try_woe <- create_infotables(data = pack_check,y = "anomaly",parallel = F)



imp_vars <- try_woe$Summary
imp_vars <- imp_vars %>% filter(IV > 0.5) 


packet_features <- packet_features %>% select(imp_vars$Variable,"t_mac","t_label")

rm(pack_check)

return_list <- list(imp_vars,packet_features)

return(return_list)

}
