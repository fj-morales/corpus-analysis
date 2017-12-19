#Open DB connection
library("RMySQL")
library("corrplot")
dbConnection <- dbConnect(MySQL(),
                          user="root", password="ineeduyes",
                          dbname="AWA", host="localhost")

queryStatement<- paste0("SELECT ANTMOVERLABEL.annotation_label AS ANTMOVER_LABEL, AWALABEL.annotation_label AS AWA_LABEL FROM ",
                        "SENTENCE_ANNOTATION ANTMOVER, SENTENCE_ANNOTATION AWA, ANNOTATION ANTMOVERLABEL, ANNOTATION AWALABEL ",
                        "WHERE AWA.sentence_id = ANTMOVER.sentence_id ",
                        "AND AWA.tool_id = 3 AND ANTMOVER.tool_id=1 ",
                        "AND AWA.annotation_id = AWALABEL.annotation_id ",
                        "AND ANTMOVER.annotation_id = ANTMOVERLABEL.annotation_id ",
                        "AND AWA.sentence_id IN (SELECT sentence_id FROM sentence WHERE corpus_id=1) ",
                        "AND ANTMOVER.sentence_id IN (SELECT sentence_id FROM sentence WHERE corpus_id=1) ",
                        "ORDER BY ANTMOVERLABEL.annotation_id,AWALABEL.annotation_id ASC")

resultTest1 <- dbGetQuery(dbConnection, queryStatement)
summaryTableTest1 <- table(resultTest1)
summaryTableTest1 <-rbind("Claiming_centrality" = summaryTableTest1["1_claiming_centrality",],
                          "Announcing_principal_findings" = summaryTableTest1["10_announcing_principal_findings",],
                          "Evaluation_of_research" = summaryTableTest1["11_evaluation_of_research",],
                          "Making_topic_generalizations" = summaryTableTest1["2_making_topic_generalizations",],
                          "Indicating_a_gap" = summaryTableTest1["5_indicating_a_gap",],
                          "Announcing_present_research" = summaryTableTest1["9_announcing_present_research",])
#column1 <- rbind(23,17095,5460,3446,86,2411)
#colnames(column1)<-"NotAnnotated"
#temporaryTable <- cbind(summaryTableTest1,"NotAnnotated" = column1)


#Is AntMover moves independent to AWA annotations?
chisquareTest1 <- chisq.test(summaryTableTest1)

#observed count
chisquareTest1$observed
#expected count
round(chisquareTest1$expected,2)

#Finding the most contributing cells to the total Chi-square score, 
#by calculating the Chi-square statistic for each cell
#Cells with the highest absolute standardized residuals contribute the most to the total Chi-square score
round(chisquareTest1$residuals, 3)
corrplot(chisquareTest1$residuals, is.cor = FALSE)

# contribution in percentage
contribPercentageTest1 <- 100*chisquareTest1$residuals^2/chisquareTest1$statistic
round(contribPercentageTest1, 3)
corrplot(contribPercentageTest1, is.cor = FALSE)

on.exit(dbDisconnect(dbConnection))
rm(list=ls())