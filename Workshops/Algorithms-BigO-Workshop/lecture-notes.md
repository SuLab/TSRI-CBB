# Big O & Complexity Theory (15-20 minutes)

* Complexity theory is a branch of computer science that focuses on measuring the performance of algorithms.
  * Complexity is an *abstract* measurement, not a concrete measurement...
  * __What does it mean to be an abstract measurement?__
    * *We want to be able to compare algorithms without implementing them -- planning before implementing*
    * *When comparing algorithms, we don't always want to let the code get in the way*
    * *Our measurements cannot be in concrete units, like seconds, because our algorithms might only exist on whiteboards*
* __What is Big O Notation?__
  * *An estimate of the time or space requirements of an algorithm*
  * *In terms of the input to the algorithm*
  * There are some really technical definitions that I could give of Big O, involving complex F(G(x)) math jargon but they are honestly not very helpful.
* __Why is Big O measured in terms of the input?__
  * *It allows us to measure how the algorithm scales as the input scales*
* __Why measure time and space requirements?__
  * *Those are our two limiting factors, typically*
* When we use Big O, we drop the constants and all but the "worst" factor involving 'n':
  * `3 + 5n + 2n^2` => `O(n^2)`
  * __Why do we do this?__
    * *We rarely care about small input sizes. Slow algorithms still finish quickly for small input sizes*
    * *Big O only cares about what happens as n gets VERY large*
    * *Because this is a measure of how an algorithm scales, not a measurement of specific performance*
  * __Is this a weakness of big O?__
    * *YES! Big O is always going to be a fuzzy lens into performance.*
    * *But it's still a useful lens*
  * __EVERYONE WRITES: a formula that highlights this weakness of big O__
    * *I'm hoping for something like: `9999999999n + n^2` => O(n^2). It's n-squared but the large constant factor on n will clearly drive our performance in most realistic situations. n generally won't be larger than 9999999999*
* __What other weaknesses can you think of for big O?__
  * *Doesn't consider actual hardware at all*
  * *Memory usage, cache utilization, hard drive and network use will all have significant impact on performance but are not captured by Big O*
  * *Might be worth mentioning that we can time/benchmark our actual programs as well*
* Some closing thoughts:
  * You can compute the Big O of a "worst case" input or "best case" input - both are useful measurements!
  * It's often worth knowing what your actual dataset is, and computing big O over that case.
  * Big O is a "general" tool -- getting more specific by actually measuring your code's performance is a good idea.

## Class Exercise 1 -- Order Complexity Classes (10 minutes)

* __Individually__
  * Put the following complexity classes in order from slowest to fastest
  * constant, log(n), n, n*log(n) n^2, 2^n, n!, n^n
* __Compare your work with your neighbor__
  * Resolve any disagreements
* __Graph all these functions -- doesn't have to be precise, big O is an estimate anyway right?__
  * ![big o graph](big-o-graph.png)

* __Go over the answers as a class__
  * *THIS IS A REALLY GOOD TIME TO DEFINE A LOGARITHM, which people rarely understand.*
* __Where do we draw the line between "good enough" and "not good enough"?__
  * *Good question ... it depends!*
  * *Usually n^2 is "okay" and 2^n is almost always unacceptable*
  * *but it depends on the problem and your specific requirements!*

## A Note About Using Built-In Methods (5 minutes)

* A single line of code — especially a function call — might actually involve a lot of work. 
* Consider the case of searching for an item in a list vs searching for an item in a hash table
  * *If students aren't familiar with the inner workings of a hashmap/dictionary take a minute and explain it*
* The main point is: be careful when using built in methods and handy syntactical sugar, it might be hiding a lot of complexity.

## Three Worked Examples (10 minutes)

* Lets look at two examples. 
  * *Both of these are intentionally straight-forward, the exercises are a bit harder so warn students about that.*

* The classic example of "linear" O(n) is searching for something in an unsorted list
  * Searching for a character in a string is essentially the same algorithm.
  * But searching for a substring in a string is a different story... [this is in the exercise so you may not want to give it away!]

```python
def linear_search(input_list, item_of_interest):
    for index, item in enumerate(input_list):
        if item == item_of_interest:
          return index
    
    return -1 # -1 means "item_of_interest is not in this list"
```

* Note that the "best case" is constant time:
  * The `input_list` is empty, or the `item_of_interest` is in the first position of the list.
  * But we have no way of knowing that's true...
  * Worst case is when the item isn't in the list. 
  * Could argue this is: 2n. 
    * Loading the item from the list, then comparing it to the item or interest. 
    * No setup, so no constants...
  * Which means, overall this is O(n) (remember: we always drop the constants with Big O)

* A classic example of a 2nd degree polynomial (n^2) is this method of determining which items are unique:

```python
def get_unique_items(input_list):
    unique_items = []
    
    for outer_item in input_list:
        outer_item_is_unique = True
        
        for inner_item in unique_items:
            if inner_item == outer_item:
                outer_item_is_unique = False
                break
    
        if outer_item_is_unique:
            unique_items.append(outer_item)
        
    return unique_items
```

* This has a but of setup/teardown, I would argue a fair accounting is: 2 + 4n + 2n^2
    * 2 => create the array and return
    * 4n => load data into `outer_item`, set `outer_item_is_unique = True`, handle lower if statement, append the item.
    * 2n^2 => load data into `inner_item`, handle innermost if statement.
      * I don't count setting outer_item_is_unique = False or break because they'll each happen at most n times. 
      * You could reasonably argue that we should add these into the linear count and make 4n into 6n instead.
      * But Big O is an estimate anyway and we're going to drop the constants so... it's all O(n^2) at the end of the day. 
    * Therefore overall O(n^2)


* The classic log(n) example is "binary search".
  * The algorithm is a lot easier to read and understand than the code, so describe this in the abstract.
  * *I like to tell students they already know this algorithm... say I told you that I'm thinking of a number between 1-100, and that they'll get 10 guesses to figure out which number I'm thinking of, and after each guess I'll tell you if the guess was too low or too high... what do you guess?* 
    * Someone always says "50", ask them why, and they'll describe the key insight of binary search to the class. 
  * this is log(n) because each guess reduces the search space by half, so we can say more specifically even, it's 'log base 2 of n' although people rarely report the base of the log.
    * Which I personally find strange... we care about the difference between n^2 and n^10, so why not log base 2 vs log base 10? 
      * There are some okay reasons, but still it's food for thought...

* **Crucial note, we are assuming `input_list` is sorted, otherwise this algorithm does not work.**
```python
def binary_search(input_list, item_of_interest): 
    low = 0
    high = len(input_list) - 1
    mid = 0
  
    while low <= high: 
  
        mid = (high + low) // 2
  
        
        # If item_of_interest is greater, ignore left half 
        if input_list[mid] < item_of_interest: 
            low = mid + 1
  
        # If item_of_interest is smaller, ignore right half 
        elif input_list[mid] > item_of_interest: 
            high = mid - 1

        # Check if item_of_interest is present at mid 
        else: 
            return mid 
  
    # If we reach here, then the element was not present 
    return -1
```
