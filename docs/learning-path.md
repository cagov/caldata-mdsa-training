# Learning path

This guide walks you through one complete path for learning modern data stack skills.

!!! clock "Estimated Time: 16 hours (self-paced)"

---

## Your journey

### Step 1: Learn about concepts and tools (~3 hrs)

1. Read through the [training overview](overview.md) (required)

1. Understand [git](code/git.md) fundamentals (optional)
      - Read this if you are new to git and version control or if you need a refresher

1. Learn about GitHub (optional)
      - If you are completely new to this go through the [GitHub tutorials we've curated](code/platforms/github-tutorials.md)
      - If you only need a refresher keep our [GitHub](code/platforms/github.md) guide handy

    !!! Note
        If you did hands-on sessions with us to set up Snowflake architecture and CI/CD you can skip local repo setup. <br/>
        If your full team was not present for those sessions they will need to complete this step.

1. Read about the Snowflake RAW/TRANSFORM/ANALYTICS structure (required)
      - [Snowflake architecture](cloud-data-warehouses/snowflake.md##odi-snowflake-architecture)
      - [Databases and schemas](cloud-data-warehouses/snowflake.md#databases-and-schemas)

**Checkpoint:** Can you run `dbt debug` successfully? You should not move forward until this is successful.

---

### Step 2: Set up your local development environment (~2 hrs)

1. Complete your [local dev setup](code/local-dev-setup.md)
      - Complete the entire setup guide
      - You'll configure: a python environment, dbt, Snowflake connection, pre-commit hooks

---

### Step 3: Create your first staging models (~3 hrs)

1. [Part I: Foundations and staging models](data-transformation/dbt/pt-i.md)
      - Learn about dbt, data modeling, and what staging models are
      - Complete knowledge check
          - For any incorrect answers: Review content and research topics to solidy your understanding, don't just plow ahead
      - Complete hands-on practice

**Checkpoint:** Can you run `dbt run` successfully? You should have 2 staging models that build.

---

### Step 4: Write YAML docs and dbt tests (~2 hrs)

1. [Part II: YAML documentation and testing](data-transformation/dbt/pt-ii.md)
      - Learn about YAML configuration files and their structure, documentation, and dbt tests
      - Complete knowledge check
          - For any incorrect answers: Review content and research topics to solidy your understanding, don't just plow ahead
      - Complete hands-on practice

**Checkpoint:** Can you run `dbt test` and see passing tests?

---

### Step 5: Learn about model materializations and create an intermediate model (~2 hrs)

1. [Part III: Materializations and intermediate models](data-transformation/dbt/pt-iii.md)
      - Learn how to materialize your models and why for each choice and what intermediate models are
      - Complete knowledge check
          - For any incorrect answers: Review content and research topics to solidy your understanding, don't just plow ahead
      - Complete hands-on practice

<!-- TODO: fill in the model select below -->
**Checkpoint:** Can you run `dbt build --select xx` and see passing models and tests?

---

### Step 6: View your YAML docs as HTML and build a mart model (~2 hrs)

1. [Part IV: dbt docs and mart models](data-transformation/dbt/pt-iv.md)
      - Learn how to render your YAML documentation and what mart models are
      - Complete knowledge check
          - For any incorrect answers: Review content and research topics to solidy your understanding, don't just plow ahead
      - Complete hands-on practice
      - Open a PR
          - Push your branch to GitHub
          - Open a pull request with your staging models
          - Request review (or self-review to understand the process)

<!-- TODO: fill in the model select below -->
**Checkpoint:** Can you run `dbt build --select xx` and see passing models and tests? Do you have an open PR with your code?

---

### Step 7: Learn about environments, jobs, CI/CD, and custom schemas (~2 hrs)

1. [Part V: Environments, jobs, CI/CD, and custom schemas](data-transformation/dbt/pt-v.md)
      - Review your PR
      - If your check marks are red:
          1. Click through to understand the error
          1. Resolve the error locally
          1. Commit and push your changes
          1. Repeat the above steps until your check marks are ALL green

**Checkpoint:** Does your PR have passing CI checks?

---

## You've completed the training!

You now have skills in...

- Version control with git & GitHub ✅
- Data transformation with dbt ✅
- Working with Snowflake ✅
- Automated testing with CI/CD ✅
- Code review and collaboration ✅

and your final training pipeline should look like this:

```mermaid
flowchart TD
    subgraph Raw["RAW_DEV.water_quality"]
        R1[stations]
        R2[lab_results]
        R3[analytes]
        R4[sample_methods]
    end

    subgraph Staging["TRANSFORM_DEV.DBT_<initials>"]
        S1[stg_water_quality__stations]
        S2[stg_water_quality__lab_results]
        S3[stg_water_quality__analytes]
        S4[stg_water_quality__sample_methods]
    end

    subgraph Intermediate["TRANSFORM_DEV.DBT_<initials>"]
        I1[int_water_quality__stations_per_county_2023]
        I2[int_water_quality__lab_results_enriched]
        I3[int_water_quality__time_series_anomalies]
    end

    subgraph Marts["ANALYTICS_DEV.DBT_<initials>"]
        M1[water_quality_monitoring]
        M2[county_water_quality_summary]
        M3[parameter_catalog]
    end

    R1 --> S1
    R2 --> S2
    R3 --> S3
    R4 --> S4

    S1 --> I1
    S2 --> I1
    S1 --> I2
    S2 --> I2
    S3 --> I2
    S2 --> I3

    S1 --> M1
    S2 --> M1
    I2 --> M1

    I1 --> M2
    S2 --> M2

    S2 --> M3
    S3 --> M3

    style Raw fill:#ffe6e6
    style Staging fill:#e1f5ff
    style Intermediate fill:#fff4e6
    style Marts fill:#e6ffe6
```

---

## Next steps

- Apply these skills to your organization's data
- Explore [advanced dbt topics](data-transformation/dbt/advanced/macros-custom-tests.md)

---

## Using a different data warehouse?

Currently this training uses Snowflake. The dbt and git concepts remain the same, but SQL syntax may differ slightly.
