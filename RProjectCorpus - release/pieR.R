library(ggforce)
library(stringr)   # to split strings
library(tidyverse) # to unnest lists of numbers
library(ggplot2)   # for graphs
library(dplyr)     # for pretty code
#AcaWriter + Mover 
mat <- read.csv("data/AWA3_AntMover.csv", stringsAsFactors = F, row.names = 1)
#Acawriter + RWT
mat <- read.csv("data/AWA3_RWT_Intro_v2.csv", stringsAsFactors = F, row.names = 1)
#AWA + AcaWriter
mat <- read.csv("data/AWA3_RWT_Disc.csv", stringsAsFactors = F, row.names = 1)


mat <- as.matrix(mat)
'%notin%' <- Negate('%in%')

###########
#for comparisons excluding AWA3/AWA
mat %>%
  # Convert matrix to a data frame
  as.table() %>%
  as.data.frame() %>%
  # Extract/parse numbers from strings (e.g. "1,2,3")
  mutate(Freq = str_split(Freq,"#")) %>%
  unnest(Freq) %>%
  mutate(Freq = as.integer(Freq)) %>%
  # Convert the values to a percentage (which adds up to 1 for each graph)
  group_by(Var1, Var2) %>%
  mutate(Freq = ifelse(is.na(Freq), NA, Freq / sum(Freq)),
         color = row_number()) %>%
  ungroup() %>%
  # Plot
  ggplot(aes("", Freq, fill=factor(color))) + 
  geom_bar(width = 1, stat = "identity") +
  coord_polar("y") +       # Make it a pie chart
  #Orignially facet_grid was facet_wrap, I don't think for any benefit 
  #facet_wrap_paginate(
  #~Var1+Var2,
  facet_grid_paginate(
    Var1 ~ Var2, 
    #strip.position = "right",
    #strip.text.y = element_blank(),
    ncol=ncol(mat), 
    nrow=3, 
    page=1) + # Break it down into 9 charts
  # Below is aesthetics
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    #        strip.background = element_blank(), 
    #       strip.text = element_blank(), #removes the repeating labels for each pie, these need re-adding on the bottom/left
    axis.title = element_blank()) +
  guides(fill = FALSE)


#######################
####For the AWA3 AWA comparison we need to remove 'not annotated by either' because it swamps out everything else
#####################
mat <- read.csv("C:/Users/125295_admin/Oxygen Enterprise/Teaching student data/OpenCorpora/AWA3_AWA.csv", stringsAsFactors = F, row.names = 1)
mat <- as.matrix(mat)

mat %>%
  # Convert matrix to a data frame
  as.table() %>%
  as.data.frame() %>%
  # Extract/parse numbers from strings (e.g. "1,2,3")
  mutate(Freq = str_split(Freq,"#")) %>%
  #.$Freq <- lapply(.$Freq, function(this) this <- this[1:3]) doesn't work
  mutate(Freq = lapply(Freq, function(annotated) annotated[1:3])) %>% 
  
  unnest(Freq) %>%
  mutate(Freq = as.integer(Freq)) %>%
  # Convert the values to a percentage (which adds up to 1 for each graph)
  group_by(Var1, Var2) %>%
  mutate(Freq = ifelse(is.na(Freq), NA, Freq / sum(Freq)),
         color = row_number()) %>%
  ungroup() %>%
  # Plot
  ggplot(aes("", Freq, fill=factor(color))) + 
  geom_bar(width = 1, stat = "identity") +
  coord_polar("y") +       # Make it a pie chart
  facet_grid_paginate(Var1 ~ Var2,
                      ncol = ncol(mat),
                      nrow = nrow(mat),
                      page = 1) +
  #facet_wrap_paginate(~Var1+Var2, ncol=ncol(mat), nrow=3, page=2) + # Break it down into 9 charts
  # Below is just aesthetics
  xlab("") +
  ylab("") +
  theme(#axis.title.x = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    text = element_text(size = 7),
    axis.title = element_blank()) +
  guides(fill = FALSE)
