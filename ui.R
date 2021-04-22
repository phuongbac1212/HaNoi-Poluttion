#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    h1("Bản đồ nội suy ô nhiễm không khí tại Hà Nội"),
    sidebarLayout(
        sidebarPanel(
            selectInput(inputId = "timeType",
                        label = "Kiểu thời gian: ",
                        list("Giờ", "Ngày")),
            checkboxInput(inputId = "flexibleTime",
                          label = "Thời gian linh động? (chọn phạm vi hay cố định)"),
            dateInput(
                "date",
                "Date range:",
                min    = "2019-1-1",
                max    = "2021-1-1",
                format = "dd/mm/yyyy",
            ),
            selectInput(
                inputId = "hour",
                label = "Chọn giờ: ",
                list(
                    "0",
                    "1",
                    "2",
                    "3",
                    "4",
                    "5",
                    "6",
                    "7",
                    "8",
                    "9",
                    "10",
                    "11",
                    "12",
                    "13",
                    "14",
                    "15",
                    "16",
                    "17",
                    "18",
                    "19",
                    "20",
                    "21",
                    "22",
                    "23",
                    "24"
                )
            ),
            selectInput(
                inputId = "polutants",
                label = "Loại khí ô nhiễm: ",
                list("PM2.5", "PM10", "CO")
            ),
            submitButton("Update View", icon("refresh")),
        ),
        mainPanel (tabsetPanel(
            type = "tab",
            tabPanel("Plot", plotOutput("plot")),
            tabPanel("Dataframe", tableOutput("table")),
            tabPanel("text", textOutput("txt"))
        ))
    )
))