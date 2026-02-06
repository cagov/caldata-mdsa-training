# dbt (data build tool)

## Part I: Foundations and staging models

### What is dbt?

dbt is a SQL-first transformation tool that lets teams quickly and collaboratively deploy analytics code while following software engineering best practices like modularity, version control, CI/CD, and documentation. This allows your data team to safely develop and contribute to production-grade data pipelines.

### Data modeling in the context of dbt

In the context of dbt, data modeling refers to the process of organizing data in a structured and efficient manner to facilitate data analysis and decision-making. Data models in dbt serve as blueprints for transforming and organizing your raw data into valuable insights. Data models in their final form are usually a representation of a business or program area and live as tables or views in your data warehouse.

### The three-layer architecture (staging, intermediate, mart)

Data layers represent a systematic approach to data modeling by organizing data into distinct phases:

```
Raw/Source data → Staging → Intermediate → Mart
```

Each layer has a specific purpose and follows specific conventions. We'll cover intermediate and marts later.

dbt does a particularly great job of explaining best practices to structuring your project and data with naming conventions, example code, and reasoning on such practices in [this guide](https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview). We’ve summarized it below, but still recommend a thorough read of dbt’s guide from which the content below stems.

<!-- TODO: Cover source and seed data here -->

### Staging models

**Purpose:** The staging layer is the initial point of contact for your raw data.

**Key characteristics:**

  - One-to-one relationship with source data
  - Ensures data integrity
  - Provides a reliable foundation for downstream models
  - Very few data transformations

**Appropriate transformations:**

  - Column renaming (e.g., `PLACEFP` → `place_fips`)
  - Data type casting (e.g., string to numeric)
  - Basic computations (e.g., cents to dollars)

**Organization and naming:**

  - Saved in a `staging/` subdirectory
  - Files prefixed with `stg_`
  - Format: `stg_<source>__<entity>` e.g. `stg_water_quality__stations`

**Materialization:**

  - Typically materialized as views or ephemeral (more about materializations later!)
  - Cheap to rebuild, queried by downstream models

### Common table expressions (CTEs)

CTEs are widely used as a way to create modular and readable SQL queries. You can think of CTEs as temporary, named data tables within your SQL queries.

CTEs are often framed as an alternative to SQL subqueries. In dbt-style SQL, CTEs are usually preferable to subqueries for a few reasons:

1. Read code from top to bottom (not inside out)
1. Reuse intermediate results
1. Give descriptive names to intermediate results

In a nutshell, CTEs are reusable within a model and are more readable and maintainable.

=== "CTE"

    ``` sql
    with total_samples_by_county as (

      select
          "COUNTY_NAME",
          SUM(SAMPLE_COUNT) as total_samples
      from raw_dev.water_quality.stations
      group by "COUNTY_NAME"

    )

    select * from total_samples_by_county
    where total_samples > 10
    ```

=== "Subquery"

    ``` sql
    select *
    from (
        select
            COUNTY_NAME,
            SUM(SAMPLE_COUNT) as total_samples
        from raw_dev.water_quality.stations
        group by "COUNTY_NAME"
    ) as subquery
    where total_samples > 10
    ```

### Practice

Before we dive into exercises take a look at our command line reference to understand what dbt commands do. You can run these in your terminal locally or in the command line on dbt Cloud. dbt Cloud also offers a GUI with buttons you can press to run some of these commands as well.

**dbt command line reference**

1. `dbt build` – Build and test all models in the project
1. `dbt build --select path/to/the/model.sql` – Build and tests a specific model
1. `dbt build --select +path/to/the/model.sql` – Build a specific model and its upstream dependencies
1. `dbt build --select path/to/the/model.sql+` – Build a specific model and its downstream dependencies
1. `dbt build --select /path/to/the/directory` – Build all the models in a specific directory
1. `dbt test --select path/to/the/model.sql` – Test a model
1. `dbt test --select +path/to/the/model.sql+` – Test a model and its upstream and downstream dependencies
1. `dbt run` – Build, but do not test, all models

#### Create your first dbt staging model

