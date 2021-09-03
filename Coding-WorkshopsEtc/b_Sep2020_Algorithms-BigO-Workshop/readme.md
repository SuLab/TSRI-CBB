## Complexity, Big O, and Optimizing Programs

Both older and emerging approaches to computational biology are computational intensive. This computational cost has very real financial, environmental, and time costs. As grad students advance their own research, ensuring that the code they write is fast and efficient can save them precious days and grant money. 

This workshop is focused on helping students understand what makes a computer program fast or slow. This involves algorithmic analysis, concepts related to physical computers and their architecture, as well as data modeling decisions such as how to represent genetic data. 

We’ll discuss a variety of factors involved in making a computer program fast or slow, and arm students with tools to analyze the performance of a program.

**Background, students will get the most out of this workshop if they:**

* Already know the fundamentals of at least one programming language (R or Python preferred)
    * Using variables and primitive data types (strings, integers, floats)
    * Looping and control flow
    * Arrays, lists, dictionaries
    * Making and using functions

* Already know the fundamentals of genetics:
    * The structure of DNA and RNA
    * Coding vs non-coding DNA
    * The transcription process: codons, amino acids, and proteins
    * The DNA replication process

**Objectives, students will learn to:**

* Describe algorithmic complexity in terms of "speed" and “space.”
* Use Big O to classify programs into the following complexity classes.
    * Constant time
    * Log(n)
    * n
    * n log n
    * n^2 (and other polynomials)
    * 2^n (and other exponentials with a constant base)
    * n^n

* Describe some limitations of Big O, especially that:
    * It only tells us how an algorithm performs with very large n values. 
    * It ignores the constants (e.g. 10000n + 0.0001n^2 is still O(n^2) )
    * It doesn’t account for factors related to physical computers (memory hierarchy, parallelization, so on)

* Use what they’ve learned about Big O to optimize computer programs.

## Workshop Structure:

This workshop is comprised of three sections:

### Part 1: Direct Instruction (30-40 minutes)

* Introduce Big O & Algorithmic Complexity.
* Define the most common complexity classes (see above).
    * Mini-Exercise: as pairs, order the complexity classes from fast to slow.
* Two worked examples as a class.
* See [lecture-notes](lecture-notes.md) for more details.

### Part 2: Classifying Programs Into Their Complexity Class (60 minutes)

Students will be given a few functions related to basic genetics/genomics functions (e.g. finding a series of nucleotides [k-mer] in a strand of DNA/RNA) and asked to identify which complexity class they are. Students will be asked to work in pairs or small groups. **(40 minutes)**

As a class, we’ll go over the solutions to these problems **(20 minutes)**

### Part 3: Optimize Programs (80 minutes)

As a class, we’ll briefly discuss a few strategies for approaching algorithmic optimization. **(10 minutes)**

* Polya’s problem solving method.
* Avoiding nested loops.
* Looking at the input data only once (or as little as possible).
* Using an appropriate data structure.

Students will be again grouped into pairs and asked to rewrite a selection of the problems we classified above to improve their complexity class. **(50 minutes)**

As a class, we’ll go through one such optimization, then point students to the other solutions to these problems. **(10 minutes)**

Q&A **(10 minutes)**

## More Practice Opportunities:

[Rosalind](http://rosalind.info/) is a website designed to help people learn and practice programming specific to bioinformatics. In this workshop you've seen solutions to some of [the problems](http://rosalind.info/problems/list-view/) hosted there, but there are many many more. While Rosalind does not measure the speed or Big O of your solutions, you can apply what you've learned here to these problems on your own!

There are a variety of similar websites for general programming practice as well: [Code Wars](https://www.codewars.com/), [Hacker Rank](https://www.hackerrank.com/), and [Leet Code](https://leetcode.com/) all have a variety of problems and measure the speed of submitted programs in one way or another.

## Testing The Code:

Tests for the provided code are in `solutions/tests.py`. These tests use the built in Python UnitTest library and can be run by executing that file with python:

```
python tests.py
```

> If you're not in the solution directory, you'll have to specify the full path to the `tests.py` file

Or, they can be run by invoking the unittest module from anywhere above the solutions folder in the hierarchy:

```
python -m unittest
```

Students can use these tests to test their own code by changing which functions get imported. For example, say a student wants to change the code in `exercises/optimize_functions_code.py` to complete the optimization exercise. Then this student could change the imports as follows:

```python
from exercises.classify_functions_code import reverse_compliment, count_occurance, unique_kmers, count_kmers

# Change the following line from solutions.optimize_functions_code to exercises.optimize_functions_code
from solutions.optimize_functions_code import unique_kmers as optimized_unique_kmers, count_kmers as optimized_count_kmers
from solutions.find_kmer_clumps_code import clumping_kmers
```

Similarly, suppose a student adds a python file called `kmer_clumps.py` the the exercises folder to complete the final exercise. Then:

```python
from exercises.classify_functions_code import reverse_compliment, count_occurance, unique_kmers, count_kmers
from solutions.optimize_functions_code import unique_kmers as optimized_unique_kmers, count_kmers as optimized_count_kmers

# Change this line from solutions.find_kmer_clumps_code to exercises.kmer_clumps
from solutions.find_kmer_clumps_code import clumping_kmers
```
### A Final Word About Tests:

There are less involved ways for students to test their code that don't rely on understanding the unit test code. For example, they could copy the test cases and run them manually at the bottom of their own code. For example, consider this quick and dirty way of testing `reverse_complement`:

```python
        cases = [
            ('', ''),
            ('A', 'T'),
            ('T', 'A'),
            ('C', 'G'),
            ('G', 'C'),
            ('ATCG', 'CGAT')
        ]

        for sequence, expected_result in cases:
            result = reverse_compliment(sequence)
            if result != expected_result:
                print("Failed test (expected, actual)", expected_result, result)
```
