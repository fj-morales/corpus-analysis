######## ---------- LOAD PACKAGES ----------------------------------------######
library("dplyr")
library("ggplot2")
library("tidyr")
library("scales") # for percentage graphs
options("scipen"= 100)

######## ---------- LOAD DATA --------------------------------------------######
#set first letter to upper
firstup <- function(x) {
  substr(x, 1, 1) <- toupper(substr(x, 1, 1))
  x
}

# load data and make annotation labels and toolnames nice
sentence_annot <- read.csv("data/sentence_annot.csv", 
                           stringsAsFactors = FALSE) %>%
  mutate(tool_id = factor(tool_id, 
                          labels = c("AntMover", "AWA", "AWA3", "RWT"))) %>%
  mutate(annotation_label = gsub("AWA3_", "", annotation_label),
         annotation_label = gsub(pattern = ".*_m\\d_", "", annotation_label),
         annotation_label = gsub(pattern = "\\d+_", "", annotation_label),
         annotation_label = gsub("_", " ", annotation_label),
         annotation_label = firstup(annotation_label),
         sentence_label = firstup(sentence_label),
         corpus_id = factor(corpus_id),
         corpus_label = factor(corpus_label),
         sentence_label = factor(sentence_label, 
                                 levels = c("Abstract", "Introduction", 
                                            "Background", "Method", 
                                            "Discussion", "Conclusion")),
         discipline = ifelse(
           document_category %in% 
             c("History", "Linguistics", "Philosophy", "Publishing", "Classics", 
               "English", "Ethics", "Architecture"), "Humanities", 
           ifelse(document_category %in% 
                    c("Anthropology", "Economics", "Politics", "Psychology", "Society", 
                      "Sociology", "Comparative_American_Studies", "Law", "Business", 
                      "Hospitality_Leisure_Tourism_Management", "AgeingSociety", 
                      "EducationCounseling", "Planning"), "Social Sciences",
                  ifelse(document_category %in% 
                           c("Biology", "Biological_Sciences", "Chemistry", "Earth Science",
                             "Environment", "Astronomy", "Agriculture", "AgricultureSystem",
                             "Physics", "Meteorology", "Neuroscience", "Archaeology", 
                             "WaterResource"), "Natural Sciences",
                         ifelse(document_category %in% 
                                  c("Computer Science", "Computer_Science", "Mathematics"),
                                "Formal Sciences", 
                                ifelse(document_category %in% 
                                         c("Cybernetics_Electronic_Engineering", 
                                           "Engineering", "Medicine", "Health", "Radiology",
                                           "Veterinary", "Food_Sciences", "Nutrition",
                                           "InfectiousDisease", "Materials Science",
                                           "Acupunture"), "Applied Sciences", 
                                       "other")
                         )
                  )
           )
         ), 
         discipline = factor(discipline, 
                                 levels = c("Humanities", "Social Sciences", 
                                            "Natural Sciences", "Formal Sciences", 
                                            "Applied Sciences", "other")),
         discipline2 = ifelse(discipline %in% c("Social Sciences", "Humanities"),
                                 "HASS", 
                                 ifelse(discipline %in% 
                                          c("Natural Sciences", "Formal Sciences",
                                            "Applied Sciences"), "STEM", "other")))

write.csv(sentence_annot, "data/sentence_annot_nicelabs.csv", row.names = FALSE)

######## ---------- DESCRIPTIVES -----------------------------------------######
#number of documents
length(unique(sentence_annot$document_label))
#number of sentences
length(unique(sentence_annot$sentence_id))
#number of disciplines
length(unique(sentence_annot$document_category))
#number of sections
length(unique(sentence_annot$sentence_label))

#descriptives corpus
annot_per_corpus <- sentence_annot %>%
  group_by(corpus_label, document_label) %>%
  summarise(n_sent = n_distinct(sentence_id)) %>%
  group_by(corpus_label) %>%
  summarize(n_docs = n(),
            n_sentences = sum(n_sent),
            mean_per_doc = mean(n_sent),
            sd_per_doc = sd(n_sent)
            )


