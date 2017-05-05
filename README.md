# shiny-omics

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

