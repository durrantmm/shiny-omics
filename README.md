# shiny-omics

`shiny-omics` is a platform to quickly build a shiny-based web app for visualization of longitudinal multi-omics data sets.
It's currently in development.


## Installing shiny-omics
As things currently stand, the platform is not ready to be hosted by a remote server. We suggest you just download it 
to your own computer, such as a Macbook, in order to get things started. You can clone the application to your local
computer from the command line using the command:

    git clone https://github.com/durrantmm/shiny-omics.git

## R dependencies
You need to have the following packages installed in R in order to run shiny-omics:

* `shiny`
* `plotly`
* `dplyr`
* `ggfortify`
* `grid`
* `lubridate`
* `vegan`
* `readr`
* `tidyr`

## Run Shiny
You can run the shiny app from the correct directory by running the command

    R -e "shiny::runApp('app.R')"

Which should give an output like:
    
    > shiny::runApp('app.R')
    Loading required package: shiny
    
    Listening on http://127.0.0.1:6004

You can then open up a web browser and put in the selected port listed, which in ou example is `http://127.0.0.1:6004`

## Example Walkthrough
This walkthrough will help you to create a new plot for the shiny-omics platform to visualize. Follow closely and you
should know all you need to incorporate your own data in the future.

### Load the dataset in `omicsData.R`
There is already some simulated data available in the data folder. This is data to visualize gut microbiome composition,
as well as continuous glucose monitoring data. The files given are

    microbiome.cts
    microbiome.tax
    glucose.tsv
    mtcars.tsv
    
For our walkthrough, we'll use the dummy dataset called `mtcars.tsv`. This is based on the standard R dataset of the same name.

Open the file `omicsData.R`. Around line 25, load the data by inserting the code

    mtc <- read_tsv('data/mtcars.tsv')

Then change the code block

    omicsData <- list(microbiome=microbiome_data, 
                      glucose=glucose_data #, your_data=your_data
                      )

So that it reads

    omicsData <- list(microbiome=microbiome_data, 
                      glucose=glucose_data,
                      mtc=mtc)

Your data should now be available when you create your plot.

### Create the plot

To create the plot, copy the template file located in the `plots/` directory to a new file named `mtcarsPCA.R`.

Open the file to edit it. First, we'll edit the function names. Change all of the functions so that rather than
beginning with the prefix `template`, they all begin with the prefix `mtcarsPCA`, like so:

    mtcarsControls
    mtcarsPCAMainPlot
    mtcarsPCASidePlot


Let's start with the `mtcarsPCAControls()` function.

#### Writing the `Controls() function`
 
Our dataset looks at two separate 'Car Dealerships', and all of the cars that they sell. Replace the line

    selectInput(ns("participants"), "Choose Participant:", "object_containing_participants_data")
    
With the line

    selectInput(ns("dealerships"), "Choose Car Dealership:", unique(omicsData$mtc$ID)),
   
This loads the IDs in omicsData$mtc$ID into the dropdown menu.

After this line, add a two new lines of code that look like

    selectInput(ns("color"), "Choose Characteristic to color by:", names(omicsData$mtc)[2:12]),
    selectInput(ns("size"), "Choose Characteristic to size points by:", names(omicsData$mtc)[2:12])
    

This adds a second and third dropdown menu that will allow us to choose the characteristic that we color in for our plot,
and the characteristic used to determine the point size.

The final function should look like this

    mtcarsPCAControls <- function(ns, omicsData){
      
      tagList(
        # Select the participant
        # The third object needs to specify a vector of participant IDs for your dataset, usually accessed through
        # omicsData loaded by the omicsData.R script.
        selectInput(ns("dealership"), "Choose Car Dealership:", unique(omicsData$mtc$ID)),
        selectInput(ns("color"), "Choose Characteristic to color by:", names(omicsData$mtc)[2:12]),
        selectInput(ns("size"), "Choose Characteristic to size points by:", names(omicsData$mtc)[2:12])
      )
      
    }


Now let's edit the `mtcarsPCAMainPlot()` function.


#### Writing the `MainPlot() function`

First, we want to filter our data so that we only have the data for the selected dealership.

At the top of the function, add the code
    
    # Insert code here
    dealer <- reactive({
      input$dealership
    })

This will allow us to use access the dealer variable to filter our data. 

We also want to be able to access the "color" and "size" variables selected from the drop down. Do this by adding the code

    point_color <- reactive({
      input$color
    })
    
    point_size <- reactive({
      input$size
    })
    
to the function.    