#descriptives corpus by tool
annot_per_corpus_tool <- sentence_annot %>%
  group_by(corpus_label, document_label, tool_id) %>%
  summarise(n_sent = n_distinct(sentence_id)) %>%
  group_by(corpus_label, tool_id) %>%
  summarize(n_docs = n(),
            n_sentences = sum(n_sent),
            mean_per_doc = mean(n_sent),
            sd_per_doc = sd(n_sent)
  )



#docs per section
annot_per_corpus_section <- sentence_annot %>%
  group_by(sentence_label, corpus_label ) %>%
  summarise(n = n_distinct(sentence_id)/n_distinct(document_label)) %>%
  spread(corpus_label, n, fill = 0)

#docs per discipline
annot_per_corpus_discipline <- sentence_annot %>%
  group_by(discipline, corpus_label) %>%
  summarise(n = n_distinct(document_label)) %>%
  spread(corpus_label, n, fill = 0)


######## ---------- PLOTS PER ANNOTATION ---------------------------------######
# only if value is larger than 0.5 we regard it as rhetorical move
annot_filtrwt <- sentence_annot %>%
  filter(prob_value >= 0.5)

#sentences per corpus
corp <- sentence_annot %>%
  group_by(tool_id, corpus_label ) %>%
  summarise(n_sentences = n_distinct(sentence_id))

