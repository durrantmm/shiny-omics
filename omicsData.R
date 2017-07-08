require(readr)
require(tidyr)
require(dplyr)

########################################################################################################################
# EDIT THIS FILE
# You can edit this file to include your own data sets of interest.
# I strongly suggest you store these data sets in the data folder.
# You need to make sure your data is included in the omicsData object at the end of the script.
########################################################################################################################

# Microbiome Data
microbiome.tax <- read_tsv("data/microbiome.tax")
microbiome.cts <- read_tsv("data/microbiome.cts")
microbiome_data <- microbiome.cts %>% 
  gather(key='TaxID', value='Count', -ID, -Site, -Time) %>% 
  inner_join(microbiome.tax) %>% select(-TaxID)

# Continuous Glucose Data
glucose_data <- read_tsv("data/glucose.tsv")
glucose_data$Date <- as.Date(glucose_data$Date)

# Load and process your data here to make sure it is formatted properly for your plots
# your_data <- read_tsv("data/your_data.tsv")
mtc <- read_tsv('data/mtcars.tsv')

# Combine all data as single object
# YOU MUST ADD YOUR DATA AT THIS POINT.
omicsData <- list(microbiome=microbiome_data, 
                  glucose=glucose_data, #, your_data=your_data)
                  mtc=mtc)
