# dbt (data build tool)

## Part V: Environments, jobs, CI/CD, and custom schemas

### Environments in Snowflake

During step 3 of the [learning path](../../learning-path.md#step-3-learn-about-concepts-and-tools-3-hrs) we had you read a bit about Snowflake architecture. In that content, we briefly introduced the concept of _environments_. Broadly speaking, environments are a collection of compute resources, software, and configuration, which together represent a functioning context for development. Examples of environments include:

1. A **production** environment which is used to run the dbt models that have been merged to `main`. This can be run on an ad-hoc basis, or can be run on a schedule to ensure that models are never more than some amount of time old.
1. A **development** environment, which is used to run tests on branches and pull requests, and can help to catch bugs and regressions before they are deployed to production.
1. A **user acceptance testing (UAT)** environment, which can be used as a final testing environment for verifying code before it is deployed to production.

Unfortunately, that's pretty vague, since there are lots of different ways environments can be set up! Depending on your situation, different environments in Snowflake could be represented by:

- entirely different accounts
- different databases within the same account, or even
- different schemas within the same database.

In our default MDSA architecture we have two environments, _dev_ and _prod_, which reside in the same Snowflake account. Each of these environments consists of a set of databases corresponding to our layered [data architecture](../../cloud-data-warehouses/snowflake.md#snowflake-architecture) you also read about in step 3.

### Environments in dbt Platform

dbt Platform also has a concept of an Environment, which is a virtual machine in dbt Platform that has all of the relevant software dependencies and environment variables set. Roughly speaking, an environment in dbt Platform will correspond to one of your environments in Snowflake.

If using dbt Platform, you’ve already encountered one environment, your _Develop: Cloud IDE_. But you can create other environments in dbt Platform for various purposes. Our typical dbt Platform setup includes the following environments:

- Development, which uses the "dev" Snowflake environment. This is what you use when you work in the cloud IDE.
- Production, which uses the "prod" Snowflake environment. This is what we use to build production data models.
- Continuous Integration, which uses the "dev" Snowflake environment. This is what runs the automated CI checks.

### Jobs

A _job_ is a command or series of commands that run in a given environment. Examples of jobs we often use include:

- Running a nightly build of data models
- Running Continuous Integration – CI checks (see below!)
- Building project docs

Jobs can be configured in a number of ways: they can have different environment variables set, they can run on a schedule, or they can be triggered by a specific action like a pull request being opened, or a branch being merged.

### Continuous Integration and Continuous Deployment (CI/CD)

#### Continuous Integration (CI)

Continuous Integration checks in GitHub, Azure DevOps, BitBucket, or similar are automated tests that are run against your code every time you push a change. They are an important part of the software development process, and can help you:

- **Catch errors and issues early:** CI checks can identify issues with your code before they can cause problems in production.
- **Improve code quality:** CI checks can help you to improve the quality of your code by identifying issues like duplicate or dead code and potential security vulnerabilities.
- **Establish a house style:** CI checks can enforce various code formatting rules and conventions that your team has agreed upon.

We usually set up git repositories so that PRs cannot be merged to `main` unless these checks pass. This can sometimes feel annoying! However, CI/CD checks shouldn’t feel too painful or like a box-checking exercise. They are intended to be a routine and helpful part of the development process. Ultimately, experience has shown that effective use of CI/CD greatly speeds up development.

#### Continuous Deployment (CD)

Continuous Deployment (CD) in most of our MDSA projects is usually simple. We typically do not build any applications or deploy cloud resources. Instead, whatever is in the `main` branch is considered _production_, and our dbt projects and docs are built using that.

<!-- #### Demo: CI/CD in a development workflow -->
<!-- TODO: https://app.asana.com/1/1202865175765955/project/1209598911230625/task/1213457268000676?focus=true -->

1. How to read the results of CI checks on a PR.
1. How merging to `main` results in production dbt builds.

<!-- ### Custom schema names

1. You'll learn about how the database schemas in which dbt models are built are determined. In development, the models get built in a different place (e.g., your `DBT_<first-name-initial+last-name>`schema) than they do in production.
1. Youll how a custom schema name can be generated using a macro we built `get_custom_schema.sql`. -->

<!-- TODO: https://app.asana.com/1/1202865175765955/project/1209598911230625/task/1213457270764693?focus=true -->

### Knowledge check

#### Question #1

<div class="quiz-container">
  <div class="quiz-question">What does an environment represent in data and software engineering?</div>
  <ul class="quiz-options">
    <li class="quiz-option" data-correct="false">A specific database table where data is stored</li>
    <li class="quiz-option" data-correct="true">A collection of compute resources, software, and configuration representing a functioning development context</li>
    <li class="quiz-option" data-correct="false">A scheduling tool for running data pipelines</li>
    <li class="quiz-option" data-correct="false">A version control system for tracking code changes</li>
  </ul>
  <div class="quiz-explanation">
    <strong>Explanation:</strong> An environment is a collection of compute resources, software, and configuration which together represent a functioning context for development. Common examples include production environments (for running merged code), development environments (for testing branches and PRs), and UAT environments (for final verification before production deployment).
  </div>
</div>

#### Question #2

<div class="quiz-container">
  <div class="quiz-question">Why are repositories typically configured so that pull requests cannot be merged to main unless CI checks pass?</div>
  <ul class="quiz-options">
    <li class="quiz-option" data-correct="false">To slow down the development process and give teams more time to review</li>
    <li class="quiz-option" data-correct="true">To prevent code with errors, quality issues, or style violations from reaching production</li>
    <li class="quiz-option" data-correct="false">Because only some people can deploy code to production</li>
    <li class="quiz-option" data-correct="false">To ensure documentation for the codebase is built first</li>
  </ul>
  <div class="quiz-explanation">
    <strong>Explanation:</strong> CI checks help catch errors early, improve code quality, and enforce code formatting rules and conventions. Requiring these checks to pass before merging prevents problematic code from reaching production. While this may sometimes feel restrictive, experience has shown that effective use of CI/CD greatly speeds up development by catching issues before they cause problems in production.
  </div>
</div>

#### Question #3

<div class="quiz-container">
  <div class="quiz-question">What is the primary purpose of Continuous Integration (CI) checks?</div>
  <ul class="quiz-options">
    <li class="quiz-option" data-correct="false">To deploy code to production automatically</li>
    <li class="quiz-option" data-correct="false">To schedule nightly data builds</li>
    <li class="quiz-option" data-correct="true">To catch errors and issues early before they reach production</li>
    <li class="quiz-option" data-correct="false">To create custom schema names</li>
  </ul>
  <div class="quiz-explanation">
    <strong>Explanation:</strong> Continuous Integration (CI) checks are automated tests that run against your code every time you push a change. They help catch errors and issues early, improve code quality, and establish a house style. CI checks run before code is merged to production, helping prevent bugs from reaching production environments.
  </div>
</div>

### References

#### Key pairs for CI

- [Creating encrypted key-pairs for service accounts that run CI and Production jobs](https://docs.snowflake.com/en/user-guide/key-pair-auth#configuring-key-pair-authentication)

<!-- code for page navigation -->
<div class="page-navigation">
  <a href="../pt-iv-dbt-docs-and-mart-models/" class="nav-button prev">Part IV</a>
  <div class="nav-spacer"></div>
</div>
