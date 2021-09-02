# Hao Ye
# R Users Group
# December 5, 2013

library(Rcpp)
library(microbenchmark)

setwd("~/Desktop/rcpp_basics")

# Example 1 -------------------------------------------------------
# (1) use cppFunction (from Rcpp package) to create an R function from c++ source code
#     (N.B. This requires a c++ compiler [usually via Rtools on Windows, or Xcode on Mac])
# (2) use microbenchmark (from microbenchmark package) to do speed comparison

R_fib <- function(n)
{
  if(n < 2) # stopping condition
    return(n)
  return(R_fib(n-1) + R_fib(n-2))
}

# cpp version
cppFunction("
int cpp_fib(int n)
{
  if(n < 2)
    return n;
  return cpp_fib(n-1) + cpp_fib(n-2);
}")

# speed comparison
microbenchmark(cpp_fib(20), R_fib(20))

# Example 2 ---------------------------------------------------------------
# (1) use sourceCpp (from Rcpp package) to compile an external c++ file with 
#     multiple R functions
# (2) demonstrate correct data types for matrices as input/output

# compile c++ function
sourceCpp("mmult.cpp")

mat_size <- 200
a <- matrix(rnorm(mat_size*mat_size), nrow = mat_size)
b <- matrix(rnorm(mat_size*mat_size), nrow = mat_size)

# speed comparison
microbenchmark(mmult(a, b), {a %*% b}, times = 10)





