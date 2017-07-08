require(dplyr)
require(plotly)
require(ggfortify)
require(grid)


# Load the omics data into the environment
source("omicsData.R")

# Specify the choices for the plots to display
##############################################
# EDIT THIS TO INCLUDE YOUR OWN VISUALIZATIONS
##############################################
choices = c(
  "Microbiome - Microbial Abundance" = "microbiomeAbundance",
  "Microbiome - Shannon Diversity" = "microbiomeShannon",
  "Microbiome - F/B Ratio" = "microbiomeFB",
  "Microbiome - Principal Components" = "microbiomePCA",
  "Glucose - Daily" = "glucoseDaily",
  "Glucose - Hourly" = "glucoseHourly",
  "Test Template" = "template",
  "Car Dealership Principal Components" = "mtcarsPCA"
)

# Load all of the modules
for (c in choices){
  source(paste('plots/', c, '.R', sep=''))
}

# A module representing the input
choosePlotInput <- function(id, label = "Choose Plot", ...) {
  # Create a namespace function using the provided id
  ns <- NS(id)
  
  tagList(
    selectInput(ns("choice"), "Choose Visualization", choices, ...),
    uiOutput(ns("plot_controls"))
  )
}

# A module representing the output
choosePlotOutput <- function(id, label = "Choose Plot"){
  ns <- NS(id)
  
  fluidRow(
    column(9, plotOutput(ns("mainplot"))),
    column(3, plotOutput(ns("sideplot")))
  )
  
}

# Module server function
##########################################################################################################
# This where the plots are rendered. I'm currently taking a risky approach by evaluating the text paste
# as the function of interest. It would be nice to find a more elegant solution.
#########################################################################################################
choosePlot <- function(input, output, session) {
  
  output$plot_controls <- renderUI({
    eval(parse(text=paste(input$choice, 'Controls(session$ns, omicsData)', sep='')))
  })
  
  output$mainplot <- renderPlot({
    eval(parse(text=paste(input$choice, 'MainPlot(input, omicsData)', sep='')))
  })
  
  output$sideplot <- renderPlot({
    eval(parse(text=paste(input$choice, 'SidePlot(input, omicsData)', sep='')))
  })
  
  return(1)
}