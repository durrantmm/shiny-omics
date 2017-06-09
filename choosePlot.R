require(dplyr)
require(plotly)
require(ggfortify)
require(grid)


# Load the omics data into the environment
source("omicsData.R")

# Specify the choices for the plots to display
choices = c(
  "Microbiome - Microbial Abundance" = "microbiomeAbundance",
  "Microbiome - Shannon Diversity" = "microbiomeShannon",
  "Microbiome - F/B Ratio" = "microbiomeFB",
  "Microbiome - Principal Components" = "microbiomePCA"
)

# Load all of the modules
for (c in choices){
  source(paste(c, '.R', sep=''))
}

choosePlotInput <- function(id, label = "Choose Plot", ...) {
  # Create a namespace function using the provided id
  ns <- NS(id)
  
  tagList(
    selectInput(ns("choice"), "Choose Visualization", choices, ...),
    selectInput(ns("participants"), "Choose Participant:", unique(omicsData$microbiome$ID), 
                selected="ZOZOW1T"),
    uiOutput(ns("plot_controls"))
  )
}

choosePlotOutput <- function(id, label = "Choose Plot"){
  ns <- NS(id)
  
  fluidRow(
    column(9, plotOutput(ns("mainplot"))),
    column(3, plotOutput(ns("sideplot")))
  )
  
}

# Module server function
choosePlot <- function(input, output, session) {
  
  output$plot_controls <- renderUI({
    eval(parse(text=paste(input$choice, 'Controls(session$ns)', sep='')))
  })
  
  output$mainplot <- renderPlot({
    eval(parse(text=paste(input$choice, 'MainPlot(input, omicsData)', sep='')))
  })
  
  output$sideplot <- renderPlot({
    eval(parse(text=paste(input$choice, 'SidePlot(input, omicsData)', sep='')))
  })
  
  return(1)
}

plotOrPlotlyOutput <- function(){
  
}

renderPlotOrPlotly <- function(){
  
}