# This file contains just the functions from the classify functions exercise. 
# Primarily, this is to make the code easier to run, test, and debug.


# This function takes a string representing a dna sequence 
# as input, and returns its reverse complement.
reverse_compliment <- function(dna_sequence) {

    compliments <- list(
        'T' = 'A',
        'A' = 'T',
        'C' = 'G',
        'G' = 'C'
    )

    rev_comp <- c()
    # This strsplit syntax allows us to loop over the characters in a string
    for(c in strsplit(dna_sequence, '')[[1]]) {
        # NOTE: In R, adding items to a list this way ALWAYS
        # results in a copy of the list, which means this operation
        # is not O(1), it's O(n) where n is the length size of 
        # rev_comp... Consider this in your analysis. It also means
        # This function has a different complexity from the Python 
        # implementation!
        rev_comp <- append(rev_comp, compliments[[c]])
    }

    return(paste(rev(rev_comp), collapse=''))
}

# This function accepts two strings, one representing the genome
# of an organism (or a part of the genome) and another representing
# some smaller DNA/RNA pattern. It returns the number of times this
# pattern occurs within the provided genome.
count_occurance <- function(genome, pattern) {
    count <- 0
    final_search_position <- nchar(genome) - nchar(pattern) + 1
    
    for(start_position in 1:final_search_position) {
        match <- TRUE
        for (i in 1:nchar(pattern)) {
            c_in_pattern <- substring(pattern, i, i)

            offset_position = start_position + i - 1
            c_in_genome <- substring(genome, offset_position, offset_position)

            if(c_in_genome != c_in_pattern) {
                match <- FALSE
                break
            }
        }
        if(match) {
            count <- count + 1
        }
    }
        
    return(count)
}


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

