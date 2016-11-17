
timezoneUI <- function(id) {
  ns <- NS(id)
  
  tags$div(id = ns("timezone"), 
    tags$iframe(src = "https://timezone.io/team/rstudio", 
                frameborder="0", 
                height = "800px",
                width = "100%")
  )
}

timezone <- function(input, output, session, rstudio) {}