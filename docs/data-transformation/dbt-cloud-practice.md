# **dbt Cloud practice**

## **Day 1**

### **Tour of dbt Cloud user interface**

1. We’ll give you a brief overview of the dbt Cloud user interface:
    1. _Studio_ → _File explorer_ → _File editor_ → _Preview_ → _Results_ → _Lineage_
1. Validate your development environment:
    1. Open the Develop tab in your own environment and open `transform/models/staging/training/stg_water_quality__stations.sql`
    1. Click on the _Preview_ button. You should see data in the lower panel
1. Demonstrate the _Lint_/_Fix_ functionality
1. Demonstrate the _Build_/_Test_ functionality
1. Demonstrate `dbt run --select <model name>` on the command line
1. Verify that the models you built/ran are visible in your personal schema within `TRANSFORM_DEV`

### **Practice A: Create your first dbt staging model for the `stations` data**

Let’s create two staging models! The data in `raw_dev.water_quality.stations` and `raw_dev.water_quality.lab_results` have been loaded from [data.ca.gov/dataset/water-quality-data](https://data.ca.gov/dataset/water-quality-data) without modification except for the exclusion of the `_id` column in each table. There are a few simple transformations we can do to make working with these data more ergonomic. Models that require simple transformations involving things like data type conversion or column renaming are called staging models.

1. Find and switch to your branch: `<your-first-name>-dbt-training`
1. Open `transform/models/staging/training/stg_water_quality__stations.sql` – you should see a SQL statement that selects all of the data from the raw table
1. Update the select statement to do the following:
    1. Explicitly select all columns by name rather than with `*`
    1. Exclude the following column: `STATION_NAME`
    1. Change the `STATION_ID` column type to varchar
        1. Use Snowflake’s [TO_VARCHAR()](https://docs.snowflake.com/en/sql-reference/functions/to_char) function which needs one argument – the column to be converted
    1. Change the `SAMPLE_DATE_MIN` and `SAMPLE_DATE_MAX` columns to timestamps and rename them to `SAMPLE_TIMESTAMP_MIN` and `SAMPLE_TIMESTAMP_MAX`
        1. Use Snowflake’s [TO_TIMESTAMP()](https://docs.snowflake.com/en/sql-reference/functions/to_timestamp) function which needs two arguments – the column to be converted and the output format e.g. `YYYY-MM-DD HH24:MI:SS`
    1. Structure your query so that the main part of it is in a CTE, from which you `select *` at the end

### **Practice B: Create your second staging model for the `lab_results` data**

1. Remain on your current branch: `<your-first-name>-dbt-training`
1. Open `transform/models/staging/training/stg_water_quality__lab_results.sql` – you should see a SQL statement that selects all of the data from the raw table
1. Update the select statement to do the following:
    1. Explicitly select the following columns by name rather than with `*`:
        - `station_id`, `status`, `sample_code`, `sample_date`, `sample_depth`, `sample_depth_units`, `parameter`, `result`, `reporting_limit`, `units`, and `method_name`
    1. Change the `station_id` column type to varchar
        1. Use Snowflake’s [TO_VARCHAR()](https://docs.snowflake.com/en/sql-reference/functions/to_char) function which needs one argument – the column to be converted
    1. Change the `sample_date` column type to timestamp and rename it to SAMPLE_TIMESTAMP
        1. Use Snowflake’s [TO_TIMESTAMP()](https://docs.snowflake.com/en/sql-reference/functions/to_timestamp) function which needs two arguments – the column to be converted and the output format e.g. `YYYY-MM-DD HH24:MI:SS`
    1. Alias and capitalize all of your columns (except for the two timestamp columns since you did this already) e.g. `select “column_name” as COLUMN_NAME`
1. Structure your query so that the main part of it is in a CTE, from which you `select *` at the end

**Final instructions**

1. _Lint_ and _Fix_ your files, save any changes made
1. Commit and sync your code and leave a concise, yet descriptive commit message
1. In GitHub (or Azure DevOps), create a new pull request and add a teammate as a reviewer
1. We’ll end the day by reviewing each other’s PRs

## **Day 2**

### **Practice A: Write YAML for your source data and staging models**

Here you’ll write YAML configuration for the Water Quality source tables, and for the two staging models you built. It will build on the branch you created in the previous exercise, so open dbt Cloud, navigate to the developer tab, and make sure that branch is checked out.

1. Switch to your existing branch: `<your-first-name>-dbt-training`
1. Open `transform/models/_sources.yml`. You should see mostly empty stubs for models and sources.
1. First, specify where the Water Quality data exists in the Snowflake database. We’ll do that by adding some keys to the `Water Quality` source:
    1. Add a key for the database: (`database: RAW_DEV`).
    1. Add a key for the schema: (`schema: WATER_QUALITY`).
1. Describe the tables that exist in the WATER_QUALITY schema:

    ```yaml
    sources:
      - name: WATER_QUALITY
        database: <database name here>
        schema: <schema name here>
        description: <data description here>
        tables:
          - name: <table name here>
            description: <table description here>
            columns:
              - name: <column name here>
                description: <column description here>
                name: <column name here>
                description: <column description here>
                …  # etc
    ```

1. _Format_ your file, save any changes made
1. Open `transform/models/staging/training/stg_water_quality__stations.sql` and change the reference to our source data by using the `source()` macro we just learned about instead of directly referring to the table name
1. _Lint_ and _Fix_ your file, save any changes made
1. Commit and sync your code and leave a concise, yet descriptive commit message

### **Practice B: Write tests for the `stg_water_quality__stations` model**

Open your `transform/models/staging/training/_water_quality.yml` and write some data integrity tests for your `stg_water_quality__stations` model.

1. Add a not null test for STATION_ID
1. Add a unique test for COUNTY_NAME. This one should fail!
1. In your dbt Cloud command line, run `dbt test --select stg_water_quality__stations`

!!! note
    The grain at which the stations data is collected results in duplicate county names so this is not a good test for this column.

## **Day 3**

### **Practice: Create an intermediate dbt model**

Now that we’ve gotten some practice creating two staging models and editing our YAML file to reference our source data and models, let's create an intermediate model and update the relevant YAML file.

**SQL:**

1. Switch to your existing branch: `<your-first-name>-dbt-training`
1. Open `transform/models/intermediate/training/int_water_quality__stations_per_county_with_parameter_2023_counted.sql`
1. Change the reference to the staging model by using the `ref()` macro we learned about
1. Write a SQL query to return a count of the stations per county that reported a parameter of Dissolved Chloride for the year 2023 sorted from greatest to least.
1. _Hints_
    1. This will make use of a SQL group by, aggregation, and join
    1. Your output table should have two columns
    1. Use Snowflake’s [year()](https://docs.snowflake.com/en/sql-reference/functions/year) function
1. Structure your query so that the main part of it is in a CTE, from which you `select *` at the end
1. _Lint_ and _Fix_ your file, save any changes made

**YAML:**

1. Document your new intermediate model in the `transform/models/intermediate/training/_water_quality.yml` file
1. Materialize your model as a table
1. _Format_ your file, save any changes made

**Pull Request:**

1. Commit and sync your code and leave a concise, yet descriptive commit message
1. In GitHub or Azure DevOps, check that you’ve added a teammate as a reviewer to your PR
1. Review someone else’s PR
1. Optional: Check that your PR passes all CI (continuous integration) checks. If not, click “details” and investigate the failure – We’ll spend more time on this in Day 4

## **Day 4**

### **Practice A: Custom schemas**

1. Configure your intermediate model to build in a custom schema called `statistics`. You can do this by creating a new property in the model YAML config block: “`schema: statistics`”.
1. Build your model and find it in Snowflake.

### **Practice B: Get your branch to pass CI checks**

You’ve been working in your own branches to create dbt models and configuration files. Ultimately, our goal is to develop production-grade models, which are documented, configured, and passing CI.

**If using GitHub:**

1. Inspect the `pre-commit` results of your pull request in GitHub.
1. Address any issues flagged by the results. Remember, the “_Format_”, “_Lint_”, and “_Fix_” buttons in dbt Cloud can help with auto-resolving issues around formatting.
1. Inspect the dbt Cloud test results in GitHub. Resolve any issues with your models not building or failing data integrity tests.
1. Request a review of a teammate. Review another teammate’s PR.
1. Address any comments or suggestions from your code review.
1. Repeat the above steps until there are no remaining comments, and you get a green checkmark on the CI checks!

**If using Azure DevOps:**

1. On the page for your pull request you should see the results of the CI checks. If it’s green, great, it passed!
1. If the CI check is red, click on it to see the logs, which will give more information about the failure. You might see failures in:
    1. The linter checks (which looks for code style and common gotchas).
    1. Model builds, which indicate some logic issue in the code.
    1. Data tests, which ensure that the data has the shape you expect.
1. Address any issues flagged by the check. Remember, the “_Format_”, “_Lint_”, and “_Fix_” buttons in dbt Cloud can help with auto-resolving issues around formatting.
1. Request a review of a teammate. Review another teammate’s PR.
1. Address any comments or suggestions from your code review.
1. Repeat the above steps until there are no remaining comments, and you get a green checkmark on the CI checks.
