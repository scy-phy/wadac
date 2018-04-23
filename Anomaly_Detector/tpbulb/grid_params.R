hyper_params <- list(
hidden=list(  
              c(17,15,17),c(15,13,15),c(15,12,15),c(15,11,15),c(15,10,15),c(15,9,15),c(15,7,15),c(15,5,15),c(15,3,15),c(15,2,15),
              c(15,13,15),c(15,12,15),c(15,11,15),c(15,10,15),c(15,9,15),c(15,7,15),c(15,5,15),c(15,3,15),c(15,2,15),
              c(13,12,13),c(13,11,13),c(13,10,13),c(13,9,13),c(13,7,13),c(13,5,13),c(13,3,13),c(13,2,13),
              c(12,11,12),c(12,10,12),c(12,9,12),c(12,7,12),c(12,5,12),c(12,3,12),c(12,2,12),
              c(11,10,11),c(11,9,11),c(11,7,11),c(11,5,11),c(11,3,11),c(11,2,11),
              c(10,9,10),c(10,7,10),c(10,5,10),c(10,3,10),c(10,2,10),
              c(9,7,9),c(9,5,9),c(9,3,9),c(9,2,9),
              c(7,5,7),c(7,3,7),c(7,2,7),
              c(5,3,5),c(5,2,5),
              c(3,2,3),
              c(17,17,17),c(15,15,15),c(13,13,13),
              c(12,12,12),c(11,11,11),c(10,10,10),
              c(9,9,9),c(7,7,7),c(5,5,5),c(3,3,3),c(2,2,2),
              c(17),c(15),c(13),c(12),c(11),c(10),c(9),c(7),c(5),c(3),c(2)
             #  ,
             #c(27,25,27),c(23,23,23),c(25,25,25),c(21,21,21), c(31,31,31),c(33,33,33),c(35,35,35), c(33,25,33),c(27,27,27),c(35,33,35),c(33,31,33),c(31,29,31),c(27,19,27),c(25,12,25),c(27,13,27),c(35,17,35),c(34,17,34),c(35,18,35)
  ),
  
   input_dropout_ratio=c(0,0.05)
  # rate=c(0.01,0.02),
  #rate_annealing=c(1e-8,1e-7,1e-6)
)
hyper_params
feature_names = colnames(train_normal.hex)
tpbulb_grid <- h2o.grid(x = feature_names,training_frame=train_normal.hex,validation_frame = test_normal.hex, 
                       algorithm="deeplearning",
                       grid_id="tp_bulb_grid",         
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
tpbulb_grid


## Sort by logloss
grid_tp <- h2o.getGrid("tp_bulb_grid",sort_by="MSE",decreasing=FALSE)

## Find the best model and its full set of parameters
grid_tp@summary_table[1,]
best_tp <- h2o.getModel(grid_tp@model_ids[[1]])
best_tp@model_id
best_tp

print(best_tp@allparameters)
print(h2o.performance(best_tp, valid=T))
print(h2o.rmse(best_tp, valid=T))

