# shiny-omics

## data folder
This is where you will keep your own data to be used by shiny-omics to produce the visualizations. 

### Microbiome Composition File Format
For the microbiome visualizations, you need two files: microbiome.tax and microbiome.cts.


#### microbiome.tax
Here is the required format of the microbiome.tax file:

1| Kingdom  | Phylum         | Class       | Order         | Family          | Genus       | Species              |
|----------|----------------|-------------|---------------|-----------------|-------------|----------------------|
2| Bacteria | NA             | NA          | NA            | NA              | NA          | NA                   |
3| Bacteria | Bacteroidetes  | NA          | NA            | NA              | NA          | NA                   |
4| Bacteria | Bacteroidetes  | Bacteroidia | NA            | NA              | NA          | NA                   |
5| Bacteria | Bacteroidetes  | Bacteroidia | Bacteroidales | NA              | NA          | NA                   |
6| Bacteria | Bacteroidetes  | Bacteroidia | Bacteroidales | Bacteroidaceae  | NA          | NA                   |
7| Bacteria | Bacteroidetes  | Bacteroidia | Bacteroidales | Bacteroidaceae  | Bacteroides | NA                   |
8| Bacteria | Bacteroidetes  | Bacteroidia | Bacteroidales | Bacteroidaceae  | Bacteroides | Bacteroides vulgatus |
9| Bacteria | Proteobacteria | NA          | NA            | NA              | NA          | NA                   |
10| ...      | ...            | ...         | ...           | ...             | ...         | ...                  |
11| Bacteria | Firmicutes     | Clostridia  | Clostridiales | Lachnospiraceae | Roseburia   | Roseburia hominis    |

Each column value should be separated by tabs.
Each column corresponds to the level in the taxonomic tree. Header must be identical to shown above.
The order can be any order that you want, but it must match up with the microbiome.cts file.

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

ID: The first column contains the unique IDs of the study participant of interest.
Site: The second column indicates the site on the body where the microbiome was sampled.
Time: The second column indicates the longitudinal ordering of the samples, these can be dates or numbers, but not both.
1...n: Columns labeled 1 through n contain taxonomical counts. Each number