
# MAchine learning with different models
library(pacman); 
library("caret"); library("shiny"); library("shinydashboard"); library("ggplot2")
library("mlbench"); library("DT"); library("randomForest"); library("dplyr") ; library("e1071")                          


# library("shiny"); library("shinydashboard"); library("caret"); library(); library(); library(); library(); library(); library(); library(); 
# library(); library(); library(); library(); library(); library(); library(); library(); library(); library(); 
ui= dashboardPage(skin="green",
              dashboardHeader(title = "Apply Machine Learning to Predict Diabetes",
                              tags$li(a(href = 'http://www.rstudio.com',
                                        icon("star"),
                                        title = "rstudio Homepage"),
                                      class = "dropdown"),
                              tags$li(a(href = 'http://www.rstudio.com',
                                        img(src = 'RStudio-Logo-Blue-Gradient.png',
                                            title = "rstudio", height = "50px"),
                                        style = "padding-top:10px; padding-bottom:10px;"),
                                      class = "dropdown"), titleWidth = 400),
              
              dashboardSidebar(width = 250,
                               sidebarMenu(
                                 br(),
                                 menuItem(tags$em("Upload your Data",style="font-size:120%"),
                                          icon=icon("upload"),tabName="data"),
                                 menuItem(tags$em("Model Selection", style="font-size:120%"),
                                          icon = icon("american-sign-language-interpreting"),
                                          tabName = "ModelSelection_Box"),
                                 menuItem(tags$em("Tune the model", style="font-size:120%"),
                                          icon = icon("cog"),sliderInput(inputId ="percent_Training", label = "Tarining pool (%)", 
                                                      min = 50, max = 90, value = 75),
                                          selectInput(inputId ="CV_folder", label = "Select CV fold", 
                                                      choices = c(3,5,10, 15, 20), selected = 5)),
                                 menuItem(tags$em("Download Predictions",style="font-size:120%"),
                                          icon=icon("download"),tabName="download")
                                 
                                 
                                 )
                                 ),
              
              dashboardBody(
                tabItems(
                  tabItem(tabName="data", labeel =" Updated Date",
                           
                          br(),
                          tags$h4("Using machine learning to predict with different models.", style="font-size:150%"),
                        
                        
                      br(),

                      tags$h4("Instructions:\n To predict using this model, upload test data in csv 
                              format by using the button below.", style="font-size:150%"),
                      
                      tags$h4("Step 1: \n Upload the file\n; the testing file named 'test_file.csv' is uploaded in Github"),
                      tags$h4(" The link to the github is: "),
                      tags$h4("Step 2: Selection prediction model;"),
                      tags$h4("Step 3: download the results;"),
                      tags$span("section in the sidebar to  download the predictions.", style="font-size:150%"),
                      
                      br(),
                      column(width = 4,
                             fileInput('file1', em('Upload test data in csv format ',
                                                   style="text-align:center;color:blue;font-size:150%"),
                                       multiple = FALSE,
                                       accept=c('.csv')),
                             
                            # uiOutput("sample_input_data_heading"),
                             dataTableOutput("sample_input_data"),
                          
                          
                          br(),
                           br(),
                           br(),
                          br()
                          ),
                          br()
                          
                        ),
                
                    # 2nd fluidRow zhanyou add here
                      tabItem(tabName="ModelSelection_Box", labeel =" Model comparison",
                              fluidRow(
                                box(title = "Create training and testing data sets",
                                    solidHeader = T, status = "info",
                                    collapsible = T, collapsed = F,
                                    width = 12,
                                    radioButtons("to_seleect_model_1", "Select ML Model", choices = c("Logistic Regression (LR)", "Random Forest (RF)", "Support Vector Machine (SVM)"), 
                                                 selected = "Random Forest (RF)", inline = T),
                                    
                                    # add a row by zhanyou
                                    # upload the 3 .pcr files at once
                                    
                                    fluidRow(
                                      box(title = "Training and testing data set Selected",
                                          width = 6, solidHeader = T, status = "info",
                                          h3("how many samples in the training data set?"),
                                           uiOutput("summary_training")
                                         # helpText("Show the top 5 of the data")
                                         # dataTableOutput("top5_training")
                                      ),
                                      box(title = "Prediction Accuracy based on the training/testing set",
                                          width = 6,solidHeader = T, status = "info",
                                          # helpText("how many samples in the testing data set?"),
                                          tableOutput("prediction_accuracy_001")
                                          
                                      ))
                                    # add another row to display the three heat maps: ROX, FAM, and VIC
                                    # add radio buton for heatmap or surface map
                                    # add slider bar for threshold for ROX, FAM, and VIC
                                    # this row has three boxes: box one has ROX, box2 has FAM, and box3 has VIC
                                   )),
                          column(width = 4,
                                 h3("to estomate the reliable of the model by n-fold cros-vlidation, default 5-fold"),
                                   dataTableOutput("CV_10Ffolder_results")

                            )),
                    
                  # add the 3rd row
                  tabItem(tabName="download",
                          fluidRow(
                            box(title = "Prediction results for the new data you have uploaded",
                                tags$h4("After you upload a test dataset, you can download the predictions in csv format by
                                    clicking the button below.", 
                                        style="font-size:200%"),
                                width = 12, solidHeader = T, status = "primary")),
                                # helpText("how many samples in the testing data set?"),
                                # tableOutput("predicted_results_for_newData"))),
                            br(),
                          fluidRow(
                            
                            box(title = "doanload the predicted data",  width = 6,solidHeader = T,
                                status = "warning", 
                            tableOutput("predicted_results_for_newData"),
                            downloadButton("downloadData", em('Download Predictions',
                                        style="text-align:center;color:blue;font-size:150%"))
                            ),
                            box(title = "Summary of the predictionS!",  width = 6, solidHeader = T,
                                status = "warning",
                            tableOutput("sample_prediction_heading")

                            )
                              
                            ))
                          )))