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

#############################################################################

############################option 1 (from RData)############################
#load the resultSet.RData
load("AWA_resultSet.RData")
#############################################################################


#plot bar chart to show the total number of each annotations used in OASTM corpus by AntMover
#########################using frequency count##############################
tableResultSet <- table(resultSet$annotation_id)

par(oma = c(1,1,1,1))
par(mar = c(5,4,2,0))

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
colnames(tableDocumentId) <- c("Id27","Id28","Id29","Id30","Id31","Id32","Id33","Id34","Id35","Id36","Id37","TotalSentenceLines")

tempTable <- tableDocumentId
tempTable <- transform(tempTable)
tempTable$Id27 <- round(tempTable$Id27/tempTable$TotalSentenceLines, digits = 5)
tempTable$Id28 <- round(tempTable$Id28/tempTable$TotalSentenceLines, digits = 5)
tempTable$Id29 <- round(tempTable$Id29/tempTable$TotalSentenceLines, digits = 5)
tempTable$Id30 <- round(tempTable$Id30/tempTable$TotalSentenceLines, digits = 5)
tempTable$Id31 <- round(tempTable$Id31/tempTable$TotalSentenceLines, digits = 5)
tempTable$Id32 <- round(tempTable$Id32/tempTable$TotalSentenceLines, digits = 5)
tempTable$Id33 <- round(tempTable$Id33/tempTable$TotalSentenceLines, digits = 5)
tempTable$Id34 <- round(tempTable$Id34/tempTable$TotalSentenceLines, digits = 5)
tempTable$Id35 <- round(tempTable$Id35/tempTable$TotalSentenceLines, digits = 5)
tempTable$Id36 <- round(tempTable$Id36/tempTable$TotalSentenceLines, digits = 5)
tempTable$Id37 <- round(tempTable$Id37/tempTable$TotalSentenceLines, digits = 5)


newPropotionTable <- rbind(c(sum(tempTable$Id27),sum(tempTable$Id28),sum(tempTable$Id29),
                             sum(tempTable$Id30),sum(tempTable$Id31),sum(tempTable$Id32),
                             sum(tempTable$Id33),sum(tempTable$Id34),sum(tempTable$Id35),
                             sum(tempTable$Id36), sum(tempTable$Id37)))
colnames(newPropotionTable) <- c("Id27","Id28","Id29","Id30","Id31","Id32","Id33","Id34","Id35","Id36","Id37")

barplot(newPropotionTable,
        main = "AWA: Proportion (Document) of Annotation Scheme",
        xlab = "Annotation Scheme",
        ylab = "Proportion",
        names.arg = c("27", "28", "29","30","31","32","33","34","35","36","37"),
        col=c("beige"))

#exit connection
on.exit(dbDisconnect(dbConnection))
rm(list=ls())