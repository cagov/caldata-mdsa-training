# Continuous Integration/Continuous Deployment

Continuous Integration and Continuous Deployment (or Delivery), usually abbreviated as CI/CD,
are a critical part of modern software, data, and analytics engineering.
Broadly speaking, they are about automating parts of the code development process:

* **Continuous Integration (CI)** refers to automating testing, linters, formatters, and other code quality checks.
* **Continuous Deployment (CD)** refers to automating build, deployment, or publishing processes.
    This could happen on every merge to `main`, or could be triggered by specific actions in special repository branches.


## Continuous Integration (CI)

Most developers interact with CI checks on a daily basis.
Most often, CI checks run on every proposed change to the code base (i.e., pull requests to `main`).
Examples of CI checks include:

- **Code quality checks:** These look for issues with your code, such as syntax errors, potential security vulnerabilities, and performance issues.
- **Build checks:** These ensure your code can be successfully built.
- **Test checks:** These run your unit tests and integration tests to ensure that they pass.
- **Deployment checks:** These ensure your code can be successfully deployed to a test environment.

ODI's MDSA projects usually include the following CI checks:

#### pre-commit

The pre-commit check is a collection of smaller checks.
They are intended to be fast and cheap to run,
so the entire suite run in a couple of seconds or less.

Since they are fast and cheap, they can be installed as git 
[pre-commit hooks](https://git-scm.com/book/ms/v2/Customizing-Git-Git-Hooks) (hence the name of the check).
For instructions on how to install

#### dbt build

#### docs build


## Continuous Deployment (CD)


