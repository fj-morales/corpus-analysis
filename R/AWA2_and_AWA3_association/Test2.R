#Open DB connection
library("RMySQL")
library("corrplot")
dbConnection <- dbConnect(MySQL(),
                          user="root", password="ineeduyes",
                          dbname="AWA", host="localhost")

sqlStatement <- "SELECT sentence_id FROM sentence WHERE corpus_id=1"
corpusSentences <- dbGetQuery(dbConnection,sqlStatement)
resultTable <- cbind("AWA2"="","AWA3"="")

annotationList <- c("Background","Contrast","Emphasis","Novelty","Position","Question","Surprise","Trend")

for(sentence in corpusSentences$sentence_id){
  for(annotationLabel in annotationList){
    sqlStatementAWA2 <- paste0("select an.annotation_label as 'AWA2' from sentence_annotation sa, annotation an where sa.annotation_id=an.annotation_id and an.annotation_label='",annotationLabel,"' and sa.sentence_id=",sentence," LIMIT 1")
    resultAWA2 <- dbGetQuery(dbConnection,sqlStatementAWA2)
    if(nrow(resultAWA2)>0){
      
      sqlStatementAWA3 <- paste0("select an.annotation_label as 'AWA3' from sentence_annotation sa, annotation an where sa.annotation_id=an.annotation_id and an.annotation_label in ('AWA3_Background','AWA3_Contrast','AWA3_Emphasis','AWA3_Novelty','AWA3_Position','AWA3_Question','AWA3_Surprise','AWA3_Trend') and sa.sentence_id=",sentence)
      resultAWA3 <-dbGetQuery(dbConnection,sqlStatementAWA3)
      for(annotationLabelAWA3 in resultAWA3$AWA3){
        resultTable<-rbind(resultTable,cbind(resultAWA2,"AWA3" = annotationLabelAWA3)) 
      }
    }
  }
}

copyResultTable <- resultTable[-1,]
summaryTable <- table(copyResultTable)
summaryTable <- rbind("Contrast" =summaryTable[2,-1],
                      "Background"=summaryTable[5,-1],
                      "Emphasis"=summaryTable[3,-1],
                      "Position"=summaryTable[8,-1],
                      "Novelty"=summaryTable[4,-1],
                      "Question"=summaryTable[6,-1],
                      "Trend"=summaryTable[7,-1],
                      "Surprise"=summaryTable[9,-1])

chisquare <- chisq.test(summaryTable)

#Finding the most contributing cells to the total Chi-square score, 
#by calculating the Chi-square statistic for each cell
#Cells with the highest absolute standardized residuals contribute the most to the total Chi-square score
round(chisquare$residuals, 3)
corrplot(chisquare$residuals, is.cor = FALSE)

on.exit(dbDisconnect(dbConnection))
rm(list=ls())