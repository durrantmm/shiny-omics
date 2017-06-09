require(readr)
require(tidyr)
require(dplyr)

microbiome.tax <- read_tsv("data/microbiome.tax")
microbiome.cts <- read_tsv("data/microbiome.cts")
microbiome_data <- microbiome.cts %>% 
  gather(key='TaxID', value='Count', -ID, -Site, -Time) %>% 
  inner_join(microbiome.tax) %>% select(-TaxID)

omicsData <- list(microbiome=microbiome_data)

# Get subsets of data
filter_microbiome_data_by_individual <- function(indiv_id){
  filter(hlpr.microbiome_data, ID=='ZOZOW1T') %>%
    select(-ID)
}
