library("testthat")

# You may need to change the path to this directory depending on what your
# working directory is when you execute the file. We assume you execute it 
# from the top level of the repo. If your working directory is the folder
# containing this file, change it to source('classify_functions_code.R')
source('big-o/solutions/optimize_functions_code.R')
source('big-o/solutions/find_kmer_clumps_code.R')


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

# This test uses a bit of a hack to test hash equality...
# we just convert it to a list and check the the list contents are identical. 
test_that("count_kmers works", {
    contents_identical(as.list(count_kmers('A', 1)), as.list(hash('A' = 1)))
    contents_identical(as.list(count_kmers('T', 1)), as.list(hash('T' = 1)))
    contents_identical(as.list(count_kmers('C', 1)), as.list(hash('C' = 1)))
    contents_identical(as.list(count_kmers('G', 1)), as.list(hash('G' = 1)))
    contents_identical(as.list(count_kmers('ATCG', 1)), as.list(hash('A' = 1, 'T' = 1, 'C' = 1, 'G' = 1)))
    contents_identical(as.list(count_kmers('ATCG', 2)), as.list(hash('AT' = 1, 'TC' = 1, 'CG' = 1)))
    contents_identical(as.list(count_kmers('ATCG', 3)), as.list(hash('ATC' = 1, 'TCG' = 1)))
    contents_identical(as.list(count_kmers('ATCG', 4)), as.list(hash('ATCG' = 1)))
    contents_identical(as.list(count_kmers('AAATTTCCCGGG', 2)), as.list(hash('AA' = 2, 'AT' = 1, 'TT' = 2, 'TC' = 1, 'CC' = 2, 'CG' = 1, 'GG' = 2)))
})

test_that("clumping_kmers works", {
    contents_identical(as.list(clumping_kmers('CGGACTCGACAGATGTGAAGAACGACAATGTGAAGACTCGACACGACAGAGTGAAGAGAAGAGGAAACATTGTAA', 5, 50, 4)), as.list(hash('CGACA' = list(7), 'GAAGA' =  list(17))))
    contents_identical(as.list(clumping_kmers('AAAACGTCGAAAAA', 2, 4, 2)), as.list(hash('AA' = list(1, 2, 10, 11, 12))))
    contents_identical(as.list(clumping_kmers('ACGTACGT', 1, 5, 2)), as.list(hash('A' =  list(1), 'C' =  list(2), 'G' =  list(3), 'T' =  list(4))))
    contents_identical(as.list(clumping_kmers('CCACGCGGTGTACGCTGCAAAAAGCCTTGCTGAATCAAATAAGGTTCCAGCACATCCTCAATGGTTTCACGTTCTTCGCCAATGGCTGCCGCCAGGTTATCCAGACCTACAGGTCCACCAAAGAACTTATCGATTACCGCCAGCAACAATTTGCGGTCCATATAATCGAAACCTTCAGCATCGACATTCAACATATCCAGCG', 3, 25, 3)), as.list(hash('CCA' =  list(78, 100), 'AAA' =  list(18, 19), 'GCC' =  list(77), 'TTC' =  list(65), 'CAG' =  list(92), 'CAT' =  list(178)))) 
})
