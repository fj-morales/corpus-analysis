#populate data into R.data frame
############################option 1 (from mysql)###########################
#install RMySQL : install.packages("RMySQL")
#create connection
library("RMySQL")
dbConnection <- dbConnect(MySQL(),
                          user="root", password="ineeduyes",
                          dbname="corpus", host="localhost")

queryStatement <- "SELECT sentence_id,annotation_id FROM SENTENCE_ANNOTATION
WHERE tool_id=1 ORDER BY sentence_id"

resultSet <- dbGetQuery(dbConnection, queryStatement)

#############################################################################

############################option 1 (from RData)############################
#load the resultSet.RData
load("resultSet.RData")
#############################################################################


#plot bar chart to show the total number of each annotations used in OASTM corpus by AntMover
#########################using frequency count##############################
tableResultSet <- table(resultSet$annotation_id)
barplot(tableResultSet,
        main = "AntMover: Frequency (Sentence) of Annotation Scheme",
        xlab = "Annotation Scheme",
        ylab = "Count",
        col=c("beige","beige","beige","beige","beige","beige"))

##############using count/total count per document id###############
#select all annotation scheme for AntMover
queryStatement <- "SELECT annotation_id FROM ANNOTATION WHERE tool_id=1"
resultSet <-  dbGetQuery(dbConnection, queryStatement)
tableDocumentId <- NULL

for(indexId in resultSet$annotation_id){
  queryStatement <- paste("SELECT COUNT(SENTENCE_ANNOTATION.annotation_id) AS annotation_id ",
                          "FROM SENTENCE ", 
                          "LEFT JOIN SENTENCE_ANNOTATION ON SENTENCE.sentence_id = SENTENCE_ANNOTATION.sentence_id ",
                          "AND  SENTENCE_ANNOTATION.annotation_id= ",
                          indexId,
                          " GROUP BY SENTENCE.document_id ",
                          "ORDER BY SENTENCE.document_id ASC")
  resultSet <-  dbGetQuery(dbConnection, queryStatement)
  tableDocumentId <- cbind(tableDocumentId,resultSet$annotation_id)
}

#get total number of lines in each document
queryStatement <- paste("SELECT COUNT(SENTENCE.sentence_id) AS 'number_of_lines' FROM SENTENCE ",
                        "GROUP BY SENTENCE.document_id ",
                        "ORDER BY SENTENCE.document_id ASC")

resultSet <- dbGetQuery(dbConnection, queryStatement)
tableDocumentId <- cbind(tableDocumentId,resultSet$number_of_lines)

#rename the columns names
colnames(tableDocumentId) <- c("Id1","Id2","Id3","Id4","Id5","Id6","TotalSentenceLines")

tempTable <- tableDocumentId
tempTable <- transform(tempTable)
tempTable$Id1 <- round(tempTable$Id1/tempTable$TotalSentenceLines, digits = 5)
tempTable$Id2 <- round(tempTable$Id2/tempTable$TotalSentenceLines, digits = 5)
tempTable$Id3 <- round(tempTable$Id3/tempTable$TotalSentenceLines, digits = 5)
tempTable$Id4 <- round(tempTable$Id4/tempTable$TotalSentenceLines, digits = 5)
tempTable$Id5 <- round(tempTable$Id5/tempTable$TotalSentenceLines, digits = 5)
tempTable$Id6 <- round(tempTable$Id6/tempTable$TotalSentenceLines, digits = 5)

newPropotionTable <- rbind(c(sum(tempTable$Id1),sum(tempTable$Id2),sum(tempTable$Id3),
                             sum(tempTable$Id4),sum(tempTable$Id5),sum(tempTable$Id6)))
colnames(newPropotionTable) <- c("Id1","Id2","Id3","Id4","Id5","Id6")
barplot(newPropotionTable,
        main = "AntMover: Proportion (Document) of Annotation Scheme",
        xlab = "Annotation Scheme",
        ylab = "Count",
        names.arg = c("1", "2", "3","4","5","6"),
        col=c("beige","beige","beige","beige","beige","beige")
)

#exit connection
on.exit(dbDisconnect(dbConnection))
rm(list=ls())