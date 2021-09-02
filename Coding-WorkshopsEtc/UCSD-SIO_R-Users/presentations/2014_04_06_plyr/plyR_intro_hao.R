# R-users Group 4/15/2014
# Hao Ye
# plyR
# 
# lots of material stolen from http://plyr.had.co.nz/ and http://plyr.had.co.nz/09-user/

rm(list = ls())
library(plyr)

# basic apply functions ----
# {apply, lapply, sapply, tapply, mapply}

# general idea:
# (1) fit the same model to subsets of data
# (2) calculate summary statistics for each group
# (3) perform group-wise transformations (e.g. scaling)

# apply -- use on arrays or matrices
mat <- matrix(1:24, nrow = 6)
apply(mat, 1, sum) # take sum over the rows
apply(mat, 2, sum) # take sum over the columns

mat3d <- array(1:30, dim = c(2, 3, 5))
apply(mat3d, 1, sum) # take sum, collapsing all but dim 1 (rows)
apply(mat3d, c(1, 2), sum) # take sum, collapsing all but dim 1 and 2 (collapse over depth)

# lapply -- use on lists or vectors (objects with just 1 dimension), returns a list of equal length
data(iris)
by_species <- split(iris, iris$Species)
mean_petal_width <- lapply(by_species, function(df) {mean(df$Petal.Width)})
do.call(rbind, mean_petal_width)

# sapply -- like lapply, but simplifies into vector or matrix
mean_petal_width_vector <- sapply(by_species, function(df) {mean(df$Petal.Width)})

# vapply -- like sapply, but additional argument specifies return type
# (can be useful if function can return multiple types of results)
mean_petal_width <- vapply(by_species, function(df) {mean(df$Petal.Width)}, "")

# tapply -- applies a function to groups defined by unique combination of certain factors
data(mtcars)
average_mpg <- tapply(mtcars$mpg, mtcars$am, mean)
average_mpg <- tapply(mtcars$mpg, list(mtcars$am, mtcars$gear), mean)

# mapply -- applies a function that takes multiple arguments
mapply(rep, 1:3, 2:4)

# plyr functions ----
# functionality is similar to base apply functions
# consistent naming
# input and output determined by name of function (first letter = input type, second letter = output type)
# {aaply, llply, ddply, ldply}

# aaply -- input array, output array

x <- aaply(mat, 1, sum, .drop = FALSE) # don't drop dimensions
aaply(mat, 2, sum)
aaply(mat3d, 1, sum)
aaply(mat3d, c(1, 2), sum)

# llply -- input list, output list (nearly identical to lapply)
mean_petal_width <- llply(by_species, function(df) {mean(df$Petal.Width)})

# ldply -- input list, output data.frame
mean_petal_width <- ldply(by_species, function(df) {mean(df$Petal.Width)}, .id = "Species")

# ddply -- input data.frame, output data.frame (effectively split, lapply, and rbind in one)
mean_petal_width <- ddply(iris, "Species", function(df) {mean(df$Petal.Width)})

# "summarize" function is useful for summary statistics
summary_means <- ddply(iris, "Species", summarize, mean_sepal_length = mean(Sepal.Length), mean_sepal_width = mean(Sepal.Width))
# similar, but using sapply
summary_means <- ddply(iris, "Species", function(df) {sapply(df[,1:4], mean)})

# other variants in plyr:
# mlply -- similar to mapply
mlply(cbind(1:3, 2:4), rep)
# d_ply -- input data.frame, no output (useful for plotting or output to file, etc.)
# raply -- repeat evaluation n times (useful for randomizations), similar to replicate

# additional notes ----
# plyr functions can use progress bars and parallel operation
# dplyr package for data.frames (some functionality written in Rcpp, much faster?)