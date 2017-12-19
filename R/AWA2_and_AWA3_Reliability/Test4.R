library("RMySQL")
library("irr")
dbConnection <- dbConnect(MySQL(),
                          user="root", password="ineeduyes",
                          dbname="AWA", host="localhost")

sqlStatement <- paste0("select sentence_id from ",
                       "(select distinct sentence_id as 'sentence_id' from sentence_annotation where tool_id=2 ",
                       "and sentence_id in (select sentence_id from sentence where corpus_id=1) ",
                       "union ",
                       "select distinct sentence_id as 'sentence_id' from sentence_annotation where tool_id=3 ",
                       "and sentence_id in (select sentence_id from sentence where corpus_id=1) ",
                       ") AWA2_AWA3 ")

allAnnotatedSentence <- dbGetQuery(dbConnection,sqlStatement)

annotationLabelAWA2 <- "Trend"
annotationLabelAWA3 <- "AWA3_Trend"
comparisonTable <- data.frame("AWA2"=character(0),"AWA3"=character(0))


for(sentenceId in allAnnotatedSentence$sentence_id){
  sqlStatment <- paste0("select count(sa.sentence_id) as AWA2 from sentence_annotation sa, annotation an where sa.annotation_id=an.annotation_id ",
                        "and an.annotation_label='",annotationLabelAWA2,"' ",
                        "and sa.sentence_id=",sentenceId)
  resultAWA2 <- dbGetQuery(dbConnection,sqlStatment)
  
  sqlStatment <- paste0("select count(sa.sentence_id) as AWA3 from sentence_annotation sa, annotation an where sa.annotation_id=an.annotation_id ",
                        "and an.annotation_label='",annotationLabelAWA3,"' ",
                        "and sa.sentence_id=",sentenceId)
  resultAWA3 <- dbGetQuery(dbConnection,sqlStatment)
  if(resultAWA2$AWA2[1]!=0 || resultAWA3$AWA3[1]!=0){
    comparisonTable <- rbind(comparisonTable,cbind("AWA2" = resultAWA2$AWA2[1],"AWA3" = resultAWA3$AWA3[1]))
  }
}

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