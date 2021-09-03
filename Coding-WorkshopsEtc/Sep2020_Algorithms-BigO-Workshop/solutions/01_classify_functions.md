## Classifying Functions With Big O Solutions.

This document contains solutions and further explanations for each of the problems in the classify functions problem.

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
* Clearly define the size of the input:
    * **The length of the string `dna_sequence`**

* Identify an input representing a worst case scenario, which 
   would cause the maximum number of operations relative to the 
   input size.
    * **In this case, there is no definable worst case. Regardless of the input, this program will look at each character in the input string once, append it to the list `rev_comp` and then create a string using the `join` method.**

* Determine roughly how many operations will occur
   relative to that input size.
    * **Roughly 2n, where n is the length of `dna_sequence`. The loop looks at each element once, and the `join` method does as well.**
    * **You might also say something like 2n+5, where 5 represents the constant amount of work required to setup the `compliments` dictionary and add 4 elements to it. 5 is a slight underestimate, but as long as `dna_sequence` is relatively long, it hardly matters.** 

* Once you have determined the formula, reduce it to it's Big O
   notation form. e.g. 5n+n^2 ==> O(n^2)
    * **O(n), where n is the length of `dna_sequence`.**

* Decide if the pathological worst case scenario is a realistic
   one that will occur frequently for this function. 
    * **Since there is not a pathological worst case, this isn't relevant.**

* If you determined that the pathological worst case is probably 
   not a realistic/frequent occurrence, try to define the Big O for
   the "average case."
    * **See above.**

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

* The main difference in the R code is the fact that this method of appending is O(n) instead of O(1)
    * This makes the overall complexity of this function O(n^2). 
    * Because an O(n) method used in loop that happens n times.

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
* This time, the analysis is essentially the same for both versions of the code.

* Clearly define the size of the input. 
    * **There are two important inputs, the length of `genome` and the length of `pattern`**

* Identify an input representing a worst case scenario, which 
   would cause the maximum number of operations relative to the 
   input size.
    * **When `genome` and `pattern` share a long repetitive sequence.** 
    * For example, consider `genome='aaaaaaaaaaaaaaaaaaaaaaaaaa'` and `pattern='aaaaaaaaaaaaaaaa'`. In this case, we will repeatedly loop through the entirety of `pattern` in the inner loop. 
    * Contrast this with the same value for `genome` but `pattern='gaaaaaa'`, where the `break` statement will exit the inner for loop on the first character.

* Determine roughly how many operations will occur
   relative to that input size.
    * Using G to mean `len(genome)` and P to mean `len(pattern)`, we have roughly:
    * **7 + 4G + 2PG**
    * 7 is from the initial setup of `count` and `final_search_position` and the `return` statement. 
    * 4G is from repeatedly setting `match=True`, checking `if match:` and incrementing `count`.
    * 2PG is from looking up the position in `genome` and comparing it to `c`. I didn't count the statements inside the if, because they will only happen once PER G, not PER P because of the break statement. 

