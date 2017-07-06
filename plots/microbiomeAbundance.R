require(dplyr)
require(plotly)
require(ggfortify)
require(grid)

taxonomy_levels <- c("Kingdom", "Phylum", 
                     "Class", "Order", "Family", 
                     "Genus", "Species")
selected_taxonomy <- taxonomy_levels[2]


# The sidebar controls used to control the shiny app
microbiomeAbundanceControls <- function(ns, omicsData){
  
  tagList(
    # Select the participant
    selectInput(ns("participants"), "Choose Participant:", unique(omicsData$microbiome$ID), 
                selected="ZOZOW1T"),
    
    # Select the taxonomy level drop down menu
    selectInput(ns("select_taxon_level"), 
                label = "Select taxonomy level:", 
                choices = taxonomy_levels, 
                selected = selected_taxonomy),
    
    # Menu to select the number of distinct taxa to display, maximum 11, the rest are designated as "other"
    sliderInput(ns("display_n_taxa_slider"), 
                "Number of taxa to display:", 
                min=1, max=11, value=5),
    
    # Menu to select the number of distinct taxa to display, maximum 11, the rest are designated as "other"
    checkboxInput(ns("include_unclassified"), "Include unclassified taxa:", value=TRUE)
  )
  
}

# This function takes the input from the siderbar
# and outputs a plot to be displayed.
microbiomeAbundanceMainPlot <- function(input, omicsData){
  
  taxon_level <- reactive({
    input$select_taxon_level
  })
  
  indiv_id <- reactive({
    input$participants
  })
  
  n_taxa <- reactive({
    input$display_n_taxa_slider
  })
  
  include_unclassified <- reactive({
    input$include_unclassified
  })
  
  gg <- ggplot_relative_abundance(taxon_level, indiv_id, n_taxa, include_unclassified, omicsData$microbiome)
  
  gg <- gg + theme(legend.position='none', axis.text=element_text(size=16), 
                   axis.title=element_text(size=18),
                   axis.text.y=element_text(angle = 90, hjust=0.5))
  
  return(gg)
}

# This function takes the input from the siderbar
# and outputs a plot to be displayed.
microbiomeAbundanceSidePlot <- function(input, omicsData){
  taxon_level <- reactive({
    input$select_taxon_level
  })
  
  indiv_id <- reactive({
    input$participants
  })
  
  n_taxa <- reactive({
    input$display_n_taxa_slider
  })
  
  include_unclassified <- reactive({
    input$include_unclassified
  })
  
  gg <- ggplot_relative_abundance(taxon_level, indiv_id, n_taxa, include_unclassified, omicsData$microbiome) +
    theme(legend.text=element_text(size=12))
  
  tmp <- ggplot_gtable(ggplot_build(gg))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  gg_legend <- grid.draw(legend)

  return(gg_legend)
}


relative_proportions_all_average <- function(taxon_level, microbiome){
  
  data.f <- microbiome
  
  data.f <- data.f %>% group_by_("ID", "Time", taxon_level) %>%
    summarize(Count=sum(Count)) %>% 
    group_by(ID, Time) %>%
    mutate(TotalCount=sum(Count)) %>%
    rowwise() %>%
    mutate(Count=Count/TotalCount) %>%
    select(-TotalCount) %>%
    group_by_(taxon_level) %>%
    summarize(RelativeAbundance=mean(Count))
  
  data.f <- data.f %>% mutate(Time="Comparison") %>% select_("Time", taxon_level, "RelativeAbundance")
  
  return(data.frame(data.f))
}


ggplot_relative_abundance <- function(taxon_level, indiv_id, n_taxa, include_unclassified, microbiome_data){
  composition_colors <- c('#a6cee3','#1f78b4','#b2df8a','#33a02c','#fb9a99','#e31a1c',
                          '#fdbf6f','#ff7f00','#cab2d6','#6a3d9a','#ffff99','#b15928')
  
  # Get subsets of data
  microbiome <- microbiome_data
  
  data.f <- get_relative_proportions_data(indiv_id(), taxon_level(), n_taxa(), include_unclassified(), microbiome)
  
  data.f.comp <- filter(data.f, Time=='Comparison')
  data.f.nocomp <- filter(data.f, Time!='Comparison')
  
  data.f.nocomp$Time <- as.numeric(data.f.nocomp$Time)
  gg <- ggplot(data=data.f.nocomp, aes_string(text = taxon_level(), x="Time", y="RelativeAbundance", fill=taxon_level()))
  
  if (length(unique(data.f.nocomp$Time)) > 1){
    gg <- gg + geom_area(position='stack')
  }else{
    gg <- gg + geom_bar(stat='identity')
  }
  
  gg <- gg + theme_classic() +
    scale_fill_manual(name=element_blank(), values=composition_colors) +
    ylab("Relative Abundance of Microbial Taxa")
}

# Get relative props data
get_relative_proportions_data <- function(indiv_id, taxon_level, display_n_taxa, include_unclassified, microbiome_data){
  data.f <- filter_microbiome_data_by_individual(microbiome_data, indiv_id)
  
  if (!include_unclassified){
    data.f <- data.f %>% filter_(paste("!is.na(", taxon_level, ")"))
  }
  
  data.f <- data.f %>% group_by_("Time", taxon_level) %>%
    summarize(Count=sum(Count)) %>%
    group_by(Time) %>%
    mutate(TotalCount=sum(Count)) %>%
    rowwise() %>%
    mutate(RelativeAbundance=Count/TotalCount) %>%
    select(-Count, -TotalCount)
  
  data.f <- rbind(relative_proportions_all_average(taxon_level, microbiome_data), data.frame(data.f))
  
  data.f <- replace(data.f, is.na(data.f), "Unclassified")
  
  data.f <- data.f %>% arrange(desc(RelativeAbundance))
  
  keep_taxa <- unique( ( data.f[, c(taxon_level, 'RelativeAbundance')] %>% arrange_("desc(RelativeAbundance)") )[[taxon_level]])[1:display_n_taxa]
  
  data.f[[taxon_level]] <- ifelse(data.f[[taxon_level]] %in% keep_taxa, data.f[[taxon_level]], 'Other')
  data.f[[taxon_level]] <- factor(as.character(data.f[[taxon_level]]), levels=unique(data.f[[taxon_level]]))
  
  data.f <- data.f %>%
    group_by_('Time', taxon_level) %>%
    dplyr::summarize(RelativeAbundance=sum(RelativeAbundance)) %>%
    group_by()
  
  return(data.f)
}

# Get subsets of data
filter_microbiome_data_by_individual <- function(microbiome_data, indiv_id){
  filter(microbiome_data, ID==indiv_id) %>%
    select(-ID)
}

 
g_legend<-function(a.gplot){
  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  legend
}