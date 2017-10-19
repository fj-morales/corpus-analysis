#populate data into R.data frame
############################option 1 (from mysql)###########################
#install RMySQL : install.packages("RMySQL")
#create connection
library("RMySQL")
dbConnection <- dbConnect(MySQL(),
                          user="root", password="ineeduyes",
                          dbname="corpus", host="localhost")

queryStatement <- "SELECT sentence_id,annotation_id FROM SENTENCE_ANNOTATION
WHERE tool_id=2 ORDER BY sentence_id"

resultSet <- dbGetQuery(dbConnection, queryStatement)

#exit connection
on.exit(dbDisconnect(dbConnection))
#############################################################################

############################option 1 (from RData)############################
#load the resultSet.RData
load("AWA_resultSet.RData")
#############################################################################


#plot bar chart to show the total number of each annotations used in OASTM corpus by AntMover
#########################using frequency count##############################
tableResultSet <- table(resultSet$annotation_id)
barplot(tableResultSet,
        main = "AWA: Frequency (Sentence) of Annotation Scheme",
        xlab = "Annotation Scheme",
        ylab = "Count",
        col=c("beige"))

##############using count/total count per document id###############
#select all annotation scheme for AntMover
queryStatement <- "SELECT annotation_id FROM ANNOTATION WHERE tool_id=2"
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
colnames(tableDocumentId) <- c("Id18","Id19","Id20","Id21","Id22","Id23","Id24","Id25","Id26","TotalSentenceLines")

tempTable <- tableDocumentId
tempTable <- transform(tempTable)
tempTable$Id18 <- round(tempTable$Id18/tempTable$TotalSentenceLines, digits = 5)
tempTable$Id19 <- round(tempTable$Id19/tempTable$TotalSentenceLines, digits = 5)
tempTable$Id20 <- round(tempTable$Id20/tempTable$TotalSentenceLines, digits = 5)
tempTable$Id21 <- round(tempTable$Id21/tempTable$TotalSentenceLines, digits = 5)
tempTable$Id22 <- round(tempTable$Id22/tempTable$TotalSentenceLines, digits = 5)
tempTable$Id23 <- round(tempTable$Id23/tempTable$TotalSentenceLines, digits = 5)
tempTable$Id24 <- round(tempTable$Id24/tempTable$TotalSentenceLines, digits = 5)
tempTable$Id25 <- round(tempTable$Id25/tempTable$TotalSentenceLines, digits = 5)
tempTable$Id26 <- round(tempTable$Id26/tempTable$TotalSentenceLines, digits = 5)


newPropotionTable <- rbind(c(sum(tempTable$Id18),sum(tempTable$Id19),sum(tempTable$Id20),
                             sum(tempTable$Id21),sum(tempTable$Id22),sum(tempTable$Id23),
                             sum(tempTable$Id24),sum(tempTable$Id25),sum(tempTable$Id26)))
colnames(newPropotionTable) <- c("Id18","Id19","Id20","Id21","Id22","Id23","Id24","Id25","Id26")
barplot(newPropotionTable,
        main = "AWA: Proportion (Document) of Annotation Scheme",
        xlab = "Annotation Scheme",
        ylab = "Count",
        names.arg = c("18", "19", "20","21","22","23","24","25","26"),
        col=c("beige")
)

#exit connection
on.exit(dbDisconnect(dbConnection))
rm(list=ls())