FLAGS <- flags(
  flag_integer("dense_units1",11),
# #  flag_numeric("dropout1", 0.2),
  flag_integer("dense_units2",5),
  flag_integer("epochs", 30),
  flag_integer("batch_size", 100),
  flag_numeric("learning_rate", 0.001)
)


FLAGS_idle <- flags(
  flag_integer("dense_units1",24),
  # #  flag_numeric("dropout1", 0.2),
  flag_integer("dense_units2",12),
  flag_integer("epochs", 30),
  flag_integer("batch_size", 100),
  flag_numeric("learning_rate", 0.001)
)
