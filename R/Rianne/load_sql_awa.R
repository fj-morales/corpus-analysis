######## ---------- LOAD PACKAGES ----------------------------------------######
library("dplyr")
library("dbplyr")

######## ---------- LOAD DATA --------------------------------------------######
# connect to mysql database (localhost)
awadb <- src_mysql(dbname = "awa", 
                   user = "root",
                   password = pw)
remove(pw)

# load tables
document <- data.frame(tbl(awadb, "document"))
tool <- data.frame(tbl(awadb, "tool"))
annotation <- data.frame(tbl(awadb, "annotation"))
corpus <- data.frame(tbl(awadb, "corpus"))
sentence_annotation <- data.frame(tbl(awadb, "sentence_annotation"))
sentence <- data.frame(tbl(awadb, "sentence"))

