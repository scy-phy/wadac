require(ROCR)

line_integral <- function(x, y) {
  dx <- diff(x)
  end <- length(y)
  my <- (y[1:(end - 1)] + y[2:end]) / 2
  sum(dx * my)
}




plot_precall <- function(prediction_obj,plot_name){
# precision-recall curve
# perf1 <- performance(prediction_obj, measure = "prec", x.measure = "rec") 
# 
# x1 <- perf1@x.values[[1]]
# y1 <- perf1@y.values[[1]]
# y1[1] <- 0

# sensitivity-specificity curve
perf2 <- performance(prediction_obj, measure = "sens", x.measure = "spec") 
x2 <- perf2@x.values[[1]]
y2 <- perf2@y.values[[1]]
y2[1] <- 0



pdf(paste0("Results/ROC_plots/",plot_name,".pdf"))
# par(mfrow = c(1, 2))
# par(mar = c(5.1,4.1,4.1,2.1))
# par(xaxp=c(0,1,0.1))
# plot(perf1, main = paste("Area Under the\nPrecision-Recall Curve:\n", round(abs(line_integral(x1,y1)), digits = 3)))
# par(mar = c(5.1,4.1,4.1,2.1))
plot(perf2, main = paste("Area Under the\nSensitivity-Specificity Curve:\n", round(abs(line_integral(x2,y2)), digits = 3)))
dev.off()
}

# 
# plot_sensitivity <- function(prediction_obj){
# par(mfrow = c(1, 2))
# par(mar = c(5.1,4.1,4.1,2.1))
# 
# return(p_sense)
# }