# Optimizing Functions Solutions

The optimized solution to these problems are remarkably similar, and both end up being strictly bounded by O(GK). Neither runtime depends on the number of unique kmers, and in the second function we have eliminated the inner loop over the genome per each unique k-mer by keeping a rolling count of every k-mer as we loop over the genome, which we now do only once. 


## Unique Kmers 

```python
def unique_kmers(genome, k):
    '''
    This function takes in a string representing the genome of an
    organism (or section of a genome) and an integer value k. It 
    returns a list of all the unique substrings of length k
    (often called k-mers) contained in that genome.

    But the runtime is simply O(GK), and is completely independent of 
    the value U (the number of unique k-mers)
    '''
    kmers = {} # NOTE: a dictionary instead of a list.
    final_kmer_position = len(genome) - k + 1
    
    for start_position in range(final_kmer_position):
        kmer = genome[start_position:start_position + k]

        # We don't even need to check if it's in there or not.
        # If it is, it'll stay true, of it's not it will become true.
        kmers[kmer] = True
    
    return list(kmers.keys())
```

```R
# This function takes in a string representing the genome of an
# organism (or section of a genome) and an integer value k. It 
# returns a list of all the unique substrings of length k
# (often called k-mers) contained in that genome.

# But the runtime is simply O(GK), and is completely independent of 
# the value U (the number of unique k-mers)
unique_kmers <- function(genome, k) {
    kmers <- hash() # NOTE: a hash instead of a list.
    final_kmer_position <- nchar(genome) - k + 1
    
    for(start_position in 1:final_kmer_position) {
        kmer <- substring(genome, start_position, start_position + k - 1)

        # We don't even need to check if it's in there or not.
        # If it is, it'll stay true, of it's not it will become true.
        kmers[[kmer]] <- TRUE
    }
    
    return(as.list(keys(kmers)))
}
```

## Kmer Frequencies

```python
def count_kmers(genome, k):
    '''
    This function accepts a string representing a genome
    and an integer k. It returns a dictionary which maps
    each occurring k-mer to the number of times that k-mer
    occurs within the genome.

    Instead of finding the unique k-mers and then counting them
    one by one, we just look at the genome once and keep a running
    count of ALL the k-mers at the same time!

    Note that it is almost identical to the above function!
    '''
    kmers = {}
    final_kmer_position = len(genome) - k + 1
    
    for start_position in range(final_kmer_position):
        kmer = genome[start_position:start_position + k]

        if kmer not in kmers:
            kmers[kmer] = 0
        
        kmers[kmer] += 1
    
    return kmers
```

```R
# This function accepts a string representing a genome
# and an integer k. It returns a hash which maps
# each occurring k-mer to the number of times that k-mer
# occurs within the genome.

# Instead of finding the unique k-mers and then counting them
# one by one, we just look at the genome once and keep a running
# count of ALL the k-mers at the same time!

# Note that it is almost identical to the above function!
count_kmers <- function(genome, k){
    kmers <- hash() # NOTE: a hash instead of a list.
    final_kmer_position <- nchar(genome) - k + 1
    
    for(start_position in 1:final_kmer_position) {
        kmer <- substring(genome, start_position, start_position + k - 1)

        # We don't even need to check if it's in there or not.
        # If it is, it'll stay true, of it's not it will become true.
        if(is.null(kmers[[kmer]])) {
            kmers[[kmer]] <- 0
        }

        kmers[[kmer]] <- kmers[[kmer]] + 1
    }

    return(kmers)
}
```