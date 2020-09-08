# Finding Clusters of K-Mers Efficiently

As part of attempts to determine the origin of replication, bioinformatics software will attempt to identify regions of the genome that have clusters of some particular k-mer. This problem, already computationally expensive due to the size of a typical genome, is complicated by a number of factors:

* We typically do not know *which* k-mer we are searching for until after we find it, so we must count them all.
* Global counts of k-mers aren't especially useful in this context: we are specifically looking for a section of the genome with a high count of the k-mer in question.
* The existence of a particular k-mer as well as its reverse compliment will both contribute to the likelihood that this is a replication origin site.

## The Task

Create a program that identifies fixed-size regions within a genome that have clusters of k-mers. Specifically write a program that:

* Accepts as input:
    * `genome` — a string representing the genome of an organism.
    * `kmer_length` - an integer representing the length of the k-mers to be considered for clumping.
    * `window_size` — an integer representing the size of the "region of interest".
    * `min_kmer_count` – an integer representing the minimum number of duplicate k-mers found within `window_size` of each other to be considered a cluster.
* Returns as output:
    * A dictionary mapping all the k-mers that satisfy the clustering criteria to a list of all the start locations within `genome` for those clusters.
    * Each position in the list should be a start location of the k-mer satisfying the clustering criteria.
        * For example, consider the genome `'ATATGATGATAT'` the 3-mer `'ATG'` a `window_length` of 10, and a `min_kmer_count`of 2.
        * In reality, we could map this window to all the positions `[0, 1, 2]` — but all of these positions contain the SAME cluster, and the most relevant of those positions is `2` because it is the start of the first copy of our k-mer `'ATG'`. 
            * Including positions 0 and 1 in our solution would be both redundant and less useful in subsequent analysis. 

For example, suppose we ran this code and got the following result:

```python
clustering_kmers(genome, 3, 50, 5)
{
    'ATG': [0, 576]
    'GGT': [732]
}
```

This implies that in the string `genome` there are two 3-mers (`'ATG'` and `'GGT'`) that ever occur at least 5 times within a substring of length 50. Furthermore, for the windows containing `'ATG'` that substring (`'ATG'`) begin at positions 0 and 576, and for `'GGT'` that substring begins at position 732. 

In addition to writing this program, you should:

* Write some test cases to verify the correctness of your solution.
* Perform a Big O analysis of your solution.
* Search for possible optimizations, and if you can think of some, implement them!
* **Bonus points:** Write some timing code and *large* test cases to see how fast your program is in reality, not just in Big O terms.

## Some Hints:

* There are really a few problems being solved here, consider breaking the problem into smaller sub-problems and solve them separately.
    * Map all the unique k-mers to all starting locations...
    * Filter out k-mers that couldn't satisfy the criteria...
    * For each list of locations find the relevant windows... 
    * Done right, you can test these sub-tasks individually, which can give you more confidence in the final solution!
* A good rule of thumb for software development:
    * First, get the program to run.
    * Second, make the program correct.
    * Third, make it fast. 
    * It's usually easier to refactor a working solution into a highly optimized one.
        * Plus you learn a lot about the problem in steps 1 and 2. 

# Looking For Even More of a Challenge?

In order to make this problem a little easier to solve, we ignored a critical reality of genetics: mutations occur. This means that a k-mer that is off by one or two nucleotides may actually be a match that has been mutated either through insertion, deletion, or substitution. Similarly, our tools might also contribute to these differences: genetic sequencing techniques sometimes include errors that may also be an insertion, deletion, or substitution. Can you update your code, or write a new program that can gracefully handle such errors?

The challenge is to write a a new version of this code that accepts two additional parameters, `distance_type` and `error_tolerance` and modify the code such that "near matches" as defined by the distance type and error tolerance parameters be included in the clustering count. We have not provided solutions to these bonus challenges — often times in the real world you must be able to verify your own solution. However, there are numerous solutions both to the overall problem and the individual subproblems available online.

Additionally, we are suggesting some starting points for your research.

## Research:

There are two relevant ways to quantify the "difference" between two strings. The [Hamming Distance](https://en.wikipedia.org/wiki/Hamming_distance) and the [Edit Distance](https://en.wikipedia.org/wiki/Edit_distance). [Here is a video](https://www.youtube.com/watch?v=MCvHeW13DsE) discussing both kinds of distance in the context of bioinformatics and our problem, the [whole playlist]9https://www.youtube.com/watch?v=MCvHeW13DsE) is useful and a few videos later they [solve the edit distance problem](https://www.youtube.com/watch?v=8Q2IEIY2pDU&list=PL2mpR0RYFQsBiCWVJSvVAO3OJ2t7DzoHA&index=34&t=0s).

You can practice and get some test cases for [edit distance on leetcode](https://leetcode.com/problems/edit-distance/) and [hamming distance on Jet Brains Academy](https://hyperskill.org/learn/step/5240) (signup required for both...).

Once you feel comfortable with computing these distances, incorporate them into your solution to the clumping problem.

**Good Luck!**