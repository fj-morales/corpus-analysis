######## ---------- LOAD PACKAGES ----------------------------------------######
library("dplyr")
library("dbplyr")

pw <- ''
######## ---------- LOAD DATA --------------------------------------------######
# connect to mysql database (localhost)
awadb <- src_mysql(dbname = "awa_2020", 
                   user = "root",
                   password = pw) #provide your password here
remove(pw)

# load tables
document <- data.frame(tbl(awadb, "document"))
tool <- data.frame(tbl(awadb, "tool"))
annotation <- data.frame(tbl(awadb, "annotation"))
corpus <- data.frame(tbl(awadb, "corpus"))
sentence_annotation <- data.frame(tbl(awadb, "sentence_annotation"))
sentence <- data.frame(tbl(awadb, "sentence"))

