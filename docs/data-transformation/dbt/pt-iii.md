# dbt (data build tool)

## Part III: Materializations and intermediate models

### Materializations

Materializations refer to the way dbt executes and persists the results of SQL queries. It is the Data Definition Language (DDL) and Data Manipulation Language (DML) used to create a model’s equivalent in a data warehouse.

Understanding the options for materializations will allow you to choose the best strategy based on factors like query performance, data freshness, and data volume. There are four materializations used in dbt: view, table, incremental, and ephemeral. We used [dbt docs as our main source](https://docs.getdbt.com/best-practices/materializations/5-best-practices) for most of the materialization descriptions below.

#### View

- Views return the freshest, real-time state of their input data when they’re queried, this makes them ideal as building blocks for larger models.
- Views are also great for small datasets with minimally intensive logic that we want near real time access to.
- Staging models are rarely accessed directly by our end users.
- Staging models need to be always up-to-date and in sync with our source data as building blocks for later models so we’ll want to materialize our staging models as views.
- Since views are the default materialization in dbt, we don’t have to do any specific configuration for this.
- Still, for clarity, it’s a good idea to go ahead and specify the configuration to be explicit. We’ll want to make sure our dbt_project.yml looks like this:

```yaml
models:
  jaffle_shop:
    staging:
      +materialized: view
```

#### Table

- Tables are the most performant materialization, they return transformed data when queried with no need for reprocessing.
- Tables are also ideal for frequently used, compute intensive transformations. Making a table allows us to _freeze_ transformations in place.
- Marts, like one that services a popular dashboard, are frequently accessed directly by our end users, and need to be performant.
- Can often function with intermittently refreshed data, end user decision making in many domains is fine with hourly or daily data.
- Given the above properties we’ve got a great use case for building the data itself into the warehouse, not the logic. In other words, a table.
- The only decision we need to make with our marts is whether we can process the whole table at once or do we need to do it in chunks, that is, are we going to use the table materialization or incremental.

#### Incremental

- Incremental models build a table in pieces over time, only adding and updating new or changed rows.
- Builds more quickly than a regular table of the same logic.
- Initial runs are slow. Typically we use incremental models on very large datasets, so building the initial table on the full dataset is time consuming and equivalent to the table materialization.

Sources: [Incremental models in-depth](https://docs.getdbt.com/best-practices/materializations/4-incremental-models) and [Available materializations](https://docs.getdbt.com/best-practices/materializations/2-available-materializations)

#### A comparison table

![dbt materializations comparison table](../../images/dbt_materializations_comparison_table.png)

Source: [Available materializations](https://docs.getdbt.com/best-practices/materializations/2-available-materializations)

#### Materializations golden rule

- 🔍 Start with a view. When the view gets too long to query for end users,
- ⚒️ Make it a table. When the table gets too long to build in your dbt Jobs,
- 📚 Build it incrementally. That is, layer the data in chunks as it comes in.

#### Ephemeral

Ephemeral models are not directly built into the database. Instead, dbt will interpolate the code from this model into dependent models as a CTE. Use the ephemeral materialization for:

- Light-weight transformations that are early on in your DAG
- When they are only used in one or two downstream models, and
- Do not need to be queried directly

✅ Can help keep your data warehouse clean by reducing clutter<br/>
🚫 Overuse of ephemeral materialization can make queries harder to debug

Source: [Materializations](https://docs.getdbt.com/docs/build/materializations#ephemeral)

### Where to configure materializations

You can configure models in `dbt_project.yml`, the YAML file within the corresponding model’s folder, or within a specific model itself. Confusing thing about dbt configuration: the syntax and format change depend on where you use it!

```yaml
# in the dbt_project.yml file...
models:
  dse_analytics:
    staging:
      +materialized: view
    intermediate:
      +materialized: view
    marts:
      +materialized: table

# the YAML file within the corresponding model’s folder
version: 2

models:
  - name: int_state_entities__active
    materialized: table
    description: This is a sample description.
    columns:
      - name: name
        description: Name of the entity
```

```sql
-- within a specific model itself
{{
    config(
        materialized='view'
    )
}}

select ...
```

### Intermediate models

**Purpose:** Apply more complex transformations

**Key characteristics:**

- Combines data from multiple sources
- Contains reusable transformations
- Follows DRY (Don't Repeat Yourself) principles
- Modular building blocks for marts

**Common transformations:**

- Table joins or unions
- Data aggregations (e.g., `SUM()`, `COUNT()`, `AVG()`)
- Data pivots
- Feature engineering
- Business logic calculations

**Organization and naming:**

- Saved in an `intermediate/` subdirectory
- Files prefixed with `int_`
- Format: `int_<description>`
- Example: `int_water_quality__stations_per_county_2023`

**Materialization:**

- Views (if only used by one downstream model)
- Tables (if used by multiple marts or computationally expensive)

**When to create an intermediate model:**

- A calculation is used by multiple marts
- Complex business logic needs to be tested separately
- A join is used repeatedly
- You want to keep marts simple and focused

### Part III practice

Let refresh our memory on the value of [common table expressions (CTEs)](https://cagov.github.io/caldata-mdsa-training/data-transformation/dbt/#common-table-expressions-ctes).

#### Refresher on CTEs

Let's go from writing our code like this...

``` sql

select
    "station_id",
    "latitude",
    "longitude",
    "county_name"

from {{ source('WATER_QUALITY', 'lab_results') }}
```

To writing our code like this...

``` sql
with source_data as (
    select * from {{ source('WATER_QUALITY', 'lab_results') }}
),

lab_results as (
  select
    "station_id",
    "latitude",
    "longitude",
    "county_name"

  from source_data
)

select * from lab_results
```

Here’s [another example of a more complex, multi-stage CTE](https://github.com/cagov/data-infrastructure/blob/main/transform/models/marts/geo_reference/geo_reference__global_ml_building_footprints_with_tiger.sql) query.

#### Advanced model building and YAML documentation practice

!!! abstract "Create and document an intermediate dbt model"

    Now that we’ve gotten some practice creating two staging models and editing our YAML file to reference our source data and models, let's create an intermediate model and update the relevant YAML file.

    **SQL:**

    1. Switch to your working branch: `<your-first-name>-dbt-training`
    1. Open `transform/models/intermediate/training/int_water_quality__stations_per_county_with_parameter_2023_counted.sql`
    1. Change the reference to the staging model by using the `ref()` macro we learned about
    1. Write a SQL query to return a count of the stations per county that reported a parameter of Dissolved Chloride for the year 2023 sorted from greatest to least.
    1. _Hints_
        1. This will make use of a SQL group by, aggregation, and join
        1. Your output table should have two columns
        1. Use Snowflake’s [year()](https://docs.snowflake.com/en/sql-reference/functions/year) function
    1. Structure your query so that the main part of it is in a CTE, from which you `select *` at the end

    **YAML:**

    1. Document your new intermediate model in the `transform/models/intermediate/training/_int_water_quality.yml` file
    1. Materialize your model as a table

#### Write some data tests

!!! abstract "Write tests for the `stg_water_quality__stations` model"

    Open your `transform/models/staging/training/_stg_water_quality.yml` and write some data integrity tests for your `stg_water_quality__stations` model.

    1. Add a not null test for STATION_ID
    1. Add a unique test for COUNTY_NAME. This one should fail!
    1. In your dbt Cloud command line, run `dbt test --select stg_water_quality__stations`

    !!! note
        The grain at which the stations data is collected results in duplicate county names so this is not a good test for this column.

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

### Part III references

#### Materializations, Jinja, and dbt Models

- [dbt materialization and performance considerations](https://cagov.github.io/data-infrastructure/dbt/dbt-performance/#2-model-level-materialization-matters)
- [Jinja tutorial: Use Jinja to improve your SQL code](https://docs.getdbt.com/guides/using-jinja?step=1)
- [Re-watch the second and third video from Day 1: Models in dbt](https://cagov.github.io/caldata-mdsa-training/data-transformation/dbt-cloud/#models-in-dbt)
