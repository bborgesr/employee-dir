
directoryUI <- function(id, rstudio) {
  ns <- NS(id)
  
  tags$div(id = ns("thumbnails"),
    apply(rstudio, 1, function(row) {
      tagList(
        tags$div(class = "col-lg-3 col-md-4 col-xs-6 thumbnail",
          actionLink(ns(paste0("a-", row[["Photo"]])), {
            tags$img(class = "img-responsive",
              src = paste0("photos/", row[["Photo"]], ".jpg"),
              id = ns(row[["Photo"]]),
              tags$div(class = "name",
                tags$h4(list(row[["FirstName"]], row[["LastName"]]))
              )
            )
          })
        )
      )
    })
  )
}

directory <- function(input, output, session, rstudio) {
  for (i in seq_len(nrow(rstudio))) {
    local({
      name <- rstudio[i, "Photo"]
      element <- paste0("a-", name)
      observeEvent(input[[element]], {
        pushState(NULL, NULL, paste0("?page=", name))
      })
    })
  }
}