options(shiny.launch.browser=F, shiny.minified=F, shiny.port = 9000)

library(shiny)
library(shinythemes)
library(whisker)
library(dplyr)
library(rvest)
library(ggplot2)
library(shinyjs)

rstudio <- read.csv("www/rstudio.csv", stringsAsFactors = FALSE)

ui <- function(request) {
  # downloadable <- as.character(htmlTemplate("www/views/_app.html"))
  # cat(downloadable, file = paste0("www/app.html"))

  fluidPage(
    useShinyjs(),
    htmlTemplate("www/views/_landing.html",
                 thumbnails = uiOutput("profile"))
    # htmlTemplate("www/views/_landing.html",
    #   # thumbnails = checkboxGroupInput("thumbnails", label = NULL, choices = rstudio$Photo)
    #   thumbnails = tags$div(id = "thumbnails",
    #   apply(rstudio, 1, function(row) {
    # 
    #     # out <- whisker.render(readLines("www/views/_profile.html"), data = row)
    #     # out <- gsub("\n", "", out)
    # 
    #     # downloadable <- htmlTemplate("www/views/_profile-downloadable.html", profile = HTML(out))
    #     # downloadable <- gsub("<!-- Back.*<!-- Title", "<!-- Title", as.character(downloadable))
    #     # cat(as.character(downloadable), file = paste0("www/profiles/", row[["Photo"]], ".html"))
    # 
    #     tagList(
    #       tags$div(class = "col-lg-3 col-md-4 col-xs-6 thumbnail",
    #                # Copy the chunk below to make a group of checkboxes
    #                # checkboxGroupInput("checkGroup", label = h3("Checkbox group"),
    #                #                    choices = list("Choice 1" = 1, "Choice 2" = 2, "Choice 3" = 3),
    #                #                    selected = 1),
    # 
    #         # onclick = HTML("document.getElementById('thumbnails').style.display = 'none';",
    #         #                "document.getElementById('profile').innerHTML = '", out, "';",
    #         #                "scroll(0,0);"),
    # 
    #         # tags$a(class = "navigate", 
    #         #        #href = paste0("../profiles/", row[["Photo"]], ".html"),
    #         #    tags$img(class = "img-responsive",
    #         #             src = paste0("photos/", row[["Photo"]], ".jpg"),
    #         #             id = row[["Photo"]],
    #         #             tags$div(class = "name",
    #         #                      tags$h4(list(row[["FirstName"]], row[["LastName"]]))
    #         #             )
    #         #    )
    #         # )
    # 
    #         
    #         actionLink(paste0("a-", row[["Photo"]]), {
    #           tags$img(class = "img-responsive",
    #                    src = paste0("photos/", row[["Photo"]], ".jpg"),
    #                    id = row[["Photo"]],
    #                    tags$div(class = "name",
    #                             tags$h4(list(row[["FirstName"]], row[["LastName"]]))
    #                    )
    #           )
    #         })
    #       )
    #     )
    #   }))
    #   #,
    #   #app = tags$div(id = "app", style = "display: none;",
    #   #                    htmlTemplate("www/views/_app.html"))
    # ),
    
    #uiOutput("profile")
    )
}

server <- function(input, output, session) {
  
  linkNames <- paste0("input$a-", rstudio$Photo)
  
  observeEvent(input[["a-kim"]], {
    # out <- whisker.render(readLines("www/views/_profile.html"), data = rstudio[40,])
    # out <- gsub("\n", "", out)
    
    pushState(NULL, NULL, paste0("?employee=", "kim"))
  })
  
  output$profile <- renderUI({
    query <- parseQueryString(session$clientData$url_search)
    if (identical(query, list())) {
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
               }))
    } else {
      out <- whisker.render(readLines("www/views/_profile.html"), data = rstudio[40,])
      out <- gsub("\n", "", out)
      HTML(out)
      # html(id = "profile", html = out, selector = "#profile")
      # show(id = "profile")
    }
  })

  # for (i in seq_len(nrow(rstudio))) {
  #   observeEvent(try(get(paste0("input$a-", rstudio[i, "Photo"]))), {
  #     id <- rstudio[i, "Photo"]
  #     
  #     ## take reactive dependency
  #     #try(get(paste0("input$a-", id)))
  #     #link <- get(name)
  #     
  #     pushState(NULL, NULL, paste0("?employee=", id))
  #     
  #     hide(selector = "#main")
  #     
  #     out <- whisker.render(readLines("www/views/_profile.html"), data = rstudio[i,])
  #     out <- gsub("\n", "", out)
  #     
  #     html(html = out, selector = "#profile")
  #     
  #   })
  # }
  
  # selectedData <- reactive({
  #   iris[, c(input$xcol, input$ycol)]
  # })
  # 
  # output$plot1 <- renderPlot({
  #   plot(selectedData())
  # }, height = 450, width = 600)
  # outputOptions(output, "plot1", suspendWhenHidden = FALSE)
  
  observeEvent(input$add, {
    showModal(modalDialog(
      title = "Add an employee",
      textInput("first", "First name:"),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("ok", "OK")
      ),
      fade = FALSE
    ))
  })

  
  observeEvent(input$ok, {
    if (isTruthy(input$first)) removeModal()
  })

  rstudioCurrent <- reactive({
    if (isTruthy(input$first)) {
      new <- input$first
      row <- df <- data.frame(First.Name = new,
                              Last.Name = NA,
                              Title = NA,
                              Location = NA,
                              GitHub.Username = NA,
                              Photo = NA,
                              Description = NA,
                              stringsAsFactors = FALSE)
      rbind(rstudio, row)
    }
    else rstudio
  })
  
  # observeEvent(input$add, {
  #   btn <- input$insertBtn
  #   id <- paste0('txt', btn)
  #   insertUI(
  #     selector = '#placeholder',
  #     ## wrap element in a div with id for ease of removal
  #     ui = tags$div(
  #       tags$p(paste('Element number', btn)), 
  #       id = id
  #     )
  #   )
  # })
}

shinyApp(ui, server)
