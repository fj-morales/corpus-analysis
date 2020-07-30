######## ---------- LOAD PACKAGES ----------------------------------------######
library("dplyr")
library("ggplot2")
library("tidyr")
library("scales") # for percentage graphs
options("scipen"= 100)

######## ---------- LOAD DATA --------------------------------------------######
#set firt letter to upper
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

#OPTION 1
######## ---------- PLOTS PER ANNOTATION ---------------------------------######
# only if value is larger than 0.5 we regard it as rhetorical move
annot_filtrwt <- sentence_annot %>%
  filter(prob_value >= 0.5)


#annotated sentences per section
sent <- sentence_annot %>%
  group_by(tool_id) %>%
  summarise(n_sentences = n_distinct(sentence_id))

#plot per tool per annotated sentence
annot_filtrwt %>%
  group_by(tool_id, annotation_label, sentence_label) %>%
  summarise(n = n())  %>%
  left_join(sent, by = c("tool_id")) %>%
  complete(annotation_label,sentence_label) %>% 
  ggplot(aes(x= annotation_label, y = n/n_sentences, fill = tool_id)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_grid(~tool_id, scales = "free_x", space = "free_x") + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        legend.position = "none") +
  labs(fill='Document section', x= "Annotation label", 
       y = "Percentage of sentences") +
  scale_y_continuous(labels = percent)


########  
#OPTION 2

#annotated sentences per section
sentall <- sentence_annot %>%
  summarise(n_sentences = n_distinct(sentence_id))

#plot per section for all sentences
annot_filtrwt %>%
  group_by(tool_id, annotation_label, sentence_label) %>%
  summarise(n = n())  %>%
  mutate(n_sentences = sentall$n_sentences) %>%
  complete(annotation_label,sentence_label) %>% 
  ggplot(aes(x= annotation_label, y = n/n_sentences, fill = tool_id)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_grid(~tool_id, scales = "free_x", space = "free_x") + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        legend.position = "none") +
  labs(fill='Document section', x= "Annotation label", 
       y = "Percentage of sentences") +
  scale_y_continuous(labels = percent)

#OPTION 3
######## ---------- PLOTS PER ANNOTATION ---------------------------------######
# select the max annotation for each sentence in RWT
annot_filtrwt <- sentence_annot %>%
  group_by(tool_id,sentence_id) %>%
  filter(prob_value == max(prob_value))

annot_filtrwt <- subset(annot_filtrwt, !(annotation_label %in% c("Anyauthor","Important","Important&Summary","Tempstat")))

#annotated sentences per section
sent <- sentence_annot %>%
  group_by(tool_id) %>%
  summarise(n_sentences = n_distinct(sentence_id))

#plot per section per annotated sentence
annot_filtrwt %>%
  group_by(tool_id, annotation_label, sentence_label) %>%
  summarise(n = n())  %>%
  left_join(sent, by = c("tool_id")) %>%
  complete(annotation_label,sentence_label) %>% 
  ggplot(aes(x= annotation_label, y = n/n_sentences, fill = tool_id)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_grid(~tool_id, scales = "free_x", space = "free_x") + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        legend.position = "none") +
  labs(fill='Document section', x= "Annotation label", 
       y = "Percentage of sentences") +
  scale_y_continuous(labels = percent)
