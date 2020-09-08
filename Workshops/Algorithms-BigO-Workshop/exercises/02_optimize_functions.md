# Optimizing Code With Big O In Mind

The complexity/Big O value of a program is only one aspect of what might make a program fast or slow, but it is an important one: Often times taking code from one complexity class to another [e.g. `O(n^2)` ==> `O(n)`] can be the difference between a program that cannot realistically be run to completion, and one that can. 

Further optimizations may not change the complexity class, but can still significantly improve the runtime speed of a program. For example, perhaps a critical for loop can be modified to perform fewer operations per loop, while still achieving the same result [e.g. 35n + 10 ==> 10n + 10].

Moving a piece of code from one complexity class to a better one often requires us to completely change our strategy. Optimizations of the second variety are more often slight changes to the existing strategy. There are opportunities for both kinds of optimization in this exercise but we are primarily focused on the first variety of optimization. Keep that in mind as you work though this exercise. 

## The Task

Two of the four functions we saw in the last section are much slower than they need to be. For each of these functions:

* Identify the section or sections of the code that represent the dominant complexity class.
    * Is it a function call?
    * A series of deeply nested for loops?

* Before you start changing the code, describe an alternate strategy to solve the problem that would be in a smaller complexity class.

* Write at least three test cases, so that you can verify your new code still works as you make changes!
    * Consider making one of these test cases with "big" data (remember, Big O only really matters as the data gets large!) 

* Rewrite the code to apply your new strategy. 
    * Remember to test it!

* Perform a Big O analysis on your new code — is it true that it's in a better complexity class? 
    * How much better is it?

* **Bonus points**, read [this article](https://realpython.com/python-timer/) and then use what you learned to time your code and the old code.
    * How much faster is it?
    * Are the speed differences more apparent with larger input data?

## A Few Hints

* The Python and R solutions are not always the same complexity, due to fundamental differences in how certain data structures work in each language.
    * In particular, the default ways to add items to a list is O(1) in Python but O(n) in R. 
    * There are workarounds for this behavior, but you really have to work to find them.
    * In the solutions here the R code *is in fact* less efficient than the Python code. 

* Try to find ways to unnest for loops. 
    * Nested loops typically represent multiplicative workloads such as O(n^2) or O(n*m).
    * Removing such a nesting to create something with a runtime of 2n or O(n + m) is a huge improvement.

* Try to find ways to look at each relevant piece of data the fewest number of times.
    * If you're looping over a long string twice to perform two tasks, try to do both tasks at the same time and loop over the data only once.

* Choosing the right data structure to store your data can be a big deal.
    * Finding an item in a list or array is O(n), but finding an item in a dictionary, hashmap, or set is O(1).

* Sometimes adhering to the DRY principle is at odds with optimization.
    * Reusing code is great, but sometimes using a function in another function causes you to duplicate work.

## The Functions:

### Finding The Unique k-mers:

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

### Counting Each K-mer

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
```