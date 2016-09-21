varImpContinuousPlot <- function(variable_name, response, dataset, gbm, iteration_num,upper_outlier=NA,lower_outlier=NA,binomial_flag=FALSE) {
  # Prepares a plot visualizing the average prediction across a continuous predictor variable
  # Includes information about the distribution of the predictor variable
  #
  # Args:
  #  variable_name: A string with the name of the predictor variable featured in the plot
  #  response: A string with the name of the response variable
  #  dataset: The data set from which the boosted tree was developed
  #  gbm: The gbm object for the fitted boosted tree
  #  iternation_num: The number of iterations for the fitted boosted tree
  #  lower_outlier: Optional. A number specifying the lower bound on the predictor variable. Useful  #   if the predictor variable has small outliers that obscure the plot.
  #  upper_outlier: Optional. A number specifying the upper bound on the predictor variable. Useful  #   if the predictor variable has large outliers that obscure the plot.
  #  binomial_flag: True if the response variable is a binary variable.
  #
  # Returns:
  #   A ggplot2 object 
  
  require(ggplot2)
  require(dplyr)

  ##obtain important indices
  variable_index_marginal <- which(names(dataset)[names(dataset)!=response]==variable_name)
  variable_index_full <- which(names(dataset)==variable_name)
  response_index <- which(names(dataset)==response)
  
  ##generate a table with the average prediction for the specified variable
  if (binomial_flag == FALSE) {
    variable_imp_data <- plot(gbm, i.var =variable_index_marginal, n.trees = iteration_num,return.grid=TRUE)
  }
  else {
    variable_imp_data <- plot(gbm, i.var =variable_index_marginal, n.trees = iteration_num,return.grid=TRUE,type="response")
  }
  
  #generate a data frame with the predicted values and the actual values of the specified variable
  if (binomial_flag == FALSE) {
    yhat <- predict(gbm)
  }
  else {
    yhat <- predict(gbm,type="response")
  }
  obs_data <- data.frame(yhat,dataset[,variable_index_full])
  names(obs_data) <- c("yhat","obs_var")
  
  #generate plot
  if (is.na(upper_outlier)==TRUE) { 
    if (is.na(lower_outlier)==TRUE) { ##no upper and no lower outlier
      s <- ggplot(data=NULL) + geom_point(data=obs_data[is.na(obs_data$obs_var)==FALSE,],aes(x=obs_var,y=yhat),colour="gray",alpha=0.5)
      s <- s+ geom_line(data=variable_imp_data,aes_string(x=variable_name,y="y"),colour ="steelblue", size=1, linetype=1)
    }
    else { ##no upper outlier but has lower outlier
      s <- ggplot(data=NULL) + geom_point(data=obs_data[is.na(obs_data$obs_var)==FALSE & obs_data$obs_var > lower_outlier,],aes(x=obs_var,y=yhat),colour="gray",alpha=0.5)
      s <- s+ geom_line(data=variable_imp_data[variable_imp_data[,1] > lower_outlier,],aes_string(x=variable_name,y="y"),colour ="steelblue", size=1, linetype=1)
    }
  }
  else { ##has upper outlier
    if (is.na(lower_outlier)==TRUE) { ##upper outlier with no lower outlier
      s <- ggplot(data=NULL) + geom_point(data=obs_data[is.na(obs_data$obs_var)==FALSE & obs_data$obs_var < upper_outlier,],aes(x=obs_var,y=yhat),colour="gray",alpha=0.5)
      s <- s+ geom_line(data=variable_imp_data[variable_imp_data[,1] < upper_outlier,],aes_string(x=variable_name,y="y"),colour ="steelblue", size=1, linetype=1)
    }
    else { ##has lower and upper outliers
      s<- ggplot(data=NULL) + geom_point(data=obs_data[is.na(obs_data$obs_var)==FALSE & obs_data$obs_var < upper_outlier & obs_data$obs_var > lower_outlier,],aes(x=obs_var,y=yhat),colour="gray",alpha=0.5)
      s <- s+ geom_line(data=variable_imp_data[variable_imp_data[,1] > lower_outlier & variable_imp_data[,1] < upper_outlier,],aes_string(x=variable_name,y="y"),colour ="steelblue", size=1, linetype=1)
    }
  }
  s <- s +theme(text = element_text(size=20))
  s <- s + labs(y = "Expected Value",title="Marginal Plot",x=variable_name)
   
  return(s)
  
}