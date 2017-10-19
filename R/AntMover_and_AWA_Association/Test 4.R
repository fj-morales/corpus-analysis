#Open DB connection
library("RMySQL")
library("corrplot")
dbConnection <- dbConnect(MySQL(),
                          user="root", password="ineeduyes",
                          dbname="corpus", host="localhost")

queryStatement<- paste0("SELECT ANTMOVERLABEL.annotation_label AS ANTMOVER_LABEL, AWALABEL.annotation_label AS AWA_LABEL FROM ",
                        "SENTENCE_ANNOTATION ANTMOVER, SENTENCE_ANNOTATION AWA, ",
                        "ANNOTATION ANTMOVERLABEL, ANNOTATION AWALABEL, ",
                        "SENTENCE AWASENTENCE, DOCUMENT AWADOCUMENT ",
                        "WHERE AWASENTENCE.document_id = AWADOCUMENT.document_id ",
                        "AND AWASENTENCE.sentence_id = AWA.sentence_id ",
                        "AND AWA.sentence_id = ANTMOVER.sentence_id ",
                        "AND AWADOCUMENT.document_category = 'Materials Science' ",
                        "AND AWA.tool_id = 2 AND ANTMOVER.tool_id=1 ",
                        "AND ANTMOVER.sentence_date='2017-10-08' ",
                        "AND AWA.annotation_id = AWALABEL.annotation_id ",
                        "AND ANTMOVER.annotation_id = ANTMOVERLABEL.annotation_id ",
                        "ORDER BY ANTMOVERLABEL.annotation_id,AWALABEL.annotation_id ASC")

resultTest1 <- dbGetQuery(dbConnection, queryStatement)
summaryTableTest1 <- table(resultTest1)
summaryTableTest1 <-rbind("Claiming_centrality" = summaryTableTest1["1_claiming_centrality",],
                          "Announcing_principal_findings" = summaryTableTest1["10_announcing_principal_findings",],
                          "Evaluation_of_research" = summaryTableTest1["11_evaluation_of_research",],
                          "Making_topic_generalizations" = summaryTableTest1["2_making_topic_generalizations",],
                          "Indicating_a_gap" = summaryTableTest1["5_indicating_a_gap",],
                          "Announcing_present_research" = summaryTableTest1["9_announcing_present_research",])
column1 <- rbind(23,17095,5460,3446,86,2411)
colnames(column1)<-"NotAnnotated"
temporaryTable <- cbind(summaryTableTest1,"NotAnnotated" = column1)


#Test 1: Is AntMover moves independent to AWA annotations?
#Result: Not independent. They are related
chisquareTest1 <- chisq.test(summaryTableTest1) #X-squared = 176.7, df = 40, p-value < 2.2e-16

#Bind some columns with smaller values
tempSummaryTableTest1 = cbind("Contrast" = summaryTableTest1[,"Contrast"],
                              "Others" = (summaryTableTest1[,"Emphasis"] + summaryTableTest1[,"Background"] + summaryTableTest1[,"MainCategory"] + summaryTableTest1[,"Novelty"] + summaryTableTest1[,"Position"] + summaryTableTest1[,"Question"]))
chisq.test(tempSummaryTableTest1)


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

#Creating new Annotation Scheme called 'others' to accomodate the sentences that AWA not annotated but AntMover annotates
queryStatement<-paste0("SELECT ANTMOVER.annotation_id AS ANTMOVER_ID, AWA.annotation_id AS AWA_ID ",
                       "FROM SENTENCE_ANNOTATION ANTMOVER ",
                       "LEFT JOIN SENTENCE_ANNOTATION AWA ",
                       "ON ANTMOVER.sentence_id = AWA.sentence_id AND AWA.tool_id = 2 ",
                       "WHERE ANTMOVER.tool_id=1 ",
                       "AND ANTMOVER.sentence_date='2017-10-08' ",
                       "ORDER BY ANTMOVER.annotation_id,AWA.annotation_id ASC")

resultTest2 <- dbGetQuery(dbConnection, queryStatement)
resultTest2$AWA_ID[is.na(resultTest2$AWA_ID)] <- 'NoAnnotation'
resultTest2$AWA_ID[resultTest2$AWA_ID==18] <- 'MainCategory'
resultTest2$AWA_ID[resultTest2$AWA_ID==19] <- 'Background'
resultTest2$AWA_ID[resultTest2$AWA_ID==20] <- 'Constrast'
resultTest2$AWA_ID[resultTest2$AWA_ID==21] <- 'Emphasis'
resultTest2$AWA_ID[resultTest2$AWA_ID==22] <- 'Novelty'
resultTest2$AWA_ID[resultTest2$AWA_ID==23] <- 'Position'
resultTest2$AWA_ID[resultTest2$AWA_ID==24] <- 'Question'
resultTest2$AWA_ID[resultTest2$AWA_ID==25] <- 'Surprise'
resultTest2$AWA_ID[resultTest2$AWA_ID==26] <- 'Trend'

