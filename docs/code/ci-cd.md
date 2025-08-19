# Continuous Integration/Continuous Deployment

Continuous Integration and Continuous Deployment (or Delivery), usually abbreviated as CI/CD,
are a critical part of modern software, data, and analytics engineering.
Broadly speaking, they are about automating parts of the code development process:

* **Continuous Integration (CI)** refers to automating testing, linters, formatters, and other code quality checks.
* **Continuous Deployment (CD)** refers to automating build, deployment, or publishing processes.
    This could happen on every merge to `main`, or could be triggered by specific actions in special repository branches.

Automating things using CI/CD provides major benefits to development teams:

1. Catch bugs and other errors before they are deployed
1. Develop new features with speed and confidence
1. Establish a house style with linters and formatters
1. Remove humans from complex and error-prone deployment processes

## Continuous Integration (CI)

Most developers interact with CI checks on a daily basis.
Usually CI checks run on every proposed change to the code base (i.e., pull requests to `main`).
Examples of CI checks include:

- **Code quality checks:** These look for issues with your code, such as syntax errors, potential security vulnerabilities, and performance issues.
- **Build checks:** These ensure your code can be successfully built.
- **Test checks:** These run your unit tests and integration tests to ensure that they pass.
- **Deployment checks:** These ensure your code can be successfully deployed to a test environment.

ODI's MDSA projects usually use a combination of
dbt Cloud (setup instructions [here](https://cagov.github.io/data-infrastructure/setup/dbt-setup/))
and GitHub Actions (setup instructions [here](https://cagov.github.io/data-infrastructure/setup/repo-setup/#set-up-ci-in-github))
for running CI. We include the following CI checks:

#### pre-commit

The pre-commit check is a collection of smaller checks.
They are intended to be fast and cheap to run,
so the entire suite runs in a couple of seconds or less.

ODI's MDSA projects typically contains (at least) the following pre-commit checks:

* Verifying that `.json` files are valid
* Verifying that `.yaml` files are valid
* Trimming whitespace from the end of lines and files
* Checking that merge conflicts aren't committed
* Type checking, linting, and formatting Python files using `ruff` and `mypy`
    (for projects that include Python)
* Linting and formatting SQL files using `sqlfluff`
* Linting and formatting YAML files using `prettier` and `yamllint`.

These checks run in two different contexts:

1. They are run for the whole project on every pull request to `main` in CI.
1. Since they are fast and cheap, they can be installed as git
    [pre-commit hooks](https://git-scm.com/book/ms/v2/Customizing-Git-Git-Hooks) (hence the name of the check).
    For instructions on how to install pre-commit hooks locally see
    [these docs](local-repo-setup.md#5-install-pre-commit-hooks).

#### dbt build

The dbt build check builds the dbt project in the development environment.
Depending on the scale of the data, this build might take a significant amount of time,
and may cost some money in Snowflake compute (as such it isn't appropriate for a pre-commit check).
Building a dbt project includes the following components:

* Verifies that models can build
* Verifies that data tests pass
* Verifies that seed load

The ODI team currently uses two different approaches to running this CI check:

1. Run using [dbt Cloud's continuous integration hooks](https://docs.getdbt.com/docs/deploy/continuous-integration)
1. Run using GitHub actions (example [here](https://github.com/cagov/caldata-ddrc-pipelines/blob/main/.github/workflows/tests.yml))

In both cases, a service account is used to connect to Snowflake when running the check.
The schemas for models built during CI are prefixed with either
`DBT_CLOUD_PR_` or `GH_CI_PR_`, depending on whether CI is run through dbt Cloud or GitHub Actions.

#### docs build

The docs build check ensures that the project docs build without issue
(example [here](https://github.com/cagov/caldata-ddrc-pipelines/blob/main/.github/workflows/docs.yml)).

## Continuous Deployment (CD)

Continuous Deployment (CD) in most MDSA projects is usually pretty simple.
We typically do not build any applications or deploy cloud resources.
Instead, whatever is in the `main` branch is considered "production",
and our dbt projects and docs are built using that.

ODI's MDSA projects usually include the following CD processes:

#### dbt build

The dbt build step checks out the `main` branch of the project repository
and builds the dbt project in the production environment.

The ODI team currently uses two different approaches to running this process:

1. Run using a dbt Cloud production environment
1. Run using GitHub actions (example [here](https://github.com/cagov/caldata-ddrc-pipelines/blob/main/.github/workflows/pipeline.yml))

#### docs build

The docs build step checks out the `main` branch of the project repository,
builds the HTML project docs, and pushes them to GitHub Pages
(example [here](https://github.com/cagov/caldata-ddrc-pipelines/blob/main/.github/workflows/docs.yml)).

In most cases our docs CI check is the same as our docs CD process,
the CI check just skips the push to GitHub pages.
