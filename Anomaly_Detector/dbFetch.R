fetchdata <- function(dbnum,filenames){
  require(RSQLite)
  require(dplyr)
  require(caret)
  require(Information)
  driver <- dbDriver("SQLite")
  dbname <- filenames[dbnum]
  #Establish Connection 
  conn <- dbConnect(driver,dbname=paste0("../camera_db/",dbname))
  
  tab <- dbListTables(conn)
  tab
  
  packet_features <- dbGetQuery(conn,paste0("select * from ", tab[2])) 
  packet_features2 <- dbGetQuery(conn,paste0("select * from ", tab[3])) 
  packet_features3 <- dbGetQuery(conn,paste0("select * from ", tab[4])) 
  
  
  packet_features <- cbind(packet_features, packet_features2 %>% select(-t_mac,-t_label,-c_blk_sz,-f_time_window),packet_features3 %>% select(-t_mac,-t_label,-c_blk_sz,-f_time_window))
  
  packet_features <- packet_features %>% filter(grepl("dlink",t_label,ignore.case = T) | grepl("tplink",t_label,ignore.case = T) | grepl("Nestcam",t_label,ignore.case = T) |
                                                  grepl("Netatmo",t_label,ignore.case = T)
  ) %>% mutate(anomaly = ifelse(grepl("streaming",t_label,ignore.case = T)|grepl("idle",t_label,ignore.case = T),0,1),
               t_label = ifelse(t_label == "dlink_dosSlowloris","dlink_attackSlowloris",t_label)
  )
  
  
  pack_check <- packet_features %>% select(-t_mac,-t_label,-c_blk_sz)
  
  
  try_woe <- create_infotables(data = pack_check,y = "anomaly",parallel = F)
  
  
  
  imp_vars <- try_woe$Summary
  imp_vars <- imp_vars %>% filter(IV > 1) 
  
  f_time <- packet_features$f_time_window
  
  packet_features <- packet_features %>% select(imp_vars$Variable,"t_mac","t_label","f_time_window")
  
  rm(pack_check)
  
  return_list <- list(imp_vars,packet_features,f_time)
  
  return(return_list)
  
}


# Use fetchtrain2 for data from nestcam 

fetchtrain2_data <- function(dbnum,filenames){
  #setwd("~/Documents/anomaly_detection/")
  require(RSQLite)
  require(dplyr)
  require(caret)
  require(Information)
  driver <- dbDriver("SQLite")
  dbname <- filenames[dbnum]
  
  conn <- dbConnect(driver,dbname=paste0("../nestcam/",dbname))
  
  tab <- dbListTables(conn)
  tab
  
  attack_features <- dbGetQuery(conn,paste0("select * from ", tab[2])) 
  attack_features2 <- dbGetQuery(conn,paste0("select * from ", tab[3])) 
  attack_features3 <- dbGetQuery(conn,paste0("select * from ", tab[4])) 
  
  attack_features <- cbind(attack_features, attack_features2 %>% select(-t_mac,-t_label,-c_blk_sz,-f_time_window),attack_features3 %>% select(-t_mac,-t_label,-c_blk_sz,-f_time_window))
  
  attack_features <- attack_features %>% filter(grepl("dlink",t_label,ignore.case = T) | grepl("tplink",t_label,ignore.case = T) | grepl("Nestcam",t_label,ignore.case = T) |
                                                  grepl("Netatmo",t_label,ignore.case = T))
  
  
  normal_features <- attack_features %>% filter(t_label=="nestcam_normalactions")
  set.seed(1234)
  train_index_nestcam <- sample(nrow(normal_features), 0.6*nrow(normal_features))
  train_nestcam <- normal_features[train_index_nestcam, ]
  test_nestcam <- normal_features[-train_index_nestcam, ]
  return_list <- list(train_nestcam,test_nestcam)
  
  return(return_list)
  
}