resultTest2$ANTMOVER_ID[resultTest2$ANTMOVER_ID==1]<-'Claiming_centrality'
resultTest2$ANTMOVER_ID[resultTest2$ANTMOVER_ID==2]<-'Making_topic_generalization'
resultTest2$ANTMOVER_ID[resultTest2$ANTMOVER_ID==3]<-'Indicating_a_gap'
resultTest2$ANTMOVER_ID[resultTest2$ANTMOVER_ID==4]<-'Announcing_present_research'
resultTest2$ANTMOVER_ID[resultTest2$ANTMOVER_ID==5]<-'Announcing_principal_findings'
resultTest2$ANTMOVER_ID[resultTest2$ANTMOVER_ID==6]<-'Evaluation_of_research'
summaryTableTest2 <- table(resultTest2)

##Test 2: Is AntMover moves independent to AWA annotations with new columns 'Others'?
#Result: Not independent. They are related
chisq.test(summaryTableTest2) #X-squared = 575.11, df = 45, p-value < 2.2e-16

#Test 3: Is AntMover moves independent to AWA annotations after combining few categories of AWA with small values into one category
#Using the summary table from Test 1, combine the columns with small values
#combine 'surprise', 'mainCategory' as 'surprise_mainCategory'
summaryTableTest3 <- cbind("Background" = summaryTableTest1[,"Background"],
                           "Contrast" = summaryTableTest1[,"Contrast"],
                           "Emphasis" = summaryTableTest1[,"Emphasis"],
                           "Novelty" = summaryTableTest1[,"Novelty"],
                           "Position" = summaryTableTest1[,"Position"],
                           "Question" = summaryTableTest1[,"Question"],
                           "Trend" = summaryTableTest1[,"Trend"],
                           "Surprise_mainCategory" = (summaryTableTest1[,"Surprise"] + summaryTableTest1[,"MainCategory"])) 

chisq.test(summaryTableTest3) #X-squared = 171.09, df = 35, p-value < 2.2e-16

#combine 'position' and 'trend' from summaryTableTest3
summaryTableTest4 <- cbind("Background" = summaryTableTest3[,"Background"],
                           "Contrast" = summaryTableTest3[,"Contrast"],
                           "Emphasis" = summaryTableTest3[,"Emphasis"],
                           "Novelty" = summaryTableTest3[,"Novelty"],
                           "Question" = summaryTableTest3[,"Question"],
                           "Surprise_mainCategory" = summaryTableTest3[,"Surprise_mainCategory"],
                           "Position_trend" = (summaryTableTest3[,"Position"] + summaryTableTest3[,"Trend"])) 

chisq.test(summaryTableTest4) #X-squared = 142.74, df = 30, p-value < 2.2e-16

#combine 'Surprise_mainCategory' and 'Novelty' from summaryTableTest4
summaryTableTest5 <- cbind("Background" = summaryTableTest4[,"Background"],
                           "Contrast" = summaryTableTest4[,"Contrast"],
                           "Emphasis" = summaryTableTest4[,"Emphasis"],
                           "Question" = summaryTableTest4[,"Question"],
                           "Position_trend" = summaryTableTest4[,"Position_trend"],
                           "Surprise_mainCategory_novelty" = (summaryTableTest4[,"Surprise_mainCategory"] + summaryTableTest4[,"Novelty"])) 

chisq.test(summaryTableTest5) #X-squared = 141.75, df = 25, p-value < 2.2e-16

#combine 'Background' and 'Question' from summaryTableTest5
summaryTableTest6 <- cbind("Contrast" = summaryTableTest5[,"Contrast"],
                           "Emphasis" = summaryTableTest5[,"Emphasis"],
                           "Surprise_mainCategory_novelty" = summaryTableTest5[,"Surprise_mainCategory_novelty"],
                           "Position_trend" = summaryTableTest5[,"Position_trend"],
                           "Background_question" = (summaryTableTest5[,"Background"] + summaryTableTest5[,"Question"]))

chisq.test(summaryTableTest6) #X-squared = 130.8, df = 20, p-value < 2.2e-16



on.exit(dbDisconnect(dbConnection))
rm(list=ls())