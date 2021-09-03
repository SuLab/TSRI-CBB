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