!!! abstract "Create a staging model for the `STATIONS` data"

    There are a few simple transformations we can do to make working with these data more ergonomic. Models that require simple transformations involving things like data type conversion or column renaming are called staging models.

    1. Switch to your branch: `git switch <your-first-name>-dbt-training` (we created this in advance for you!)
    1. In your text editor, open `transform/models/staging/training/stg_water_quality__stations.sql` – you should see a SQL statement that selects all of the data from the raw table
    1. Update the select statement to do the following:
        1. Explicitly select all columns by name rather than with `*`
        1. Exclude the following column: `STATION_NAME`
        1. Change the `STATION_ID` column type to varchar
            1. Use Snowflake’s [TO_VARCHAR()](https://docs.snowflake.com/en/sql-reference/functions/to_char) function which needs one argument – the column to be converted
        1. Change the `SAMPLE_DATE_MIN` and `SAMPLE_DATE_MAX` columns to timestamps and rename them to `SAMPLE_TIMESTAMP_MIN` and `SAMPLE_TIMESTAMP_MAX`
            1. Use Snowflake’s [TO_TIMESTAMP()](https://docs.snowflake.com/en/sql-reference/functions/to_timestamp) function which needs two arguments – the column to be converted and the output format e.g. `YYYY-MM-DD HH24:MI:SS`
        1. Structure your query so that the main part of it is in a CTE, from which you `select *` at the end

#### Create your second dbt staging model

!!! abstract "Create a staging model for the `LAB_RESULTS` data"

    1. Remain on your current branch: `<your-first-name>-dbt-training`
    1. Open `transform/models/staging/training/stg_water_quality__lab_results.sql` – you should see a SQL statement that selects all of the data from the raw table
    1. Update the select statement to do the following:
        1. Explicitly select the following columns by name rather than with `*`:
            - `station_id`, `status`, `sample_code`, `sample_date`, `sample_depth`, `sample_depth_units`, `parameter`, `result`, `reporting_limit`, `units`, and `method_name`
        1. Change the `station_id` column type to varchar
            1. Use Snowflake’s [TO_VARCHAR()](https://docs.snowflake.com/en/sql-reference/functions/to_char) function which needs one argument – the column to be converted
        1. The `sample_date` column in the source data table is of data type `VARCHAR` and we want to change it to `DATE`. The values for this column are also formatted like timestamps. We want this column to both be of type `DATE` and contain values that look like dates.
            1. Use Snowflake's [DATE_FROM_PARTS()](https://docs.snowflake.com/en/sql-reference/functions/date_from_parts) function to extract the parts of this column needed to turn it into a date. You'll need to use other string manipulation functions as well e.g. [SUBSTR()](https://docs.snowflake.com/en/sql-reference/functions/substr), [LEFT()](https://docs.snowflake.com/en/sql-reference/functions/left), [RIGHT()](https://docs.snowflake.com/en/sql-reference/functions/right). And [cast](https://docs.snowflake.com/en/sql-reference/functions/cast) the values from those resulting parts as `INT` before feeding them into the date_from_parts function. This column should still be aliased as SAMPLE_DATE.
        1. Change the `sample_date` column type again, to timestamp and rename it to SAMPLE_TIMESTAMP
            1. Use Snowflake’s [TO_TIMESTAMP()](https://docs.snowflake.com/en/sql-reference/functions/to_timestamp) function which needs two arguments – the column to be converted and the output format e.g. `YYYY-MM-DD HH24:MI:SS`
    1. Structure your query so that the main part of it is in a CTE, from which you `select *` at the end

=== "dbt Core"

    1. _Lint_ and _Format_ your files
        1. You can lint your SQL files by navigating to the transform directory and running: `sqlfluff lint models/staging`
        1. You can fix your SQL files (at least the things that are easy to fix) by remaining in the transform directory and running `sqlfluff fix models/staging`
            1. For things that could not be auto-fixed you'll have to manually do it.
        1. Or, to run all the checks, run`pre-commit run --all-files` Note: we don't recommend running this at this stage, since crucial project set up fixes will be addressed in further exercises.

    Any of the above steps may modify your files requiring you to save (`git add`) them again.

    1. Check to see which files need to be added or removed: `git status`
    1. Add or remove any relevant files: `git add filename.ext` or `git rm filename.ext`
    1. Commit your code and leave a concise, yet descriptive commit message: `git commit -m "example message"`
        1. During this step pre-commit may catch an error you missed. It may auto-fix your file or you may have to do it yourself. Regardless you will have to repeat `git add...` (for each modified file) and `git commit...`.
    1. Push your code: `git push origin <your-first-name>-dbt-training`



=== "dbt Cloud"

    1. Click the _Lint_ and _Fix_ buttons to check and edit your files
    1. Save any changes made by clicking "Save" or using a keyboard shortcut
    1. Commit and sync your code
    1. Leave a concise, yet descriptive commit message

### Self-assessment

<div class="quiz-container">
  <div class="quiz-question">What is the purpose of staging models in dbt?</div>
  <ul class="quiz-options">
    <li class="quiz-option" data-correct="false">Apply complex business logic transformations</li>
    <li class="quiz-option" data-correct="true">Provide a one-to-one representation of source data with light transformations</li>
    <li class="quiz-option" data-correct="false">Create final analytical tables for end users</li>
    <li class="quiz-option" data-correct="false">Join multiple tables together</li>
  </ul>
  <div class="quiz-explanation">
    <strong>Explanation:</strong> Staging models create a one-to-one relationship with source data and perform only basic transformations like column renaming, type casting, and simple computations. Complex business logic belongs in intermediate or mart models.
  </div>
</div>

### References

#### dbt Fundamentals

[dbt Fundamentals](https://courses.getdbt.com/courses/fundamentals) is an online self-paced course on how to use dbt and dbt Cloud. It is broadly similar to the content in this training, and you may find some of the videos from the course helpful to review. We’ve linked to some of the videos below.

#### Models in dbt

- [What are models?](https://platform.thinkific.com/videoproxy/v1/play/c71iuqg02svskgqkn6jg)
- [Building your first model](https://platform.thinkific.com/videoproxy/v1/play/cecuppiekd0onghk4p20)
- [What is modularity?](https://platform.thinkific.com/videoproxy/v1/play/c71iuqg02svskgqkn6lg)
