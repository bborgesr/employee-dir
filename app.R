options(shiny.launch.browser=F, shiny.minified=F, shiny.port = 9000)

library(shiny)
library(dplyr)
library(shinythemes)
library(ggplot2)
library(leaflet)

source("modules/directory.R")
source("modules/timezone.R")
source("modules/analytics.R")
source("modules/profile.R")

rstudio <- read.csv("www/data/rstudio.csv", stringsAsFactors = FALSE)
github <- read.csv("www/data/github.csv", stringsAsFactors = FALSE)

ui <- function(request) {
  htmlTemplate("www/views/landing.html",
    dir = conditionalPanel(
      condition = "output.view === 'directory'",
      directoryUI("dir", rstudio = rstudio)
    ),
    timezone = conditionalPanel(
      condition = "output.view === 'timezone'",
      timezoneUI("time")
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
    query <- getQueryString()
    removeUI(selector = ".profile")

    if (identical(query, list())) {
      updateQueryString("?page=directory", mode = "push")
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
  callModule(timezone, "time")
  callModule(analytics, "app", github)
  
  observeEvent(input$landing, updateQueryString("?page=directory", mode = "push"))
  observeEvent(input$directory, updateQueryString("?page=directory", mode = "push"))
  observeEvent(input$timezone, updateQueryString("?page=timezone", mode = "push"))
  observeEvent(input$analytics, updateQueryString("?page=analytics", mode = "push"))
}

shinyApp(ui, server)
