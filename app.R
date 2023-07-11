## app.R ##

library(shiny)
library(shinydashboard)
library(readr)
library(plotly)
library(ggplot2)
library(DT)


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
                 href = "https://github.com/rstudio/shinydashboard/")
    )
  ),
  # Define body content
  dashboardBody(
    tags$head(
            tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    # Added some custom CSS to make the title background area the same
    # color as the rest of the header.
    tags$head(tags$style(HTML('
        .skin-blue .main-header .logo {
          background-color: #3c8dbc;
        }
        .skin-blue .main-header .logo:hover {
          background-color: #3c8dbc;
        }
      '))),
      
    tabItems(
        tabItem(tabName = "dashboard",
            fluidRow(
              box(status = "info", width = 3,
                  fileInput("file", "SELECT A FILE:")
              )
            ),
            
            # Plot 1
            fluidRow(
              box(status = "danger", title = "Allocated CPUS",
                  plotlyOutput("plot1", height = 250),
                  solidHeader = TRUE,
              ),
              
              box(status = "danger", title = "From:",
                  selectInput("dateRange", "Select Date Range",
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
  input_file <- reactive({
    if (is.null(input$file)) {
      return("")
    }
    
    # actually read the file
    read_csv(file = input$file$datapath)
  })
  
  observe({
    req(input_file())
    
    data <- input_file()
    data$Start <- as.Date(substr(data$Start, start = 1, stop = 10))
    dateChoices <- unique(data$Start)
    dateChoices <- sort(dateChoices)
    
    # Update 'From' dates for graph 1
    updateSelectInput(session, "dateRange",
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
  })
  
  # Display plot1
  output$plot1 <- renderPlotly({
    # render only if there is data available
    req(input_file())

    # reactives are only callable inside an reactive context like render
    data <- input_file()
    data$Start <- as.Date(substr(data$Start, start = 1, stop = 10))
    data <- subset(
      data, 
      Start >= input$dateRange & Start <= input$dateRange2,
      select=c('Start', 'AllocCPUS'))
    
    plot_ly(data, x = ~Start, y = ~AllocCPUS, type = "bar")
  })
  
  # Plot 2
  output$plot2 <- renderPlotly({
    # render only if there is data available
    req(input_file())
    
    # reactives are only callable inside an reactive context like render
    data <- input_file()
    data$Start <- as.Date(substr(data$Start, start = 1, stop = 10))
    data <- subset(
      data, 
      Start >= input$dateRange3 & Start <= input$dateRange4,
      select=c('Start', 'AllocNodes'))
    
    plot_ly(data, x = ~Start, y = ~AllocNodes, type = "bar")
  })
  
  # Plot 3
  output$plot3 <- renderPlotly({
    # render only if there is data available
    req(input_file())
    
    # reactives are only callable inside an reactive context like render
    data <- input_file()
    data$Start <- as.Date(substr(data$Start, start = 1, stop = 10))
    data <- subset(
      data, 
      Start >= input$dateRange5 & Start <= input$dateRange6,
      select=c('Start', 'ElapsedRaw'))
    
    plot_ly(data, x = ~Start, y = ~ElapsedRaw, type = "bar")
  })
  
  # Render data table
  output$table <- DT::renderDataTable({

    # render only if there is data available
    req(input_file())

    # reactives are only callable inside an reactive context like render
    data <- input_file()
    data <- subset(data,
                   select=c('JobID','Start', 'End', 'AllocCPUS', 'AllocNodes')
                  )
    data$Start <- as.Date(substr(data$Start, start = 1, stop = 10))
    data$End <- as.Date(substr(data$End, start = 1, stop = 10))
    
    data <- data[with(data, order(data$Start, data$End)), ]

    data
  })
}

shinyApp(ui, server)
