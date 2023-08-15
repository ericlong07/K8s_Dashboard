library(shiny)
library(shinydashboard)
library(readr)
library(plotly)
library(ggplot2)
library(DT)
library(DBI)
library(RODBC)
library(odbc)
library(RPostgres)


# Specify database information
dsn_database = "postgres"
dsn_hostname = "postgres-service"  
dsn_port = "5432"
dsn_uid = "postgres"
dsn_pwd = "mysecretpassword"


ui <- dashboardPage(
  # Declare header
  dashboardHeader(title = "Slurm Data"),

  # Define sidebar
  dashboardSidebar(
    sidebarMenu(
        sidebarSearchForm(textId = "searchText", buttonId = "searchButton",
                          label = "Search..."),
        menuItem("Dashboard", tabName = "dashboard", 
                 icon = icon("signal", lib = "glyphicon")),
        menuItem("Data Table", tabName = "dataTable", 
                 icon = icon("th", lib = "glyphicon")),
        menuItem("Source code", icon = icon("file", lib = "glyphicon"),
                 href = "https://github.com/ericlong07/K8s_Dashboard.git")
    )
  ),

  # Define body content
  dashboardBody(

    # Added some custom CSS to change the font and background color of title area.
    tags$head(
        tags$link(rel = "icon", type = "image/x-icon", href = "favicon.ico"),
        tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
        tags$style(HTML('
          .skin-blue .main-header .logo {
            background-color: #3c8dbc;
          }
          .skin-blue .main-header .logo:hover {
            background-color: #3c8dbc;
          }
        '))),

    tabItems(
        tabItem(tabName = "dashboard",
            # Plot 1
            fluidRow(
              box(status = "danger", title = "Allocated CPUS",
                  plotlyOutput("plot1", height = 250),
                  solidHeader = TRUE,
              ),
              
              box(status = "danger", title = "From:",
                  selectInput("dateRange1", "Select Date Range",
                              choices = NULL,
                              selected = NULL
                  ),
                  solidHeader = TRUE, collapsible = TRUE
              ),
              
              box(status = "danger", title = "To:",
                  selectInput("dateRange2", "Select Date Range",
                              choices = NULL,
                              selected = NULL
                  ),
                  solidHeader = TRUE, collapsible = TRUE
              ),
            ),
            
            # Plot 2
            fluidRow(
              box(status = "success", title = "Allocated Nodes",
                  plotlyOutput("plot2", height = 250),
                  solidHeader = TRUE,
              ),
              
              box(status = "success", title = "From:",
                  selectInput("dateRange3", "Select Date Range",
                              choices = NULL,
                              selected = NULL
                  ),
                  solidHeader = TRUE, collapsible = TRUE
              ),
              
              box(status = "success", title = "To:",
                  selectInput("dateRange4", "Select Date Range",
                              choices = NULL,
                              selected = NULL
                  ),
                  solidHeader = TRUE, collapsible = TRUE
              )
            ),
            
            # Plot 3
            fluidRow(
              box(status = "warning", title = "Elapsed Time (in seconds)",
                  plotlyOutput("plot3", height = 250),
                  solidHeader = TRUE,
              ),
              
              box(status = "warning", title = "From:",
                  selectInput("dateRange5", "Select Date Range",
                              choices = NULL,
                              selected = NULL
                  ),
                  solidHeader = TRUE, collapsible = TRUE
              ),
              
              box(status = "warning", title = "To:",
                  selectInput("dateRange6", "Select Date Range",
                              choices = NULL,
                              selected = NULL
                  ),
                  solidHeader = TRUE, collapsible = TRUE
              ),
            )
        ),
        
        # Data table
        tabItem(tabName = "dataTable",
                fluidRow(
                  box(status = "info", width = 12,
                    DT::dataTableOutput("table")
                  )
                )
        )
    )
  )
)

# Define the server logic
server <- function(input, output, session) {

  # Establish R and PostgreSQL connection through RPostgres
  print("Connecting to Database…")
  connec <- dbConnect(RPostgres::Postgres(), 
              dbname = dsn_database,
              host = dsn_hostname, 
              port = dsn_port,
              user = dsn_uid, 
              password = dsn_pwd)
  print("Database Connected!")

   # Fetch data from the database
  query <- glue::glue("SELECT * FROM slurm_data")
  data <- dbGetQuery(connec, query)

  # Get the date range
  data$Start <- as.Date(substr(data$Start, start = 1, stop = 10))
  data$End <- as.Date(substr(data$End, start = 1, stop = 10))
  dateChoices <- unique(data$Start)
  dateChoices <- sort(dateChoices)
  
  # Update 'From' dates for graph 1
  updateSelectInput(session, "dateRange1",
                    choices = dateChoices,
                    selected = dateChoices[1]
  )

  # Update 'To' dates
  updateSelectInput(session, "dateRange2",
                    choices = dateChoices,
                    selected = dateChoices[length(dateChoices)]
  )

  # Update for graph 2
  updateSelectInput(session, "dateRange3",
                    choices = dateChoices,
                    selected = dateChoices[1]
  )

  updateSelectInput(session, "dateRange4",
                    choices = dateChoices,
                    selected = dateChoices[length(dateChoices)]
  )

  # Update for graph 3
  updateSelectInput(session, "dateRange5",
                    choices = dateChoices,
                    selected = dateChoices[1]
  )

  updateSelectInput(session, "dateRange6",
                    choices = dateChoices,
                    selected = dateChoices[length(dateChoices)]
  )

  # Create a function to generate plotly plots
  create_plot <- function(data, start_date_input, end_date_input, y_var) {
    subdata <- subset(
      data, 
      Start >= input[[start_date_input]] & Start <= input[[end_date_input]],
      select=c('Start', y_var))
    
    plot_ly(subdata, x = ~Start, y = as.formula(paste0("~", y_var)), type = "bar")
  }

  # Display plot1
  output$plot1 <- renderPlotly({
    create_plot(data, "dateRange1", "dateRange2", "alloccpus")
  })
  
  # Plot 2
  output$plot2 <- renderPlotly({
    create_plot(data, "dateRange3", "dateRange4", "allocnodes")
  })
  
  # Plot 3
  output$plot3 <- renderPlotly({
    create_plot(data, "dateRange5", "dateRange6", "elapsedraw")
  })
  
  # Render data table
  output$table <- DT::renderDataTable({
    subdata <- subset(data,
                   select=c('jobid','Start', 'End', 'alloccpus', 'allocnodes')
                  )
    subdata
  })

  # Add a function to close the connection when the app exits
  onSessionEnded(function() {
    if (!is.null(connec)) {
      print("Closing database connection...")
      dbDisconnect(connec)
    }
  })
}

shinyApp(ui, server)
