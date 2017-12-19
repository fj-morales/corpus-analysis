library("RMySQL")
library("irr")
dbConnection <- dbConnect(MySQL(),
                          user="root", password="ineeduyes",
                          dbname="AWA", host="localhost")

sqlStatement <- paste0("select AWA3.sentence_id from ",
                       "(select distinct sentence_id as 'sentence_id' from sentence_annotation where tool_id=2 ",
                       "and sentence_id in (select sentence_id from sentence where corpus_id=1) ",
                       ") AWA2, ",
                       "(select distinct sentence_id as 'sentence_id' from sentence_annotation where tool_id=3 ",
                       "and sentence_id in (select sentence_id from sentence where corpus_id=1) ",
                       ") AWA3 ",
                       "where AWA2.sentence_id = AWA3.sentence_id")

allAnnotatedSentence <- dbGetQuery(dbConnection,sqlStatement)

allAnnotations <- c("Important","Summary","Important&Summary","Background","Contrast","Emphasis","Novelty","Position","Question","Surprise","Trend")
subCategories <- c("Background","Contrast","Emphasis","Novelty","Position","Question","Surprise","Trend")
mainCategories <- c("Important","Summary","Important&Summary")

comparisonTable <- data.frame("AWA2"=character(0),"AWA3"=character(0))
dataAWA2 <- ""
dataAWA3 <- ""

for(sentenceId in allAnnotatedSentence$sentence_id){
  for(annotationLabel in subCategories){
    sqlStatment <- paste0("select an.annotation_label as AWA2 from sentence_annotation sa, annotation an where sa.annotation_id=an.annotation_id ",
                          "and an.annotation_label='",annotationLabel,"' ",
                          "and sa.sentence_id=",sentenceId)
    resultAWA2 <- dbGetQuery(dbConnection,sqlStatment)
    if(nrow(resultAWA2)==0){
      dataAWA2 <- "empty"
    }else{
      dataAWA2 <- resultAWA2$AWA2[1]
    }
    
    
    sqlStatment <- paste0("select substr(an.annotation_label,6) as AWA3 from sentence_annotation sa, annotation an where sa.annotation_id=an.annotation_id ",
                          "and an.annotation_label='AWA3_",annotationLabel,"' ",
                          "and sa.sentence_id=",sentenceId)
    resultAWA3 <- dbGetQuery(dbConnection,sqlStatment)
    if(nrow(resultAWA3)==0){
      dataAWA3 <- "empty"
    }else{
      dataAWA3 <- resultAWA3$AWA3[1]
    }
    
    if(nrow(resultAWA2)!=0 || nrow(resultAWA3)!=0){
      comparisonTable <- rbind(comparisonTable,cbind("AWA2" = dataAWA2,"AWA3" = dataAWA3))
    }
  }
}

summarytable <-table(comparisonTable)

#percentage of agreement
agree(comparisonTable)

#Cohen kappa to test the agreement
kappa2(comparisonTable)

#convert the resultSet output to matrix 2 X n (n is the total number of sentences)
resultSetMatrix <- c(comparisonTable$AWA2)
resultSetMatrix <- rbind(resultSetMatrix,c(comparisonTable$AWA3))

#Krippendorf’s alpha to test the disagreement
#between AntMover and AWA in sentence annotation
kripp.alpha(resultSetMatrix,'nominal')

on.exit(dbDisconnect(dbConnection))
rm(list=ls())