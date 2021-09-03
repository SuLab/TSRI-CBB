# The built in key/value store "list" is unfortunately an O(n) lookup
# in R, so we need to use the hash library to get the O(1) performance
# we want for lookups in both of these cases. If you haven't installed 
# this library uncomment the following line, or run it from your R interpreter.

# install.packages("hash")
library("hash")

# This function finds clusters of k-mers in a genome.
# * Accepts as input:
#     * `genome` — a string representing the genome of an organism.
#     * `kmer_length` - an integer representing the length of the k-mers to be considered for clumping.
#     * `window_size` — an integer representing the size of the "region of interest".
#     * `min_kmer_count` – an integer representing the minimum number of duplicate k-mers found within `window_size` of each other to be considered a cluster.

# * Returns as output:
#     * A hash mapping all the k-mers that satisfy the clustering criteria to a list of all the start locations within `genome` for those clusters.
#     * Each position in the list should be a start location of the k-mer satisfying the clustering criteria.
#         * For example, consider the genome `'ATATGATGATAT'` the 3-mer `'ATG'` a `window_length` of 10, and a `min_kmer_count`of 2.
#         * In reality, we could map this window to all the positions `[0, 1, 2]` — but all of these positions contain the SAME cluster, and the most relevant of those positions is `2` because it is the start of the first copy of our k-mer `'ATG'`. 
#             * Including positions 0 and 1 in our solution would be both redundant and less useful in subsequent analysis. 

clumping_kmers <- function(genome, kmer_length, window_length, min_kmer_count) {
    # Collect all the unique kmers and where they occur
    kmers <- hash()
    for(start_position in 1:(nchar(genome) - kmer_length + 1)) {
        kmer <- substring(genome, start_position, start_position + kmer_length - 1)
        if(is.null(kmers[[kmer]])) {
            kmers[[kmer]] <- list()
        }

        kmers[[kmer]] <- append(kmers[[kmer]], start_position)
    }

    # For each kmer and it's locations determine if they meet
    # the min-count within the window length.
    candidate_kmers <- hash()
    for(kmer in keys(kmers)) {
        locations <- kmers[[kmer]]
        if(length(locations) < min_kmer_count){
            next
        }

        cluster_window_start_points <- list()
        for(location_start_index in 1:length(locations)) {
            window_start_location <- locations[[location_start_index]]

            # Iteratively check if the next kmer is within the window length and expand the window
            # until we reach the end of the match locations or the kmer falls outside the window
            for(location_end_index in location_start_index:length(locations)) {
                current_match_end_position <- locations[[location_end_index]] + kmer_length
                
                # If the current match is outside the window, go back one location and stop.
                if((current_match_end_position - window_start_location) > window_length) {
                    location_end_index = location_end_index - 1
                    break
                }
            }
            # if there are at least min_kmer_count in this window
            # it's a candidate
            matches_within_window <- (location_end_index - location_start_index) + 1
            if(matches_within_window >= min_kmer_count) {
                cluster_window_start_points <- append(cluster_window_start_points, window_start_location)
            }
        }

        # If we found at least one window for this kmer, add them.
        if(length(cluster_window_start_points) > 0) {
            candidate_kmers[kmer] <- cluster_window_start_points
        }
    }

    return(candidate_kmers)
}