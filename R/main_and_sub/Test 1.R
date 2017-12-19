#open db connection
library("RMySQL")
library("corrplot")
dbConnection <- dbConnect(MySQL(),user="root",password="ineeduyes",dbname="AWA",host="localhost")

#sentences with both main and sub categories
sqlStatement <- paste0("select main.main_categories,sub.sub_categories from",
                      " (select sa.sentence_id as 'main_sentence_id',an.annotation_label as 'main_categories' from sentence_annotation sa,annotation an where sa.annotation_id=an.annotation_id and sa.annotation_id in (7,8,9) and sa.sentence_id in (select sentence_id from sentence where corpus_id=1)) main,",
                      " (select sa.sentence_id as 'sub_sentence_id',an.annotation_label as 'sub_categories' from sentence_annotation sa,annotation an where sa.annotation_id=an.annotation_id and sa.annotation_id in (10,11,12,13,14,15,16,17) and sa.sentence_id in (select sentence_id from sentence where corpus_id=1)) sub",
                      " where main.main_sentence_id = sub.sub_sentence_id")

resultSet <- dbGetQuery(dbConnection,sqlStatement)
totalSet <-resultSet

#sentence with only main categories
sqlStatement <- paste0("select an.annotation_label as 'main_categories', 'sub_other' as 'sub_categories' from sentence_annotation sa,annotation an where sa.annotation_id=an.annotation_id and sa.annotation_id in (7,8,9) and sa.sentence_id in (select sentence_id from sentence where corpus_id=1)",
                       " and sa.sentence_id not in (select distinct sa.sentence_id from sentence_annotation sa,annotation an where sa.annotation_id=an.annotation_id and sa.annotation_id in (10,11,12,13,14,15,16,17) and sa.sentence_id in (select sentence_id from sentence where corpus_id=1))")

resultSet <- dbGetQuery(dbConnection,sqlStatement)
totalSet <- rbind(totalSet,resultSet)

#sentence with only sub categories
sqlStatement <- paste0("select 'main_other' as 'main_categories', an.annotation_label as 'sub_categories' from sentence_annotation sa,annotation an where sa.annotation_id=an.annotation_id and sa.annotation_id in (10,11,12,13,14,15,16,17) and sa.sentence_id in (select sentence_id from sentence where corpus_id=1)",
                       " and sa.sentence_id not in (select distinct sa.sentence_id from sentence_annotation sa,annotation an where sa.annotation_id=an.annotation_id and sa.annotation_id in (7,8,9) and sa.sentence_id in (select sentence_id from sentence where corpus_id=1))")

resultSet <- dbGetQuery(dbConnection,sqlStatement)
totalSet <- rbind(totalSet,resultSet)

summaryTable <- table(totalSet)

#combine AWA_Important row with main_other row
#summaryTable<- rbind("AWA3_Important"=(summaryTable[1,] + summaryTable[4,]), "AWA3_Important&Summary" = summaryTable[2,],"AWA3_Summary" = summaryTable[3,])


#Are main categories independent to sub categories?
chisquare <- chisq.test(summaryTable)

#observed count
chisquare$observed
#expected count
round(chisquare$expected,2)

#Finding the most contributing cells to the total Chi-square score, 
#by calculating the Chi-square statistic for each cell
#Cells with the highest absolute standardized residuals contribute the most to the total Chi-square score
round(chisquare$residuals, 3)
corrplot(chisquare$residuals, is.cor = FALSE)

on.exit(dbDisconnect(dbConnection))
rm(list=ls())
