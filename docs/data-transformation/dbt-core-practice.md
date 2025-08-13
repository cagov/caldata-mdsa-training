# **dbt Core exercises**

## **Day 1**

### **dbt core command line reference**

1. Build and test all models in the project: `dbt build`
1. Build and tests a specific model: `dbt build --select path/to/the/model.sql`
1. Build a specific model and its upstream dependencies: `dbt build --select +path/to/the/model.sql`
1. Build a specific model and its downstream dependencies: `dbt build --select path/to/the/model.sql+`
1. Build all the models in a specific directory: `dbt build --select /path/to/the/directory`
1. Test a model: `dbt test --select path/to/the/model.sql`
1. Test a model and its upstream and downstream dependencies: `dbt test --select +path/to/the/model.sql+`
1. Build, but do not test, all models: `dbt run`

### **Practice A: Create your first dbt staging model for the `stations` data**

Let’s create two staging models! The data in `raw_dev.water_quality.stations` and `raw_dev.water_quality.lab_results` have been loaded from [data.ca.gov/dataset/water-quality-data](https://data.ca.gov/dataset/water-quality-data) without modification except for the exclusion of the `_id` column in each table. There are a few simple transformations we can do to make working with these data more ergonomic. Models that require simple transformations involving things like data type conversion or column renaming are called staging models.

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

1. _Lint_ and _Format_ your files
    1. You can lint your SQL files by navigating to the transform directory and running: `sqlfluff lint`
    1. You can fix your SQL files (at least the things that are easy to fix) by remaining in the transform directory and running `sqlfluff fix`
        1. For things that could not be auto-fixed you'll have to manually do it.
    1. Or, to run all the checks, run`pre-commit run --all-files`

Any of the above steps may modify your files requiring you to save (`git add`) them again.

1. Check to see which files need to be added or removed: `git status`
1. Add or remove any relevant files: `git add filename.ext` or `git rm filename.ext`
1. Commit your code and leave a concise, yet descriptive commit message: `git commit -m "example message"`
    1. During this step pre-commit may catch an error you missed. It may auto-fix your file or you may have to do it yourself. Regardless you will have to repeat `git add...` (for each modified file) and `git commit...`.
1. Push your code: `git push origin <your-first-name>-dbt-training`

## **Day 2**

### **Practice A: Write YAML for your source data and staging models**

Here you’ll write YAML configuration for the Water Quality source tables, and for the two staging models you built. It will build on the branch you created in the previous exercise, so open dbt Cloud, navigate to the developer tab, and make sure that branch is checked out.

1. Switch to your working branch: `git switch <your-first-name>-dbt-training`
1. In your text editor, open `transform/models/_sources.yml`. You should see mostly empty stubs for models and sources.
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

1. Open `transform/models/staging/training/stg_water_quality__stations.sql` and change the reference to our source data by using the `source()` macro we just learned about instead of directly referring to the table name

### **Practice B: Write tests for the `stg_water_quality__stations` model**

Open your `transform/models/staging/training/_water_quality.yml` and write some data integrity tests for your `stg_water_quality__stations` model.

1. Add a not null test for STATION_ID
1. Add a unique test for COUNTY_NAME. This one should fail!
1. In your dbt Cloud command line, run `dbt test --select stg_water_quality__stations`

!!! note
    The grain at which the stations data is collected results in duplicate county names so this is not a good test for this column.

**Final instructions**

1. _Lint_ and _Format_ your files
    1. You can lint your SQL files by navigating to the transform directory and running: `sqlfluff lint`
    1. You can fix your SQL files (at least the things that are easy to fix) by remaining in the transform directory and running `sqlfluff fix`
        1. For things that could not be auto-fixed you'll have to manually do it.
    1. Or, to run all the checks, run`pre-commit run --all-files`

Any of the above steps may modify your files requiring you to save (`git add`) them again.

1. Check to see which files need to be added or removed: `git status`
1. Add or remove any relevant files: `git add filename.ext` or `git rm filename.ext`
1. Commit your code and leave a concise, yet descriptive commit message: `git commit -m "example message"`
    1. During this step pre-commit may catch an error you missed. It may auto-fix your file or you may have to do it yourself. Regardless you will have to repeat `git add...` (for each modified file) and `git commit...`.
1. Push your code to your working branch: `git push origin <your-first-name>-dbt-training`

## **Day 3**

### **Practice: Create an intermediate dbt model**

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

1. Document your new intermediate model in the `transform/models/intermediate/training/_water_quality.yml` file
1. Materialize your model as a table

**Final instructions**

1. _Lint_ and _Format_ your files
    1. You can lint your SQL files by navigating to the transform directory and running: `sqlfluff lint`
    1. You can fix your SQL files (at least the things that are easy to fix) by remaining in the transform directory and running `sqlfluff fix`
        1. For things that could not be auto-fixed you'll have to manually do it.
    1. Or, to run all the checks, run`pre-commit run --all-files`

Any of the above steps may modify your files requiring you to save (`git add`) them again.

1. Check to see which files need to be added or removed: `git status`
1. Add or remove any relevant files: `git add filename.ext` or `git rm filename.ext`
1. Commit your code and leave a concise, yet descriptive commit message: `git commit -m "example message"`
    1. During this step pre-commit may catch an error you missed. It may auto-fix your file or you may have to do it yourself. Regardless you will have to repeat `git add...` (for each modified file) and `git commit...`.
1. Push your code to your working branch: `git push origin <your-first-name>-dbt-training`

## **Day 4**

### **Practice A: Custom schemas**

1. Configure your intermediate model to build in a custom schema called `statistics`. You can do this by creating a new property in the model YAML config block: “`schema: statistics`”.
1. Build your model and find it in Snowflake.

**Final instructions**

1. _Lint_ and _Format_ your files
    1. You can lint your SQL files by navigating to the transform directory and running: `sqlfluff lint`
    1. You can fix your SQL files (at least the things that are easy to fix) by remaining in the transform directory and running `sqlfluff fix`
        1. For things that could not be auto-fixed you'll have to manually do it.
    1. Or, to run all the checks, run`pre-commit run --all-files`

Any of the above steps may modify your files requiring you to save (`git add`) them again.

1. Check to see which files need to be added or removed: `git status`
1. Add or remove any relevant files: `git add filename.ext` or `git rm filename.ext`
1. Commit your code and leave a concise, yet descriptive commit message: `git commit -m "example message"`
    1. During this step pre-commit may catch an error you missed. It may auto-fix your file or you may have to do it yourself. Regardless you will have to repeat `git add...` (for each modified file) and `git commit...`.
1. Push your code to your working branch: `git push origin <your-first-name>-dbt-training`
1. Create a new pull request with your working branch
1. Add a teammate as a reviewer

### **Practice B: Get your branch to pass CI checks**

You’ve been working in your own branches to create dbt models and configuration files. Ultimately, our goal is to develop production-grade models, which are documented, configured, and passing CI. We’ll end the day by live reviewing a PR.
