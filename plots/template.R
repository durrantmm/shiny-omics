require(vegan)

#################################################################
# Don't edit this file directly, copy it to create another file #
#################################################################


# First and foremost, you must change the prefix of the function to match the name of this file.
# If the name of the file was, for example, interestingPlot.R, then all the functions in this file must be named:
#
# interestingPlotControls()
# interestingPlotMainPlot()
# interestingPlotSidePlot()
#
# Make sure to keep the same function parameters listed below.


# The sidebar controls used to control the shiny app
templateControls <- function(ns, omicsData){
  
  tagList(
    # Select the participant
    # The third object needs to specify a vector of participant IDs for your dataset, usually accessed through
    # omicsData loaded by the omicsData.R script.
    selectInput(ns("participants"), "Choose Participant:", "object_containing_participants_data")
  )
  
}

# You need to change this function so it processes the input (controls specified by you)
# And the omicsData to produce the desired plot.
templateMainPlot <- function(input, omicsData){

    # Insert code here
    return(plot(1:10, 1:10)) # Change this to your new plot
}

# A side plot that can accompany the main plot above. This can be a good place to store
# The legend for your plat, which helps maintain consistent plot formatting.
# You can also create a plot here that contains text that is informative to the user.
templateSidePlot <- function(input, omicsData){

    # Insert code here
    # You can access the participant input varianble by typing
    # input$participant
    # You can add more inputs by following the pattern in the templateControls() function.

    return(plot(1:20, 1:20))
}

# Add other functions here to process the data as you see fit.
