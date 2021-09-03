library(jsonlite)
library("ape")

jsonFile <- as.data.frame(fromJSON("http://dante.scripps.edu/services/structural_alignments.php?lpdb=1f8v,1nov,2bbv,2q23,4rft"))
row.names(jsonFile) <-jsonFile$V1
colnames(jsonFile) <- append( jsonFile$V1, 'VDB',0)

distm <- as.matrix(jsonFile[2:length(jsonFile)])
distm <- apply(distm,2, as.numeric)
distm <- 100-(distm*100)
dd <- as.dist(distm)

hc <- hclust(dd)
hdc <- as.phylo(hc)

colors = c("red", "blue", "green","blueviolet","brown","darkgoldenrod","cyan","darksalmon" , "aquamarine4","black",
           "chocolate", "tomato", "snow2", "lightblue1","yellow", "coral4","deeppink3","seagreen4", "cyan3", "orange3")
clus4 = cutree(hc, 4)
plot(hdc, type = "unrooted", cex = 1, label.offset = 1, tip.color = colors[clus4])