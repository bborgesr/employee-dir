options(shiny.launch.browser=F, shiny.minified=F, shiny.port = 9000)

library(shiny)
library(whisker)

rstudio <- read.csv("www/rstudio.csv", stringsAsFactors = FALSE)

ui <- function(request) {
  print("one")
  htmlTemplate("www/views/_landing.html",
      thumbnails = apply(rstudio, 1, function(row) {
        
        out <- whisker.render(readLines("www/views/_profile.html"), data = row)
        out <- gsub("\n", "", out)
        
        tags$div(class = "col-lg-3 col-md-4 col-xs-6 thumbnail",
          #onclick = HTML("document.getElementById('main').innerHTML = '", out, "';"),
          #onclick = paste0('location.href = "/views/', row[["Photo"]], '.html";'),
          #onclick = showModal(modalDialog(title = "Important message","This is an important message!")),
          onclick = HTML("document.getElementById('main').style.display = 'none';
                         document.getElementById('profile').innerHTML = '", out, "';
                         location.hash ='", row[["Photo"]], "';"),
            tags$img(class = "img-responsive", 
              src = paste0("photos/", row[["Photo"]], ".jpg"),
                tags$div(class = "name", 
                  tags$h4(list(row[["FirstName"]], row[["LastName"]]))
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
