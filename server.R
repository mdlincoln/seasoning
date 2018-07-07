library(shiny)
library(salty)
library(dplyr)
library(stringr)

function(input, output) {

  output$contents <- renderTable({
    uploaded_data()[1:50,]
  })

  # input$file1 will be NULL initially. After the user selects
  # and uploads a file, head of that data file by default,
  # or all rows if selected, will be shown.

  uploaded_data <- reactive({
    return(iris)
    req(input$file1)

    # when reading semicolon separated files,
    # having a comma separator causes `read.csv` to error
    tryCatch(
      {
        df <- read.csv(input$file1$datapath,
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
    tabPanel(
      title = name,
      value = str_glue("{name}_tabPanel"),
      inputPanel(
        selectInput(str_glue("{name}_salter"), label = "Salt function",
                    choices = c("none", "Insert", "Substitute", "Replace", "Delete"),
                    selected = "none", multiple = FALSE),
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
  }

  salted_df <- reactive({
    working_df <- uploaded_data()
    df_names <- names(working_df)
    for (i in seq_along(df_names)) {
      coln <- df_names[i]
      str(coln)
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
        working_df[[coln]] <- salt_substitute(working_df[[coln]],
                                              shaker[[input[[str_glue("{coln}_shaker")]]]],
                                              p = input[[str_glue("{coln}_p")]],
                                              n = input[[str_glue("{coln}_n")]])
      }
    }
    working_df
  })

  output$salted_table <- renderTable({
    salted_df()[1:20,]
  })

  output$salt_opts <- renderUI({
    box(title = "Salting Options", width = 12,
      lapply(names(uploaded_data()), column_ui)
    )
  })


}
