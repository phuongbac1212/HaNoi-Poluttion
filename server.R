#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

source("IDW.R")
library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    res = NA
    output$plot <- renderPlot({
        res <<- idw_func(input$timeType, date= input$date, hour=input$hour, polutants = input$polutants)
        res[1]
    }, width = 1000, height = 800, unit = "px")
    
    output$table <- renderTable({
        res[2]
    })

    output$txt <- renderText({
      print(res)
    })
})
