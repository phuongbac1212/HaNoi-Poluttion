library(shiny)

port <- Sys.getenv('PORT')

shiny::runapp (
  appDir = getwd(),
  host = '0.0.0.0',
  port = as(numberic(port))
)