library(tfruns)
source("flags.R")
# run various combinations of dropout1 and dropout2
tuning_run("stream_model.R", flags = list(
  dense_units1 = c(29:30),
  dense_units2 = c(17:19)
))

# list runs witin the specified runs_dir
stream_model = ls_runs(order = 'metric_loss')
bla = latest_run()
bla$model