fetchtrain3 <- function(dbnum,filenames){
  #setwd("~/Documents/anomaly_detection/")
  require(RSQLite)
  require(dplyr)
  require(caret)
  require(Information)
  driver <- dbDriver("SQLite")
  dbname <- filenames[dbnum]
  
  conn <- dbConnect(driver,dbname=paste0("../tplink_cam/",dbname))
  
  tab <- dbListTables(conn)
  tab
  
  attack_features <- dbGetQuery(conn,paste0("select * from ", tab[2])) 
  attack_features2 <- dbGetQuery(conn,paste0("select * from ", tab[3])) 
  attack_features3 <- dbGetQuery(conn,paste0("select * from ", tab[4])) 
  
  attack_features <- cbind(attack_features, attack_features2 %>% select(-t_mac,-t_label,-c_blk_sz,-f_time_window),attack_features3 %>% select(-t_mac,-t_label,-c_blk_sz,-f_time_window))
  
  attack_features <- attack_features %>% filter(grepl("dlink",t_label,ignore.case = T) | grepl("nestcam",t_label,ignore.case = T) | grepl("tplink",t_label,ignore.case = T) |
                                                  grepl("Netatmo",t_label,ignore.case = T))
  
  
  normal_features <- attack_features %>% filter(t_label=="tplinkcam_normalactions")
  set.seed(1234)
  train_index_tplink <- sample(nrow(normal_features), 0.6*nrow(normal_features))
  train_tplink <- normal_features[train_index_tplink, ]
  test_tplink <- normal_features[-train_index_tplink, ]
  return_list <- list(train_tplink,test_tplink)
  
  return(return_list)
  
}


#MIRAI
fetch_mirai_attack <- function(dbnum,filenames){
  #setwd("~/Documents/anomaly_detection/")
  require(RSQLite)
  require(dplyr)
  require(caret)
  require(Information)
  driver <- dbDriver("SQLite")
  dbname <- filenames[dbnum]
  #Establish Connection 
  conn <- dbConnect(driver,dbname=paste0("../mirai/dlink_mirai_attack3/",dbname))
  
  tab <- dbListTables(conn)
  tab
  
  
  attack_features <- dbGetQuery(conn,paste0("select * from ", tab[2])) 
  attack_features2 <- dbGetQuery(conn,paste0("select * from ", tab[3])) 
  attack_features3 <- dbGetQuery(conn,paste0("select * from ", tab[4])) 
  
  attack_features <- cbind(attack_features, attack_features2 %>% select(-t_mac,-t_label,-c_blk_sz,-f_time_window),attack_features3 %>% select(-t_mac,-t_label,-c_blk_sz,-f_time_window))
  
  attack_features <- attack_features %>% filter(grepl("dlink",t_label,ignore.case = T) | grepl("nestcam",t_label,ignore.case = T) | grepl("tplink",t_label,ignore.case = T) |
                                                  grepl("Netatmo",t_label,ignore.case = T))
  attack_features <- attack_features %>% mutate(t_label = "mirai_attack")
  unique(attack_features$t_label)
  return(attack_features)
}

fetch_mirai_normal <- function(dbnum,filenames){
  #setwd("~/Documents/anomaly_detection/")
  require(RSQLite)
  require(dplyr)
  require(caret)
  require(Information)
  driver <- dbDriver("SQLite")
  dbname <- filenames[dbnum]
  #Establish Connection 
  conn <- dbConnect(driver,dbname=paste0("../mirai/dlink_mirai_normal/",dbname))
  tab <- dbListTables(conn)
  tab
  attack_features <- dbGetQuery(conn,paste0("select * from ", tab[2])) 
  attack_features2 <- dbGetQuery(conn,paste0("select * from ", tab[3])) 
  attack_features3 <- dbGetQuery(conn,paste0("select * from ", tab[4])) 
  
  attack_features <- cbind(attack_features, attack_features2 %>% select(-t_mac,-t_label,-c_blk_sz,-f_time_window),attack_features3 %>% select(-t_mac,-t_label,-c_blk_sz,-f_time_window))
  
  attack_features <- attack_features %>% filter(grepl("dlink",t_label,ignore.case = T) | grepl("nestcam",t_label,ignore.case = T) | grepl("tplink",t_label,ignore.case = T) |
                                                  grepl("Netatmo",t_label,ignore.case = T))
  
  attack_features <- attack_features %>% mutate(t_label = "mirai_normal")
  unique(attack_features$t_label)
  return(attack_features)
  
}



fetch_mirai_att2 <- function(dbnum,filenames){
  #setwd("~/Documents/anomaly_detection/")
  require(RSQLite)
  require(dplyr)
  require(caret)
  require(Information)
  driver <- dbDriver("SQLite")
  dbname <- filenames[dbnum]
  #Establish Connection 
  conn <- dbConnect(driver,dbname=paste0("../mirai/dlink_mirai_attack2/",dbname))
  tab <- dbListTables(conn)
  tab
  attack_features <- dbGetQuery(conn,paste0("select * from ", tab[2])) 
  attack_features2 <- dbGetQuery(conn,paste0("select * from ", tab[3])) 
  attack_features3 <- dbGetQuery(conn,paste0("select * from ", tab[4])) 
  
  attack_features <- cbind(attack_features, attack_features2 %>% select(-t_mac,-t_label,-c_blk_sz,-f_time_window),attack_features3 %>% select(-t_mac,-t_label,-c_blk_sz,-f_time_window))
  
  attack_features <- attack_features %>% filter(grepl("dlink",t_label,ignore.case = T) | grepl("nestcam",t_label,ignore.case = T) | grepl("tplink",t_label,ignore.case = T) |
                                                  grepl("Netatmo",t_label,ignore.case = T))
  
  # attack_features <- attack_features %>% mutate(t_label = "mirai_att2")
  unique(attack_features$t_label)
  return(attack_features)
  
}

