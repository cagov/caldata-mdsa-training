# Azure DevOps

## What is Azure DevOps?

Azure DevOps is a suite of developer tool and services provided by Microsoft. Its intention is to streamline the software development lifecycle, enabling teams to collaborate effectively, automate processes, and deliver high-quality products at a faster pace.

Three key features and services that the ODI CalData team use in their MDSA service are:

- Azure Pipelines
- Azure Repos (what we'll focus most of this training on!)
- Azure Boards (we'll spend a little time here as well!)

## What are Azure Pipelines, Repos, and Boards?

### Azure Pipelines

A continuous integration and continuous deployment (CI/CD) platform that automates your builds and deployments.

### Azure Repos

Azure Repos is Microsoft's cloud service built on top of git. It provides a centralized place to store your git repositories and collaborate with your team. Here's what it offers:

- **All the benefits of git:** Such as branching, merging, and history tracking.
- **Seamless Integration:** Azure Repos integrates with other Azure DevOps services, making it easy to manage your entire code development lifecycle in one place.
- **Enhanced Security:** Azure DevOps provides robust access control and security features to protect your code.
- **Flexibility:** You can use your favorite git client (like GitHub Desktop, your command line, or VS Code) to work with your code.

In essence, Azure Repos takes the power and flexibility of git and adds features and integrations within the Azure ecosystem, making it a comprehensive solution for managing your source code.

### Cloning the Azure project repo locally

Before you clone your repository you'll need a to do either of the following options:

Option 1:

- Install a code editor of your choice (if you do not already have one), we highly recommend [VS Code](https://code.visualstudio.com/download), you can read through [our team's example VS Code set up](https://cagov.github.io/data-infrastructure/code/local-setup/#example-vs-code-setup) for inspiration.
- Install [Git Credential Manager (GCM)](https://github.com/git-ecosystem/git-credential-manager), which makes the task of authenticating to Azure DevOps repositories easy and secure. (recommended method)
    - Mac OS: You can install GCM (with [Homebrew](https://brew.sh/))
        - After you install GCM run the following command: `brew install git-credential-manager`
    - Windows: Install [git for Windows](https://git-scm.com/downloads/win) which already comes bundled with GCM

Option 2:

- Install [Github Desktop](https://github.com/apps/desktop) which also provides support for working with Azure Repos
- This option may need an installation of GCM though we haven't tested it. If so, follow the steps above depending on your machine.

#### Steps to clone the repo

1. Go to your command line
2. Type `cd ~`.
3. Type git clone `<Azure DevOps repo URL>`.

### Working with Azure Repos remotely or locally

#### Code branches

When you are writing code you often create something called a branch. This allows you to track your work separately from the main branch of the code repository. Below are the steps for how to do this in Azure Repos or locally. Furthermore, all of the subsections underneath "Code branches" refer to working with git via your command line interface (CLI), we recommend bookmarking this [GitHub git cheat sheet](https://education.github.com/git-cheat-sheet-education.pdf) for easy reference in addition to what we've provided.

**Creating or switching branches in Azure Repos:**

1. Go to your Azure DevOps repository.
2. Click on the "Branches" tab.
3. Click "New branch".
4. Enter a descriptive name for your branch (e.g., "feature/new-feature").
5. Select the base branch (usually "main").
6. Click "Create".

**Creating or switching branches locally:**

If you're working with git locally, you can create and switch branches as well as check your current git branch using the following git commands:

- Create and switch to a branch: `git switch -c <branch_name>`
    - This also works, but is the older way of doing it: `git checkout -b <branch_name>`
- Switch to an existing branch: `git switch <branch_name>`
    - If this doesn’t work it’s likely that you created a branch remotely. You have to pull down (or fetch) the remote branch you want to work with using `git fetch`
    - Then you can run `git switch <branch_name>` again
- Check which branch you are on: `git branch --show-current`

Once you are satisfied with the work you've done on your branch you will want to save (stage) it and commit it. Below are the steps for how to do this locally.

**Staging and committing your changes:**

1. Create or switch your branch
    1. Make sure you’re on the branch you want to commit changes to (you almost never want to commit directly to “main”). If you just created a branch you are likely already on the branch you want to make changes to, if not switch to it.
    1. To create or switch branches, follow the steps above
1. Navigate to the file you want to modify and make the necessary changes
    1. Whether you’re editing a file in dbt Cloud, locally with a code editor like VS Code, or directly in Azure (not recommended) you must click SAVE or use CTRL/COMMAND S. To save the changes to your file BEFORE you commit them.
1. Stage your changes
    1. We’ll skip how to do this in Azure Repos because we don’t recommend editing and committing changes directly in Azure Repos as this doesn’t allow you to run linting tools that can help you catch errors BEFORE you push changes. We will have CI checks set up on the project repo that will help catch database, formatting, SQL errors, etc.
    1. Locally this is done by:
        1. Tying `git add <file_name.file_extension>`
        1. You can use `git add .` to add ALL files you’ve edited. This can be a dangerous operation because you may accidentally stage files you made changes to but did not want to be added to the project repo. For instance you could have made changes to a file that may contain sensitive information. Only use `git add .` if you are sure all files are safe to stage!
    1. In dbt Cloud the git add process is handled under the hood so be sure that every file you edit is actually a file you want to later commit, if not you must revert changes to any files you do not want to commit.
1. Commit your changes
    1. Again we’ll skip how to do this in Azure – we do not recommend it!
    1. Locally this is done with: `git commit -m “<a short message about the changes you made>”`
    1. In dbt Cloud this is done by:
        1. Clicking the “commit and sync” button
        1. Then typing a short, yet descriptive message about the changes you made in the text box that appears
        1. Then clicking “Commit Changes” ![dbt cloud git commit example](https://github.com/cagov/data-infrastructure/blob/main/docs/images/github/commit-changes.png?raw=true)

**Pushing your changes:**

1. Locally this is done with: `git push origin <branch_name>`
1. In dbt Cloud this is also done under the hood when you click “Commit Changes”

#### Pull requests

To submit the changes you've pushed to the codebase you'll open a pull request (PR). A PR proposes changes to a code repository. It's a formal request to merge your changes into the main branch of the repository.

Benefits of Using PRs:

- Collaboration: PRs allow developers to collaborate on code and share ideas.
- Code review: PRs allow for feedback on your changes. You can read about how the ODI CalData team approaches code review [here](https://cagov.github.io/data-infrastructure/code/code-review/)
- Testing: PRs can test changes before merging.
- Documentation: PRs can document changes to the code.
- History: PRs provide a history of changes.

**Opening a PR:**

_in Azure Repos:_

The official Microsoft documentation related to Azure Repos PRs is [here](https://learn.microsoft.com/en-us/azure/devops/repos/git/pull-requests?view=azure-devops&tabs=browser) (ignore cherry-pick section). Summarized steps are listed below.

1. Go to your Azure DevOps repository.
2. Click on the "Pull requests" tab.
3. Click "New pull request".
4. Select the source branch (your feature branch) and the target branch (usually "main").
5. Add a descriptive title and detailed description.
6. Add yourself as a reviewer and select other reviewers as needed.
7. Click "Create"

_in dbt Cloud:_

1. After you commit your changes you’ll see a light green button on the upper left that says “Create a pull request...”. This will only appear if you’ve yet to open a PR. If you have already opened a PR and are simply committing more changes to it you will not see this option.

**Reviewing a PR:**

1. Go to the "Pull requests" tab in your Azure DevOps repository.
2. Find the PR you want to review.
3. Review the changes, leave comments, and suggest changes if necessary.
4. Approve the PR or request changes.

**Suggesting changes to a PR:**

- When reviewing a PR, you can suggest changes directly in the code using the Azure DevOps interface.
- Alternatively you can open your own branch and suggest changes this way

**Resolving a merge conflict:**

- Merge conflicts occur when changes are made to the same part of a file in both the source and target branches.
- Resolve merge conflicts manually by editing the file and choosing which changes to keep.
- Stage, commit, and push the resolved changes.

**Merging a PR:**

- As a reviewer, you can merge a PR after you approve it and all CI checks pass.
- Click the "Complete" button on the PR page to merge the changes.

### Azure Boards

A work tracking system that supports agile methodologies. Teams can create backlogs, plan sprints, track work items, and visualize progress.

#### Azure Boards work items

In Azure Boards, **work items** are how we document and track our work, think of is as a task. A well-written work item provides clear information on the what, why, and who, enabling efficient collaboration and quicker problem resolution. They serve as documentation, capturing decisions and discussions valuable for current and future team members. Clear work items also help with task prioritization and progress tracking.

When writing a work item you can use markdown, this Microsoft [reference document](https://learn.microsoft.com/en-us/azure/devops/project/wiki/markdown-guidance?view=azure-devops) is a great starting point.

**Creating a work item:**

1. Go to the **Boards** hub in your Azure DevOps project.
2. Choose the appropriate **Work Item Type** (e.g., User Story, Task, Bug).
3. Fill in the work item form. At a minimum, include:
   - **Title:** A clear, concise, and descriptive title.
   - **Description:** A detailed description of the work.
   - **Assigned To:** The team member responsible for the work.
   - **Area Path:** The area of the project this work belongs to.
   - **Iteration Path:** The sprint or iteration this work is scheduled for.
   - **State:** (e.g., To Do, In Progress, Done).
   - **Priority:** (e.g., Urgent, High, Medium, Low)
   - **Effort:** (e.g., Story Points, hours)

**Tips for effective work items:**

- Use clear and concise language.
- Provide all relevant details.
- Attach relevant files or screenshots.
- Link related work items.
- Use tags to categorize work items.

**Work items magic:**

- **Linking to Code:** You can link work items to commits, pull requests, and branches. This is great for traceability as it helps track the progress of work and provides context for code changes.
- **@Mentioning Teammates:** Type "@" followed by your teammate's name to notify them in comments and descriptions.

**Azure DevOps Documentation:**

- [Azure Repos | Microsoft Learn](https://learn.microsoft.com/en-us/azure/devops/repos/?view=azure-devops)
- [Azure DevOps | Microsoft Learn](https://learn.microsoft.com/en-us/azure/devops/?view=azure-devops)
