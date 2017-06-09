require(vegan)

# The sidebar controls used to control the shiny app
microbiomePCAControls <- function(ns){
  
  tagList()
  
}

# This function takes the input from the sidebar
# and outputs a plot to be displayed.
microbiomePCAMainPlot <- function(input, omicsData){
  
  indiv_id <- reactive({
    input$participants
  })
  
  pca_data <- get_pca_data(omicsData$microbiome)
  data.f <- pca_data$data
  data.f$Time <- as.character(data.f$Time)
  
  data.f <- data.f %>% 
    mutate(MySample = ifelse(ID==indiv_id(), TRUE, FALSE)) %>%
    mutate(Time = ifelse(ID==indiv_id(), Time, "Other Sample"))
  
  data_in <- cbind(select(data.f, ID, Time), pca_data$pca$x)
  
  data_in.not_indiv <- filter(data_in, ID != indiv_id())
  data_in.indiv <- filter(data_in, ID == indiv_id())
  
  gg <- ggplot(data=data_in.not_indiv, aes(x=PC1, y=PC2)) + 
    geom_point(colour='grey', size=3) +
    geom_point(data=data_in.indiv, aes(x=PC1, y=PC2, label=Time), size=3, colour='blue') +
    theme_bw() + 
    theme(legend.position='none', axis.text=element_text(size=16), 
          axis.title=element_text(size=18))
  
  return(gg)
}

# This function takes the input from the sidebar
# and outputs a side plot to be displayed.
microbiomePCASidePlot <- function(input, omicsData){
  return(1)
}


# Get subsets of data
filter_microbiome_data_by_individual <- function(microbiome_data, indiv_id){
  filter(microbiome_data, ID==indiv_id) %>%
    select(-ID)
}


# Principal components 
get_pca_data <- function(microbiome_data){
  microbiome_data <- omicsData$microbiome
  data.f <- microbiome_data %>% 
    filter(!is.na(Phylum)) %>%
    group_by(ID, Time, Phylum) %>% 
    summarize(Count=sum(Count)) %>%
    group_by() %>%
    select(ID, Time, Phylum, Count)
  
  totals <- data.f %>% 
    group_by(ID, Time) %>%
    dplyr::summarize(total=sum(Count))
  
  data.f <- inner_join(data.f, totals) %>%
    mutate(Count = Count / total) %>%
    select(ID, Time, Phylum, Count)
  
  data.f <- spread(data.f, key=Phylum, value=Count, fill=0) 
  data.f <- data.f[, colSums(data.f != 0) > 0]
  data.m <- as.matrix(data.f %>% group_by() %>% select(-ID, -Time))
  
  data.m.pca <- prcomp(data.m,
                       center=TRUE,
                       scale=TRUE)
  
  return(list(pca=data.m.pca, data=group_by(data.f)))
}
