#install.packages('devtools')
#devtools::install_github('rstudio/keras')
#install.packages('reticulate')
#reticulate::use_python('/opt/conda/bin/python')

#require(tensorflow)
#require(reticulate)
#require(keras)

#is_keras_available()
#system('which python')
#Sys.setenv(TENSORFLOW_PYTHON='/opt/conda/bin/python')
#use_python('/opt/conda/bin/python')

#py_discover_config('tensorflow')
#py_discover_config('keras')
#is_keras_available()

packages = c("keras",
	     "reticulate",
	     "ggplot2",
             "dplyr",
             "RSQLite",
             "magrittr",
             "zeallot",
             "tfruns",
             "randomForest",
             "lubridate",
             "future",
             "purrr",
             "shiny",
             "shinythemes",
             "rsconnect",
             "caret"
             )

for (package in packages) {
    install.packages(package)
}

library(reticulate)
library(keras)
reticulate::use_python('/opt/conda/bin/python')

system('which python')
Sys.setenv(TENSORFLOW_PYTHON='/opt/conda/bin/python')
use_python('/opt/conda/bin/python')

py_discover_config('tensorflow')
py_discover_config('keras')
is_keras_available()


library(RSQLite)
library(dplyr)
library(randomForest)
library(lubridate)
library(future)
plan(multiprocess)
library(ggplot2)
library(purrr)
