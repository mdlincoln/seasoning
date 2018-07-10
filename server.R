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
    return(mtcars)
    req(input$file1)

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
        selectInput(str_glue("{name}_salter"), label = "Salt function",
                    choices = c("none", "Insert", "Substitute", "Replace", "Delete"),
                    selected = "none", multiple = FALSE),
        conditionalPanel(
          condition = str_glue("input['{name}_salter'] != 'none'"),
          selectInput(str_glue("{name}_shaker"), label = "Shaker",
                      choices = available_shakers(), selected = "punctuation"),
          sliderInput(str_glue("{name}_p"), label = "Proportion of values to salt",
                      min = 0, max = 1, step = 0.1, value = 0.5),
          sliderInput(str_glue("{name}_n"), label = "Proportion of characters to change",
                      min = 0, max = 10, step = 1, value = 2),
          sliderInput(str_glue("{name}_rep_p"), label = "Proportion of characters to change",
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
      salt_type <- input[[str_glue("{coln}_salter")]]
      if (salt_type == "Insert") {
        print("Inserting")
        working_df[[coln]] <- salt_insert(working_df[[coln]],
                                          shaker[[input[[str_glue("{coln}_shaker")]]]],
                                          p = input[[str_glue("{coln}_p")]],
                                          n = input[[str_glue("{coln}_n")]])
      } else if (salt_type == "Substitute") {
        print("Substituting")
        working_df[[coln]] <- salt_substitute(working_df[[coln]],
                                          shaker[[input[[str_glue("{coln}_shaker")]]]],
                                          p = input[[str_glue("{coln}_p")]],
                                          n = input[[str_glue("{coln}_n")]])
      } else if (salt_type == "Replace") {
        print("Replacing")
        working_df[[coln]] <- salt_replace(working_df[[coln]],
                                              replacement_shaker[[input[[str_glue("{coln}_shaker")]]]],
                                              p = input[[str_glue("{coln}_p")]],
                                              rep_p = input[[str_glue("{coln}_rep_p")]])
      } else if (salt_type == "Delete") {
        print("Deleting")
        working_df[[coln]] <- salt_delete(working_df[[coln]],
                                              p = input[[str_glue("{coln}_p")]],
                                              n = input[[str_glue("{coln}_n")]])
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
