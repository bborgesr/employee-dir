
timezoneUI <- function(id) {
  ns <- NS(id)
  
  tags$div(id = ns("timezone"), 
           width = "100%", height = "100%",
           style="overflow: hidden !important;",
    tags$iframe(src = "https://timezone.io/team/rstudio", 
                frameborder="0", 
                #style="overflow: hidden; height: 100%; width: 100%; position: absolute;", 
                style="overflow: hidden !important;",
                #scrolling="no",
                height = "800px",
                width = "100%")
  )
}

timezone <- function(input, output, session, rstudio) {}