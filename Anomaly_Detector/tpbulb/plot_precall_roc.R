require(ROCR)

line_integral <- function(x, y) {
  dx <- diff(x)
  end <- length(y)
  my <- (y[1:(end - 1)] + y[2:end]) / 2
  sum(dx * my)
}


plot_precall <- function(prediction_obj,plot_name){

# sensitivity-specificity curve
perf2 <- performance(prediction_obj, measure = "sens", x.measure = "spec") 
x2 <- perf2@x.values[[1]]
y2 <- perf2@y.values[[1]]
y2[1] <- 0

pdf(paste0("Results/ROC_plots/",plot_name,".pdf"))
plot(perf2, main = paste("Area Under the\nSensitivity-Specificity Curve:\n", round(abs(line_integral(x2,y2)), digits = 3)))
dev.off()

}

