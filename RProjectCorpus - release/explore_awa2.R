######## ---------- LOAD DATA --------------------------------------------######
source("load_sql_db.R")

######## ---------- LOAD PACKAGES ----------------------------------------######
library("ggplot2")

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

#if you have the csv created in the write_ena_awa you can skip this step and do a load instead

######## ---------- ANALYZE PER ANNOTATION -------------------------------######
annot <- sentence_annot %>%
  group_by(tool_id, document_label, annotation_label) %>%
  summarise(n= n()) %>%
  group_by(tool_id, annotation_label) %>%
  summarize(sum = sum(n),
            n_docs = n(),
            mean = mean(n),
            sd = sd(n))


######## ---------- ANALYZE PER SECTION ----------------------------------######
# table of moves per section
section_annot <-  table(sentence_annot$annotation_label,
                        sentence_annot$sentence_label) 

# plot moves per section for every tool
plot_moves_per_tool <- function(filler, tool){
  sentence_annot %>%
    filter(tool_id == tool) %>%
    ggplot(aes_string("annotation_label", fill = filler)) +
    geom_bar(position="dodge")
}

# plot antMover moves per section
plot_moves_per_tool("sentence_label", 1)
# plot AWA moves per section
plot_moves_per_tool("sentence_label", 2)
# plot AWA3 moves per section
plot_moves_per_tool("sentence_label", 3)


ggplot(aes_string("annotation_label", fill = "sentence label")) +
  geom_bar(position = "dodge")



######## ---------- ANALYZE PER CATEGORY ---------------------------------######
# table of moves per section
category_annot <-  table(sentence_annot$annotation_label,
                         sentence_annot$document_category) 

# plot antMover moves per section
plot_moves_per_tool("document_category", 1)
# plot AWA moves per section
plot_moves_per_tool("document_category", 2)
# plot AWA3 moves per section
plot_moves_per_tool("document_category", 3)

######## ---------- ANALYZE PER DOCUMENT ---------------------------------######
document_annot <- sentence_annot %>%
  group_by(document_label, tool_id) %>%
  summarise(n_sentence = n())

doc_per_cat <- sentence_annot %>%
  group_by(tool_id, document_category) %>%
  summarise(n_docs = length(unique(document_label)))

doc_per_corpus <- sentence_annot %>%
  group_by(tool_id, corpus_label) %>%
  summarise(n_docs = length(unique(document_label)))
