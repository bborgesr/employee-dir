options(shiny.launch.browser=F, shiny.minified=F, shiny.port = 9000)

library(shiny)
library(whisker)

rstudio <- read.csv("www/rstudio.csv", stringsAsFactors = FALSE)

ui <- function(request) {
  htmlTemplate("views/landing.html",
    thumbnails = apply(rstudio, 1, function(row) {
      
      out <- whisker.render(readLines("views/profile.html"), data = list(name = row[["First.Name"]]))
      cat(out, file = paste0("views/", row[["Photo"]], ".html"))
      
      tagList(
        tags$a(href = paste0("views/", row[["Photo"]], ".html")),
        tags$div(class = "col-lg-3 col-md-4 col-xs-6 thumbnail",
          tags$img(class = "img-responsive", 
            id = row[["Photo"]], 
            src = paste0("photos/", row[["Photo"]], ".jpg"),
              tags$div(class = "name", 
                tags$h4(list(row[["First.Name"]], row[["Last.Name"]]))
              )
          )
        )
      )
    })
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
      ),
      fade = FALSE
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
