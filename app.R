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
      profileUI("profile")
    )
  )
}

server <- function(input, output, session) {
  
  rv <- reactiveValues(currentEmployee = "")
  
  output$view <- reactive({
    query <- parseQueryString(session$clientData$url_search)

    if (identical(query, list())) {
      pushState(NULL, NULL, "?page=directory")
      return()
    }
    
    if (query$page %in% rstudio$Photo) {
      rv$currentEmployee = query$page
      return("profile")
    }
    
    query$page
  })
  
  outputOptions(output, "view", suspendWhenHidden = FALSE)
  
  callModule(directory, "dir", rstudio = rstudio)
  callModule(analytics, "app", github = github)
  callModule(profile, "profile", rstudio = rstudio, 
             employee = reactive(rv$currentEmployee))
  
  observeEvent(input$landing, pushState(NULL, NULL, "?page=directory"))
  observeEvent(input$directory, pushState(NULL, NULL, "?page=directory"))
  observeEvent(input$analytics, pushState(NULL, NULL, "?page=analytics"))
}

shinyApp(ui, server)
