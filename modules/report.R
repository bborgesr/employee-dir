generateReportUI <- function(id) {
  ns <- NS(id)
  textOutput(ns("name"))
}

generateReport <- function(input, output, session, data) {
  print(data)
  output$name <- renderText({ data })
}