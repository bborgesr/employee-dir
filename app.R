options(shiny.launch.browser=F, shiny.minified=F, shiny.port = 9000)

library(shiny)
library(dplyr)
library(shinythemes)
library(ggplot2)

source("modules/directory.R")
source("modules/profile.R")
source("modules/analytics.R")

rstudio <- read.csv("www/data/rstudio.csv", stringsAsFactors = FALSE)
github <- read.csv("www/data/github.csv", stringsAsFactors = FALSE)

ui <- function(request) {
  htmlTemplate("www/views/landing.html",
    dir = conditionalPanel(
     condition = "output.view == 'directory'",
     directoryUI("dir", rstudio = rstudio)
    ), 
    app = conditionalPanel(
     condition = "output.view == 'analytics'",
     analyticsUI("app", github = github)
    ),
    profile = conditionalPanel(
      condition = "output.view == 'profile'",
      profileUI("profile")
    )
  )
}

server <- function(input, output, session) {
  
  output$view <- reactive({
    query <- parseQueryString(session$clientData$url_search)

    if (identical(query, list())) {
      pushState(NULL, NULL, "?page=directory")
      return()
    }
    
    if (query$page %in% rstudio$Photo) {
      callModule(profile, "profile", rstudio = rstudio, employee = rstudio$Photo)
      return("profile")
    }
    
    query$page
  })
  
  outputOptions(output, "view", suspendWhenHidden = FALSE)
  
  callModule(directory, "dir", rstudio = rstudio)
  callModule(analytics, "app", github = github)

  
  
  # output$main <- renderUI({
  # 
  #   query <- parseQueryString(session$clientData$url_search)
  # 
  #   # if (query$page != "analytics") shinyjs::hide("app")
  #   # else shinyjs::show("app")
  # 
  #   if (identical(query, list())) {
  #     pushState(NULL, NULL, "?page=directory")
  #   }
  #   else if (query$page == "directory") {
  #     tags$div(id = "thumbnails",
  #       apply(rstudio, 1, function(row) {
  #         tagList(
  #           tags$div(class = "col-lg-3 col-md-4 col-xs-6 thumbnail",
  #             actionLink(paste0("a-", row[["Photo"]]), {
  #               tags$img(class = "img-responsive",
  #                 src = paste0("photos/", row[["Photo"]], ".jpg"),
  #                 id = row[["Photo"]],
  #                 tags$div(class = "name",
  #                   tags$h4(list(row[["FirstName"]], row[["LastName"]]))
  #                 )
  #               )
  #           })
  #          )
  #         )
  #       })
  #     )
  #   } else if (query$page == "analytics") {
  #     #app
  #     #shinyjs::show("app")
  #     #htmlTemplate("www/views/app.html")
  #     #callModule(analytics, "analytics", github = github)
  #   } else {
  #     #shinyjs::hide(id = "app")
  #     args <- as.list(rstudio[which(rstudio$Photo == query$page), ])
  #     args$filename = "www/views/profile.html"
  #     do.call(htmlTemplate, args)
  #   }
  # })
  
  # observe({
  #   callModule(analytics, "analytics", github = github)
  # })
  # 
  observeEvent(input$landing, {
    pushState(NULL, NULL, "?page=directory")
  })
  
  observeEvent(input$directory, {
    pushState(NULL, NULL, "?page=directory")
  })
  
  observeEvent(input$analytics, {
    pushState(NULL, NULL, "?page=analytics")
  })
  
  # for (i in seq_len(nrow(rstudio))) {
  #   local({
  #     name <- rstudio[i, "Photo"]
  #     element <- paste0("a-", name)
  #     observeEvent(input[[element]], {
  #       pushState(NULL, NULL, paste0("?page=", name))
  #     })
  #   })
  # }
  
  # callModule(analytics, "analytics", github = github)
}

shinyApp(ui, server)
