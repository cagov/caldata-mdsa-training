# git

## What is git?

**Git**, a distributed [version control](https://en.wikipedia.org/wiki/Version_control) system, is software that you install locally on your machine that enables source code management. Code is organized into folder-like structures called **git repositories**, which enables you to track the history of changes to the code, safely develop features in side branches, and collaborate with others. Git is a distributed version control system, which means that each developer has a local copy of the entire code repository. This makes it easy to work on code offline and to share changes with other developers.

Git is an essential tool for software development as it allows developers to track changes to code, collaborate, and share open or closed-source code.

## Learning git

There are many high-quality resources for learning git online. Here are a few:

- Atlassian has an excellent set of tutorials for learning git, including:
  - [A conceptual overview for beginners](https://www.atlassian.com/git/tutorials/what-is-version-control)
  - [How to set up a repository](https://www.atlassian.com/git/tutorials/setting-up-a-repository)
  - [How to use git to collaborate with others](https://www.atlassian.com/git/tutorials/syncing)
- GitHub has a nice [cheat-sheet](https://education.github.com/git-cheat-sheet-education.pdf) for common git commands
- The [official git documentation](https://git-scm.com/doc) is not always the most user-friendly, but it has a depth of information that isn't available elsewhere

If you have a remote repository set up on something like GitHub or Azure DevOps and want to make a local copy of it you have to run the `git clone` command. Once you have a working copy of your remote repo, all version control operations are managed through this local copy. Follow the steps below to clone a repository.

## Clone a repo locally

*for MacOS or Linux-based CLI*

1. Go to your command line
2. Type `cd ~`
3. Type `git clone <https://github.com/org/repo-name.git>`

## Other ways to work with git

- Install [Git for Windows](https://git-scm.com/downloads)
- Or install [GitHub for Desktop](https://desktop.github.com/)