* Once you have determined the formula, reduce it to it's Big O
   notation form. e.g. 5n+n^2 ==> O(n^2)
    * **O(PG)** (which is generally considered most similar to O(n^2) as it's a multiple of two inputs that will both scale linearly). 
    * **I would argue that no, this is not misleading. The coefficients in the formula are all relatively small and in the same range (4 and 2).**

* Decide if the pathological worst case scenario is a realistic
   one that will occur frequently for this function. 
     * **This is not completely straightforward.** 
     * There ARE large repetitive sections of DNA in most organisms, but they aren't generally overlapping the same way the "all a's" input does. In most cases, we will hit the `break` statement relatively early on in the inner for loop. 
     * **Overall, I would say "no" the pathological case is not going to occur very frequently.**

* If you determined that the pathological worst case is probably 
   not a realistic/frequent occurrence, try to define the Big O for
   the "average case."
    * A more realistic average case will terminate the inner `for` loop via the `break` statement well before reaching the end of `pattern`.
    * **Therefore, I believe O(G) is a better estimate of the "average" case.**


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

* Clearly define the size of the input. 
    * **The length of the string `genome` and the value of the integer `k` are both important.**

 * Identify an input representing a worst case scenario, which 
   would cause the maximum number of operations relative to the 
   input size.
    * **The more unique k-mers there are, the longer the list `kmers` will become, which makes the inner `for` loop longer to execute. So a worst case would be a `genome` and choice of `k` such that all the k-mers are unique.**
    * **Additionally, when `k` is around half the length of `genome` things are worse: if `k` is very small, making `k` length slices is cheap. When `k == len(genome)` there is only 1 possible k-mer (the whole genome). Halfway between results in the most looping overall.**
    * This fact is a bit of a challenge for the Big O analysis of the function: there is no clear way to represent the number of unique k-mers in `genome` with respect to the size of the input: `aaaaaaaa` and `abcdefgh` are the same length, but the first has only one unique 3-mer and the second has all unique 3-mers. 
    * Furthermore, there is no way to know this quantity prior to executing the algorithm for any particular string. This illustrates the importance of understanding the domain/common inputs for our programs.

 * Determine roughly how many operations will occur
   relative to that input size.
    * Using G as the length of `genome` and K as the value of `k`.
    * **5 + 3G + GK**
        * 5 for the initial setup and return.
        * 3G for `new_kmer = True` and the final `if` statement with `append`.
        * GK for `genome[start_position:start_position + k]` which costs K operations to perform the slice operation, and occurs in the outer `for` loop (meaning, once per G).
     * However, this formula essentially leaves out the cost of looping over `known_kmers`. Supposing we add U as the number of unique k-mers in `genome`, we could use the formula:
    * **5 + 2G + GK + GU**
        * If K is small, but U is large, this could really matter!
    * But, we can put an upper bound on U based on K because we know there are only 4 values in our 'alphabet': the 4 base pairs. Therefore, U will never be more than 4^K. Therefore, we can rewrite this as:
    * **5 + 2G + GK + G(4^K)**, which looks a lot worse than GU...

 * Once you have determined the formula, reduce it to it's Big O
   notation form. e.g. 5n+n^2 ==> O(n^2)
    * **Either O(GK) or O(GU), depending on which of K or U is larger. Because of the uncertainty, you could say O(GU + GK). Because we can bound U, you might also say O(G4^K)**
    * If you said O(GK), it would be misleading by leaving out the work done by the inner `for` loop. If you said O(GU) it would be misleading by leaving out the work required to compute the slice. If you said O(GU + GK), it's more accurate, but it is still hard to know the value of U beforehand, which you could argue is "misleading."
    * Because there's no way of knowing for sure how many of the possible unique k-mers will actually be represented in `genome` O(G4^K) could also be considered misleading.

 * Decide if the pathological worst case scenario is a realistic
   one that will occur frequently for this function. 
    * **Not really. In most genetic data, as `k` gets large a relatively small number of the possible k-mers will actually be represented in the genome which means we won't get that close to having 4^K entries in the `known_kmers` list.**

 * If you determined that the pathological worst case is probably 
   not a realistic/frequent occurrence, try to define the Big O for
   the "average case."
     * **O(GK) is a decent estimate, this number of operations will always happen. But we still have to keep in mind that the number of unique k-mers might overwhelm us in some datasets.**

**We also asked:** In addition to the questions posed above, consider this:

the inner `for` loop, and following `if` statement can be replaced with this much simpler code:

```python
if kmer not in kmers:
    kmers.append(kmer)
```

Does using this syntax change the complexity? Hint, see this Python documentation: https://wiki.python.org/moin/TimeComplexity

* **No, the `in` statement is O(n) where n = the length of the list.** 
    * That said, it's definitely easier to read the code using `in`!

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

* Unfortunately, due to the use of `append` again, this function is again less efficient than the Python version.
    * The append operation is O(U), which happens within an O(G) loop.
    * However, we already have one such loop, so this changes the analysis only in terms of a constant 2GU vs GU.
    * So the Big O remains the same, while the R runtime will surely be slower. (small constant on a BIG value)

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

* Clearly define the size of the input. 
   * **The length of the string `genome` and the value of the integer `k` are both important.**

* Identify an input representing a worst case scenario, which 
   would cause the maximum number of operations relative to the 
   input size.
     * **The worst case is the same as the previous question.**

* Determine roughly how many operations will occur
   relative to that input size.
     * Recall that `unique_kmers` costs: 5 + 2G + GK + G(4^K), and that the size of the return value is the number of unique k-mers, which is bounded by 4^K.
     * **5 + 2G + GK + G(4^K) + 4^K*(GK)** (OUCH!)
     * The only new thing is: 4^K*(GK), which is saying: for every unique k-mer, we loop over the genome and make a slice of length K at each position.

* Once you have determined the formula, reduce it to it's Big O
   notation form. e.g. 5n+n^2 ==> O(n^2)
    * **O( 4^K*(GK) )**
    * It's definitely misleading for the same reasons as the last problem (most possible k-mers won't actually be represented). 
    * However, this function will still be *incredibly* slow.

 * Decide if the pathological worst case scenario is a realistic
   one that will occur frequently for this function. 
     * **No, for the same reasons as above.**

 * If you determined that the pathological worst case is probably 
   not a realistic/frequent occurrence, try to define the Big O for
   the "average case."
     * **This is honestly hard to say, but it also hardly matters: Lets heavily underestimate the number of unique k-mers by assuming there are exactly K of them. Now our Big O estimate would be O(GK^2)**
     * Genomes are generally big, even for smallish K values, this is just way too much processing work. 
     * Assume a genome with only 10,000 base pairs and k=9, thats 10,000*81 = 810,000 operations. Unfortunately:
        * The average bacterial genome is actually ~3.8 million base pairs.
        * The average mammalian genome is actually ~3.5 billion base pairs.

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

* Here too the R code is slower...
    * Finding a value within a `list` in R is O(n), so the update `kmer_counts[[kmer]] <- kmer_counts[[kmer]] + 1` takes O(U) time (aka O(4^K)).
        * In Python this lookup is O(1)
        * This again won't change the overall Big O, because we already have an O(G*4^K) term, now we have 2 of them, and we drop the constants.
* **NOTE THAT** Had we used a `hash` instead of a `list` for the variable `kmer_counts` the analysis would be the same as the Python code, so this is an inefficiency introduced by our choices rather than an actual language limitation.