options(shiny.launch.browser=F, shiny.minified=F, shiny.port = 9000)

library(shiny)
library(shinythemes)
library(whisker)
library(httr)

rstudio <- read.csv("www/rstudio.csv", stringsAsFactors = FALSE)

ui <- function(request) {
  htmlTemplate("www/views/_landing.html",
    thumbnails = tags$div(id = "thumbnails",
    apply(rstudio, 1, function(row) {
      
      out <- whisker.render(readLines("www/views/_profile.html"), data = row)
      out <- gsub("\n", "", out)
      
      downloadable <- htmlTemplate("www/views/_profile-downloadable.html", profile = HTML(out))
      downloadable <- gsub("<!-- Back.*<!-- Title", "<!-- Title", as.character(downloadable))
      cat(as.character(downloadable), file = paste0("www/views/", row[["Photo"]], ".html"))
      
      tagList(
        tags$div(class = "col-lg-3 col-md-4 col-xs-6 thumbnail",
          onclick = HTML("document.getElementById('thumbnails').style.display = 'none';",
                         "document.getElementById('profile').innerHTML = '", out, "';",
                         "scroll(0,0);"),
            tags$img(class = "img-responsive", 
              src = paste0("photos/", row[["Photo"]], ".jpg"),
              id = row[["Photo"]],
                tags$div(class = "name", 
                  tags$h4(list(row[["FirstName"]], row[["LastName"]]))
                )
            )
        )
      )
    })), app = tags$div(id = "app", style = "display: none;",
                        htmlTemplate("www/views/_app.html"))
  )
}

server <- function(input, output, session) {
  
  selectedData <- reactive({
    iris[, c(input$xcol, input$ycol)]
  })
  
  output$plot1 <- renderPlot({
    #data <- content(GET('https://api.github.com/users/bborgesr'))
    data <- content(GET('https://api.github.com/users/bborgesr/events'))[[1]]
    #print(rstudio$GitHubUsername)
    print(data)
    plot(selectedData())
  }, height = 450, width = 600)
  outputOptions(output, "plot1", suspendWhenHidden = FALSE)
  
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
