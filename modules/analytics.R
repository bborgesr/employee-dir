
analyticsUI <- function(id, github) {
  ns <- NS(id)
  
  fluidPage(
    
    p("This is a snapshot of our profiles and activity on Github as of",
      "October 2016.", strong("Hover over each bar"), "to see that",
      "person's info!"),
    br(),
    
    sidebarLayout(
      
      sidebarPanel(
        # shinythemes::themeSelector(),
        selectInput(ns("flt"), "Filter by title:", 
          choices = unique(github$Title), 
          selected = c("Software Engineer"),
          multiple = TRUE),
        radioButtons(ns("yaxis"), "Select the y-axis", 
          choices = c("Repos", "Stars", "Followers", 
                     "Following", "Contributions"),
          selected = "Contributions"),
        actionButton(ns("sort"), "Sort"),
        actionButton(ns("unslct"), "Unselect")
      ),
      
      mainPanel(
        plotOutput(ns("plt"), 
          hover = hoverOpts(id = ns("plt_hover"), delay = 20)
        )
      )
    ),
    
    fluidRow(
      column(width = 6, htmlOutput(ns("info"))),
      column(width = 6, leafletOutput(ns("map")))
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
    rv$selected <- NULL
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
      labs(x = "GitHub Username", y = input$yaxis) +
      guides(fill = FALSE)
  })
  
  output$info <- renderText({
    req(rv$selected)
    HTML(paste0(
      '<h1 class="page-header">',
      rv$github[rv$selected, "FirstName"], " ", rv$github[rv$selected, "LastName"], " ",
      '<small>', rv$github[rv$selected, "Title"], '</small>',
      '</h1>',
      '<div class="row">',
      '<div class="col-xs-6">',
      '<img class="img-responsive" 
      src="photos/', rv$github[rv$selected, "Photo"], '.jpg" 
      alt="" height="200" width="200" style="inline">',
      '</div>',
      '<div class="col-xs-6">',
      '<div><strong>Github Info:</strong></div>',
      '<div>Number of Repos: ', rv$github[rv$selected, "Repos"],'</div>',
      '<div>Number of Stars: ', rv$github[rv$selected, "Stars"],'</div>',
      '<div>Number of Followers: ', rv$github[rv$selected, "Followers"],'</div>',
      '<div>Number of Followees: ', rv$github[rv$selected, "Following"],'</div>',
      '<div>Number of Contributions: ', rv$github[rv$selected, "Contributions"],'</div>',
      '</div>',
      '</div>'
    ))
  })
  
  output$map <- renderLeaflet({
    req(rv$selected)
    leaflet() %>%
      addTiles() %>% 
      setView(-40.614032, 39.746552, zoom = 1) %>%
      addMarkers(lng = as.numeric(rv$github[rv$selected, "Longitude"]), 
                 lat = as.numeric(rv$github[rv$selected, "Latitude"]), 
                 popup = paste(rv$github[rv$selected, "FirstName"],
                               rv$github[rv$selected, "LastName"])) %>%
      fitBounds(38.066040, 6.814138, -131.330978, 50.097924)
  })
}