We can then filter the data by adding

    mtc <- filter(omicsData$mtc, ID==dealer()) %>% 
        select(-ID)
    
To our function. Next, we perform principal components analysis on our data, and extract the first and second principal
components. We do this by adding the following lines of code:

    pca <- select(as.data.frame(prcomp(mtc, center=TRUE, scale=TRUE)$x), PC1, PC2)
    mtc <- cbind(mtc, pca)
    
Our PCA data is now available to plot, and we can specify the color and size of the points using the available variable.

We will make a `ggplot` object with the following code:

    gg <- ggplot(mtc, aes_string(x='PC1', y='PC2', color=point_color(), size=point_size())) +
      geom_point() +
      theme_bw() +
      theme(legend.position='none', axis.text=element_text(size=16), 
            axis.title=element_text(size=18),
            axis.text.y=element_text(angle = 90, hjust=0.5))
            
This makes a plot that has been formatted properly, and it does NOT have a legend (this will go into the side plot)

and then returning the plot that we create at the end of the function with the code:

    return(gg)

In summary, you should have a function that looks like this:

    mtcarsPCAMainPlot <- function(input, omicsData){
    
        dealer <- reactive({
          input$dealership
        })
        
        point_color <- reactive({
          input$color
        })
        
        point_size <- reactive({
          input$size
        })
        
        mtc <- filter(omicsData$mtc, ID==dealer()) %>% 
          select(-ID)
        
        pca <- select(as.data.frame(prcomp(mtc, center=TRUE, scale=TRUE)$x), PC1, PC2)
        mtc <- cbind(mtc, pca)
        
        gg <- ggplot(mtc, aes_string(x='PC1', y='PC2', color=point_color(), size=point_size())) +
          geom_point() +
          theme_bw() +
          theme(legend.position='none', axis.text=element_text(size=16), 
                axis.title=element_text(size=18),
                axis.text.y=element_text(angle = 90, hjust=0.5))
        
        return(gg) 
    }      

Finally, we move on to the `mtcarsPCASidePlot()` function

#### Writing the `SidePlot() function`

This side plot can contain as much or as little as you want. You can have it do nothing at all by simply filling it
with the placeholder `return(1)`. In our case, we will be putting our figure legend in that position.

This will be really straight forward. We will actually just be filling it with most of the same code from the `MainPlot()`
function. Here is the code that you should add to the `mtcarsPCASidePlot()` function:

    dealer <- reactive({
          input$dealership
    })
    
    point_color <- reactive({
      input$color
    })
    
    point_size <- reactive({
      input$size
    })
    
    mtc <- filter(omicsData$mtc, ID==dealer()) %>% 
      select(-ID)
    
    pca <- select(as.data.frame(prcomp(mtc, center=TRUE, scale=TRUE)$x), PC1, PC2)
    mtc <- cbind(mtc, pca)

It's that same as we saw MainPlot function. Now, instead of making a `ggplot` object that excludes the legend, we will
only keep the legend and remove the plot itself. Here is the code that accomplishes this:

    gg <- ggplot(mtc, aes_string(x='PC1', y='PC2', color=point_color(), size=point_size())) +
        geom_point() +
        theme_bw() +
        theme(legend.text=element_text(size=12))
    
    tmp <- ggplot_gtable(ggplot_build(gg))
    leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
    legend <- tmp$grobs[[leg]]
    gg_legend <- grid.draw(legend)
  
    
Finally, let's return the `gg_legend` object from our function
 
    return(gg_legend) 


In summary, the final function should look like this:

    mtcarsPCASidePlot <- function(input, omicsData){
    
      dealer <- reactive({
        input$dealership
      })
      
      point_color <- reactive({
        input$color
      })
      
      point_size <- reactive({
        input$size
      })
      
      mtc <- filter(omicsData$mtc, ID==dealer()) %>% 
        select(-ID)
      
      pca <- select(as.data.frame(prcomp(mtc, center=TRUE, scale=TRUE)$x), PC1, PC2)
      mtc <- cbind(mtc, pca)
      
      
      gg <- ggplot(mtc, aes_string(x='PC1', y='PC2', color=point_color(), size=point_size())) +
        geom_point() +
        theme_bw() +
        theme(legend.text=element_text(size=12))
      
      tmp <- ggplot_gtable(ggplot_build(gg))
      leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
      legend <- tmp$grobs[[leg]]
      gg_legend <- grid.draw(legend)
      
      
      return(gg_legend)
    }

That's it! Now we just have to plug in this new plot into our function.

