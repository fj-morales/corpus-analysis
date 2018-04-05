######## ---------- LOAD DATA --------------------------------------------######
source("load_sql_awa.R")

######## ---------- LOAD PACKAGES ----------------------------------------######
library("tidyr")

######## ---------- OUTPUT DATA FOR ENA ----------------------------------######
# create output file
annot <- sentence %>% 
  # join datasets
  left_join(sentence_annotation, by = "sentence_id") %>%
  left_join(annotation, by = c("annotation_id", "tool_id")) %>%
  left_join(document, by = c("document_label", "corpus_id")) %>%
  left_join(corpus, by = "corpus_id") %>%
  # take only AntMover annotations
  filter(tool_id == 1) %>%
  # spread the annotations to binary columns for ENA
  mutate(yesno = 1) %>%
  spread(annotation_label, yesno, fill = 0) %>%
  group_by(sentence_id, document_label, sentence_label, sentence_detail,
           corpus_label, document_category) %>%
  summarise_at(vars(`1_claiming_centrality`:`9_announcing_present_research`), 
               sum) 

# write dataset
write.csv(annot, "ena_antmover_full.csv")