library("RMySQL")
library("plyr")
dbConnection <- dbConnect(MySQL(),
                          user="root", password="ineeduyes",
                          dbname="corpus", host="localhost")

#get all annotation id for particular tool
queryStatement <- "SELECT DISTINCT(annotation_id) AS annotation_id FROM ANNOTATION WHERE tool_id=2"
annotationId<-dbGetQuery(dbConnection,queryStatement)


queryStatement <- "SELECT DISTINCT(document_category) AS category FROM DOCUMENT WHERE corpus_id IN (1,4) ORDER BY document_category ASC"
resultSet <- dbGetQuery(dbConnection, queryStatement)

countno <- 1
for(categoryName in resultSet$category){
  specificStatement <- paste0("SELECT SENTENCE_ANNOTATION.sentence_id,SENTENCE_ANNOTATION.annotation_id ", 
                              "FROM SENTENCE_ANNOTATION,SENTENCE,DOCUMENT ",
                              "WHERE SENTENCE_ANNOTATION.tool_id=2 ",
                              "AND SENTENCE_ANNOTATION.sentence_id = SENTENCE.sentence_id ",
                              "AND SENTENCE.document_id = DOCUMENT.document_id ",
                              "AND DOCUMENT.document_category like ", "'%",categoryName, "%' " ,"ORDER BY SENTENCE.sentence_id")
  
  specificResultSet <- dbGetQuery(dbConnection,specificStatement)
  
  #add dummy records for each annotation to avoid no annotation id display 
  #when no sentence annotated with that id
  for(id in annotationId$annotation_id){
    specificResultSet <- rbind(specificResultSet,c(0,id))
  }
  
  specificTableResult <- table(specificResultSet$annotation_id)
  
  if(countno==1){
    summaryTable <- rbind(specificTableResult)
  }else{
    summaryTable <- rbind(summaryTable, specificTableResult)
  }
  countno <- countno + 1
}

#remove back the dummy value added for each annotation
summaryTable <- summaryTable-1
row.names(summaryTable) <-resultSet$category

#get the total sentences for each category
queryStatement <- paste0("SELECT DOCUMENT.document_category, COUNT(*) AS 'Sentences' FROM ",
                         "DOCUMENT, SENTENCE ",
                         "WHERE DOCUMENT.document_id = SENTENCE.document_id ",
                         "GROUP BY DOCUMENT.document_category ",
                         "ORDER BY DOCUMENT.document_category ASC")

resultSetCategory <- dbGetQuery(dbConnection,queryStatement)

tempSummaryTable <- summaryTable
#get the percentage of annotations by dividing number of annotation with total sentences in that category
tempSummaryTable[,1] <- round((tempSummaryTable[,1]/resultSetCategory$Sentences)*100,3)
tempSummaryTable[,2] <- round((tempSummaryTable[,2]/resultSetCategory$Sentences)*100,3)
tempSummaryTable[,3] <- round((tempSummaryTable[,3]/resultSetCategory$Sentences)*100,3)
tempSummaryTable[,4] <- round((tempSummaryTable[,4]/resultSetCategory$Sentences)*100,3)
tempSummaryTable[,5] <- round((tempSummaryTable[,5]/resultSetCategory$Sentences)*100,3)
tempSummaryTable[,6] <- round((tempSummaryTable[,6]/resultSetCategory$Sentences)*100,3)
tempSummaryTable[,7] <- round((tempSummaryTable[,7]/resultSetCategory$Sentences)*100,3)
tempSummaryTable[,8] <- round((tempSummaryTable[,8]/resultSetCategory$Sentences)*100,3)
tempSummaryTable[,9] <- round((tempSummaryTable[,9]/resultSetCategory$Sentences)*100,3)
tempSummaryTable[,10] <- round((tempSummaryTable[,10]/resultSetCategory$Sentences)*100,3)
tempSummaryTable[,11] <- round((tempSummaryTable[,11]/resultSetCategory$Sentences)*100,3)



#need to install RColorBrewer
require("RColorBrewer")
barplot(summaryTable,
        beside = TRUE,
        main = "AWA: Frequency of Annotations In Each Document Category",
        col = brewer.pal(12,"Paired"),
        xlab = "Annotation Id",
        ylab = "Number of sentences")

legend(locator(1),
       cex = 0.6,
       rownames(summaryTable),
       fill = brewer.pal(12,"Paired"))

barplot(tempSummaryTable,
        beside = TRUE,
        main = "AWA: Frequency (% Proportion) of Annotations In Each Document Category",
        col = brewer.pal(12,"Paired"),
        xlab = "Annotation Id",
        ylab = "Number of sentences")

legend(locator(1),
       cex = 0.6,
       rownames(tempSummaryTable),
       fill = brewer.pal(12,"Paired"))

#set the columns and rows to display the barplots
#par(mfrow=c(1,2))
on.exit(dbDisconnect(dbConnection))
rm(list=ls())