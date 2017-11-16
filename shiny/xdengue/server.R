#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(naivebayes)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  modelo <- readRDS(file="./models/xdengue.RData")

  #selectedData <- reactive({
  #  dados <- data.frame(VOMITO=as.logical(input$vomito),
  #                      LACO=as.logical(input$laco),
  #                      FEBRE=as.logical(input$febre),
  #                      MIALGIA=as.logical(input$mialgia))
  #  predict(modelo, dados)
  #})

  selectedData <- eventReactive(input$ver, {
    dados <- data.frame(VOMITO=as.logical(input$vomito),
                        LACO=as.logical(input$laco),
                        FEBRE=as.logical(input$febre),
                        MIALGIA=as.logical(input$mialgia),
                        DT_OBITO=as.logical(input$obito))
    predict(modelo, dados)
  }, ignoreNULL = FALSE)

  output$tipo <- renderText({as.character(selectedData())})

})




