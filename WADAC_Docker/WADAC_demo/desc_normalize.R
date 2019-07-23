library(purrr)

#' Gets descriptive statistics for every variable in the dataset.
get_desc <- function(x) {
  map(x, ~list(
    min = min(.x),
    max = max(.x),
    mean = mean(.x),
    sd = sd(.x)
  ))
} 

#' Given a dataset and normalization constants it will create a min-max normalized
#' version of the dataset.
normalization_minmax <- function(x, desc) {
  map2_dfc(x, desc, ~(.x - .y$min)/(.y$max - .y$min))
}
