#Open DB connection
library("RMySQL")
dbConnection <- dbConnect(MySQL(),
                          user="root", password="ineeduyes",
                          dbname="corpus", host="localhost")

#get all the sentence with annotation for AntMover
queryStatement <- "SELECT SENTENCE.sentence_id,SENTENCE_ANNOTATION.annotation_id AS 'AntMover'
FROM SENTENCE
LEFT JOIN SENTENCE_ANNOTATION ON SENTENCE.sentence_id=SENTENCE_ANNOTATION.sentence_id
AND SENTENCE_ANNOTATION.tool_id=1
AND SENTENCE_DATE='2017-10-08'
ORDER BY SENTENCE.sentence_id ASC"

resultSet <- dbGetQuery(dbConnection, queryStatement)
resultSet$AntMover[is.na(resultSet$AntMover)] <- 0 # change all NULL (no annotation id) to 0 means 'not annotated'
resultSet$AntMover[resultSet$AntMover>0]<-1 #change all annotation id to 1 means 'annotated'
resultSet<-unique(resultSet) # remove duplicate values as one sentence may have multiple annotations

#get all the sentence with annotation for AWA
queryStatement <- "SELECT SENTENCE.sentence_id,SENTENCE_ANNOTATION.annotation_id AS 'AWA'
FROM SENTENCE
LEFT JOIN SENTENCE_ANNOTATION ON SENTENCE.sentence_id=SENTENCE_ANNOTATION.sentence_id
AND SENTENCE_ANNOTATION.tool_id=2
ORDER BY SENTENCE.sentence_id ASC"

AWAResultSet <- dbGetQuery(dbConnection,queryStatement)
AWAResultSet$AWA[is.na(AWAResultSet$AWA)] <- 0
AWAResultSet$AWA[AWAResultSet$AWA>0]<-1
AWAResultSet<-unique(AWAResultSet) # remove duplicate values as one sentence may have multiple annotations

#append the AWAResult to resultSet (AntMover)
resultSet <- cbind(resultSet,AWA = AWAResultSet$AWA)

#delete the sentence_id column
resultSet$sentence_id <- NULL

#convert the resultSet output to matrix 2 X n (n is the total number of sentences)
resultSetMatrix <- c(resultSet$AntMover)
resultSetMatrix <- rbind(resultSetMatrix,c(resultSet$AWA))

library(irr)
#percentage of agreement
agree(resultSet)

#Krippendorf’s alpha to test the disagreement
#between AntMover and AWA in sentence annotation
kripp.alpha(resultSetMatrix,'nominal')

#Cohen kappa to test the agreement
kappa2(resultSet)

#barplot to compare the frequency of annotations between AWA and AntMover
tableResultAWA <- table(resultSet$AWA)
tableResultAntMover <-table(resultSet$AntMover)
tableResult <- rbind(AWA = tableResultAWA,AntMover = c(0,tableResultAntMover))
par(oma = c(1,1,1,1))
par(mar = c(5,4,2,0))
barplot(tableResult,
        beside = TRUE,
        main = "Frequency of Sentence Annotation Between AntMover and AWA",
        col = c("beige","steelblue"),
        xlab = "Annotation (0 = No, 1 = Yes)",
        ylab = "Number of sentences")

legend(locator(1),
       cex = 0.7,
       rownames(tableResult),
       fill = c("beige","steelblue"))

on.exit(dbDisconnect(dbConnection))
rm(list=ls())