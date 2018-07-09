library(shiny)
library(shinydashboard)

header <- dashboardHeader()

upload_menu <- menuItem(
  "Upload Data",
  tabName = "upload_tab"
)

upload_tab <- tabItem(
  tabName = "upload_tab",
  box("CSV parsing options", width = 3,

  # Input: Select a file ----
  fileInput("file1", "Choose CSV File",
            multiple = FALSE,
            accept = c("text/csv",
                       "text/comma-separated-values,text/plain",
                       ".csv")),

  # Horizontal line ----
  tags$hr(),

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
               selected = '"')),
  box("Data preview", width = 9, dataTableOutput("contents"))
)

salt_menu <- menuItem(
  "Salting Options",
  tabName = "salt_tab"
)

salt_tab <- tabItem(
  tabName = "salt_tab",
  title = "Salting Options",
  uiOutput("salt_opts"),
  box(title = "Data preview", width = 12,
      downloadButton("download_salted", label = "Download salted data"),
      hr(),
      dataTableOutput("salted_table"))
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

title <- "Salty Data"

dashboardPage(header, sidebar, body, title)
