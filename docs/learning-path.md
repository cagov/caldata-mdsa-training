# Learning path

This guide walks you through the complete path you will take to learn data and analytics engineering concepts and skills as well as modern data tooling. If at any point throughout this training you get stuck, feel free to ask questions in the Teams channel you were added to.

!!! clock "Estimated Time: 16 hours (self-paced)"

---

## Your journey

### Step 1: Set up your local development environment (~2 hrs)

1. Complete your [local dev setup](code/local-dev-setup.md)
      1. Complete the entire setup guide
      1. You'll configure: the training repo, a python environment, dbt, Snowflake connection, pre-commit hooks

    !!! Note
        If you did hands-on sessions with us to set up Snowflake architecture and CI/CD you may have already done some of this, please go through it anyway to ensure you have not missed a step. If your full team was not present for those sessions they will need to complete this step.

### Step 1a: Load the data to Snowflake (one team member)

This is intended for only one person on the team to do. Follow the instructions on the [data loading page](/docs/code/loading-data.md).

---

### Step 2: Learn about concepts and tools (~3 hrs)

1. Read through the [concepts and tools](concepts-tools.md) guide (required)

1. Understand [git](code/git.md) fundamentals (optional)
      1. Read this if you are new to git and version control or if you need a refresher

1. Learn about GitHub (optional)
      1. If you are completely new to this go through the [GitHub tutorials we've curated](code/platforms/github-tutorials.md)
      1. If you only need a refresher keep our [GitHub](code/platforms/github.md) guide handy for easy reference

1. Read about the Snowflake architecture after which we model the data warehouse (required)
      1. Read this section [Databases and schemas](cloud-data-warehouses/snowflake.md#databases-and-schemas) all the way through _Defaults_
      1. Read this section, [Snowflake architecture](cloud-data-warehouses/snowflake.md#odi-snowflake-architecture), all the way through _Visualizing the ODI context_

    !!! Note
        You only need to read about the two sections we linked to above, not the entirety of the Snowflake page.

---

### Step 3: Create your first staging models (~3 hrs)

1. [Part I: Foundations and staging models](data-transformation/dbt/pt-i-foundations-and-staging-models.md)
      1. Learn about dbt, data modeling, and what staging models are
      1. Complete the knowledge check section
          1. For any incorrect answers: Review content and research topics to solidy your understanding before moving forward
      1. Complete the practice section
          1. Review the answer key. For parts you got wrong, try to understand how your model and the answer key model are different. What is the grain of your model? For answers you got correct, but solved differently, note the distinctions. It's okay to arrive at the right answer with a different method, we only want you to be aware of other solutions. If you think your solution is more readable or performant, let us know!

**Checkpoint:** Can you run `dbt run` successfully? You should have 2 staging models that build.

---

### Step 4: Write YAML docs and dbt tests (~2 hrs)

1. [Part II: YAML documentation and testing](data-transformation/dbt/pt-ii-yaml-docs-and-testing.md)
      1. Learn about YAML configuration files and their structure, documentation, and dbt tests
      1. Complete the knowledge check section
          1. For any incorrect answers: Review content and research topics to solidy your understanding before moving forward
      1. Complete the practice section
          1. Review the answer key. For parts you got wrong, try to understand how your model and the answer key model are different. What is the grain of your model? For answers you got correct, but solved differently, note the distinctions. It's okay to arrive at the right answer with a different method, we only want you to be aware of other solutions. If you think your solution is more readable or performant, let us know!

**Checkpoint:** Can you run `dbt test` and see passing tests?

---

### Step 5: Learn about model materializations and create an intermediate model (~2 hrs)

1. [Part III: Materializations and intermediate models](data-transformation/dbt/pt-iii-materializations-and-intermediate-models.md)
      1. Learn how to materialize your models and why for each choice and what intermediate models are
      1. Complete the knowledge check section
          1. For any incorrect answers: Review content and research topics to solidy your understanding before moving forward
      1. Complete the practice section
          1. Review the answer key. For parts you got wrong, try to understand how your model and the answer key model are different. What is the grain of your model? For answers you got correct, but solved differently, note the distinctions. It's okay to arrive at the right answer with a different method, we only want you to be aware of other solutions. If you think your solution is more readable or performant, let us know!

**Checkpoint:** Can you run `dbt build --select int_water_quality__lab_results_enriched` and see passing models and tests?

---

### Step 6: View your YAML docs as HTML and build a mart model (~2 hrs)

1. [Part IV: dbt docs and mart models](data-transformation/dbt/pt-iv-dbt-docs-and-mart-models.md)
      1. Learn how to render your YAML documentation and what mart models are
      1. Complete the knowledge check section
          1. For any incorrect answers: Review content and research topics to solidy your understanding before moving forward
      1. Complete the practice section
          1. Review the answer key. For parts you got wrong, try to understand how your model and the answer key model are different. What is the grain of your model? For answers you got correct, but solved differently, note the distinctions. It's okay to arrive at the right answer with a different method, we only want you to be aware of other solutions. If you think your solution is more readable or performant, let us know!
      1. Open a PR
          1. Push your branch to GitHub
          1. Open a pull request with your staging models
          1. Request review (or self-review to understand the process)

**Checkpoint:** Can you run `dbt build --select stations` and see passing models and tests? Do you have an open PR with your code?

---

### Step 7: Learn about environments, jobs, CI/CD, and custom schemas (~2 hrs)

1. [Part V: Environments, jobs, CI/CD, and custom schemas](data-transformation/dbt/pt-v-environments-jobs-ci-cd-and-custom-schemas.md)
      1. Review your PR
      1. If your check marks are red:
          1. Click through to understand the error
          1. Resolve the error locally
          1. Commit and push your changes
          1. Repeat the above steps until your check marks are ALL green

**Checkpoint:** Does your PR have passing CI checks?

---

## You've completed the training! ✅

You now have skills in

- Version control with git & GitHub
- Data transformation with dbt
- Working with Snowflake
- Automated testing with CI/CD
- Code review and collaboration

and your final training pipeline should look like this:

```mermaid
flowchart LR
    subgraph Raw["RAW_DEV.WATER_QUALITY"]
        R1[stations]
        R2[lab_results]
    end

    subgraph Staging["TRANSFORM_DEV.DBT_JDOE"]
        S1[stg_water_quality__stations]
        S2[stg_water_quality__lab_results]
    end

    subgraph Intermediate["TRANSFORM_DEV.DBT_JDOE"]
        I1[int_water_quality__lab_results_enriched]
    end

    subgraph Marts["ANALYTICS_DEV.DBT_JDOE"]
        M1[stations]
    end

    R1 --> S1
    R2 --> S2

    S1 --> I1
    S2 --> I1

    I1 --> M1

    style Raw fill:#ffe6e6
    style Staging fill:#e1f5ff
    style Intermediate fill:#fff4e6
    style Marts fill:#e6f7e6
```

---

## Next steps

- Apply these skills to your organization's data
- Explore [advanced dbt topics](data-transformation/dbt/advanced/macros-custom-tests.md)

---

## Using a different data warehouse?

Currently this training uses Snowflake. The dbt and git concepts remain the same, but SQL syntax may differ slightly.
