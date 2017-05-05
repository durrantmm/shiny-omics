library(shiny)
library(plotly)
library(dplyr)
source("helpers.R")

ui <- fluidPage(
  
  titlePanel("iPOP Participant Microbiome Dashboard"),
  
  # First row contains the control panel
  sidebarLayout(
    
    sidebarPanel(
      # Select the individual ID drop down menu
      selectInput("select_indiv", label = h3("Select Individual ID"), 
                  choices = hlpr.individual_ids, 
                  selected = 1),
      
      # Select the taxonomy level drop down menu
      selectInput("select_taxon_level", 
                  label = h3("Select taxonomy level:"), 
                  choices = hlpr.taxonomy_levels, 
                  selected = hlpr.selected_taxonomy),
      
      # Menu to select the number of distinct taxa to display, maximum 11, the rest are designated as "other"
      sliderInput("display_n_taxa_slider", 
                  h3("Number of taxa to display:"), 
                  min=1, max=11, value=5)
    ),
    
    mainPanel(
      fluidRow(
        column(width=12, plotlyOutput('relative_props'))
        
      )
    )
  ),
  fluidRow(
    column(width=4, plotlyOutput('bacteroidetes_firmicutes')),
    column(width=4, plotlyOutput('pca')),
    column(width=4, plotlyOutput('species_diversity'))
  )
)


