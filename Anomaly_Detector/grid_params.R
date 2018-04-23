hyper_params <- list(
  hidden=list(c(27,25,27),c(27,23,27),c(27,21,27),c(27,14,27),c(27,13,27),
              c(25,23,25),c(25,21,25),c(25,13,25),c(25,12,25),
              c(23,21,23),c(23,19,23),c(23,12,23),c(23,11,23),
              c(21,19,21),c(21,17,21),c(21,11,21),c(21,10,21),
              c(21),c(23),c(25),c(27),c(22),c(24),c(26),c(28),c(29)
              
             #  ,
             #c(27,25,27),c(23,23,23),c(25,25,25),c(21,21,21), c(31,31,31),c(33,33,33),c(35,35,35), c(33,25,33),c(27,27,27),c(35,33,35),c(33,31,33),c(31,29,31),c(27,19,27),c(25,12,25),c(27,13,27),c(35,17,35),c(34,17,34),c(35,18,35)
  ),
  
   input_dropout_ratio=c(0,0.05)
  # rate=c(0.01,0.02),
  #rate_annealing=c(1e-8,1e-7,1e-6)
)
hyper_params
feature_names = colnames(train_idle)
model_idle_grid <- h2o.grid(x = feature_names,training_frame=train_idle.hex,validation_frame = test_idle.hex, 
                       algorithm="deeplearning",
                       grid_id="dl_grid",         
                         epochs = 200,
                               #hidden = c(27,25,27),
                               adaptive_rate = T,
                               autoencoder = TRUE,
                               reproducible = T,
                               seed = 1234,
                               #rate= 0.001,
                               activation = "Tanh",export_weights_and_biases = T,
                               stopping_metric="MSE",
                               stopping_tolerance = 0.001,
                               variable_importances = T,
                               hyper_params=hyper_params
                       # stopping_metric="logloss",
                       # # stopping_tolerance=1e-2,        ## stop when logloss does not improve by >=1% for 2 scoring events
                       # stopping_rounds=2
                               
)
model_idle_grid


## Sort by logloss
grid_idle <- h2o.getGrid("dl_grid",sort_by="MSE",decreasing=FALSE)

## Find the best model and its full set of parameters
grid_idle@summary_table[1,]
best_idle <- h2o.getModel(grid_idle@model_ids[[1]])
best_idle@model_id
best_idle

print(best_idle@allparameters)
print(h2o.performance(best_idle, valid=T))
print(h2o.rmse(best_idle, valid=T))



feature_names = colnames(train_idle)
model_stream_grid <- h2o.grid(x = feature_names,training_frame=train_stream.hex,validation_frame = test_stream.hex, 
                            algorithm="deeplearning",
                            grid_id="dl_grid_stream",         
                            epochs = 200,
                            #hidden = c(27,25,27),
                            adaptive_rate = T,
                            autoencoder = TRUE,
                            reproducible = T,
                            seed = 1234,
                            #rate= 0.001,
                            activation = "Tanh",export_weights_and_biases = T,
                            stopping_metric="MSE",
                            stopping_tolerance = 0.001,
                            variable_importances = T,
                            hyper_params=hyper_params
                            # stopping_metric="logloss",
                            # # stopping_tolerance=1e-2,        ## stop when logloss does not improve by >=1% for 2 scoring events
                            # stopping_rounds=2
                            
)
model_stream_grid


## Sort by logloss
grid_stream <- h2o.getGrid("dl_grid_stream",sort_by="mse",decreasing=FALSE)

## Find the best model and its full set of parameters
grid_stream@summary_table[1,]
best_stream <- h2o.getModel(grid_stream@model_ids[[1]])
best_stream@model_id
best_stream

print(best_stream@allparameters)
print(h2o.performance(best_stream, valid=T))
print(h2o.rmse(best_stream, valid=T))




