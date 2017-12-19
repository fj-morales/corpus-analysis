library(readr)
documentAnnotations <- read_csv("~/DIC-Corpus-Analysis/AWA_test3.csv")
tableAnnotation = NULL #empty table
tableAnnotation <- rbind(tableAnnotation,documentAnnotations[1,])
tableAnnotation <- rbind(tableAnnotation,documentAnnotations[2,])
tableAnnotation$X1 <- NULL #delete column with label
row.names(tableAnnotation) <- c("Annotation","No Annotation")

#only annotation
annotationSentences <- data.matrix(tableAnnotation[1,])

#annotation and no annotation
newTableAnnotation <- data.matrix(tableAnnotation)

par(oma = c(0,0,0,0))
par(mar = c(5,4,2,0))

barplot(annotationSentences,
        main="AWA:Spread of Annotations (%) Over Sub-corpora (Annotated Sentences Only)",
        xlab = "Category",
        ylab = "Percentage",
        col=c("steelblue"))


barplot(newTableAnnotation,
        main = "AWA: Spread of Annotations (%) Over Sub-corpora (All Sentences)",
        xlab = "Category",
        ylab = "Percentage",
        beside = TRUE,
        col = c("steelblue","thistle")
)

legend(locator(1),
       cex = 0.7,
       rownames(newTableAnnotation),
       fill = c("steelblue","thistle"))

rm(list=ls())