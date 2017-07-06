require(dplyr)
require(plotly)
require(ggfortify)
require(grid)


# The sidebar controls used to control the shiny app
glucoseDailyControls <- function(ns, omicsData){
  start_date = min(omicsData$glucose$Date)
  end_date = max(omicsData$glucose$Date)
  
  tagList(
    # Select the participant
    selectInput(ns("participants"), "Choose Participant:", unique(omicsData$glucose$ID)),
    dateRangeInput(ns("date"), "Date Range:", start = start_date,
                   end = end_date, min = start_date,
                   max = end_date)
  )
  
}

# This function takes the input from the siderbar
# and outputs a plot to be displayed.
glucoseDailyMainPlot <- function(input, omicsData){
  
  indiv_id <- reactive({
    input$participants
  })
  
  date <- reactive({
    input$date
  })
  
  #glucose <- filter(omicsData$glucose, ID==indiv_id())
  glucose <- filter(omicsData$glucose, ID==indiv_id() & Date >= date()[1] & Date <= date()[2]) %>%
    group_by(Date) %>% summarize(AverageGlucose=mean(GlucoseValue), MaximumGlucose=max(GlucoseValue), 
                                 MinimumGlucose=min(GlucoseValue)) %>%
    gather(key="Measurement", value="Glucose", -Date)
  
  gg <- ggplot(glucose, aes(x=Date, y=Glucose, group=Measurement, color=Measurement)) +
    geom_line() + 
    theme_bw() +
    theme(legend.position='none', axis.text=element_text(size=16), 
          axis.title=element_text(size=18),
          axis.text.y=element_text(angle = 90, hjust=0.5))
  
  return(gg)
}

# This function takes the input from the siderbar
# and outputs a plot to be displayed.
glucoseDailySidePlot <- function(input, omicsData){
  
  indiv_id <- reactive({
    input$participants
  })
  
  date <- reactive({
    input$date
  })
  
  #glucose <- filter(omicsData$glucose, ID==indiv_id())
  glucose <- filter(omicsData$glucose, ID==indiv_id() & Date >= date()[1] & Date <= date()[2]) %>%
    group_by(Date) %>% summarize(AverageGlucose=mean(GlucoseValue), MaximumGlucose=max(GlucoseValue), 
                                 MinimumGlucose=min(GlucoseValue)) %>%
    gather(key="Measurement", value="Glucose", -Date)
  
  gg <- ggplot(glucose, aes(x=Date, y=Glucose, group=Measurement, color=Measurement)) +
    geom_line() + 
    theme_bw() +
    theme(axis.text=element_text(size=16),
          legend.text=element_text(size=16),
          legend.title=element_text(size=18))
  
  tmp <- ggplot_gtable(ggplot_build(gg))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  gg_legend <- grid.draw(legend)
  
  return(gg_legend)
}