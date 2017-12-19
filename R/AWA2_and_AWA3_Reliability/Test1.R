#Open DB connection
library("RMySQL")
dbConnection <- dbConnect(MySQL(),
                          user="root", password="ineeduyes",
                          dbname="AWA", host="localhost")

sqlStatement <- "SELECT sentence_id FROM sentence WHERE corpus_id=1"
corpusSentences <- dbGetQuery(dbConnection,sqlStatement)
resultTable <- cbind("AWA3"="","AWA2"="")

annotationList <- c("Background","Contrast","Emphasis","Novelty","Position","Question","Surprise","Trend")

for(sentence in corpusSentences$sentence_id){
  for(annotationLabel in annotationList){
    sqlStatementAWA2 <- paste0("select an.annotation_label as 'AWA2' from sentence_annotation sa, annotation an where sa.annotation_id=an.annotation_id and an.annotation_label='",annotationLabel,"' and sa.sentence_id=",sentence," LIMIT 1")
    resultAWA2 <- dbGetQuery(dbConnection,sqlStatementAWA2)
    if(nrow(resultAWA2)==0){
      resultAWA2 <- cbind("AWA2"="no_annotation")
    }
    
    sqlStatementAWA3 <- paste0("select substr(an.annotation_label,6) as 'AWA3' from sentence_annotation sa, annotation an where sa.annotation_id=an.annotation_id and an.annotation_label='AWA3_", annotationLabel ,"' and sa.sentence_id=",sentence, " LIMIT 1")
    resultAWA3 <- dbGetQuery(dbConnection,sqlStatementAWA3)
    if(nrow(resultAWA3)==0){
      resultAWA3 <- cbind("AWA3"="no_annotation")
    }
    
    if(resultAWA2!="no_annotation" || resultAWA3!="no_annotation"){
      resultTable<-rbind(resultTable,cbind(resultAWA3,resultAWA2))
    }
  }
}

copyResultSet <- resultTable[-1,]

library(irr)
#percentage of agreement
agree(copyResultSet)

#Cohen kappa to test the agreement
kappa2(copyResultSet,"unweighted")

on.exit(dbDisconnect(dbConnection))
rm(list=ls())