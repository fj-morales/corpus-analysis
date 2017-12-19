library("RMySQL")
library("plyr")
dbConnection <- dbConnect(MySQL(),
                          user="root", password="ineeduyes",
                          dbname="corpus", host="localhost")

#get all annotation id for particular tool
queryStatement <- "SELECT DISTINCT(annotation_id) AS annotation_id FROM ANNOTATION WHERE tool_id=1"
annotationId<-dbGetQuery(dbConnection,queryStatement)


queryStatement <- "SELECT DISTINCT(document_category) AS category FROM DOCUMENT WHERE corpus_id=1"
resultSet <- dbGetQuery(dbConnection, queryStatement)

countno <- 1
for(categoryName in resultSet$category){
  specificStatement <- paste0("SELECT SENTENCE_ANNOTATION.sentence_id,SENTENCE_ANNOTATION.annotation_id ", 
                              "FROM SENTENCE_ANNOTATION,SENTENCE,DOCUMENT ",
                              "WHERE SENTENCE_ANNOTATION.tool_id=1 ",
                              "AND SENTENCE_ANNOTATION.sentence_date='2017-10-08' ",
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
  print(categoryName)
}
#remove back the dummy value added for each annotation
summaryTable <- summaryTable-1
row.names(summaryTable) <-resultSet$category
on.exit(dbDisconnect(dbConnection))

barplot(summaryTable,
        beside = TRUE,
        main = "AntMover: Frequency of Sentence Annotation In Each Document Category",
        col = c("aliceblue","bisque1","yellow1","chocolate1","darkseagreen1","deeppink1","gold1","gray1","lightsalmon1","olivedrab1"),
        xlab = "Annotation Id",
        ylab = "Number of sentences")

legend(locator(1),
       cex = 0.6,
       rownames(summaryTable),
       fill = c("aliceblue","bisque1","yellow1","chocolate1","darkseagreen1","deeppink1","gold1","gray1","lightsalmon1","olivedrab1"))

#set the columns and rows to display the barplots
#par(mfrow=c(1,2)) 

rm(list=ls())