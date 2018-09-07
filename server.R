library(shiny)
library(salty)
library(dplyr)
library(stringr)

function(input, output) {

  output$contents <- renderDataTable({
    uploaded_data()
  }, options = list(
    pageLength = 10
  ))

  # input$file1 will be NULL initially. After the user selects
  # and uploads a file, head of that data file by default,
  # or all rows if selected, will be shown.

  uploaded_data <- reactive({
    if (is.null(input$file1))
      return(starter_data)

    tryCatch(
      {
        df <- read.csv(
          input$file1$datapath,
          header = input$header,
          sep = input$sep,
          quote = input$quote,
          colClasses = "character",
          stringsAsFactors = FALSE)
      },
      error = function(e) {
        # return a safeError if a parsing error occurs
        stop(safeError(e))
      }
    )
  })

  column_ui <- function(name) {
    box(
      title = name,
      collapsible = TRUE,
      collapsed = TRUE,

      flowLayout(
        selectInput(str_glue("{name}_shaker"),
                    label = "Shaker",
                    choices = c("none", available_shakers()), selected = "none", multiple = FALSE),
        conditionalPanel(
          condition = str_glue("input['{name}_shaker'] != 'none'"),
          sliderInput(str_glue("{name}_p"), label = "Proportion of values to salt",
                      min = 0, max = 1, step = 0.1, value = 0.5),
          sliderInput(str_glue("{name}_n"), label = "Proportion of characters to change",
                      min = 0, max = 1, step = 0.1, value = 0.5)
        )
      )
    )
  }

  salted_df <- reactive({
    working_df <- uploaded_data()
    df_names <- names(working_df)
    for (i in seq_along(df_names)) {
      coln <- df_names[i]
      coln_shaker <- input[[str_glue("{coln}_shaker")]]
      if (!is.null(coln_shaker) && coln_shaker != "none") {
        if (coln_shaker %in% available_shakers()$replacement_shaker) {
          working_df[[coln]] <- salt_replace(x = working_df[[coln]],
                                             replacement_shaker[[coln_shaker]],
                                             p = input[[str_glue("{coln}_p")]],
                                             rep_p = input[[str_glue("{coln}_n")]])
        } else {
          working_df[[coln]] <- salt_substitute(x = working_df[[coln]],
                                                shaker[[coln_shaker]],
                                                p = input[[str_glue("{coln}_p")]],
                                                n = input[[str_glue("{coln}_n")]] * 10)
        }
      }
    }
    working_df
  })

  output$salted_table <- renderDataTable({
    salted_df()
  }, options = list(
    pageLength = 10
  ))

  output$salt_opts <- renderUI({
    lapply(names(uploaded_data()), column_ui)
  })


  output$download_salted <- downloadHandler(
    filename = function() str_glue("salted_{input$file1$name}"),
    content = function(file) write.csv(salted_df(), file, row.names = FALSE)
  )
}
