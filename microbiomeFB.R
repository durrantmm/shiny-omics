require(vegan)

# The sidebar controls used to control the shiny app
microbiomeFBControls <- function(ns){
  
  tagList()
  
}

# This function takes the input from the sidebar
# and outputs a plot to be displayed.
microbiomeFBMainPlot <- function(input, omicsData){
  data.f <- get_bac_firm_data(omicsData$microbiome, 'ZOZOW1T')
  
  data.f$Time <- as.numeric(data.f$Time)
  max_stage <- max(data.f$Time) + 0.5
  min_stage <- min(data.f$Time) - 0.5
  
  mildly_elevated_rect <- data.frame(xmin=min_stage, xmax=max_stage, ymin=5.7, ymax=9.1)
  optimal_rect <- data.frame(xmin=min_stage, xmax=max_stage, ymin=1.0, ymax=5.6)
  mildly_decreased_rect <- data.frame(xmin=min_stage, xmax=max_stage, ymin=0.6, ymax=0.9)
  low_rect <- data.frame(xmin=min_stage, xmax=max_stage, ymin=0, ymax=0.5)
  
  p <- ggplot(data=data.f, aes(x=Time, y=`F/B Ratio`, group=1)) + 
    
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
    theme(legend.position="None",
          axis.text=element_text(size=16), 
          axis.title=element_text(size=18)) +
    ylab("Firmicutes to Bacteroidetes Ratio")
  
  return(p)
}

# This function takes the input from the sidebar
# and outputs a side plot to be displayed.
microbiomeFBSidePlot <- function(input, omicsData){
  return(1)
}


# Get subsets of data
filter_microbiome_data_by_individual <- function(microbiome_data, indiv_id){
  filter(microbiome_data, ID==indiv_id) %>%
    select(-ID)
}


# Get Bacteroidetes-Firmicutes data table
get_bac_firm_data <- function(microbiome_data, indiv_id){
  data.f <- filter_microbiome_data_by_individual(microbiome_data, indiv_id) %>% select(Time, Phylum, Class, Count)
  data.f <- filter(data.f, (Phylum=="Bacteroidetes" | Phylum=="Firmicutes")) %>% group_by(Time, Phylum) %>% summarize(Count=sum(Count))
  data.f <- data.f %>% spread(key=Phylum, value=Count) %>% mutate(`F/B Ratio` = Firmicutes/Bacteroidetes)  
  
  return(data.f)
}
