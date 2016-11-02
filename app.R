options(shiny.launch.browser=F, shiny.minified=F, shiny.port = 9000)

library(shiny)
library(dplyr)
library(shinythemes)
library(ggplot2)

source("modules/analytics.R")

rstudio <- read.csv("www/data/rstudio.csv", stringsAsFactors = FALSE)
github <- read.csv("www/data/github.csv", stringsAsFactors = FALSE)
app <- analyticsUI("analytics", github = github)

ui <- function(request) {
  htmlTemplate("www/views/landing.html"
               #, 
               #app = analyticsUI("analytics", github = github)
               )
}

server <- function(input, output, session) {
  
  output$main <- renderUI({
    
    query <- parseQueryString(session$clientData$url_search)
    
    # if (query$page != "analytics") shinyjs::hide("app")
    # else shinyjs::show("app")
    
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
      app
      #shinyjs::show("app")
      #htmlTemplate("www/views/app.html")
      # callModule(analytics, "analytics")
    } else {
      #shinyjs::hide(id = "app")
      args <- as.list(rstudio[which(rstudio$Photo == query$page), ])
      args$filename = "www/views/profile.html"
      do.call(htmlTemplate, args)
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
  
  callModule(analytics, "analytics", github = github)
}

shinyApp(ui, server)
