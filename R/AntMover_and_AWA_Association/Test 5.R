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

resultTest <- dbGetQuery(dbConnection, queryStatement)

#just get the main category
#'important', 'summary' and 'important&summary'
mainCategory <- subset(resultTest,resultTest$AWA_LABEL=='AWA3_Important')
mainCategory <- rbind(mainCategory,subset(resultTest,resultTest$AWA_LABEL=='AWA3_Summary'))
mainCategory <- rbind(mainCategory,subset(resultTest,resultTest$AWA_LABEL=='AWA3_Important&Summary'))

#remove certain rows to prevent chisquare warning
modifiedMainCategory <- subset(mainCategory,mainCategory$ANTMOVER_LABEL=='2_making_topic_generalizations')
modifiedMainCategory <- rbind(modifiedMainCategory,subset(mainCategory,mainCategory$ANTMOVER_LABEL=='10_announcing_principal_findings'))
modifiedMainCategory <- rbind(modifiedMainCategory,subset(mainCategory,mainCategory$ANTMOVER_LABEL=='11_evaluation_of_research'))
modifiedMainCategory <- rbind(modifiedMainCategory,subset(mainCategory,mainCategory$ANTMOVER_LABEL=='9_announcing_present_research'))
summaryMainCategory <- table(modifiedMainCategory)
chisq.test(summaryMainCategory)

summaryTableTest <- table(mainCategory)
chisquareTest <- chisq.test(summaryTableTest)
corrplot(chisquareTest$residuals, is.cor = FALSE,
         title = 'All document categories',mar=c(0,0,3,0))
# contribution in percentage
contribPercentageTest <- 100*chisquareTest$residuals^2/chisquareTest$statistic
corrplot(contribPercentageTest, is.cor = FALSE,
         title = 'All document categories',mar=c(0,0,3,0))


#just get the sub category
summaryResultSet = table(resultTest)
summarySubCategory <- summaryResultSet[,c(1,2,3,6,7,8,10,11)]


#remove certain rows to prevent chisquare warning
summaryModifiedSubCategory <- summarySubCategory[c(2,3,4),]
summaryModifiedSubCategory <- summaryModifiedSubCategory[,c(1,4,5,6,7,8)]
chisquareTest<-chisq.test(summaryModifiedSubCategory)

chisquareTest <- chisq.test(summarySubCategory)
corrplot(chisquareTest$residuals, is.cor = FALSE,
         title = 'All document categories',mar=c(0,0,3,0))
# contribution in percentage
contribPercentageTest <- 100*chisquareTest$residuals^2/chisquareTest$statistic
corrplot(contribPercentageTest, is.cor = FALSE,
         title = 'All document categories',mar=c(0,0,3,0))

on.exit(dbDisconnect(dbConnection))
rm(list=ls())