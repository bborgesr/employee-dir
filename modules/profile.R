
profileUI <- function(id) {
  ns <- NS(id)
  uiOutput(ns("profile"))
}

profile <- function(input, output, session, rstudio, employee) {
  
  output$profile <- renderUI({
    args <- as.list(rstudio[which(rstudio$Photo == employee), ])
    args$filename = "www/views/profile.html"
    do.call(htmlTemplate, args)
  })
}