## **Azure DevOps Deep Dive**

This document is a guide for using Azure DevOps Repos and Azure DevOps.

**Tips**

Even though the following two items reference Git/GitHub they work well with  Azure Devops as well. Additional details are provided in the following section.

* Install [Git for Windows](https://git-scm.com/downloads) or [GitHub for Desktop](https://desktop.github.com/)  
* Bookmark GitHub’s [Git Cheat Sheet](https://education.github.com/git-cheat-sheet-education.pdf)

**What are Git and Azure DevOps?**

This section explains the basics of Git and how it integrates with Azure DevOps Repos

**What is Git?**

[**Git**](https://git-scm.com/) is a **distributed version control system**. Think of it as a tool that meticulously tracks every change made to your code. This allows you to:

* **See the history of changes:** Understand who made what changes and when.  
* **Revert to previous versions:** Easily go back to an older version of your code if needed.  
* **Create branches:** Work on new features or bug fixes without affecting the main codebase.  
* **Merge changes:** Combine code changes from different branches.  
* **Collaborate effectively:** Work with others on the same codebase without conflicts.

**What are Azure DevOps Repos?**

Azure DevOps Repos is Microsoft's cloud service built on top of Git. It provides a centralized place to store your Git repositories and collaborate with your team. Here's what it offers:

* **All the benefits of Git:** You get all the core features of Git, such as branching, merging, and history tracking.  
* **Seamless Integration:** Azure DevOps Repos integrates with other Azure DevOps services, making it easy to manage your entire development lifecycle in one place. These services include:  
  * **Pipelines:** Automate your builds and deployments (CI/CD).  
  * **Boards:** Track your work items and progress.  
  * **Test Plans:** Manage your testing efforts.  
* **Enhanced Security:** Azure DevOps provides robust access control and security features to protect your code.  
* **Flexibility:** You can use your favorite Git client (like GitHub Desktop, the Git command line, or Visual Studio Code) to work with your code.

**In essence:** Azure DevOps Repos takes the power and flexibility of Git and adds features and integrations within the Azure ecosystem, making it a comprehensive solution for managing your source code.

**Cloning the Project Repo Locally**

[Git Credential Manager (GCM)](https://github.com/git-ecosystem/git-credential-manager), which makes the task of authenticating to Azure DevOps repositories easy and secure. GitHub Desktop now provides support for it. Installing git credential manager is recommended for working with Azure DevOps repos.

Here are instructions for installing GCM.

* Install git credential manager (with [Homebrew](https://brew.sh/) if on a Mac, if on a windows you should have it by default with [Github Desktop](https://github.com/apps/desktop).) Then run the following three commands:  
* brew install git-credential-manager

**Steps to Clone a repo**

1. Go to your command line  
2. Type `cd ~`.  
3. Type git clone `<Azure DevOps repo URL>`.
**Pull Requests** 

A pull request (PR) proposes changes to a code repository. It's a formal request to merge your changes into the main branch of the repository. 

**Benefits of Using PRs:**

* Collaboration: PRs allow developers to collaborate on code and share ideas.  
* Code review: PRs allow for feedback on your changes. More details are available [here](https://cagov.github.io/data-infrastructure/code/code-review/)   
* Testing: PRs can test changes before merging.  
* Documentation: PRs can document changes to the code.  
* History: PRs provide a history of changes.

**Creating or Switching Branches**

1. Go to your Azure DevOps repository.  
2. Click on the "Branches" tab.  
3. Click "New branch".  
4. Enter a descriptive name for your branch (e.g., "feature/new-feature").  
5. Select the base branch (usually "main").  
6. Click "Create".

**Staging and Committing Changes**

1. Make sure you're on the correct branch.  
2. Navigate to the file you want to modify and make the necessary changes.  
3. Save the changes to your file.  
4. Stage your changes using `git add <file_name>` or `git add .` (to add all changes).  
5. Commit your changes with `git commit -m "<a short message about the changes you made>"`.  
6. In **dbt** Cloud the git add process is handled under the hood so be sure that every file you edit is actually a file you want to later commit, if not you must revert   
   changes to any files you do not want to commit.  
     
7. In **dbt** Cloud this is is done by:  
   1. Clicking the “commit and sync” button  
   2. Then type a short, yet descriptive message about the changes you made in the text box that appears and click “Commit Changes”

**Pushing Your Changes**

* Use git push origin \<branch\_name\> to push your changes to the remote repository.  
* In **dbt** Cloud this is also done under the hood when you click “Commit Changes”

**Opening a PR** 

The official Microsoft documentation related to Azure DevOps PRs is [here](https://learn.microsoft.com/en-us/azure/devops/repos/git/pull-requests?view=azure-devops&tabs=browser) (ignore cherry-pick section). Summarized steps are listed below.

1. Go to your Azure DevOps repository.  
2. Click on the "Pull requests" tab.  
3. Click "New pull request".  
4. Select the source branch (your feature branch) and the target branch (usually "main").  
5. Add a descriptive title and detailed description.  
6. Add yourself as a reviewer and select other reviewers as needed.  
7. Click "Create"  
8. You have the option to open a PR in **dbt** Cloud 

After you commit your changes you’ll see a light green button on the upper left that says “Create a pull request on Azure DevOps”. This will only appear if you’ve yet to open a PR. If you have already opened a PR and are simply committing more changes to it you will not see this option. 

TODO: Add a relevant image after completing the **dbt** Cloud \- Azure DevOps integration.

**Reviewing a PR**

1. Go to the "Pull requests" tab in your Azure DevOps repository.  
2. Find the PR you want to review.  
3. Review the changes, leave comments, and suggest changes if necessary.  
4. Approve the PR or request changes.

**Suggesting Changes to a PR**

* When reviewing a PR, you can suggest changes directly in the code using the Azure DevOps interface.

**Resolving a Merge Conflict**

* Merge conflicts occur when changes are made to the same part of a file in both the source and target branches.  
* Resolve merge conflicts manually by editing the file and choosing which changes to keep.  
* Stage, commit, and push the resolved changes.

**Merging a PR**

* As a reviewer, you can merge a PR after you approve it and all CI checks pass.  
* Click the "Complete" button on the PR page to merge the changes.

The basic writing and formatting syntax used on GitHub largely works in Azure DevOps as well. Both platforms utilize Markdown for formatting text in work items, pull requests, wikis, and other areas.

## **Azure DevOps Work Items**

In Azure DevOps, **Work Items** are how we document and track our work. A well-written work item provides clear information on the what, why, and who, enabling efficient collaboration and quicker problem resolution. They serve as documentation, capturing decisions and discussions valuable for current and future team members. Clear work items also help with task prioritization and progress tracking.

**Creating a Work Item:**

1. Go to the **Boards** hub in your Azure DevOps project.  
2. Choose the appropriate **Work Item Type** (e.g., User Story, Task, Bug).  
3. Fill in the work item form. At a minimum, include:  
   * **Title:** A clear, concise, and descriptive title.  
   * **Description:** A detailed description of the work.  
   * **Assigned To:** The team member responsible for the work.  
   * **Area Path:** The area of the project this work belongs to.  
   * **Iteration Path:** The sprint or iteration this work is scheduled for.  
   * **State:** (e.g., To Do, In Progress, Done).  
   * **Priority:** (e.g., Urgent, High, Medium, Low)  
   * **Effort:** (e.g., Story Points, hours)

**Tips for Effective Work Items:**

* Use clear and concise language.  
* Provide all relevant details.  
* Attach relevant files or screenshots.  
* Link related work items.  
* Use tags to categorize work items.

**Azure DevOps Magic**

* **Linking to Code:** You can link work items to commits, pull requests, and branches. This helps track the progress of work and provides context for code changes.  
* **@Mentioning Teammates:** Type "@" followed by your teammate's name to notify them in comments and descriptions.

**Azure DevOps Tips**

* Link PRs to work items and vice versa for better traceability.  
* Tag teammates in comments and descriptions using the "@" symbol.

This guide provides a foundation for using Azure DevOps Repos and Azure DevOps for development projects. Refer to the following official Azure DevOps documentation for the additional information

### **Writing Markdown**

Writing markdown is important to learn when creating project documentation in markdown files (.md) and for writing Azure DevOps Work Items. This Microsoft [reference document](https://learn.microsoft.com/en-us/azure/devops/project/wiki/markdown-guidance?view=azure-devops) is a great starting point.

**Common Markdown features supported in Azure DevOps:**

* **Headers:** \# H1, \#\# H2, \#\#\# H3, etc.  
  * *Example:* \# This is a Heading 1  
  * *Reference:* [Markdown guidance](https://learn.microsoft.com/en-us/azure/devops/project/wiki/markdown-guidance?view=azure-devops) (Azure DevOps)  
* **Emphasis:** \*italics\* or \_italics\_, \*\*bold\*\* or \_\_bold\_\_  
  * *Example:* This is \*\*bold\*\* text and this is \*italic\* text.  
* **Lists:** Unordered lists using \*, \-, or \+, and ordered lists using numbers followed by a period.  
  * *Example:*

```
* Item 1
* Item 2

1. First item
2. Second item
```

* **Links:** \[Link text\](URL)  
  * *Example:* \[Microsoft\](https://www.microsoft.com)  
* **Images:** \!\[Image alt text\](image.jpg)  
  * *Example:* \!\[A cat\](https://placekitten.com/200/300)  
* **Code blocks:** Use backticks (\`) for inline code or triple backticks (\`\`\`) for code blocks.  
  * *Example:* This isinline codeand this is a code block:

```
function myFunction() {
  // code here
}
```

* **Tables:** Use pipes (|) and hyphens (\-) to create tables.  
  * *Example:* markdown | Header 1 | Header 2 | |---|---| | Row 1, Cell 1 | Row 1, Cell 2 | | Row 2, Cell 1 | Row 2, Cell 2 |

**Key Differences and Considerations:**

* **Feature Support:** While the basic syntax is the same, there might be slight variations in the specific features supported. For example, Azure DevOps might have limitations on certain elements like nested lists or advanced formatting options.   
* **Rendering:** The way Markdown is rendered might differ slightly between the two platforms. This is usually minor and doesn't affect the core functionality.

**Azure DevOps Documentation References**

* [Azure Repos documentation \- Azure DevOps | Microsoft Learn](https://learn.microsoft.com/en-us/azure/devops/repos/?view=azure-devops)  
* [Azure DevOps documentation | Microsoft Learn](https://learn.microsoft.com/en-us/azure/devops/?view=azure-devops)