fetch_mirai_att2_new <- function(dbnum,filenames){
  #setwd("~/Documents/anomaly_detection/")
  require(RSQLite)
  require(dplyr)
  require(caret)
  require(Information)
  driver <- dbDriver("SQLite")
  dbname <- filenames[dbnum]
  #Establish Connection 
  conn <- dbConnect(driver,dbname=paste0("../mirai/dlink_mirai_attack2/new/",dbname))
  tab <- dbListTables(conn)
  tab
  attack_features <- dbGetQuery(conn,paste0("select * from ", tab[2])) 
  attack_features2 <- dbGetQuery(conn,paste0("select * from ", tab[3])) 
  attack_features3 <- dbGetQuery(conn,paste0("select * from ", tab[4])) 
  
  attack_features <- cbind(attack_features, attack_features2 %>% select(-t_mac,-t_label,-c_blk_sz,-f_time_window),attack_features3 %>% select(-t_mac,-t_label,-c_blk_sz,-f_time_window))
  
  attack_features <- attack_features %>% filter(grepl("dlink",t_label,ignore.case = T) | grepl("nestcam",t_label,ignore.case = T) | grepl("tplink",t_label,ignore.case = T) |
                                                  grepl("Netatmo",t_label,ignore.case = T))
  
  # attack_features <- attack_features %>% mutate(t_label = "mirai_att2")
  unique(attack_features$t_label)
  return(attack_features)
  
}

fetch_mirai_att1 <- function(dbnum,filenames){
  #setwd("~/Documents/anomaly_detection/")
  require(RSQLite)
  require(dplyr)
  require(caret)
  require(Information)
  driver <- dbDriver("SQLite")
  dbname <- filenames[dbnum]
  #Establish Connection 
  conn <- dbConnect(driver,dbname=paste0("../mirai/dlink_mirai_attack1/",dbname))
  tab <- dbListTables(conn)
  tab
  attack_features <- dbGetQuery(conn,paste0("select * from ", tab[2])) 
  attack_features2 <- dbGetQuery(conn,paste0("select * from ", tab[3])) 
  attack_features3 <- dbGetQuery(conn,paste0("select * from ", tab[4])) 
  
  attack_features <- cbind(attack_features, attack_features2 %>% select(-t_mac,-t_label,-c_blk_sz,-f_time_window),attack_features3 %>% select(-t_mac,-t_label,-c_blk_sz,-f_time_window))
  
  attack_features <- attack_features %>% filter(grepl("dlink",t_label,ignore.case = T) | grepl("nestcam",t_label,ignore.case = T) | grepl("tplink",t_label,ignore.case = T) |
                                                  grepl("Netatmo",t_label,ignore.case = T))
  
  # attack_features <- attack_features %>% mutate(t_label = "mirai_att1")
  unique(attack_features$t_label)
  return(attack_features)
  
}

fetch_mirai_att1_new <- function(dbnum,filenames){
  #setwd("~/Documents/anomaly_detection/")
  require(RSQLite)
  require(dplyr)
  require(caret)
  require(Information)
  driver <- dbDriver("SQLite")
  dbname <- filenames[dbnum]
  #Establish Connection 
  conn <- dbConnect(driver,dbname=paste0("../mirai/dlink_mirai_attack1/new/",dbname))
  tab <- dbListTables(conn)
  tab
  attack_features <- dbGetQuery(conn,paste0("select * from ", tab[2])) 
  attack_features2 <- dbGetQuery(conn,paste0("select * from ", tab[3])) 
  attack_features3 <- dbGetQuery(conn,paste0("select * from ", tab[4])) 
  
  attack_features <- cbind(attack_features, attack_features2 %>% select(-t_mac,-t_label,-c_blk_sz,-f_time_window),attack_features3 %>% select(-t_mac,-t_label,-c_blk_sz,-f_time_window))
  
  attack_features <- attack_features %>% filter(grepl("dlink",t_label,ignore.case = T) | grepl("nestcam",t_label,ignore.case = T) | grepl("tplink",t_label,ignore.case = T) |
                                                  grepl("Netatmo",t_label,ignore.case = T))
  
  # attack_features <- attack_features %>% mutate(t_label = "mirai_att1")
  unique(attack_features$t_label)
  return(attack_features)
  
}
