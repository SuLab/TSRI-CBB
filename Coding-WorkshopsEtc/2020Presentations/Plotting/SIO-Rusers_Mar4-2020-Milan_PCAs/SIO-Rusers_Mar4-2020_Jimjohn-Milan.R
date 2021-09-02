rm(list = ls())


# A Simple PCA
# dataset consists of data on 32 models of car, 
# taken from an American motoring magazine
# each car, have 11 features, vary in units 

str(mtcars)

# Compute the Principal Components

# PCA works best with numerical data, 
# exclude the two categorical variables (vs and am). 
# left with a matrix of 9 columns and 32 rows, 
# which you pass to the prcomp() function, 
# assigning your output to mtcars.pca
# also set two arguments, center and scale, to TRUE 
mtcars.pca <- prcomp(mtcars[,c(1:7, 10, 11)],
                     center = TRUE,
                     scale. = TRUE)

# peek at your PCA object with summary().
summary(mtcars.pca)

# 9 principal components, which you call PC1-9
# Each explains a % of total variation in dataset
# PC1 explains 63% of the total variance, 
# which means that nearly two-thirds of the information 
# in dataset (9 variables) can be encapsulated by just
# one Principal Component

# PC2 explains 23% of the variance 
# So, by knowing position of a sample in relation to PC1 and PC2, 
# you can get accurate view on where it stands in relation to other samples, 
# as just PC1 and PC2 can explain 86% of the variance

# Let's call str() to have a look at your PCA object
str(mtcars.pca)

# downloading ggbiplot
library(devtools)
install_github("vqv/ggbiplot")


# Plotting PCA
# Make a biplot, which includes both the position 
# of each sample in terms of PC1 and PC2 
# and also will show you how the initial variables 
# map onto this

# You will use the ggbiplot package, 
# which offers a user-friendly and pretty function 
# to plot biplots

# A biplot is a type of plot that will allow you 
# to visualize how the samples relate to one another 
# in our PCA (which samples are similar and which are 
# different) and will simultaneously reveal how each 
# variable contributes to each principal component.

# Axes are arrows originating from the center point

# Here, you see that the variables hp, cyl, and disp 
# all contribute to PC1, with higher values in those 
# variables moving the samples to the right on this 
# plot

# This lets you see how the data points relate to 
# the axes, but it's not very informative without 
# knowing which point corresponds to which sample (car)

# You'll provide an argument to ggbiplot: 
# let's give it the rownames of mtcars as labels. 
# This will name each point with the name of the car 
# in question:

# Now you can see which cars are similar to one another 
# For example, the Maserati Bora, Ferrari Dino and Ford Pantera L 
# all cluster together at the top
# Makes sense, as all of these are sports cars


# plotting the PCA - PC1 vs PC2
library(ggbiplot)
ggbiplot(mtcars.pca)

# add labels to see where each car falls in plot
ggbiplot(mtcars.pca, labels = rownames(mtcars))

# how can we better interpret this data?
# Maybe if you look at the origin of each of the cars. 
# You'll put them into one of three categories (cartegories?), 
# one each for the US, Japanese and European cars. 
# You make a list for this info, then pass it to the groups argument 
# of ggbiplot. You'll also set the ellipse argument to be TRUE, 
# which will draw an ellipse around each group.
mtcars.country <- c(rep("Japan", 3),
                    rep("US", 4),
                    rep("Europe", 7),
                    rep("US", 3),
                    "Europe",
                    rep("Japan", 3),
                    rep("US", 4),
                    rep("Europe", 3),
                    "US",
                    rep("Europe", 3))

ggbiplot(mtcars.pca, 
         ellipse = TRUE, 
         labels = rownames(mtcars),
         groups = mtcars.country)

# Now you see something interesting: 
# the American cars form a distinct cluster to the right. 
# Looking at the axes, you see that the American cars are 
# characterized by high values for cyl, disp, and wt. 

# Japanese cars, on the other hand, are characterized by high mpg. 

# European cars are somewhat in the middle and less tightly clustered 
# than either group
 

# Of course, you have many principal components available, 
# each of which map differently to the original variables. 

# You can also ask ggbiplot to plot these other components, 
# by using the choices argument.




# how does PC3 & PC4 look like?
ggbiplot(mtcars.pca,
         ellipse = TRUE,
         choices = c(3,4),
         labels = rownames(mtcars),
         groups = mtcars.country)
# don't see much bc PC3 & PC4 explain a small % of total variation
# it would be surprising if we found that they were very informative 
# and separated the groups or revealed apparent patterns

# Moment to recap: having performed a PCA using mtcars dataset, 
# we can see clear separation between American and Japanese cars 
# along a principal component that is closely correlated to 
# cyl, disp, wt, and mpg

# Provides some clues for future analyses; 
# if we were to try to build a classification model to identify 
# origin of a car, these variables might be useful.


# can customize graphical parameters of ggbiplot
ggbiplot(mtcars.pca,
         ellipse = TRUE,
         obs.scale = 1, 
         var.scale = 1,
         var.axes=FALSE,   
         labels=rownames(mtcars), 
         groups=mtcars.country)



