options(shiny.launch.browser=F, shiny.minified=F, shiny.port = 9000)

library(shiny)
library(dplyr)
library(shinythemes)
library(ggplot2)
library(leaflet)

source("modules/directory.R")
source("modules/profile.R")
source("modules/analytics.R")

rstudio <- read.csv("www/data/rstudio.csv", stringsAsFactors = FALSE)
github <- read.csv("www/data/github.csv", stringsAsFactors = FALSE)

ui <- function(request) {
  htmlTemplate("www/views/landing.html",
    dir = conditionalPanel(
     condition = "output.view === 'directory'",
     directoryUI("dir", rstudio = rstudio)
    ), 
    app = conditionalPanel(
     condition = "output.view === 'analytics'",
     analyticsUI("app", github = github)
    ),
    profile = conditionalPanel(
      condition = "output.view === 'profile'",
      tags$div(id = "profilePlaceholder")
    )
  )
}

server <- function(input, output, session) {
  
  output$view <- reactive({
    query <- parseQueryString(session$clientData$url_search)
    removeUI(selector = ".profile")

    if (identical(query, list())) {
      pushState(NULL, NULL, "?page=directory")
      return()
    }
    
    if (query$page %in% rstudio$Photo) {
      
      insertUI(
        selector = "#profilePlaceholder",
        where = "afterEnd",
        ui = profileUI(query$page)
      )
      
      callModule(profile, query$page, rstudio, query$page)
      
      return("profile")
    }
    
    query$page
  })
  
  outputOptions(output, "view", suspendWhenHidden = FALSE)
  
  callModule(directory, "dir", rstudio)
  callModule(analytics, "app", github)
  
  observeEvent(input$landing, pushState(NULL, NULL, "?page=directory"))
  observeEvent(input$directory, pushState(NULL, NULL, "?page=directory"))
  observeEvent(input$analytics, pushState(NULL, NULL, "?page=analytics"))
}

shinyApp(ui, server)
