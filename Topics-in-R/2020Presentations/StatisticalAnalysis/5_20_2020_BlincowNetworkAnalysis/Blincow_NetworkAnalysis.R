#Kayla Blincow
#5/19/2020

#This script walks through Network Analysis in the R environment for the R 
#Users meeting on 5/20/2020

#much of the material from this code is from here:
#https://www.jessesadler.com/post/network-analysis-with-r/

#clear my workspace
rm(list = ls())

#load my libraries
library(tidyverse) #load all the tidyverse packages in one go

library(circlize) #create chord diagram network visualizations
library(chorddiag)  #create interactive chord diagrams
library(igraph) #key network analysis package (calculate metrics)
library(ggraph) #network visualizations in ggplot format
library(tidygraph) #network visualizations in "tidy" framework
library(visNetwork) #network visualization package
library(networkD3) #create interactive network visualizations



#color pallette/figure formatting packages
library(RColorBrewer)
library(viridis)
library(patchwork)
library(hrbrthemes)



####Step 1. GET YOUR DATA INTO THE RIGHT FORMAT####
#load the data file
load("CCMFishData.RData")
#this data file is the output from running convergent cross mapping on 
#species landings from the San Diego CPFV fleet

#ccm_matrix is the file we will be working with the most, it is a matrix
#telling us the strength of the causal interactions found between the 
#different species landings


#only pull out significant results from ccm_matrix using values from 
#ccm_signficance matrix
for(i in 1:nrow(ccm_matrix)){
  for(j in 1:ncol(ccm_matrix)){
    if(ccm_significance[i,j] > 0.05){
      ccm_matrix[i,j] <- 0
    }
  }
}

#CONVERT THE CCM_MATRIX INTO AN EDGE LIST
# An edge list is a data frame that contains a minimum of two columns, one 
# column of nodes that are the source of a connection and another column of
# nodes that are the target of the connection. In our case the direction of
# the relationship is important, so it is a directed network. In our case,
# the network is also weighted, so we need to add an additional column that
# tells us the weight of the relationship between nodes.
# definition from: https://www.jessesadler.com/post/network-analysis-with-r/


#create a list of my nodes
nodes <- as.data.frame(colnames(ccm_matrix))
colnames(nodes) <- "label"

#number my nodes to correspond to their placement in the ccm_matrix matrix
nodes <- nodes %>% rowid_to_column("id")

#turn it into a tibble
nodes <- as.tbl(nodes)

#create an empty matrix for edgelist output
edges <- matrix(NA, nrow(ccm_matrix)^2, 3)

#pair each of my nodes and populate the first two columns of my matrix
edges[,1:2] <- rep(1:ncol(ccm_matrix), nrow(ccm_matrix))
edges[,1] <- sort(edges[,1])

#populate third column with the rho values from the cross map
for(i in 1:nrow(edges)){
  edges[i,3] <- ccm_matrix[edges[i,1], edges[i,2]]
}

#convert my edge list to a dataframe
edges <- as.data.frame(edges)

#rename the columns
colnames(edges) <- c("driver", "response", "weight")

#remove edges that aren't significant/have no weight
edges <- edges[edges$weight!=0,]



####Calculate Network Metrics####
# To use igraph, which is a common way to calculate these metrics, you need to
# create a "graph" object.

#Create the "graph object
ccm_igraph <- graph_from_data_frame(d = edges, vertices = nodes, directed = TRUE)

#calculate the metrics
#total degree
igraph::degree(ccm_igraph)

#out degree
igraph::degree(ccm_igraph, mode = "out")

#centrality metrics: there a are a whole lot of these, you will need to find the
#correct one for your purposes
centr_degree(ccm_igraph)

#output:
# res = node-level centrality scores
# centralization = graph level centrality index
# theoretical_max = graph level centralization score for a graph with a given 
# number of vertices


#NOTE on metrics: Network metrics are varied and many. For my thesis work, when 
# calculating network metrics, I have found the metrics I want to use in the 
# literature. I then hard core the calculation of those metrics to ensure I have 
# control of the formula and output. With the edge list, you should have
# everything you need to calculate most metrics.


