# This file contains just the functions from the classify functions exercise. 
# Primarily, this is to make the code easier to run, test, and debug.

# You may wish to modify this code to complete the exercise, or you may wish to 
# create a new file and make your modifications there.


# This function takes in a string representing the genome of an
# organism (or section of a genome) and an integer value k. It 
# returns a list of all the unique substrings of length k
# (often called k-mers) contained in that genome.
unique_kmers <- function(genome, k) {
    kmers <- list()
    final_kmer_position <- nchar(genome) - k + 1
    
    for(start_position in 1:final_kmer_position) {
        # Hint: Consider this line carefully... 
        kmer <- substring(genome, start_position, start_position + k - 1)

        # Looping to check if this kmer is already in the list
        new_kmer <- TRUE
        for(i in seq_along(kmers)) {
            known_kmer <- kmers[i]
            if(known_kmer == kmer) {
                new_kmer <- FALSE
                break
            }
        }

        if(new_kmer) {
            # Note: like above, this is O(n) where n is the length of kmers
            # which may impact your Big O analisys.
            kmers <- append(kmers, kmer)
        }
    }
    
    return(kmers)
}

# This function accepts a string representing a genome
# and an integer k. It returns a dictionary which maps
# each occurring k-mer to the number of times that k-mer
# occurs within the genome.

# Note that it uses the above function, and so you 
# must consider that functions complexity in determining
# this functions complexity.
count_kmers <- function(genome, k) {
    all_kmers <- unique_kmers(genome, k)
    kmer_counts <- list()
    
    for(i in seq_along(all_kmers)) {
        # Start by assuming we don't encounter this kmer
        # (we know we will, but this makes the code cleaner)
        kmer = all_kmers[[i]]
        kmer_counts[[kmer]] <- 0
        
        # Loop over the full genome searching for this kmer
        stop_position <- nchar(genome) - k + 1
        for(start_position in 1:stop_position) {
            inner_kmer <- substring(genome, start_position, start_position + k - 1)

            if(inner_kmer == kmer) {
                kmer_counts[[kmer]] <- kmer_counts[[kmer]] + 1
            }
        }
    }
    
    return(kmer_counts)
}

