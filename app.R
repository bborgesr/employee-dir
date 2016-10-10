library(shiny)
rstudio <- read.csv("www/rstudio.csv", stringsAsFactors = FALSE)

ui <- function(request) {
  tagList(
    HTML("<h1>Test</h1>"),
    htmlTemplate("views/landing.html")
  )
}

server <- function(input, output, session) {

  observeEvent(input$add, {
    showModal(modalDialog(
      title = "Add an employee",
      textInput("first", "First name:"),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("ok", "OK")
      )
    ))
  })

  
  observeEvent(input$ok, {
    if (isTruthy(input$first)) removeModal()
  })

  rstudioCurrent <- reactive({
    if (isTruthy(input$first)) {
      new <- input$first
      row <- df <- data.frame(First.Name = new,
                              Last.Name = NA,
                              Title = NA,
                              Location = NA,
                              GitHub.Username = NA,
                              Photo = NA,
                              Description = NA,
                              stringsAsFactors = FALSE)
      rbind(rstudio, row)
    }
    else rstudio
  })
  
  # observeEvent(input$add, {
  #   btn <- input$insertBtn
  #   id <- paste0('txt', btn)
  #   insertUI(
  #     selector = '#placeholder',
  #     ## wrap element in a div with id for ease of removal
  #     ui = tags$div(
  #       tags$p(paste('Element number', btn)), 
  #       id = id
  #     )
  #   )
  # })
}

shinyApp(ui, server)