####Arc Diagram Visualization####

#create necessary objects for the plots we want
ccm_igraph <- graph_from_data_frame(d = edges, vertices = nodes, directed = TRUE)
ccm_tidy  <- tbl_graph(nodes = nodes, edges = edges, directed = T)
ccm_igraph_tidy <- as_tbl_graph(ccm_igraph)



p1 <- ggraph(ccm_igraph, layout = "linear") + 
  geom_edge_arc(aes(width = weight, alpha = weight)) + 
  scale_edge_width(range = c(1, 5), 
                   breaks = c(0.2, 0.4, 0.6, 0.8, 1),
                   limits = c(0,1)) +
  scale_edge_alpha(range = c(0, 1), 
                   breaks = c(0.2, 0.4, 0.6, 0.8, 1),
                   limits = c(0,1)) +
  geom_node_point(size = 15, color = "gray10")+
  geom_node_text(aes(label = label), size = 5, color = "white") +
  labs(edge_width = "rho", edge_alpha = "rho") +
  theme_graph()

p1
#note: the default resolution of these plots is pretty terrible, but if you 
#specify the resolution when you export them, they look good.


####Chord Diagram Visualization####

#More Data Manipulation
#name rows of my matrix, same as the columns
rownames(ccm_matrix) <- colnames(ccm_matrix)

# Convert the matrix to long format
# (another way to create the edge list we created above)
data_long <- as.data.frame(ccm_matrix) %>%
  rownames_to_column %>%
  gather(key = 'key', value = 'value', -rowname)

#Make sure you have a clean workspace to generate your circular plot
circos.clear()


#Set the parameters for your plot
circos.par(start.degree = 90, #degree at which you start drawing
           gap.degree = 4, #the amount of space between your nodes
           track.margin = c(-0.1, 0.1), #amount of space outside of plot
           points.overflow.warning = FALSE)
#set plotting area
par(mar = rep(0, 4))

#set my color palette
mycolor <- c(viridis(5, alpha = 1, begin = 0, end = 0.5), 
             viridis(1, alpha = 1, begin = 0.8, end = 0.8))


# Base plot
chordDiagram(
  x = data_long, #data
  grid.col = mycolor, #color pallette
  transparency = 0.3, #transparency of the connecitons
  directional = 1, #directionality of the data (1 from column 1 to column 2)
  direction.type = c("arrows", "diffHeight"), #how to connect the nodes
  diffHeight  = -0.04, #create a gap in the connection of nodes
  annotationTrack = "grid", #not sure..
  annotationTrackHeight = c(0.05, 0.1), #something to do with the above command
  link.arr.type = "big.arrow", #type of arrow linking the nodes
  link.sort = TRUE, #sort nodes based on the width of the links
  scale = FALSE #scale your nodes to be the same size?
  ) 

# Add text and axis
circos.trackPlotRegion(
  track.index = 1, 
  bg.border = NA, 
  panel.fun = function(x, y) {
    
    xlim = get.cell.meta.data("xlim")
    sector.index = get.cell.meta.data("sector.index")
    
    # Add names to the sector. 
    circos.text(
      x = mean(xlim), 
      y = 3.2, 
      labels = sector.index, 
      facing = "bending", 
      cex = 1
    )
    
  }
)


####Interactive SanKey Diagram Visualization####

#More Data Manipulation
# Since we are making an interactive plot from the networkD3 package, we need to
# adjust our IDs so that they begin with 0.. 

nodes_d3 <- mutate(nodes, id = id - 1)
edges_d3 <- mutate(edges, from = driver - 1, to = response - 1)

#Create our SanKey Diagram!
sankeyNetwork(Links = edges_d3, Nodes = nodes_d3, Source = "from", 
              Target = "to", NodeID = "label", Value = "weight", 
              fontSize = 16)

#Ha!
#Obviously this data is not well-suited to this type of diagram, but it's cool
#to see it all interactive...
#see a better example here: https://www.jessesadler.com/post/network-analysis-with-r/