
analyticsUI <- function(id, github) {
  ns <- NS(id)
  
  fluidPage(
    theme = shinytheme("cosmo"),
    
    tags$p("This is a snapshot of our profiles and activity on Github as of",
      "October 2016.", strong("Hover over each bar"), "to see that",
      "person's info!"),
    tags$br(),
    
    fluidRow(
      
      column(width = 4,
        tags$div(id = "inputCol",
          selectInput(ns("flt"), "Filter by title:", 
            choices = unique(github$Title), 
            selected = c("Software Engineer", "Founder", "CTO", 
                         "Master Instructor", "Chief Scientist"),
            multiple = TRUE),
          radioButtons(ns("yaxis"), "Select the y-axis", 
            choices = c("Repos", "Stars", "Followers", 
                        "Following", "Contributions"),
            selected = "Contributions"),
          actionButton(ns("sort"), "Sort"),
          actionButton(ns("unslct"), "Unselect person", 
            class = "btn btn-primary")
        )
      ),
      
      column(width = 8, 
        plotOutput(ns("plt"), 
          hover = hoverOpts(id = ns("plt_hover"), delay = 20)
        )
      )
    ),
    
    fluidRow(
      column(width = 4, uiOutput(ns("info"))),
      column(width = 8, leafletOutput(ns("map")))
    )
  )
}

analytics <- function(input, output, session, github) {
  oldSort <- new.env()
  oldSort$n <- 0
  
  rv <- reactiveValues(
    github = github,
    selected = NULL
  )
  
  observeEvent(input$flt, {
    rv$github <- rv$github %>% filter(Title %in% input$flt)
    rv$selected <- 22   # hadley
  })
  
  observe({
    rv$github$GitHubUsername <- factor(rv$github$GitHubUsername, 
                                       levels = rv$github$GitHubUsername)
    rv$github$yaxis <- switch(input$yaxis,
                              Repos = rv$github$Repos,
                              Stars = rv$github$Stars,
                              Followers = rv$github$Followers,
                              Following = rv$github$Following,
                              Contributions = rv$github$Contributions)
    if (input$sort != oldSort$n) {
      username <- rv$github$GitHubUsername[rv$selected]
      rv$github <- rv$github %>% arrange(yaxis)
      rv$selected <- which(rv$github$GitHubUsername == username)
      rv$github$GitHubUsername <- factor(rv$github$GitHubUsername, 
                                         levels = rv$github$GitHubUsername)
      oldSort$n <- input$sort
    }
    if (!is.null(input$plt_hover$x)) {
      rv$selected <- round(input$plt_hover$x)
    }
  })
  
  observeEvent(input$unslct, {
    rv$selected <- NULL
  })
  
  output$plt <- renderPlot({
    github <- rv$github
    github[rv$selected, "Color"] <- "#ddd"
    ggplot(github, aes(x = GitHubUsername, y = yaxis, fill = Color)) + 
      geom_bar(stat="identity") + 
      scale_fill_manual(values=c("#1967be", "#000000")) +
      labs(x = "GitHub Username", y = input$yaxis) +
      guides(fill = FALSE)
  })
  
  output$info <- renderUI({
    req(rv$selected)
    row <- rv$github[rv$selected, ]
    
    tags$div(
      tags$h3(class = "analyticsName", 
              row[["FirstName"]], " ", row[["LastName"]]),
      tags$h4(row[["Title"]]),
      tags$div(class = "row",
        tags$div(class = "col-xs-6",
          tags$img(class = "img-responsive",
                   src = paste0("photos/", row[["Photo"]], ".jpg"),
                   height = "200", width = "200", style = "inline")
        ),
        tags$div(class = "col-xs-6",
          tags$div(tags$strong("Github Info:")),
          tags$div(paste("Repos: ", row[["Repos"]])),
          tags$div(paste("Stars: ", row[["Stars"]])),
          tags$div(paste("Followers: ", row[["Followers"]])),
          tags$div(paste("Following: ", row[["Following"]])),
          tags$div(paste("Contributions: ", row[["Contributions"]]))
        )
      )
    )
  })
  
  output$map <- renderLeaflet({
    req(rv$selected)
    leaflet() %>%
      addTiles() %>% 
      setView(-40.614032, 39.746552, zoom = 1) %>%  # middle of the Atlantic
      addMarkers(lng = as.numeric(rv$github[rv$selected, "Longitude"]), 
                 lat = as.numeric(rv$github[rv$selected, "Latitude"]), 
                 popup = paste(rv$github[rv$selected, "FirstName"],
                               rv$github[rv$selected, "LastName"])) %>%
      fitBounds(38.066040, 6.814138, -131.330978, 50.097924) # frames US and Europe
  })
}