Github Intro
================
Hao Ye
November 8, 2016

-   [Where do I begin?](#where-do-i-begin)
-   [Collaboration through Github](#collaboration-through-github)
-   [Basic Github Collaboration (shared repository model)](#basic-github-collaboration-shared-repository-model)
-   [Basic Github Collaboration (fork and pull model)](#basic-github-collaboration-fork-and-pull-model)

Where do I begin?
-----------------

For a basic review of Git (the version control system) and Github (the code-hosting platform), take a look at Brian Stock's notes from last week ("2016\_11\_01\_github\_intro").

Collaboration through Github
----------------------------

Last week we discussed using Git and Github to manage your own projects. For such purposes, saving changes by using commits to a single `master` branch can be sufficient. But what about group collaborations? If two people try to make incompatible changes to the same branch of Git repository, there will be a conflict that needs to be resolved. And in larger groups, multiple people may be working on separate aspects of the project at the same time...

Here we go over two basic workflows for collaborations using Github as a common repository. In both cases, we use the "pull request" feature on Github to merge changes.

In the first workflow (shared repository model), everyone has the ability to push changes to Github. To avoid conflicts, individuals establish new branches for the updates they wish to make, ensure that any incompatibilities are resolved, and then push their commits to Github and issue a "pull request".

In the second workflow (fork and pull model), we don't have the ability to push changes to Github. Thus, we first `fork` the original repository, making a copy of it in our Github account. We can then operate as before, and issuing a "pull request" to merge our changes into the original repository.

Basic Github Collaboration (shared repository model)
----------------------------------------------------

1.  You want to start with an up-to-date local copy of the shared repository. If you don't currently have a local copy, you can create one using the `git clone` command. Otherwise, just pull the most recent changes.

2.  Make a new branch for your changes. This allows you to make changes and commit them without worrying that you'll be causing a conflict with someone else's commits. Please choose a descriptive name for the new branch (maybe even including your username). Note that we are running these commands in the shell.

        $ git checkout -b hye_github_collab

3.  This should create the new branch and set our local Git repo to point to that branch. We can now make changes, and commit them to this new branch.

4.  Once all your changes are committed, you will want to make sure that you can merge these changes with the `master` branch from the original repository. We do this by fetching the updates in the shell.

        $ git fetch origin

5.  Next, we try to merge our changes. (I think this can only be done from the shell.)

        $ git merge origin/master

6.  Resolve any conflicts (probably none if you're only adding new files), and commit the latest version of our new branch.

7.  Now we want to push the changes back to Github. Because our new branch isn't yet on Github, we'll need to go into the shell once again to do this.

        $ git push --set-upstream origin hye_github_collab

8.  On Github, issue a "pull request" to merge your changes into the `master` branch.

9.  After this is done, you will want to synchronize the `master` branch on your local machine. Switch back to the `master` branch and pull the changes.

10. If we don't need our new branch anymore, we probably want to delete it. (We may already have done so on Github if the pull request was accepted.) To delete our local copy of the branch, we use the shell.

        $ git branch -d hye_github_collab

Basic Github Collaboration (fork and pull model)
------------------------------------------------

1.  First, we need to fork the project on Github. This creates a copy of the repository in our account.

2.  Next, clone from Github onto our local computer.

3.  At this point, our local git only knows about the repository in our Github account. We probably also want to be able to retrieve changes to the original repository that we forked.

        $ git remote add upstream git@github.com:************

    \[From here on, the steps are similar to the shared repository model.\]

4.  Make a new branch for your changes. This allows you to make changes and commit them without worrying that you'll be causing a conflict with someone else's commits (e.g. by the original repository's owner to the `master` branch). Please choose a descriptive name for the new branch (maybe even including your username). Note that we are running these commands in the shell.

        $ git checkout -b hye_github_collab

5.  This should create the new branch and set our local Git repo to point to that branch. We can now make changes, and commit them to this new branch.

6.  Once all your changes are committed, you will want to make sure that you can merge these changes with the `master` branch from the original repository. We do this by fetching the updates in the shell.

        $ git fetch upstream

7.  Next, we try to merge our changes. (I think this can only be done from the shell.)

        $ git merge upstream/master

8.  Resolve any conflicts (probably none if you're only adding new files), and commit the latest version of our new branch.

9.  Now we want to push the changes back to Github. Because our new branch isn't yet on Github, we'll need to go into the shell once again to do this.

        $ git push --set-upstream origin hye_github_collab

10. On Github, issue a "pull request" to merge our changes into the `master` branch of the *original* repository.

11. After this is done, we will want to synchronize the changes to the `master` branch of the original repository to both our local machine and our Github account. After setting up the `upstream` remote, we can simply do the following in the shell. This will update the `master` branch on both our local machine and our Github account.

        $ git pull upstream master
        $ git push origin master

12. If we don't need our new branch anymore, we probably want to delete it. (We may already have done so on Github if the pull request was accepted.) To delete our local copy of the branch, we use the shell.

        $ git branch -d hye_github_collab
