server <- function(input, output) {
  
  library(keras)
  library(RSQLite)
  library(dplyr)
  library(randomForest)
  library(future)
  plan(multiprocess)
  library(plotly)
  load("cols_keep.RData")
  load("mse_train.RData")
  load("desc_normal_train.RData")
  model_cam = load_model_hdf5("model_cam.hdf5")
  source("desc_normalize.R")
  k= (quantile(mse_train,probs = c(0.95))+1.5*IQR(mse_train))
  dbname="demo/live_db_sigs_bnl800_bks300.db"  
  driver <- dbDriver("SQLite")
  future(system("python live_capture_n_extract_features_anomaly_detect.py"))
  # conn <- dbConnect(driver,dbname)
  # tab <- dbListTables(conn)
  # dbDisconnect(conn,dbname)
  
  # get_rowcount = function(dbname){
  #   driver <- dbDriver("SQLite")
  #   conn <- dbConnect(driver,dbname=dbname)
  #   tab <- dbListTables(conn)
  #   rowcount <- as.numeric(dbGetQuery(conn,paste0("select count(*) from ", tab[2])))
  #   rowcount2 <- as.numeric(dbGetQuery(conn,paste0("select count(*) from ", tab[2])))
  #   dbDisconnect(conn,dbname=dbname)
  #   return(rowcount)
  # }
  
  update_data = reactive({
    invalidateLater(1000)
    
    try(
    {conn <- dbConnect(driver,dbname,synchronous=NULL)
    tab <- dbListTables(conn)
    
    new_row = dbGetQuery(conn,paste0("Select count(*) from ", tab[2]))
    dbDisconnect(conn,dbname)
    # old_row = nrow(new_data)
    # new_row
    if(old_row<new_row){
      # driver <- dbDriver("SQLite")
      conn <- dbConnect(driver,dbname,synchronous=NULL)
      # tab <- dbListTables(conn)
      all_data <- dbGetQuery(conn,paste0("select * from ", tab[2]," Limit ",old_row,",",(new_row-old_row)))
      dbDisconnect(conn,dbname)
      old_row <<- new_row
      return(all_data)
    }else{
      return(NULL)
      print("No new updates")
    }},silent = T)}
  )
 
   
  get_data = reactive({
    conn <- dbConnect(driver,dbname,synchronous=NULL)
    tab <- dbListTables(conn)
    all_data <- dbGetQuery(conn,paste0("select * from ", tab[2]))
    dbDisconnect(conn,dbname)
    # old_row = nrow(all_data)
    return(all_data)
  })
  
  # start_sniffing = observeEvent(input$start,{
  #    if(input$start>0){
  #     print("works")
  # 
  # future(system("python live_capture_n_extract_features_anomaly_detect.py"))
  #    }
  # })
  
  # start_sniffing = observe({
  #   if(input$start>0){
  #     print("SNIFFF!")
  #     future(system("python live_capture_n_extract_features_anomaly_detect.py"))
  #   }
  # })
  
  
  stop_sniffing = observe({
     if(input$stop>0){
    print("terminated!")
    system("killall python")  
     }
  })
  
  data = reactive({
    library(reticulate) 
    library(future)
    plan(multiprocess)
    
    
    all_data = get_data()
    old_row<<-nrow(all_data)
    
    new_data = update_data()
    if(!is.null(new_data)){
      all_data = new_data
    }
    
    print(tail(all_data,1))
    cols_keep = c(cols_keep,"Timestamp")
    all_data <- all_data %>% mutate(Timestamp = as.POSIXct(f_time_fstframe,origin="1970-01-01",tz = Sys.timezone())) %>% select(-f_time_fstframe) %>% select(cols_keep)
    return(all_data)
  })
  
  apply_ad = reactive({
    
    all_data = data()
    desc_all = get_desc(all_data %>% select(-Timestamp))
    temp_data = all_data%>% select(-Timestamp) %>% normalization_minmax(desc_all) %>% as.matrix()
    temp_data[is.nan(temp_data)] = 0
    pred_all <- predict(model_cam,temp_data)
    mse_all <- apply((temp_data - pred_all)^2, 1, sum)
    all_data = all_data %>% mutate(mse = mse_all) %>% mutate(anomaly = as.factor(ifelse(mse>k,1,0)))
    return(all_data)
  })
  
  attack_classification = reactive({
    load("./supervised_model.RData")  
    attack_data =  apply_ad() %>% filter(anomaly==1) %>% select(-anomaly)
    print(ncol(attack_data))
    library(caret)
    if(nrow(attack_data)>0){
      attack_data$pred_label <- predict(best_model,newdata=attack_data,type = "response") }else{
        temp = data.frame(t(rep(0,20)),Sys.time(),0,0)
        colnames(temp) = colnames(attack_data)
        attack_data <- rbind(attack_data,temp)
      }
    
    return(attack_data)
  })
  
output$anomaly_detector = renderPlot({
  # k = 1.366
  mix_data =   apply_ad()
  
  p = ggplot(mix_data,aes(x = Timestamp, y = mse,color = anomaly)) + geom_point()  + geom_line(aes(y=k))+scale_color_brewer(palette = "Set2") + theme_bw()+
    theme(legend.position="bottom")
  p
  # ggplotly(p)
})

output$af1 = renderPlot({
  # k = 1.366
  mix_data =   apply_ad()
  
  p = ggplot(mix_data,aes(x = Timestamp, y = f_mn_cx_xs,color = anomaly)) + geom_point()+ theme_bw()+scale_color_brewer(palette = "Set2") +theme(legend.position="bottom")  #+ geom_line(aes(y=k))+scale_color_brewer(palette = "Set2")
  # ggplotly(p)
  p
})

output$af2 = renderPlot({
  # k = 1.366
  mix_data =   apply_ad()
  
  p = ggplot(mix_data,aes(x = Timestamp, y = f_fr_dx_tb_b1,color = anomaly)) + geom_point()+ theme_bw() +scale_color_brewer(palette = "Set2") +theme(legend.position="bottom")  #+ geom_line(aes(y=k))+scale_color_brewer(palette = "Set2")
  # ggplotly(p)
  p
})

output$af3 = renderPlot({
  # k = 1.366
  mix_data =   apply_ad()
  
  p = ggplot(mix_data,aes(x = Timestamp, y = f_fr_dx_tb_b0,color = anomaly)) + geom_point() + theme_bw() +scale_color_brewer(palette = "Set2")+theme(legend.position="bottom")  #+ geom_line(aes(y=k))+scale_color_brewer(palette = "Set2")
  # ggplotly(p)
  p
})

output$attack_class = renderPlot({
  attack_data =   attack_classification()
  p = ggplot(data=attack_data,aes(x=Timestamp,y=mse,color=pred_label))+geom_point()+theme_bw()+theme(legend.position="bottom")
  # ggplotly(p)
  p
})

output$ac1 = renderPlot({
  attack_data =   attack_classification()
  p = ggplot(data=attack_data,aes(x=Timestamp,y=f_mn_xs_dx_b0,color=pred_label))+geom_point()+theme_bw()+theme(legend.position="bottom")
  # ggplotly(p)
  p
})

output$ac2 = renderPlot({
  attack_data =   attack_classification()
  p = ggplot(data=attack_data,aes(x=Timestamp,y=c_c_dx,color=pred_label))+geom_point()+theme_bw()+theme(legend.position="bottom")
  # ggplotly(p)
  p
})


output$ac3 = renderPlot({
  attack_data =   attack_classification()
  p = ggplot(data=attack_data,aes(x=Timestamp,y=f_fr_dx_x,color=pred_label))+geom_point()+theme_bw()+theme(legend.position="bottom")
  # ggplotly(p)
  p })

output$ac4 = renderPlot({
  attack_data =   attack_classification()
  p = ggplot(data=attack_data,aes(x=Timestamp,y=f_fr_cx_x,color=pred_label))+geom_point()+theme_bw()+theme(legend.position="bottom")
  # ggplotly(p)
  p
  })




}