require(shiny)
require(ggplot2)
require(plotly)
source("choosePlot.R")

#setwd("/Users/mdurrant/OneDrive/Work/Research/SnyderLab/shiny-omics/v2")

ui <- fluidPage(theme = 'bootstrap.css',
                
  headerPanel("shiny-omics"),
  
  sidebarLayout(
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
?fixedPag
server <- function(input, output, session) {
  choice1 <- callModule(choosePlot, "choice1")
  choice2 <- callModule(choosePlot, "choice2")
  choice3 <- callModule(choosePlot, "choice3")
}

shinyApp(ui, server)

