######## ---------- LOAD PACKAGES ----------------------------------------######
library("dplyr")

######## ---------- LOAD DATA --------------------------------------------######
source("load_sql_db.R")

######## ---------- JOIN DATASETS ----------------------------------------######
sentence_annot <- sentence %>% 
  left_join(sentence_annotation, by = "sentence_id") %>%
  left_join(annotation, by = c("annotation_id", "tool_id")) %>%
  left_join(document, by = c("document_label", "corpus_id")) %>%
  left_join(corpus, by = "corpus_id") %>%
  mutate(sentence_label = factor(sentence_label, 
                                 levels = c("abstract", "introduction", 
                                            "background", "method", 
                                            "discussion", "conclusion")))

######## ---------- WRITE TO CSV -----------------------------------------######
write.csv(sentence_annot, "data/sentence_annot.csv", row.names = FALSE)
