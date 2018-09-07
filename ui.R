library(shiny)
library(shinydashboard)

header <- dashboardHeader(title = "seasoning")

upload_menu <- menuItem(
  "Upload Data",
  tabName = "upload_tab"
)

upload_tab <- tabItem(
  tabName = "upload_tab",
  fluidRow(
    box(p("This interactive web app shows off a couple of functions from", a("salty", href = "https://github.com/mdlincoln/salty"), ", an R package for dirtying your data."), p("Upload a CSV of your own data (no more than 5MB please!) or use the sample data already provided below. Then click on 'Salting Options'"), width = 6),
    box("Import data", width = 6,
        flowLayout(
          # Input: Select a file ----
          fileInput("file1", "Choose CSV File",
                    multiple = FALSE,
                    accept = c("text/csv",
                               "text/comma-separated-values,text/plain",
                               ".csv")),


          # Input: Checkbox if file has header ----
          checkboxInput("header", "Header", TRUE),

          # Input: Select separator ----
          radioButtons("sep", "Separator",
                       choices = c(Comma = ",",
                                   Semicolon = ";",
                                   Tab = "\t"),
                       selected = ","),

          # Input: Select quotes ----
          radioButtons("quote", "Quote",
                       choices = c(None = "",
                                   "Double Quote" = '"',
                                   "Single Quote" = "'"),
                       selected = '"')
        ))
  ),

  fluidRow(box("Data preview", width = 12, dataTableOutput("contents")))
)

salt_menu <- menuItem(
  "Salting Options",
  tabName = "salt_tab"
)

salt_tab <- tabItem(
  tabName = "salt_tab",
  title = "Salting Options",
  fluidRow(
    box(title = "Salting Options", width = 12,
        p("To salt a column with erroneous data, open up its control panel below and select a salting method. Additional options will then appear to fine tune how the salting works. Consult the data preview below. When you are satisfied, click on the download button to get your salted file back as a CSV"),
        hr(),
        downloadButton("download_salted", label = "Download salted data"),
    hr(),

    uiOutput("salt_opts"))),
  fluidRow(box(title = "Data preview", width = 12,
               hr(),
               dataTableOutput("salted_table")))
)

sidebar <- dashboardSidebar(
  sidebarMenu(
    upload_menu,
    salt_menu
  )
)

body <- dashboardBody(
  tabItems(
    upload_tab,
    salt_tab
  )
)

title <- "seasoning: salt your data"

dashboardPage(header, sidebar, body, title)
