varImpCategoricalPlot <- function(variable_name, response, dataset, gbm, iteration_num,cutoff=0) {
  # Prepares a plot visualizing the average prediction for each level of a specified variable.
  # Colors bars so that levels that appear more frequently have a darker luminance
  #
  # Args:
  #  variable_name: A string with the name of the predictor variable featured in the plot
  #  response: A string with the name of the response variable
  #  dataset: The data set from which the boosted tree was developed
  #  gbm: The gbm object for the fitted boosted tree
  #  iternation_num: The number of iterations for the fitted boosted tree
  #  cutoff: A value x between 0-100. If a level appears in less than x% of the data,
  #          the level will be excluded from the plot.
  #  
  #
  # Returns:
  #   A ggplot2 object 
  
  require(ggplot2)
  
  ##obtain important indices
  variable_index_marginal <- which(names(dataset)[names(dataset)!=response]==variable_name)
  variable_index_full <- which(names(dataset)==variable_name)
  response_index <- which(names(dataset)==response)
  
  ##generate a table with the average prediction for each level, sorted by prediction (largest to smallest)
  variable_imp_data <- plot(gbm, i.var =variable_index_marginal, n.trees = iteration_num,return.grid=TRUE)
  variable_imp_data <- variable_imp_data[order(variable_imp_data$y,decreasing=TRUE),]
  
  ##calculate the percent frequency of each level of the variable in the original data set
  level_frequency <- as.data.frame(prop.table(table(dataset[,variable_index_full])))
  level_frequency$Freq <- level_frequency$Freq*100
  level_frequency <- level_frequency[order(level_frequency$Freq,decreasing=TRUE),]
  
  ##merge information about level frequencies onto the average prediction table
  variable_imp_data <- merge(variable_imp_data,level_frequency,by.x=variable_name,by.y="Var1",all.x=TRUE)
  variable_index_imp <- which(names(variable_imp_data)==variable_name) 
  variable_imp_data[,variable_index_imp] <- factor(variable_imp_data[,variable_index_imp],levels=level_frequency$Var1)
  
  ##generate the marginal plot
  pass_x <- paste("reorder(",variable_name,",y)",sep="")
  s <- ggplot(data=variable_imp_data[is.na(variable_imp_data$Freq)==FALSE & variable_imp_data$Freq > cutoff,],aes_string(x=pass_x,y="y",fill="Freq")) + geom_bar( width=.5,stat="identity")     
  s <- s + labs(title="Marginal Plot",x=variable_name,y="Average Prediction")  + coord_flip() +theme(text = element_text(size=20))
  s <- s + scale_fill_gradient(low = "#deebf7", high = "#3182bd",name="Frequency")
return(s)
}