# dbt (data build tool)

## Part V: Environments, jobs, CI/CD, and custom schemas

### Environments in Snowflake

We often talk about the concept of "environments". Broadly speaking, environments are a collection of compute resources, software, and configuration, which together represent a functioning context for development. Examples of environments include:

1. A “production” environment which is used to run the dbt models that have been merged to `main`. This can be run on an ad-hoc basis, or can be run on a schedule to ensure that models are never more than some amount of time old.
1. A "development" environment, which is used to run tests on branches and pull requests, and can help to catch bugs and regressions before they are deployed to production.
1. A "user acceptance testing (UAT)" environment, which can be used as a final testing environment for verifying code before it is deployed to production.

Unfortunately, that's pretty vague, since there are lots of different ways environments can be set up! Depending on your situation, different environments in Snowflake could be represented by:

- entirely different accounts
- different databases within the same account, or even
- different schemas within the same database.

In our default MDSA architecture we usually have two environments, "dev" and "prod", which reside in the same Snowflake account. Each of these environments consists of a set of databases corresponding to our layered data architecture (see our [Snowflake training](../cloud-data-warehouses/snowflake.md#snowflake-architecture) for more detail).

### Environments in dbt Platform

dbt Platform also has a concept of an Environment, which is a virtual machine in dbt Platform that has all of the relevant software dependencies and environment variables set. Roughly speaking, an environment in dbt Platform will correspond to one of your environments in Snowflake.

You’ve already encountered one environment, which is your “Develop:  Cloud IDE”. But you can create other environments in dbt Platform for various purposes. Our typical dbt Platform setup includes the following environments:

- Development, which uses the "dev" Snowflake environment. This is what you use when you work in the cloud IDE.
- Production, which uses the "prod" Snowflake environment. This is what we use to build production data models.
- Continuous Integration, which uses the "dev" Snowflake environment. This is what runs the automated CI checks.

### Jobs

A "job" is a command or series of commands that run in a given environment.
Examples of jobs we often use in our MDSA projects include:

- Running a nightly build of data models
- Running continuous integration (CI, see below!) checks
- Building project docs

Jobs can be configured in a number of ways: they can have different environment variables set,
they can run on a schedule, or they can be triggered by a specific action like a pull request being opened,
or a branch being merged.

### Continuous integration and continuous deployment (CI/CD)

#### Continuous Integration (CI)

Continuous Integration checks in GitHub, Azure DevOps, or BitBucket are automated tests that are run against your code every time you push a change.
They are an important part of the software development process, and can help you:

- **Catch errors and issues early:** CI checks can identify issues with your code before they can cause problems in production.
- **Improve code quality:** CI checks can help you to improve the quality of your code by identifying issues like duplicate or dead code and potential security vulnerabilities.
- **Establish a house style:** CI checks can enforce various code formatting rules and conventions that your team has agreed upon.

We have set up your project repository so that PRs cannot be merged to `main` unless these checks pass.
This can sometimes feel annoying! At the end of the day, however, CI/CD checks shouldn’t feel too painful or like a box-checking exercise:
they are rather intended to be a routine and helpful part of the development process.
Ultimately, experience has shown that effective use of CI/CD greatly speeds up development.

#### Continuous Deployment (CD)

Continuous Deployment (CD) in most MDSA projects is usually pretty simple.
We typically do not build any applications or deploy cloud resources.
Instead, whatever is in the `main` branch is considered "production",
and our dbt projects and docs are built using that.

For a deeper dive into how CI/CD is configured for this project see [these docs](../code/ci-cd.md)

#### Demo: CI/CD in a development workflow
<!-- TODO: ADD a video or diagram or something as a "demo" -->

1. How to read the results of CI checks on a PR.
1. How merging to `main` results in production dbt builds.

### Custom schema names

1. We’ll talk about how the database schemas in which dbt models are built are determined. In development, the models get built in a different place (e.g., your `DBT_<first-name-initial+last-name>`schema) than they do in production.
1. We’ll discuss how this project is configured to use a custom schema name generated using `transform/macros/get_custom_schema.sql`.

<!-- TODO: Add practice -->

### Knowledge check

#### Question #1

<div class="quiz-container">
  <div class="quiz-question">What is the purpose of staging models in dbt?</div>
  <ul class="quiz-options">
    <li class="quiz-option" data-correct="false">Apply complex business logic transformations</li>
    <li class="quiz-option" data-correct="false">Join multiple tables together</li>
    <li class="quiz-option" data-correct="true">Provide a one-to-one representation of source data with light transformations</li>
    <li class="quiz-option" data-correct="false">Create final analytical tables for end users</li>
  </ul>
  <div class="quiz-explanation">
    <strong>Explanation:</strong> Staging models create a one-to-one relationship with source data and perform only basic transformations like column renaming, type casting, and simple computations. Complex business logic belongs in intermediate or mart models.
  </div>
</div>

#### Question #2

<div class="quiz-container">
  <div class="quiz-question">Which materialization is typically used for staging models?</div>
  <ul class="quiz-options">
    <li class="quiz-option" data-correct="false">Table</li>
    <li class="quiz-option" data-correct="false">Incremental</li>
    <li class="quiz-option" data-correct="false">Snapshot</li>
    <li class="quiz-option" data-correct="true">View or ephemeral</li>
  </ul>
  <div class="quiz-explanation">
    <strong>Explanation:</strong> Staging models are typically materialized as views or ephemeral because they're cheap to rebuild and are queried by downstream models rather than end users.
  </div>
</div>

#### Question #3

<div class="quiz-container">
  <div class="quiz-question">Which command builds and tests a specific model?</div>
  <ul class="quiz-options">
    <li class="quiz-option" data-correct="false"><code>dbt run --select model_name</code></li>
    <li class="quiz-option" data-correct="false"><code>dbt test --select model_name</code></li>
    <li class="quiz-option" data-correct="true"><code>dbt build --select model_name</code></li>
    <li class="quiz-option" data-correct="false"><code>dbt compile --select model_name</code></li>
  </ul>
  <div class="quiz-explanation">
    <strong>Explanation:</strong> The <i>dbt build</i> command both runs and tests models. In contrast, <i>dbt run</i> builds the model without testing, <i>dbt test</i> tests without building, and <i>dbt compile</i> compiles SQL without executing it. The <i> dbt build</i> command is the most comprehensive option to ensure your model is both created and validated.
  </div>
</div>

### References

#### Key-pairs for CI

- [Creating encrypted key-pairs for service accounts that run CI and Production jobs](https://docs.snowflake.com/en/user-guide/key-pair-auth#configuring-key-pair-authentication)

<!-- code for page navigation -->
<div class="page-navigation">
  <a href="../pt-iv/" class="nav-button prev">Part IV - dbt docs and mart models</a>
  <div class="nav-spacer"></div>
</div>