### Adding a new plot to the App
Open the file `choosePlot.R`. At the top of it you'll see a block of code that looks like this:

    choices = c(
      "Microbiome - Microbial Abundance" = "microbiomeAbundance",
      "Microbiome - Shannon Diversity" = "microbiomeShannon",
      "Microbiome - F/B Ratio" = "microbiomeFB",
      "Microbiome - Principal Components" = "microbiomePCA",
      "Glucose - Daily" = "glucoseDaily",
      "Glucose - Hourly" = "glucoseHourly",
      "Test Template" = "template"
    )

Add your new plot to the code, so that it looks like this:

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

It's very important that the second parameter `mtcarsPCA` match the prefix to specificy the file `mtcarsPCA.R` and the
prefix of the three functions in the `mtcarsPCA.R` script.

### Running the App

You should now be able to view your new plot in the App. You can do this by executing from the command line:

    R -e "shiny::runApp('app.R')"
    
And then going to the server port listed in a browser, such as Chrome.
 
That's everything, let me know if you have any questions or if you came across any errors.


## data folder
This is where you will keep your own data to be used by shiny-omics to produce the visualizations. 

### Microbiome Composition File Format
For the microbiome visualizations, you need two files: microbiome.tax and microbiome.cts.

#### microbiome.tax
Here is the required format of the microbiome.tax file:

| Kingdom  | Phylum         | Class       | Order         | Family          | Genus       | Species              |
|----------|----------------|-------------|---------------|-----------------|-------------|----------------------|
| Bacteria | NA             | NA          | NA            | NA              | NA          | NA                   |
| Bacteria | Bacteroidetes  | NA          | NA            | NA              | NA          | NA                   |
| Bacteria | Bacteroidetes  | Bacteroidia | NA            | NA              | NA          | NA                   |
| Bacteria | Bacteroidetes  | Bacteroidia | Bacteroidales | NA              | NA          | NA                   |
| Bacteria | Bacteroidetes  | Bacteroidia | Bacteroidales | Bacteroidaceae  | NA          | NA                   |
| Bacteria | Bacteroidetes  | Bacteroidia | Bacteroidales | Bacteroidaceae  | Bacteroides | NA                   |
| Bacteria | Bacteroidetes  | Bacteroidia | Bacteroidales | Bacteroidaceae  | Bacteroides | Bacteroides vulgatus |
| Bacteria | Proteobacteria | NA          | NA            | NA              | NA          | NA                   |
| ...      | ...            | ...         | ...           | ...             | ...         | ...                  |
| Bacteria | Firmicutes     | Clostridia  | Clostridiales | Lachnospiraceae | Roseburia   | Roseburia hominis    |

  * Each column value should be separated by tabs.
  * Each column corresponds to a level in the taxonomic tree. Header must be identical to shown above.
  * The order can be any order that you want, but it must match up with the microbiome.cts file (see below).
  * IMPORTANT: Note that the species column contains both the Genus and Species names, separated by a space.

#### microbiome.cts
Here is the required format of the microbiome.cts file:

| ID | Site | Time | 1    | 2   | 3   | ... | n   |
|----|------|------|------|-----|-----|-----|-----|
| P1 | Stool| 0    | 124  | 24  | 64  | ... | 543 |
| P1 | Stool| 1    | 982  | 523 | 3   | ... | 634 |
| P2 | Stool| 0    | 243  | 364 | 53  | ... | 26  |
| P2 | Stool| 1    | 345  | 24  | 634 | ... | 5   |
| P2 | Oral | 2    | 24   | 53  | 34  | ... | 53  |
| P3 | Stool| 0    | 996  | 253 | 57  | ... | 523 |
| P4 | Oral | 0    | 2243 | 780 | 523 | ... | 235 |
| P4 | Oral | 1    | 53   | 35  | 364 | ... | 64  |

  * Each column value should be separated by tabs.
  * ID: The first column contains the unique IDs of the study participant of interest.
  * Site: The second column indicates the site on the body where the microbiome was sampled.
  * Time: The third column indicates the longitudinal ordering of the samples, these can be dates or numbers, but not both.
  * 1...n: Columns labeled 1 through n contain taxonomical counts. Each column number corresponds to a specific row in the microbiome.tax file.
    * For example, the column labeled 1 contains the count 124 as its first entry. This indicates that the Sample labeled P1 - Stool - 0 contains 124 read counts that were assigned specifically at the level of Bacteroides.
    * IMPORTANT: This count corresponds to the reads that can ONLY be assigned at the level Bacteroides, and not lower. This is NOT an aggregate sum of all counts classified at the level of Bacteroides and lower. It is specifically only the number of counts classified at the level of Bacteroides.

