## Classifying Functions With Big O

This exercise is designed to help you practice classifying programs
into complexity classes using Big O notation. In addition to actually
classifying the programs this exercise is also meant to expose some
of the limitations of Big O and algorithmic complexity.

These tools are only *one* aspect of what makes programs fast
and slow, albeit an important one. They are also, at their heart, 
a fuzzy estimate into a program's speed.

For each function below do the following:

 * Clearly define the size of the input. 
   * Is it the length of some string?
   * Is it the magnitude of some number?
   * Is it something else?
   * Remember, they may be multiple relevant inputs!

 * Identify an input representing a worst case scenario, which 
   would cause the maximum number of operations relative to the 
   input size.
     * There might not be a particular input that is worse than 
       other inputs. If that's the case, try to explain why.

 * Determine roughly how many operations will occur
   relative to that input size.
     * This will look like a formula, not a number. 
     * e.g. 5n+n^2 or 30n
     * This is an estimate, so don't get caught up trying to be
       too accurate.

 * Once you have determined the formula, reduce it to it's Big O
   notation form. e.g. 5n+n^2 ==> O(n^2)
     * Decide if this reduction is fair, or if it might be misleading
       (as an example, 10000000n being O(n) is misleading)

 * Decide if the pathological worst case scenario is a realistic
   one that will occur frequently for this function. 
     * This is a judgement call and reasonable people might disagree.
     * Disagreement can be healthy, discuss this point with your group.

 * If you determined that the pathological worst case is probably 
   not a realistic/frequent occurrence, try to define the Big O for
   the "average case."
     * This is again a judgement call, and one that requires some
       domain expertise with respect to how the software will be
       used. 

## Reverse Compliment:

```python
def reverse_compliment(dna_sequence):
    '''
    This function takes a string representing a dna sequence 
    as input, and returns its reverse complement.
    '''
    compliments = {
        'T': 'A',
        'A': 'T',
        'C': 'G',
        'G': 'C'
    }

    rev_comp = []
    for c in dna_sequence[::-1]:
        rev_comp.append(compliments[c])
    
    return ''.join(rev_comp)
```

```R
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
```
## Counting Patterns in a String (or Genome)

```python
def count_occurrence(genome, pattern):
    '''
    This function accepts two strings, one representing the genome
    of an organism (or a part of the genome) and another representing
    some smaller DNA/RNA pattern. It returns the number of times this
    pattern occurs within the provided genome.
    '''
    count = 0
    final_search_position = len(genome) - len(pattern) + 1
    
    for start_position in range(final_search_position):
        match = True
        for i, c in enumerate(pattern):
            if genome[start_position + i] != c:
                match = False
                break

        if match:
            count += 1
        
    return count
```

```R
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
```

## Finding Unique K-mers In a String (or Genome)

```python
def unique_kmers(genome, k):
    '''
    This function takes in a string representing the genome of an
    organism (or section of a genome) and an integer value k. It 
    returns a list of all the unique substrings of length k
    (often called k-mers) contained in that genome.
    '''
    kmers = []
    final_kmer_position = len(genome) - k + 1
    
    for start_position in range(final_kmer_position):
        # Hint: Consider this line carefully... 
        kmer = genome[start_position:start_position + k]
        
        # Looping to check if this kmer is already in the list
        new_kmer = True
        for known_kmer in kmers:
            if known_kmer == kmer:
                new_kmer = False
                break

        if new_kmer:
            kmers.append(kmer)
    
    return kmers
```

In addition to the questions posed above, consider this:

the inner for loop, and following if statement can be replaced with this much simpler code:

```python
if kmer not in kmers:
    kmers.append(kmer)
```

Does using this syntax change the complexity? Hint, see this Python documentation: https://wiki.python.org/moin/TimeComplexity

```R
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
```

## Counting the Unique K-mers in a String (or Genome)

```python
def count_kmers(genome, k):
    '''
    This function accepts a string representing a genome
    and an integer k. It returns a dictionary which maps
    each occurring k-mer to the number of times that k-mer
    occurs within the genome.

    Note that it uses the above function, and so you 
    must consider that functions complexity in determining
    this functions complexity.
    '''
    all_kmers = unique_kmers(genome, k)

    kmer_counts = {}
    for kmer in all_kmers:
        # Start by assuming we don't encounter this kmer
        # (we know we will, but this makes the code cleaner)
        kmer_counts[kmer] = 0
        
        # Loop over the full genome searching for this kmer
        stop_position = len(genome) - k + 1
        for i in range(stop_position):
            inner_kmer = genome[start_position:start_position + k]
            
            if inner_kmer == kmer:
                kmer_counts[kmer] += 1

    return kmer_counts
```

```R
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
```