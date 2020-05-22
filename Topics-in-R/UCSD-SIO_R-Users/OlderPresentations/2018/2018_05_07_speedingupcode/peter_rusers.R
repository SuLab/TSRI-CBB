#---------------------------------------------------------
#Rusers script, May 7, 2018
#Speeding up code

#---------------------------------------------------------
#Load packages
library(plyr)
library(tidyverse)
library(microbenchmark)
library(parallel)
library(doParallel)

#---------------------------------------------------------
#Slide 5, generate sample data
set.seed(1014)

df <- data.frame(replicate(6, sample(c(1:10, -99), 10, rep = T)))
names(df) <- letters[1:6]
head(df)

#Save original data frame 
df_orig <- df
#---------------------------------------------------------
#Slide 6, one solution
df$a[df$a == -99] <- NA
df$b[df$b == -99] <- NA
df$c[df$c == -98] <- NA
df$d[df$d == -99] <- NA
df$e[df$e == -99] <- NA
df$f[df$g == -99] <- NA

#Were the -99s replaced?
#Two mistakes, can you spot them?

#---------------------------------------------------------
#Slide 7, write a function to replace -99
fix_missing <- function(x){
	x[x == -99] <- NA
	return(x)
}

#---------------------------------------------------------
#Slide 8, apply function in a loop
for(ii in 1:ncol(df)) {
	df[, ii] <- fix_missing(df[, ii])
}

#worked but generally for loops are slow

#---------------------------------------------------------
#Slide 9, Can apply the function by column
df <- df_orig

df$a <- fix_missing(df$a)
df$b <- fix_missing(df$b)
df$c <- fix_missing(df$c)
df$d <- fix_missing(df$d)
df$e <- fix_missing(df$e)
df$f <- fix_missing(df$e)

#---------------------------------------------------------
#Slide 12, use apply statements
df <- apply(X = df, MARGIN = 2, FUN = fix_missing)
df <- lapply(df_orig, fix_missing) #output is a list rather than a data frame

#---------------------------------------------------------
#Slide 15, Compare speeds of the two approaches
df <- df_orig
microbenchmark(apply(X = df_orig, MARGIN = 2, FUN = fix_missing),
	for(ii in 1:ncol(df)) {
	df[, ii] <- fix_missing(df[, ii])
})

#---------------------------------------------------------
#Slide 18, dplyr
head(iris)
unique(iris$Species)
iris %>% group_by(Species) %>%
	summarize(avg_Sepal.Length = mean(Sepal.Length))

#---------------------------------------------------------
#Slide 19, anonymous functions in dplyr
iris %>%
  group_by(Species) %>%
  do({
    mod <- lm(Petal.Width ~ Petal.Length, data =.)
    coefs <- mod$coefficients
    names(coefs) <- c("intercept", 'slope')
    data.frame(intercept = coefs[1], slope = coefs[2])
  }) 

#---------------------------------------------------------
#Running in parallel
detectCores()

#Create function
lm_width_length <- function(dat){
  mod <- lm(Petal.Width ~ Petal.Length, data = dat)
  coefs <- mod$coefficients
  names(coefs) <- c("intercept", "slope")
  out <- data.frame(intercept = coefs[1], slope = coefs[2])
  return(out)
}

#Usually subtract 2 so that computer doesn't crash
cc <- detectCores() - 2
cl <- makeCluster(cc)

start_time <- Sys.time()

#Quirks of foreach
res <- foreach(xx = unique(iris$Species)) %dopar% {
  #First filter the data
  temp <- iris %>% filter(Species == xx)

  #Then apply the linear model function
  outs <- lm_width_length(temp)
}

par_run_time <- Sys.time() - start_time
(par_run_time)

#Close clusters
stopCluster(cl) 

#Output is a list, convert it to a data frame
names(res) <- unique(iris$Species)

#Convert the list to a data frame
res <- plyr::ldply(res)
names(res)[1] <- 'species'

#-----------------------------
#Mac specific example
res1 <- mclapply(unique(iris$Species), FUN = function(xx){
  #First filter the data
  temp <- iris %>% filter(Species == xx)

  #Then apply the linear model function
  outs <- lm_width_length(temp)
})

#-----------------------------
#Run this in serial
serial_runs <- vector(length = 3, "list")
start_time <- Sys.time()
temp <- iris %>% filter(Species == "setosa")
serial_runs[[1]] <- lm_width_length(temp)

temp <- iris %>% filter(Species == "versicolor")
serial_runs[[2]] <- lm_width_length(temp)

temp <- iris %>% filter(Species == "virginica")
serial_runs[[3]] <- lm_width_length(temp)

run_time <- Sys.time() - start_time
# (run_time)

#-----------------------------
#Compare run times
par_run_time
run_time

#par_run_time is slightly lower
#doesn't make a difference in this example but can for bigger tasks







