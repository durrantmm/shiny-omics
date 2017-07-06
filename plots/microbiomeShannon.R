require(vegan)

taxonomy_levels <- c("Phylum", "Class",
                     "Order", "Family", 
                     "Genus", "Species")
selected_taxonomy <- taxonomy_levels[1]

# The sidebar controls used to control the shiny app
microbiomeShannonControls <- function(ns, omicsData){
  
  tagList(
    # Select the participant
    selectInput(ns("participants"), "Choose Participant:", unique(omicsData$microbiome$ID), 
                selected="ZOZOW1T"),
    # Select the taxonomy level drop down menu
    selectInput(ns("select_taxon_level"), 
                label = "Select taxonomy level:", 
                choices = taxonomy_levels, 
                selected = selected_taxonomy)
  )
  
}

# This function takes the input from the sidebar
# and outputs a plot to be displayed.
microbiomeShannonMainPlot <- function(input, omicsData){
  taxon_level <- reactive({
    input$select_taxon_level
  })
  
  indiv_id <- reactive({
    input$participants
  })
  
  data.f <- get_diversity_data(omicsData$microbiome, taxon_level, indiv_id())
  all_diversity_metrics <- analyze_diversity_all(omicsData$microbiome, taxon_level)
  
  gg <- ggplot(data=data.f, aes_string(x="Time", y="ShannonDiversity", group=1)) +
    geom_point(aes(size=1)) +
    geom_line() +
    theme(plot.title = element_text(hjust = 0.5)) +
    geom_hline(yintercept=all_diversity_metrics$mean, linetype='dashed') +
    geom_hline(yintercept=all_diversity_metrics$conf.low, linetype='dashed', color='red') +
    geom_hline(yintercept=all_diversity_metrics$conf.high, linetype='dashed', color='red') +
    ylab("Shannon Diversity") + 
    theme_bw() +
    theme(legend.position='none', axis.text=element_text(size=16), 
          axis.title=element_text(size=18),
          axis.text.y=element_text(angle = 90, hjust=0.5))
  
  return(gg)
}
?theme

# This function takes the input from the sidebar
# and outputs a side plot to be displayed.
microbiomeShannonSidePlot <- function(input, omicsData){
  return(1)
}

get_diversity_data <- function(microbiome_data, taxon_level, indiv_id){
  data.f <- filter_microbiome_data_by_individual(microbiome_data, indiv_id)
  
  times <- unique(as.vector(data.f$Time))
  
  species.mat <-  data.f %>% filter(!is.na(Species)) %>%
    select(Time, Species, Count) %>%
    group_by(Time, Species) %>%
    summarize(Count=sum(Count)) %>%
    spread(key=Species, value=Count, fill=0) %>%
    group_by() %>%
    select(-Time)
  
  species.divers <- as.vector(diversity(species.mat))
  
  data.frame(Time=times, ShannonDiversity=species.divers)
}

# Get subsets of data
filter_microbiome_data_by_individual <- function(microbiome_data, indiv_id){
  filter(microbiome_data, ID==indiv_id) %>%
    select(-ID)
}

# Get diversity data
analyze_diversity_all <- function(microbiome_data, taxon_level){
  species.mat <- microbiome_data %>% filter(!is.na(Species)) %>%
    select(ID, Time, Species, Count) %>%
    group_by(ID, Time, Species) %>%
    summarize(Count=sum(Count)) %>%
    spread(key=Species, value=Count, fill=0) %>%
    group_by() %>%
    select(-ID, -Time)
  
  all_diversity <- as.vector(diversity(species.mat))
  mean_diversity <- mean(all_diversity)
  low <- mean_diversity - 1.96*sd(all_diversity)
  high <- mean_diversity + 1.96*sd(all_diversity)
  
  return( list(mean=mean_diversity, conf.low=low, conf.high=high) )
}