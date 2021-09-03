# General Advice For Writing Clean Code

Keep these main principles in mind when writing code for producing more understandable programs. There are hundreds of specific pieces of advice and rules for achieving these goals, but it's important to keep the goals in mind so that you know why you're following those rules and how/when to break them appropriately.

## 1. Write For People, Not the Computer

Make it the primary concern to produce code read by a human. Unless you violate a syntax rule, the computer will be able to execute the code no matter how it is formatted. Humans (including your future self), on the other hand, need more help.

Make the computer your secondary concern, and prioritize yourself and the other programmers working in your codebase.

## 2. Be A Textbook Writer, Not a Poet

There is a place for creativity, lightheartedness, and fun in the world of computer programming. But, in a shared codebase that grows and changes over time — especially one that represents an important product like academic research or a widely used service — it's more important to be clear and concise than fun. 

You probably wouldn't try to write a calculus textbook in iambic pentameter. Similarly, it's better to approach your code with a serious intent and a consistent style. 

## 3. Use Comments For "Why" Rather Than "What"

To the extent it is possible your code should be self descriptive. The code should tell a reader what the code does. If the code is confusing or unclear, try to rewrite the code in a manner that is clear instead of adding a comment to explain the confusing code.

Use comments to explain your intent rather than to describe the code. An example of a helpful comment is: "We are sorting this array because it makes the following logic much simpler." This tells future programmers something that the code itself cannot say, and helps future readers understand why you made certain choices.

## 4. Use Functions For Grouping and to Avoid Repetition

Functions are great for breaking up long blocks of code into smaller, logical blocks. Programmers can use functions the same way writers use paragraphs, sub-headings, and chapters. By breaking logic into smaller blocks the code becomes easier to test, (usually) easier to read, and easier to refactor. 

Functions are also great for reusing logic that appears in more than one place. If you find yourself using a mathematical formula, boolean equation, or series of data pre-processing steps repeatedly then you should probably pull that code into a function and use it instead of duplicating the logic. This makes the code easier to test. If you find a bug in the logic, you'll only have to fix it in one place. And, you'll save time copy/pasting the logic for that function.

Whenever possible, keep functions short. Use fewer parameters whenever possible. Long function declarations are confusing, just like long function bodies are confusing.

## 5. Use a Style Guide

Similar to magazines and journals maintaining a style guide for writing prose, most software companies maintain a style guide for the programming languages they use. Analogous to how there are disagreements in the English world about using the Oxford Comma, there are stylistic disagreements in the programming community about topics such as tabs vs spaces, how many blank lines to put between function definitions, and where to put curly braces.

Agreeing on a style guide can help programmers avoid endlessly arguing about contentious stylistic issues. Have the argument once as a team, agree on a style guide, then follow it. Most IDEs (Integrated Development Environments) and text editors support "[linters](https://en.wikipedia.org/wiki/Lint_(software))" that can identify many style guide violations with red underlining, which can also be visually helpful.

## 6. Don't Be Dogmatic

Every rule has exceptions. Keep an open mind when writing and reviewing code. If following a particular rule in the style guide (or some other rule of thumb) makes the code harder to understand, consider making an exception to the rule. 

# Python vs R 

Many an argument has occurred over if [R or Python is the better](https://www.guru99.com/r-vs-python.html) of the two languages. The answer? Do what makes most sense to you and your work. One isn't better than the other. They each have their own strengths, weaknesses, and utilities. That said, once you've selected a language to use for your needs be sure to then understand the significance of its fundamentals and styles.

### Similarities: The Fundamentals

The reason these languages tend to come up in tandem with one another is their accessibility. These programming languages are free to use and open-source. As a result, there are many resources available online for learning and troubleshooting.

Think of programming languages similar to grammar spoken languages (English, Mandarin, Spanish, etc). Just as spoken languages have common grammar (nouns, verbs, adjectives, etc.) there are shared fundamentals in programming languages, such as:  

- Data structure: Booleans (True/False), Numbers (1, 2, 3...), Characters (a, b, c...), and/or Strings (hello, my, name...) organized as Lists, Arrays, Series, Dictionaries, or Objects
- Variables: Assigning a value so it can be understood by the code.
- Conditionals: If x is true do one thing, if x is false do something else.
- Functions: Code for performing a specific task on the data.
- Loops: Repetition of tasks, usually involving multiple functions and conditionals.

These aspects of the programming languages do not differ. So why are there two?

### Differences: Determining What's Best for You

R or Python? Python or R? Here are some aspects to consider when determining what programming language you'd like to use, and why.

- Use the tools common to your field: if all of your colleagues are using R, it will be easier to get help on your own R code. For example, R is more popular among ecologists whereas Python is more popular among phylogeneticists.
- Consider the available libraries and the software ecosystem: different programming languages have different libraries. Machine learning specialists are flocking to Python mainly because of the wide variety of useful ML libraries such as Scikit Learn and Keras. These libraries are language specific, but aren't part of the language itself, they are built by 3rd party developers. If more ecologists are using R it stands to reason that there will be more and better ecology focused libraries built in R.
- R is purpose built for statistical analysis. Running data analysis and producing visualizations is often easier and more straightforward in R. 
- Python is general purpose. If you want to do significant non-statistics work (build a website, perform web scraping, build a video game) then Python is a more natural fit. Python is sometimes called "the second best language for everything." It's rarely a bad choice, but it is not always the "best" choice for any particular problem or domain. 
- It's not an end-all, be-all. If you're unsure on which one to try out first, go for both and see which one "speaks" to you. Each are frequently updated, so there's no harm in trying. If anything, learning both at the same time helps solidify your understanding of the fundamentals. As these languages become more popular, so do the options for [incorporating crossover between the two](https://www.datacamp.com/community/tutorials/using-both-python-r). 
  - Most long-time programmers "speak" multiple languages, and it gets easier to learn new languages as you go.
- Once you've decided on a language (or maybe you choose both!), become familiar with its platforms beyond the base code. For example, [PyCharm](https://www.jetbrains.com/pycharm/) is frequently used for Python and [RStudio](https://rstudio.com/) is frequently used for R. [Jupyter Notebook](https://jupyter.org/) was developed in Python, but now features an [R Kernel installation option](https://github.com/SuLab/Applied-Bioinformatics/blob/Fall-2020/Configuration.md) and is great for those who seek to regularly practice both. 
  - Endeavor to become a "power user" of the programming tools you use frequently — it can save you an incredible amount of time and effort overall. 

### Resources for Learning Either Language
- Software Carpentry: [Python](https://swcarpentry.github.io/python-novice-inflammation/) and [R](https://swcarpentry.github.io/r-novice-gapminder/) 
- https://www.learnpython.org/
- https://realpython.com/ 
- [Python for Data Analysis](https://www.youtube.com/watch?v=RJsnqpnqkLU&list=PLpMW-laAm5rPqrX7IqKacmYqXd-sSpgSq)
- https://www.r-project.org/
- How to make packages in [Python](https://realpython.com/python-modules-packages/) or in [R](https://tinyheero.github.io/jekyll/update/2015/07/26/making-your-first-R-package.html) 
