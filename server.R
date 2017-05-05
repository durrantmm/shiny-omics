library(shiny)
library(dplyr)
library(grid)
library(ggplot2)
library(tidyr)
library(plotly)
library(ggfortify)
source("helpers.R")

server <- function(input, output, session) {
  
  composition_colors <- reactive({
    c('#a6cee3','#1f78b4','#b2df8a','#33a02c','#fb9a99','#e31a1c','#fdbf6f','#ff7f00','#cab2d6','#6a3d9a','#ffff99','#b15928')
  })
  
  taxon_level <- reactive({
    input$select_taxon_level
  })
  
  output$relative_props <- renderPlotly({
    indiv_id <- input$select_indiv
    taxon_level <- input$select_taxon_level
    n_taxa <- input$display_n_taxa_slider
    
    data.f <- hlpr.get_relative_proportions_data(indiv_id, taxon_level, n_taxa)
    
    data.f.comp <- filter(data.f, Stage=='Comparison')
    data.f.nocomp <- filter(data.f, Stage!='Comparison')
    gg <- ggplot(data=data.f.nocomp, aes_string(text = taxon_level, x="Stage", y="RelativeAbundance", group=1, fill=taxon_level))
    
    if (length(unique(data.f.nocomp$Stage)) > 1){
      gg <- gg + geom_area(position='stack')
    }else{
      gg <- gg + geom_bar(stat='identity')
    }
    
    gg <- gg + theme_classic() +
      geom_bar(data=data.f.comp, aes_string(text = taxon_level, x="Stage", y="RelativeAbundance", fill=taxon_level), stat='identity') +
      scale_fill_manual(name=element_blank(), values=composition_colors()) +
      ggtitle("Relative Abundance of Microbial Taxa")
    
    myplotly <- ggplotly(gg, tooltip=c("x", "text"))
    myplotly <- plotly_build(myplotly)
    myplotly$x$layout$annotations[[1]]$text <- taxon_level
    myplotly
    
  })
  
  
  output$species_diversity <- renderPlotly({
    indiv_id <- input$select_indiv
    
    data.f <- hlpr.get_species_diversity_data(indiv_id)
    
    gg <- ggplot(data=data.f, aes_string(x="Stage", y="ShannonDiversity", group=1)) +
      geom_point(aes(size=1)) +
      geom_line() +
      theme(plot.title = element_text(hjust = 0.5)) +
      geom_hline(yintercept=all_diversity_metrics$mean, linetype='dashed') +
      geom_hline(yintercept=all_diversity_metrics$conf.low, linetype='dashed', color='red') +
      geom_hline(yintercept=all_diversity_metrics$conf.high, linetype='dashed', color='red') +
      ggtitle("Shannon Diversity - Species") +
      theme_bw()
      
    
    myplotly <- ggplotly(gg, tooltip=c('y', 'yintercept'))
    
    myplotly
  })
  
  
  output$pca <- renderPlotly({
    indiv_id <- input$select_indiv
    
    pca <- pca_data$pca
    data.f <- pca_data$data
    data.f$Stage <- as.character(data.f$Stage)
    
    data.f <- data.f %>% 
      mutate(MySample = ifelse(SAMPLE_ID==indiv_id, TRUE, FALSE)) %>%
      mutate(Stage = ifelse(SAMPLE_ID==indiv_id, Stage, "Other Sample"))
    
    data_in <- cbind(select(data.f, SAMPLE_ID, Stage), pca_data$pca$x)
    
    data_in.not_indiv <- filter(data_in, SAMPLE_ID != indiv_id)
    data_in.indiv <- filter(data_in, SAMPLE_ID == indiv_id)
    
    gg <- ggplot(data=data_in.not_indiv, aes(x=PC1, y=PC2)) + 
      geom_point(colour='grey') +
      geom_point(data=data_in.indiv, aes(x=PC1, y=PC2, label=Stage), colour='blue') +
      theme_bw() + 
      theme(plot.title = element_text(hjust = 0.5)) +
      ggtitle("Principal Components Analysis")
    
    myplotly <- ggplotly(gg, tooltip = 'label')
    myplotly
    
  })
  
  
  output$relative_props_line <- renderPlotly({
    
    indiv_id <- input$select_indiv
    taxon_level <- input$select_taxon_level
    n_taxa <- input$display_n_taxa_slider
    
    data.f <- hlpr.get_relative_proportions_data(indiv_id, taxon_level, n_taxa)
    
    gg <- ggplot(data=data.f, aes_string(x="Stage", y="RelativeAbundance", colour=taxon_level, group=taxon_level)) + 
      geom_line() +
      geom_point(aes(size=1)) +
      theme_classic() +
      theme(plot.title = element_text(hjust = 0.5)) +
      scale_color_manual(name=element_blank(),
                         values=composition_colors()) +
      ggtitle("Relative Abundance of Microbial Taxa")
    
    myplotly <- ggplotly(gg, tooltip=c("y", "colour"))
    myplotly <- plotly_build(myplotly) %>% layout(showlegend = FALSE)
    
    return(myplotly)
    
  })
  
  
  output$bacteroidetes_firmicutes <- renderPlotly({
    
    data.f <- hlpr.get_bac_firm_data(input$select_indiv)
    
    data.f$Stage <- as.numeric(data.f$Stage)
    max_stage <- max(data.f$Stage) + 0.5
    min_stage <- min(data.f$Stage) - 0.5
    
    mildly_elevated_rect <- data.frame(xmin=min_stage, xmax=max_stage, ymin=5.7, ymax=9.1)
    optimal_rect <- data.frame(xmin=min_stage, xmax=max_stage, ymin=1.0, ymax=5.6)
    mildly_decreased_rect <- data.frame(xmin=min_stage, xmax=max_stage, ymin=0.6, ymax=0.9)
    low_rect <- data.frame(xmin=min_stage, xmax=max_stage, ymin=0, ymax=0.5)
    
    p <- ggplot(data=data.f, aes(x=Stage, y=`F/B Ratio`, group=1)) + 
      
      geom_rect(data=mildly_elevated_rect, aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax),
                fill='yellow',
                alpha=0.3,
                inherit.aes = FALSE) +
      geom_rect(data=optimal_rect, aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax),
                fill='green',
                alpha=0.3,
                inherit.aes = FALSE) +
      geom_rect(data=mildly_decreased_rect, aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax),
                fill='yellow',
                alpha=0.3,
                inherit.aes = FALSE) +
      geom_rect(data=low_rect, aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax),
                fill='red',
                alpha=0.3,
                inherit.aes = FALSE) +
      geom_line() +
      geom_point(aes(size=1)) +
      theme_bw() +
      theme(plot.title = element_text(hjust = 0.5), legend.position="None") + 
      ggtitle("Firmicutes to Bacteroidetes Ratio")
    
    return(ggplotly(p, tooltip=''))
  })
  
  
}