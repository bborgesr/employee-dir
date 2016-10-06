library(shiny)

rstudio <- read.csv("www/rstudio.csv", stringsAsFactors = FALSE)

# ui <- fluidPage(
#   tableOutput("employees"),
#   actionButton("add", "Add an employee")
# )

ui <- htmlTemplate("templates/landing.html", thumbnails = uiOutput("thumbnails"))

server <- function(input, output, session) {
  output$thumbnails <- renderUI({
    out <- tagList()
    for (i in seq_len(nrow(rstudio))) {
      out[[i]] <-
        HTML(paste0(
          '<div class="col-lg-3 col-md-4 col-xs-6 thumb">
            <a class="thumbnail" href="#">
              <img class="img-responsive" id="', rstudio$Photo[[i]], 
                  '" src="photos/',  rstudio$Photo[[i]], '.jpg" alt="">
            </a>
          </div>'
      ))
    }
    out
  })
  
  # output$employees <- renderTable({
  #   input$ok
  #   isolate(rstudioCurrent())
  # })
  # 
  # observeEvent(input$add, {
  #   showModal(modalDialog(
  #     title = "Add an employee",
  #     textInput("first", "First name:"),
  #     footer = tagList(
  #       modalButton("Cancel"),
  #       actionButton("ok", "OK")
  #     )
  #   ))
  # })
  # 
  # observeEvent(input$ok, {
  #   if (isTruthy(input$first)) removeModal()
  # })
  # 
  # rstudioCurrent <- reactive({
  #   if (isTruthy(input$first)) {
  #     new <- input$first
  #     row <- df <- data.frame(First.Name = new,
  #                             Last.Name = NA, 
  #                             Title = NA, 
  #                             GitHub.Username = NA,
  #                             Photo = NA,
  #                             Description = NA,
  #                             stringsAsFactors = FALSE) 
  #     rbind(rstudio, row)
  #   }
  #   else rstudio
  # })
  
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
