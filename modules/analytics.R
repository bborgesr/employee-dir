
analyticsUI <- function(id, github) {
  ns <- NS(id)
  
  tagList(
    shinythemes::themeSelector(),
    selectInput(ns("flt"), "Filter by title:", 
                choices = unique(github$Title), 
                selected = c("Software Engineer", "Founder", "CTO", 
                             "Master Instructor", "Chief Scientist"),
                multiple = TRUE),
    selectInput(ns("yaxis"), "Select the y-axis", 
                choices = c("Repos", "Stars", "Followers", "Following", "Contributions"),
                selected = "Contributions"),
    actionButton(ns("sort"), "Sort"),
    actionButton(ns("unslct"), "Unselect"),
    plotOutput(ns("plt"), hover = hoverOpts(id = ns("plt_hover"), delay = 20)),
    htmlOutput(ns("info"))
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
      geom_bar(stat="identity")
  })
  
  output$info <- renderText({
    req(rv$selected)
    HTML(paste0(
      '<h1 class="page-header">',
      rv$github[rv$selected, "FirstName"], " ", rv$github[rv$selected, "LastName"], " ",
      '<small>', rv$github[rv$selected, "Title"], '</small>',
      '</h1>',
      '<div class="row">',
      '<div class="col-xs-3">',
      '<img class="img-responsive" 
      src="/photos/', rv$github[rv$selected, "Photo"], '.jpg" 
      alt="" height="200" width="200" style="inline">',
      '</div>',
      '<div class="col-xs-9">',
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
}