#plot per corpus #percentage per tool per corpus
annot_filtrwt %>%
  group_by(tool_id, annotation_label, corpus_label) %>%
  summarise(n = n())  %>%
  left_join(corp, by = c("tool_id", "corpus_label")) %>%
  complete(annotation_label,corpus_label) %>% 
  ggplot(aes(x= annotation_label, y = n/n_sentences, fill = corpus_label)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_grid(~tool_id, scales = "free_x", space = "free_x") + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(fill='Corpus', x= "Annotation label", y = "Percentage of sentences") +
  scale_y_continuous(labels = percent)


#plot per tool
annot_filtrwt %>%
  group_by(tool_id, annotation_label) %>%
  summarise(n = n())  %>%
  left_join(corp, by = c("tool_id")) %>%
  complete(annotation_label) %>% 
  ggplot(aes(x= annotation_label, y = n/n_sentences, fill = tool_id)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_grid(~tool_id, scales = "free_x", space = "free_x") + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(fill='Tool', x= "Annotation label", y = "Percentage of sentences") +
  scale_y_continuous(labels = percent)

#####plot sentences annotated by tool, and a modification to remove RWT discussion tags, and fix the %
'%notin%' <- Negate('%in%')
annot_filtrwt2 <- subset(annot_filtrwt, annotation_label %notin%
                           c("Reestablishing territory", "Framing principal findings", "Reshaping the territory", "Establishing additional territory", ""))
#and let's rename AWA3
annot_filtrwt2$tool_id <- recode(annot_filtrwt2$tool_id, AWA3 = "AcaWriter")


#lets also remove all sections except intro
annot_filtrwt2 <- subset(annot_filtrwt2, sentence_label %notin% c("Method","Discussion","Conclusion"))

sent2 <- annot_filtrwt2 %>%
  group_by(tool_id ) %>%
  summarise(n_sentences = n_distinct(sentence_id))

#sentences by corpus and tool
sent_bytool_bycorpus <- annot_filtrwt2 %>%
  group_by(tool_id, corpus_label) %>%
  summarise(n_sentences = n_distinct(sentence_id))

#only the subset of sentences for which each tool was run
x <- as.data.frame.matrix(table(annot_filtrwt2$sentence_id, annot_filtrwt2$tool_id))
x$n_tools <- as.matrix(apply(x, 1, function(y) length(which(y==0))))
x <- cbind(x, rownames(x))
colnames(x)[6] <- "sentence_id"

sent_bytool_bycorpus_allrun <- x %>%
  merge(annot_filtrwt2,x, by.x="sentence_id", by.y="sentence_id") %>%
  subset(n_tools == 0) %>%  #n_tools counts the number of tools for which no annotation was recorded. So we want n_tools = 0, i.e., 0 tools recorded no annotations
  group_by(tool_id, corpus_label) %>%
  summarise(n_sentences = n_distinct(sentence_id))

#get a summary of 'labelled' vs not by tool and corpus
sent_bytool_bycorpus_run <- annot_filtrwt2 %>%
  group_by(tool_id, corpus_label) %>%
  summarise(n_sentences = n_distinct(sentence_id))

#add rows to that showing for each tool/corpus the n of sentences not analysed, and a column labelling those rows and the labelled rows. That can then be plotted using ggplot
#per something like this: ggplot(data, aes(fill=condition, y=value, x=tool_id)) +   geom_bar(position="stack", stat="identity")  + facet_grid(~ corpus_id)
#however, what's perhaps more interesting is the overlap of the sentences labelled
#so for simplicity, I'm just going to stick to the above ^^

########################################################
######################################################
#plot moves by % sentences in corpus for each tool
annot_filtrwt2 %>%
  group_by(tool_id, annotation_label, sentence_label) %>%
  summarise(n = n())  %>%
  left_join(sent2, by = c("tool_id")) %>%
  complete(annotation_label,sentence_label) %>% 
  ggplot(aes(x= annotation_label, y = n/n_sentences, fill = tool_id)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_grid(~tool_id, scales = "free_x", space = "free_x") + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        legend.position = "none") +
  labs(fill='Document section', x= "Annotation label", 
       y = "Percentage of sentences") +
  scale_y_continuous(labels = percent)

#sentences per section
sent <- sentence_annot %>%
  group_by(tool_id, sentence_label ) %>%
  summarise(n_sentences = n_distinct(sentence_id))

#plot per section (change position to 'dodge' if preferred)
annot_filtrwt %>%
  group_by(tool_id, annotation_label, sentence_label) %>%
  summarise(n = n())  %>%
  left_join(sent, by = c("tool_id", "sentence_label")) %>%
  complete(annotation_label,sentence_label) %>% 
  ggplot(aes(x= annotation_label, y = n/n_sentences, fill = sentence_label)) +
  geom_bar(stat = "identity", position = "stack") +
  facet_grid(~tool_id, scales = "free_x", space = "free_x") + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(fill='Document section', x= "Annotation label", 
       y = "Percentage of sentences") +
  scale_y_continuous(labels = percent)

#plot per tool/section
annot_filtrwt %>%
  group_by(tool_id, annotation_label, sentence_label) %>%
  summarise(n = n())  %>%
  left_join(sent, by = c("tool_id", "sentence_label")) %>%
  complete(annotation_label,sentence_label) %>% 
  ggplot(aes(x= annotation_label, y = n/n_sentences, fill = tool_id)) +
  geom_bar(stat = "identity", position = "stack") +
  facet_grid(~sentence_label, scales = "free_x", space = "free_x") + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(fill='Tool', x= "Annotation label", 
       y = "Percentage of sentences") +
  scale_y_continuous(labels = percent)


#sentences per discipline
disc <- sentence_annot %>%
  group_by(tool_id, discipline ) %>%
  summarise(n_sentences = n_distinct(sentence_id))

#plot per corpus #percentage per tool per corpus
annot_filtrwt %>%
  group_by(tool_id, annotation_label, discipline) %>%
  summarise(n = n())  %>%
  left_join(disc, by = c("tool_id", "discipline")) %>%
  complete(annotation_label,discipline) %>% 
  ggplot(aes(x= annotation_label, y = n/n_sentences, fill = discipline)) +
  geom_bar(stat = "identity", position = "stack") +
  facet_grid(~tool_id, scales = "free_x", space = "free_x") + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(fill='Discipline', x= "Annotation label", y = "Percentage of sentences") +
  scale_y_continuous(labels = percent)




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

doc_per_section_per_corpus <- ena_antmover %>% 
  group_by(corpus_label, sentence_label) %>% 
  summarise(length(unique(document_label)))
