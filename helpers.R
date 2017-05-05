library(readr)
library(vegan)
library(tidyr)
library(ggfortify)


setwd("/Users/mdurrant/OneDrive/Stanford/SnyderLab/Shiny/microbiome")

# Main Microbiome Data
hlpr.microbiome_data <- read_tsv("data/processed2.tsv")
hlpr.microbiome_data$Stage <- as.factor(hlpr.microbiome_data$Stage)


# Individual IDs
hlpr.individual_ids <- unique(hlpr.microbiome_data$SAMPLE_ID)


# Taxonomy
hlpr.taxonomy_levels <- c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species")
hlpr.selected_taxonomy <- hlpr.taxonomy_levels[2]


# Get subsets of data
filter_microbiome_data_by_individual <- function(indiv_id){
  filter(hlpr.microbiome_data, SAMPLE_ID==indiv_id) %>%
    select(-SAMPLE_ID)
}

filter_microbiome_data_by_individual("ZL63I8R")

hlpr.relative_proportions_all_average <- function(taxon_level){
  
  data.f <- hlpr.microbiome_data 
  
  data.f <- data.f %>% filter_(paste( "!is.na(", taxon_level, ")" )) %>%
    group_by_("SAMPLE_ID", "Stage", taxon_level) %>%
    summarize(proportion=sum(proportion)) %>%
    group_by() %>%
    select_('SAMPLE_ID', 'Stage', taxon_level, 'proportion')
  
  data.f <- data.f %>% 
    left_join(data.f %>% group_by(SAMPLE_ID, Stage) %>% dplyr::summarize(TOTAL=sum(proportion))) %>%
    rowwise() %>%
    mutate(proportion=proportion/TOTAL) %>%
    select(-TOTAL) %>%
    group_by_(taxon_level) %>%
    dplyr::summarize(proportion=mean(proportion))
  
  data.f <- data.f %>% mutate(Stage="Comparison") %>% select_("Stage", taxon_level, "proportion")
  
  return(data.frame(data.f))
}

hlpr.relative_proportions_all_average('Phylum')

# Get relative props data
hlpr.get_relative_proportions_data <- function(indiv_id, taxon_level, display_n_taxa){
  data.f <- filter_microbiome_data_by_individual(indiv_id)
  
  data.f <- data.f %>% filter_(paste( "!is.na(", taxon_level, ")")) %>%
    group_by_("Stage", taxon_level) %>%
    summarize(proportion=sum(proportion)) %>%
    select_('Stage', taxon_level, 'proportion')
  
  data.f$proportion <- as.numeric(data.f$proportion)
  data.f <- rbind(hlpr.relative_proportions_all_average(taxon_level), data.frame(data.f))
  data.frame(data.f)
  data.f <- data.f %>% left_join(data.f %>% group_by(Stage) %>% dplyr::summarize(TOTAL=sum(proportion))) %>%
    rowwise() %>%
    mutate(RelativeAbundance=proportion/TOTAL) %>% 
    arrange(desc(RelativeAbundance))
  
  
  keep_taxa <- unique( ( data.f[, c(taxon_level, 'RelativeAbundance')] %>% arrange_("desc(RelativeAbundance)") )[[taxon_level]])[1:display_n_taxa]
  
  data.f[[taxon_level]] <- ifelse(data.f[[taxon_level]] %in% keep_taxa, data.f[[taxon_level]], 'Other')
  data.f[[taxon_level]] <- factor(as.character(data.f[[taxon_level]]), levels=unique(data.f[[taxon_level]]))
  
  data.f <- data.f %>%
    group_by_('Stage', taxon_level) %>%
    dplyr::summarize(RelativeAbundance=sum(RelativeAbundance)) %>%
    group_by()

  return(data.f)
}

hlpr.get_relative_proportions_data("ZL63I8R", "Phylum", 4)

# Get diversity data
hlpr.analyze_diversity_all <- function(){
  species.mat <- hlpr.microbiome_data %>% filter(!is.na(Species), is.na(Subspecies)) %>%
    select(SAMPLE_ID, Stage, Species, proportion) %>%
    group_by(SAMPLE_ID, Stage, Species) %>%
    summarize(proportion=sum(proportion)) %>%
    spread(key=Species, value=proportion, fill=0) %>%
    group_by() %>%
    select(-SAMPLE_ID, -Stage)
  
  all_diversity <- as.vector(diversity(species.mat))
  mean_diversity <- mean(all_diversity)
  low <- mean_diversity - 1.96*sd(all_diversity)
  high <- mean_diversity + 1.96*sd(all_diversity)
  
  return( list(mean=mean_diversity, conf.low=low, conf.high=high) )
}


all_diversity_metrics <- hlpr.analyze_diversity_all()


hlpr.get_species_diversity_data <- function(indiv_id){
  data.f <- filter_microbiome_data_by_individual(indiv_id)
  
  stages <- unique(as.vector(data.f$Stage))
  
  species.mat <-  data.f %>% filter(!is.na(Species), is.na(Subspecies)) %>%
    select(Stage, Species, proportion) %>%
    group_by(Stage, Species) %>%
    summarize(proportion=sum(proportion)) %>%
    spread(key=Species, value=proportion, fill=0) %>%
    group_by() %>%
    select(-Stage)
  
  species.divers <- as.vector(diversity(species.mat))
  
  data.frame(Stage=as.factor(stages), ShannonDiversity=species.divers)
}

hlpr.get_species_diversity_data("ZL63I8R")

# Get Bacteroidetes-Firmicutes data table
hlpr.get_bac_firm_data <- function(indiv_id){
  data.f <- filter_microbiome_data_by_individual(indiv_id) %>% select(Stage, Phylum, Class, proportion)
  data.f <- filter(data.f, (Phylum=="Bacteroidetes" | Phylum=="Firmicutes")) %>% group_by(Stage, Phylum) %>% summarize(proportion=sum(proportion))
  data.f <- data.f %>% spread(key=Phylum, value=proportion) %>% mutate(`F/B Ratio` = Firmicutes/Bacteroidetes)  
  data.f$Stage <- as.factor(data.f$Stage)
  return(data.f)
}

hlpr.get_bac_firm_data("ZL63I8R")

# Principle components 
hlpr.get_pca_data <- function(){
  data.f <- hlpr.microbiome_data %>% 
    filter(!is.na(Phylum)) %>%
    group_by(SAMPLE_ID, Stage, Phylum) %>% 
    summarize(proportion=sum(proportion)) %>%
    group_by() %>%
    select(SAMPLE_ID, Stage, Phylum, proportion)
  
  totals <- data.f %>% 
    group_by(SAMPLE_ID, Stage) %>%
    dplyr::summarize(total=sum(proportion))
  
  data.f <- inner_join(data.f, totals) %>%
    mutate(proportion = proportion / total) %>%
    select(SAMPLE_ID, Stage, Phylum, proportion)
  
  data.f <- spread(data.f, key=Phylum, value=proportion, fill=0) 
  
  data.m <- as.matrix(data.f %>% group_by() %>% select(-SAMPLE_ID, -Stage))
  
  data.m.pca <- prcomp(data.m,
                       center=TRUE,
                       scale=TRUE)
  
  return(list(pca=data.m.pca, data=group_by(data.f)))
}

pca_data <- hlpr.get_pca_data()
