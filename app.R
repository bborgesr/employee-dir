options(shiny.launch.browser=F, shiny.minified=F, shiny.port = 9000)

library(shiny)
library(dplyr)
library(shinythemes)
library(ggplot2)

source("modules/analytics.R")

rstudio <- read.csv("www/data/rstudio.csv", stringsAsFactors = FALSE)
github <- read.csv("www/data/github.csv", stringsAsFactors = FALSE)

ui <- function(request) {
  htmlTemplate("www/views/landing.html", 
               app = analyticsUI("analytics", github = github))
}

server <- function(input, output, session) {
  
  output$main <- renderUI({
    query <- parseQueryString(session$clientData$url_search)
    
    if (identical(query, list())) {
      pushState(NULL, NULL, "?page=directory")
    }
    else if (query$page == "directory") {
      shinyjs::hide("app")
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
      shinyjs::show("app")
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
  
  selectedData <- reactive({
    iris[, c(input$xcol, input$ycol)]
  })

  output$plot1 <- renderPlot({
    plot(cars)
  }, height = 450, width = 600)
  
  outputOptions(output, "plot1", suspendWhenHidden = FALSE)
  
  callModule(analytics, "analytics", github = github)
}

shinyApp(ui, server)
