######## ---------- LOAD DATA --------------------------------------------######
ena_antmover <- read.csv("ena_antmover_full.csv")

######## ---------- LOAD PACKAGES ----------------------------------------######
library("dplyr")
library("rENA")

### https://rdrr.io/cran/rENA/man/ena.plot.network.html

######## ---------- ENA --------------------------------------------------######
code_names <- c("X1_claiming_centrality","X10_announcing_principal_findings",
              "X11_evaluation_of_research", "X2_making_topic_generalizations",
              "X5_indicating_a_gap", "X9_announcing_present_research")

#condition = corpus_label
accum = ena.accumulate.data(
  units = ena_antmover[,c("corpus_label", "document_category")],
  conversation = ena_antmover[,c("corpus_label","document_label")],
  metadata = ena_antmover[,c("sentence_detail", "sentence_detail")],
  codes = ena_antmover[,code_names],
  # use sliding window, because there are no clear boundaries for the stanza
  window = "Moving Stanza",
  # sliding windo size is 4 (per 4 sentences) (first try)
  window.size.back = 4, 
  # weighted accumalation of sentences within stanzas - 
  # using a move 1 or 4 times in a stanza makes a difference
  weight.by = "weighted" 
)

set = ena.make.set(
  enadata = accum,
  dimensions = 3,
  # normalize the number of stanzas (to normalize for document length)
  # norm.by = sphere_norm_c,
  rotation.by = ena.svd
)


######## ---------- Calculate points per condition -----------------------######

unitNames = set$enadata$units

# Subset rotated points and plot corpus_label 1 Group Mean #student essays
cond1 = unitNames$corpus_label == "BAWE"
cond1.points = set$points.rotated[cond1,]
# get means network plots
cond1.lineweights = set$line.weights[cond1,]
cond1.mean = colMeans(cond1.lineweights)

# Subset rotated points and plot corpus_label 2 Group Mean
cond2 = unitNames$corpus_label == "PMC"
cond2.points = set$points.rotated[cond2,]
# get means network plots
cond2.lineweights = set$line.weights[cond2,]
cond2.mean = colMeans(cond2.lineweights)

# Subset rotated points and plot corpus_label 3 Group Mean
cond3 = unitNames$corpus_label == "OASTM"
cond3.points = set$points.rotated[cond3,]
# get means network plots
cond3.lineweights = set$line.weights[cond3,]
cond3.mean = colMeans(cond3.lineweights)


######## ---------- Plot networks per condition --------------------------######

plot = ena.plot(set)

plot1 = ena.plot.network(plot, colors = "red", 
                         network = cond1.mean)
print(plot1)

plot = ena.plot(set)
plot2 = ena.plot.network(plot, colors = "blue", 
                         network = cond2.mean)
print(plot2)

plot = ena.plot(set)
plot3 = ena.plot.network(plot, colors = "green", 
                         network = cond3.mean)
print(plot3)


######## ---------- Plot subtracted networks -----------------------------######

#plot substracted networks + means
plot = ena.plot(set)
subtracted.network1_2 = cond1.mean - cond2.mean
plot1_2 = ena.plot.network(plot, network = subtracted.network1_2,
                           colors = c(pos = "red", "blue"))
plot1_2 = ena.plot.group(plot1_2, cond2.points, labels = "PMC", 
                       colors  = "blue", confidence.interval = "box")
plot1_2 = ena.plot.group(plot1_2, cond1.points, labels = "BAWE", 
                       colors = "red", confidence.interval = "box")
print(plot1_2)

plot = ena.plot(set)
subtracted.network1_3 = cond1.mean - cond3.mean
plot1_3 = ena.plot.network(plot, network = subtracted.network1_3,
                           colors = c(pos = "red", "green"))
plot1_3 = ena.plot.group(plot1_3, cond1.points, labels = "BAWE", 
                         colors  = "red", confidence.interval = "box")
plot1_3 = ena.plot.group(plot1_3, cond3.points, labels = "OASTM", 
                         colors = "green", confidence.interval = "box")
print(plot1_3)

plot = ena.plot(set)
subtracted.network2_3 = cond2.mean - cond3.mean
plot2_3 = ena.plot.network(plot, network = subtracted.network2_3,
                           colors = c(pos = "blue", "green"))
plot2_3 = ena.plot.group(plot2_3, cond2.points, labels = "PMC", 
                         colors  = "blue", confidence.interval = "box")
plot2_3 = ena.plot.group(plot2_3, cond3.points, labels = "OASTM", 
                         colors = "green", confidence.interval = "box")
print(plot2_3)

######## ---------- Differences in networks (t-test) ---------------------######

t.test(cond1.points, cond2.points)
t.test(cond1.points, cond3.points)
t.test(cond2.points, cond3.points)