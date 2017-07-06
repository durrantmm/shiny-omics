require(shiny)
require(ggplot2)
require(plotly)

####################################################
# This is the main module that sets up the shiny app
####################################################

# Loads the custom choosePlot shiny module.
source("choosePlot.R")

# The working directory can be set if that is necessary.
# setwd("/path/to/wd")

# You can change the css template in the www as you see fit.
ui <- fluidPage(theme = 'bootstrap.css',
                
  headerPanel("shiny-omics"),

  sidebarLayout(
    # The selected option is the default plot shown. You can change this if necessary.
    sidebarPanel(
      choosePlotInput("choice1", selected="microbiomeAbundance")
    ),
    mainPanel(
      choosePlotOutput("choice1")
    )
  ),

  sidebarLayout(
    sidebarPanel(
      choosePlotInput("choice2", selected="microbiomeShannon")
    ),
    mainPanel(
      choosePlotOutput("choice2")
    )
  ),

  sidebarLayout(
    sidebarPanel(
      choosePlotInput("choice3", selected="microbiomeFB")
    ),
    mainPanel(
      choosePlotOutput("choice3")
    )
  )
)

server <- function(input, output, session) {
  # This is where the three modules are actually called by the server.
  callModule(choosePlot, "choice1")
  callModule(choosePlot, "choice2")
  callModule(choosePlot, "choice3")
}

shinyApp(ui, server)

