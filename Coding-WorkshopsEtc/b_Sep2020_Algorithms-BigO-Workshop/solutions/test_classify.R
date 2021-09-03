# If you have not installed testthis before, run the following
# commented out line of code in your R interpreter.
# install.packages("testthat")
library("testthat")

# You may need to change the path to this directory depending on what your
# working directory is when you execute the file. We assume you execute it 
# from the top level of the repo. If your working directory is the folder
# containing this file, change it to source('classify_functions_code.R')
source('big-o/exercises/classify_functions_code.R')

test_that("reverse_compliment works", {
    expect_identical(reverse_compliment(''), '')
    expect_identical(reverse_compliment('A'), 'T')
    expect_identical(reverse_compliment('T'), 'A')
    expect_identical(reverse_compliment('C'), 'G')
    expect_identical(reverse_compliment('G'), 'C')
    expect_identical(reverse_compliment('ATCG'), 'CGAT')
})

test_that("count_occurance works", {
    expect_identical(count_occurance('G', 'G'), 1)
    expect_identical(count_occurance('AAA', 'A'), 3)
    expect_identical(count_occurance('AAA', 'AA'), 2)
    expect_identical(count_occurance('TAGTAGTAG', 'TAG'), 3)
    expect_identical(count_occurance('AATAATAT', 'AT'), 3)
    expect_identical(count_occurance('ATCGATCG', 'ATCG'), 2)
})


# This helper function was taken from Github. The testthat package does not support 
# comparison of named lists by default: https://github.com/r-lib/testthat/issues/473
# This function allows us to check that the contents of two lists is identical even 
# if the order of those contents is not.
contents_identical <- function(a, b) {
  # Convert to named vectors - needed for sorting later.
  if (is.null(names(a))) {
    names(a) <- rep("", length(a))
  }
  if (is.null(names(b))) {
    names(b) <- rep("", length(b))
  }

  # Fast path for atomic vectors
  if (is.atomic(a) && is.atomic(b)) {
    # Sort first by names, then contents. This is so that the comparison can
    # handle duplicated names.
    a <- a[order(names(a), a)]
    b <- b[order(names(b), b)]

    return(identical(a, b))
  }

  # If we get here, we're on the slower path for lists

  # Check if names are the same. If there are duplicated names, make sure
  # there's the same number of duplicates of each.
  if (!identical(sort(names(a)), sort(names(b)))) {
    return(FALSE)
  }

  # Group each vector by names
  by_names_a <- tapply(a, names(a), function(x) x)
  by_names_b <- tapply(b, names(b), function(x) x)

  # Compare each group
  for (i in seq_along(by_names_a)) {
    subset_a <- by_names_a[[i]]
    subset_b <- by_names_b[[i]]

    unique_subset_a <- unique(subset_a)
    idx_a <- sort(match(subset_a, unique_subset_a))
    idx_b <- sort(match(subset_b, unique_subset_a))
    if (!identical(idx_a, idx_b)) {
      return(FALSE)
    }
  }

  TRUE
}

count_kmers('A', 1)
 
test_that("unique_kmers works", {
    contents_identical(unique_kmers('A', 1), list('A'))
    contents_identical(unique_kmers('T', 1), list('T'))
    contents_identical(unique_kmers('C', 1), list('C'))
    contents_identical(unique_kmers('G', 1), list('G'))
    contents_identical(unique_kmers('ATCG', 1), list('A', 'T', 'C', 'G'))
    contents_identical(unique_kmers('ATCG', 2), list('AT', 'TC', 'CG'))
    contents_identical(unique_kmers('ATCG', 3), list('ATC', 'TCG'))
    contents_identical(unique_kmers('ATCG', 4), list('ATCG'))
    contents_identical(unique_kmers('AAATTTCCCGGG', 2), list('AA', 'AT', 'TT', 'TC', 'CC', 'CG', 'GG'))
})

test_that("count_kmers works", {
    contents_identical(count_kmers('A', 1), list('A' = 1))
    contents_identical(count_kmers('T', 1), list('T' = 1))
    contents_identical(count_kmers('C', 1), list('C' = 1))
    contents_identical(count_kmers('G', 1), list('G' = 1))
    contents_identical(count_kmers('ATCG', 1), list('A' = 1, 'T' = 1, 'C' = 1, 'G' = 1))
    contents_identical(count_kmers('ATCG', 2), list('AT' = 1, 'TC' = 1, 'CG' = 1))
    contents_identical(count_kmers('ATCG', 3), list('ATC' = 1, 'TCG' = 1))
    contents_identical(count_kmers('ATCG', 4), list('ATCG' = 1))
    contents_identical(count_kmers('AAATTTCCCGGG', 2), list('AA' = 2, 'AT' = 1, 'TT' = 2, 'TC' = 1, 'CC' = 2, 'CG' = 1, 'GG' = 2))
})
