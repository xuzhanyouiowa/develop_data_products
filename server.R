library(pacman); 
library("caret"); library("shiny"); library("shinydashboard"); library("ggplot2")
library("mlbench"); library("DT"); library("randomForest"); library("dplyr") ; library("e1071")                          


# load dataset
data(PimaIndiansDiabetes)


# load("RegularizedLogisticRegression.rda")    # Load saved model

# source("featureMapping.R")     #  a function for feature engineering. 
                              #  You can include data imputation, data manipulation, data cleaning,
                              #  feature transformation, etc.,  functions


shinyServer(function(input, output) {

   # output$sample_input_data_heading = renderUI({   # show only if data has been uploaded
   #  inFile <- input$file1
   #  
   #  if (is.null(inFile)){
   #    return(NULL)
   #  }else{
   #    tags$h4('Sample data')
   #  }
   # })

  output$sample_input_data = DT::renderDataTable({    # show sample of uploaded data
    inFile <- input$file1
    
    if (is.null(inFile)){
      return(NULL)
    }else{
      input_data =  read.csv(input$file1$datapath, header  = TRUE)
      
      # colnames(input_data) = c("Predictor_1", "Predictor_2", "Label")
      # 
      # input_data$Label = as.factor(input_data$Label )
      # 
      # levels(input_data$Label) <- c("Failed", "Passed")
      head(input_data)
    }
  })
  
  

# predictions<-reactive({
#     
#     inFile <- input$file1
#     
#     if (is.null(inFile)){
#       return(NULL)
#     }else{
#       withProgress(message = 'Predictions in progress. Please wait ...', {
#       input_data =  readr::read_csv(input$file1$datapath, col_names = TRUE)
#       
#       colnames(input_data) = c("test1", "test2", "Label")
#       
#       input_data$Label = as.factor(input_data$Label )
#       
#       levels(input_data$Label) <- c("Failed", "Passed")
#       
#       mapped = feature_mapping(input_data)
#       
#       df_final = cbind(input_data, mapped)
#       prediction = predict(my_model, df_final)
#       
#       input_data_with_prediction = cbind(input_data,prediction )
#       input_data_with_prediction
#       
#       })
#     }
#   })
#   

output$sample_prediction_heading = renderTable({  # show only if data has been uploaded
  inFile <- input$file1

  if (is.null(inFile)){
    return(NULL)
  }else{
    table(predicted_results_for_shared_usews()$pred_new)
  }
})

predicted_results_for_shared_usews = reactive({
  if(is.null(input$file1)){ return()}
  else {
    dataN = read.csv(input$file1$datapath)
    RF_tuned_model = readRDS("finalModel_RF_diabetes.rds")
    
    pred_new = predict(RF_tuned_model, dataN)  
    combined_df = cbind(dataN, pred_new)
  }
})

output$predicted_results_for_newData = renderTable({   # the last 6 rows to show
if(is.null(input$file1)){ return()}
  else {
  head(predicted_results_for_shared_usews())
  }
  

})


# output$plot_predictions = renderPlot({   # the last 6 rows to show
#   if( is.null(predictions()) ) {return()}
#   else{
#   pred = predictions()
#   cols <- c("Failed" = "red","Passed" = "blue")
#  ggplot(pred, aes(x = Test1, y = Test2, color = factor(prediction))) + geom_point(size = 4, shape = 19, alpha = 0.6) +
#     scale_colour_manual(values = cols,labels = c("Failed", "Passed"),name="Test Result")
#   }
# })


# Downloadable csv of predictions ----

output$downloadData <- downloadHandler(
  filename = function() {
    paste("input_data_with_predictions", ".csv", sep = "")
  },
  content = function(file) {
    write.csv(predicted_results_for_shared_usews(), file, row.names = FALSE)
  })

output$CV_10Ffolder_results = renderDataTable({
 # if(is.null(input$ModelSection1)){return()}
  if(is.null(input$CV_folder)) {return()}
  else {
     number_of_folder=as.numeric( input$CV_folder)
     number_of_samples_per_folder = round((nrow(PimaIndiansDiabetes)/number_of_folder), 0)

    # generate an empty data frame which will used for CV results
    folder   = rep("", number_of_folder)
    accuracy = rep(0,  number_of_folder)

    for (i in 1:number_of_folder){
      tt=paste0("folder_", i, sep="")
      folder[i]= tt
      random_df  = PimaIndiansDiabetes[sample(1:nrow(PimaIndiansDiabetes), nrow(PimaIndiansDiabetes)),]
      validation = random_df[((i-1)*number_of_samples_per_folder +1):(i*number_of_samples_per_folder), ]
      training = random_df[-(((i-1)*number_of_samples_per_folder +1):(i*number_of_samples_per_folder)), ]

      set.seed(7)
      RF1_model <- randomForest(diabetes~., training, mtry=2, ntree=500)
      # save the model to disk
      #saveRDS(final_model, "./final_model.rds")

      # later...

      # load the model
      #super_model <- readRDS("./final_model.rds")
      # print(super_model)
      # make a predictions on "new data" using the final model
      final_predictions <- predict(RF1_model, validation[,1:(ncol(validation)-1)])
      confusionM_1 = confusionMatrix(final_predictions, validation$diabetes)
      accuracy[i]=round( confusionM_1[[3]][1], 4)
      
    }

    CV_re= data.frame(folder, accuracy)
    CV_re
    
    # PimaIndiansDiabetes[1:3,]
    
  }
})

output$summary_training = renderUI({
  if(is.null(input$percent_Training)){return()}
  else {
  text111 = paste0("The percent of data you selected is: ", input$percent_Training, "%",". It has ", 
                   round(nrow(PimaIndiansDiabetes)*input$percent_Training/100, 0)," rows and ", ncol(PimaIndiansDiabetes),
                   " columns.", sep="")
  text222 = paste0("The percent of data you selected is: ", 100-input$percent_Training, "%",". It has ", 
                   nrow(PimaIndiansDiabetes)-round(nrow(PimaIndiansDiabetes)*input$percent_Training/100, 0)," rows and ", ncol(PimaIndiansDiabetes),
                   " columns.", sep="")
  tags$h4(text111, br(), text222)
  # br()
  # tags$h3(text222)
  
  }
})

output$top5_training= renderDataTable({
  PimaIndiansDiabetes[1:5,]
})

# output$summary_testing= renderUI({
#   if(is.null(input$percent_Training)){return()}
#   else {
#     text222 = paste0("The percent of data you selected is: ", 100-input$percent_Training, "%",". It has ", 
#                      nrow(PimaIndiansDiabetes)-round(nrow(PimaIndiansDiabetes)*input$percent_Training/100, 0)," rows and ", ncol(PimaIndiansDiabetes),
#                      " columns.", sep="")
#     tags$h4(text222)
#   }
# })

output$prediction_accuracy_001 = renderTable({
  if(is.null(input$percent_Training)){ return()}
  else {
    set.seed(7)
    # create 80%/20% for training and validation datasets
    validation_index <- createDataPartition(PimaIndiansDiabetes$diabetes, p=input$percent_Training/100, list=FALSE)
    validation <- PimaIndiansDiabetes[-validation_index,]
    training <- PimaIndiansDiabetes[validation_index,]
    # train a model and summarize model
    set.seed(7)
    control <- trainControl(method="repeatedcv", number=3, repeats=1)
    fit.rf <- train(diabetes~., data=training, method="rf", metric="Accuracy", trControl=control, ntree=500)
    #print(fit.rf)
    #print(fit.rf$finalModel)
    # create standalone model using all training data
    set.seed(7)
    finalModel <- randomForest(diabetes~., training, mtry=2, ntree=500)
    # make a predictions on "new data" using the final model
    final_predictions <- predict(finalModel, validation[,1:(ncol(validation)-1)])
    results123=confusionMatrix(final_predictions, validation$diabetes)
    ma= as.matrix(results123[[4]]) 
    ma_df=as.data.frame(ma); ma_df$V1 = apply(ma_df, 1, function(x) round(x, 4))
    ma_df_pa = data.frame(cbind(rownames(ma_df), ma_df))
    rows123= c("Sensitivity","Specificity", "Precision","Recall","Balanced Accuracy")
 names(ma_df_pa) = c("Parameters", "Accuracy")
    ma_df_pa[rownames(ma_df_pa)%in%rows123, ]
  }
})


})

