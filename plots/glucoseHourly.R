require(dplyr)
require(plotly)
require(ggfortify)
require(grid)
require(lubridate)


# The sidebar controls used to control the shiny app
glucoseHourlyControls <- function(ns, omicsData){
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
glucoseHourlyMainPlot <- function(input, omicsData){
  
  indiv_id <- reactive({
    input$participants
  })
  
  date <- reactive({
    input$date
  })
  
  glucose <- filter(omicsData$glucose, ID==indiv_id() & Date >= date()[1] & Date <= date()[2]) %>%
  #glucose <- filter(omicsData$glucose, ID=="7BA76585-ED07-4238-8F2B-43D34A9334D8" & Date >= as.Date("2015-06-01") & Date <= as.Date("2015-06-01")) %>%
    mutate(Date=as.POSIXct(format(as.POSIXct(paste(Date, Time)), format="%Y-%m-%d %H:00"))) %>%
    group_by(Date) %>% summarize(AverageGlucose=mean(GlucoseValue), MaximumGlucose=max(GlucoseValue), 
                                     MinimumGlucose=min(GlucoseValue)) %>%
    gather(key="Measurement", value="Glucose", -Date)
  
  min_time <- as.POSIXlt(min(glucose$Date))
  max_time <- as.POSIXlt(max(glucose$Date))
  
  min_time <- as.POSIXct(paste(year(min_time), month(min_time), day(min_time), sep='-'))
  max_time <- as.POSIXct(paste(year(max_time), month(max_time), day(max_time), sep='-')) + days(1)
  
  gg <- ggplot(glucose, aes(x=Date, y=Glucose, group=Measurement, color=Measurement)) +
    geom_line() + 
    theme_bw() +
    theme(legend.position='none', axis.text=element_text(size=16), 
          axis.title=element_text(size=18),
          axis.text.y=element_text(angle = 90, hjust=0.5)) +
    expand_limits(x=min_time, x=max_time)
  
  return(gg)
}

# This function takes the input from the siderbar
# and outputs a plot to be displayed.
glucoseHourlySidePlot <- function(input, omicsData){
  
  indiv_id <- reactive({
    input$participants
  })
  
  date <- reactive({
    input$date
  })
  
  glucose <- filter(omicsData$glucose, ID==indiv_id() & Date >= date()[1] & Date <= date()[2]) %>%
  #glucose <- filter(omicsData$glucose, ID=="7BA76585-ED07-4238-8F2B-43D34A9334D8") %>%
    mutate(DateTime=as.POSIXct(format(as.POSIXct(paste(Date, Time)), format="%Y-%m-%d %H:00"))) %>%
    group_by(DateTime) %>% summarize(AverageGlucose=mean(GlucoseValue), MaximumGlucose=max(GlucoseValue), 
                                     MinimumGlucose=min(GlucoseValue)) %>%
    gather(key="Measurement", value="Glucose", -DateTime)
  
  gg <- ggplot(glucose, aes(x=DateTime, y=Glucose, group=Measurement, color=Measurement)) +
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
