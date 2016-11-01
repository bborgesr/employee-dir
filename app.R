options(shiny.launch.browser=F, shiny.minified=F, shiny.port = 9000)

library(shiny)
library(shinythemes)
library(whisker)
library(ggplot2)

rstudio <- read.csv("www/rstudio.csv", stringsAsFactors = FALSE)

ui <- function(request) {
  htmlTemplate("www/views/_landing.html")
}

server <- function(input, output, session) {
  
  output$main <- renderUI({
    query <- parseQueryString(session$clientData$url_search)
    
    if (identical(query, list())) {
      pushState(NULL, NULL, "?page=directory")
    }
    else if (query$page == "directory") {
      tags$div(id = "thumbnails",
        apply(rstudio, 1, function(row) {
          tagList(
            tags$div(class = "col-lg-3 col-md-4 col-xs-6 thumbnail",
              actionLink(paste0("a-", row[["Photo"]]), {
                tags$img(class = "img-responsive",
                  src = paste0("photos/", row[["Photo"]], ".jpg"),
                  id = row[["Photo"]],
                  tags$div(class = "name",
                    tags$h4(list(row[["FirstName"]], row[["LastName"]]))
                  )
                )
            })
           )
          )
        })
      )
    } else if (query$page == "analytics") {
      htmlTemplate("www/views/_app.html")
    } else {
      row <- rstudio[which(rstudio$Photo == query$page), ]
      htmlTemplate("www/views/_profile.html",
        Photo = row[["Photo"]],
        FirstName = row[["FirstName"]],
        LastName = row[["LastName"]],
        Title = row[["Title"]]
      )
    }
  })
  
  observeEvent(input$landing, {
    pushState(NULL, NULL, "?page=directory")
  })
  
  observeEvent(input$directory, {
    pushState(NULL, NULL, "?page=directory")
  })
  
  observeEvent(input$analytics, {
    pushState(NULL, NULL, "?page=analytics")
  })
  
  for (i in seq_len(nrow(rstudio))) {
    local({
      name <- rstudio[i, "Photo"]
      element <- paste0("a-", name)
      observeEvent(input[[element]], {
        pushState(NULL, NULL, paste0("?page=", name))
      })
    })
  }
}

shinyApp(ui, server)
