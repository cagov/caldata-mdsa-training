# Macros and custom tests in dbt

## Macros

[Macros](https://docs.getdbt.com/docs/build/jinja-macros#macros) in [Jinja](https://docs.getdbt.com/docs/build/jinja-macros) are pieces of code that can be reused multiple times – they are analogous to "functions" in other programming languages, and are extremely useful if you find yourself repeating code across multiple models. Remember (DRY). Macros are defined in .sql files, typically in your macros directory (e.g.`transform/macros`).

Take a look at our macro example on the `stations` data.

1. Switch to the `britt-dbt-training` branch
1. Open and review `transform/macros/map_county_name_to_county_fips.sql`
    1. Then open `transform/models/intermediate/training/int_water_quality__counties.sql` and review line 9
1. Review this second [macro example](https://github.com/cagov/data-infrastructure/blob/main/transform/macros/map_class_fp.sql) that is called by [this code](https://github.com/cagov/data-infrastructure/blob/65a4a5c47f0326d50161bc4a1a3e81c20cb19a3e/transform/models/marts/geo_reference/geo_reference__global_ml_building_footprints_with_tiger.sql#L34)

## dbt_utils package

The [dbt_utils package](https://hub.getdbt.com/dbt-labs/dbt_utils/latest/) contains macros that can be (re)used across this project. Software engineers frequently modularize code into libraries. These libraries help programmers operate with leverage. In dbt, libraries like these are called packages. dbt's packages are powerful because they tackle many common analytic problems that are shared across teams.

1. Example that uses the _dbt_utils_ test [_equal_rowcount_](https://github.com/dbt-labs/dbt-utils/tree/1.1.1/?tab=readme-ov-file#equal_rowcount-source)
    1. Switch to the `britt-dbt-training` branch
    1. Open `transform/models/staging/training/_water_quality.yml` and review lines 6-10
    1. Run`dbt test --select stg_water_quality__stations`
        1. Note this test fails if trying to compare a table to a view

```yaml
version: 2

models:
  - name: stg_water_quality__stations
    description: Staging model for stations.
    config:
      materialized: table
    data_tests:
      - dbt_utils.equal_rowcount:
        compare_model: source('WATER_QUALITY', 'stations')
```

## Data tests

Let's revisit [data tests](../dbt.md#data-tests) from our foundational dbt training!

## Custom tests

dbt allows you to [create custom tests](https://docs.getdbt.com/best-practices/writing-custom-generic-tests) if you cannot find what you’re looking for with the generic tests, the dbt_utils package (see above), or in other packages. Custom tests are assertions you make about your models and other resources in your dbt project (e.g. sources, seeds, etc.). When you run `dbt test`, dbt will tell you if each test in your project passes or fails. You can use open source [dbt packages](https://docs.getdbt.com/docs/build/packages) like *dbt_utils* (mentioned above) or [*dbt_expectations*](https://hub.getdbt.com/calogica/dbt_expectations/latest/) rather than reinventing the wheel!

Custom tests are stored in the `tests` directory or `test-paths` entry in your `dbt_project.yml`

There are two ways of defining custom tests in dbt:

1. A [**singular**](https://docs.getdbt.com/docs/build/data-tests#singular-data-tests) **data test** is testing in its simplest form: If you can write a SQL query that returns failing rows, you can save that query in a `.sql` file within your [test directory](https://docs.getdbt.com/reference/project-configs/test-paths). It's now a data test, and it will be executed by the dbt test command.

    **Definition**:

    - SQL file with a select-type query
    - Jinja macros are usable, like ref() and source()

    **How to execute**:
    Test will automatically run on `dbt test` or `dbt build` if it is in the correct directory

    dbt example:

    ``` S
    ~/repo/transform $ cat tests/singular/example.sql
    SELECT value
    FROM (SELECT 1 AS value FROM {{ ref('model_name') }})
    WHERE value = 0

    ~/repo/transform $ dbt test --select example
    22:24:57  Running with dbt=1.6.10
    22:24:58
    22:24:58  1 of 1 START test example ............ [RUN]
    22:24:58  1 of 1 PASS example .................. [PASS in 0.64s]
    22:24:58
    22:24:58  Finished running 1 test in 1.32 seconds (1.32s).
    22:24:58
    22:24:58  Completed successfully
    22:24:58
    22:24:58  Done. PASS=1 WARN=0 ERROR=0 SKIP=0 TOTAL=1
    ```

1. A [**generic**](https://docs.getdbt.com/docs/build/data-tests#generic-data-tests) **data test** is a parameterized query that accepts arguments. The test query is defined in a special test block (like a macro). Once defined, you can reference the generic test by name throughout your `.yml` files—define it on models, columns, sources, seeds, etc.

    **Definition**:

    - Reusable test macro that accepts arguments to generate a query

    **How to use**:

    - Define test (as a macro) in a file
    - Associate test with models
    - Add additional arguments as needed

    dbt example:

    ```YAML
    ~/repo/transform $ cat models/_models.yml
    models:
      - name: city_county_extras
        columns:
          - name: county
            data_tests:
              - valid_county
    ```

    ```SQL
    ~/repo/transform $ cat tests/generic/test_valid_county.sql
    {% test valid_county(model, column_name) %}

    SELECT {{ column_name }}
    FROM {{ model }}
    WHERE {{ column_name }} NOT IN
    (SELECT name FROM {{ ref('stg_tiger_counties') }})

    {% endtest %}
    ```

## Practice

We wrote a test to verify that the `sample_date` column in the `stg_water_quality__lab_results` model matches this regex `\d{4}-\d{2}-\d{2}`.

To run the test yourself:

1. Check out the branch: `britt-dbt-training`
2. Navigate to the file: `transform/tests/singular/verify_sample_date.sql`, you should see the following code:

    ```SQL
    with validation as (
    select
        sample_date,
        case
            when REGEXP_LIKE(sample_date, '^\\d{4}-\\d{2}-\\d{2}$') then 0
            else 1
        end as verify_format
    from {{ ref('stg_water_quality__lab_results') }}
    )

    select verify_format
    from validation
    group by verify_format
    having sum(verify_format) > 0
    ```

3. Run the test `dbt test --select verify_sample_date`
4. The test should pass!
