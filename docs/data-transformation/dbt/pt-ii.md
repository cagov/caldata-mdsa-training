# dbt (data build tool)

## Part II: YAML documentation and testing

### Why document your data?

Documentation helps:

- New team members understand the data
- Future you remember what you built and why
- Stakeholders know what data means
- Build trust in data quality

What to document:

- Source tables and their purpose
- Model descriptions (what does this represent?)
- Column descriptions
- Business logic and assumptions

### What is YAML?

YAML (Yet Another Markup Language) is a human-readable format for configuration files. In dbt it is used both for documentation and configuration purposes.

Broadly speaking, there are two kinds of relations in a dbt project: “models” and “sources”. “Sources” are your raw, untransformed data sets. “Models” are the tables and views that you create when transforming your data into something. Both of these are described using YAML files.

The YAML files in a dbt project contain the metadata for your relations, both sources and models. They include:

- Documentation
- Configuration
- Data tests

YAML is a superset of JSON (JavaScript Object Notation) and intended to be a more human readable version, but JSON is still perfectly valid! For example, `{“my-key”: 4}` is YAML. YAML has support for:

- Key-value pairs (i.e., dictionaries/maps)
- Lists
- Strings, numbers, booleans

It is used for configuration for tools like:

- dbt
- GitHub Actions
- Azure Pipelines
- BitBucket Pipelines
- Kubernetes
- AWS CloudFormation
- Many other tools!

Indentation is meaningful in YAML. Use **2 spaces**, not two tabs, to indent sections per level of nesting.

#### YAML dictionaries/maps

```yaml
# In YAML, comments are started with the hashtag # symbol

# Dictionaries/maps use indentation and colons :
my_dictionary:
  a_number: 12
  a_string: "hello, world!"
  a_boolean: true
  a_nested_dictionary:
    key: "value"
    another_key: "another value"

# Because YAML is a superset of JSON, we can equivalently write:
my_dictionary: {"a_number":12, "a_string": "hello, world!", "a_boolean": true}
```

#### YAML lists

```yaml
# Lists use indentation and dashes -
my_list:
  - 1
  - 2
  - 3
  - 4

# Because YAML is a superset of JSON, we can equivalently write:
my_list: [1, 2, 3, 4]
```

#### YAML strings

```yaml
# YAML strings may be written without quotes "" as long as there is no ambiguity
my_dictionary:
  a_string: "britt is cool!"
  also_a_string: britt is cool

# But omitting the quotes for a string can get you in trouble when the string is ambiguous!
my_dictionary:
  # This is interpreted as a number and would pull in python 3.1 instead of 3.10!
  python_version: 3.10
  another_python_version: "3.10" # this is what we want!

  # This gets interpreted as a boolean instead of a string!
  should_i_eat_lunch: yes
```

#### YAML multiline strings

```yaml
# Use the pipe | or right angle bracket > to break up long strings for legibility
long_snippet: |
  cotton candy blues
  juxtaposed with blushing peaks
  postcard-worthy views

another_long_snippet: >
  Call me Ishmael. Some years ago - never mind how long precisely -
  having little or no money in my purse, and nothing particular to
  interest me on shore, I thought I would sail about a little and see
  the watery part of the world.
```

#### Markdown in YAML

```yaml
# dbt renders description strings as Markdown
a_markdown_string: |
  This is rendered as Markdown! So I can use _emphasis_
  or **bold text**. I can also include:

  - Lists
  - of
  - items

  as well as [URLs](https://github.github.com/gfm/)
```

!!! note
    Code blocks are designed to display text literally, so Markdown formatting like bolding, italicizing, or headings won't be applied. Hence why you do not see the affect above. However, in dbt which does allow
    for richer text formatting, applying markdown to your YAML, like we've done above, will work.

### Why test your data?

- Catch data quality issues early
- Prevent bad data from reaching production
- Document assumptions about your data
- Build confidence in your models

### Data tests

dbt ships with 4 “generic” data tests. We recommend giving their [data test documentation](https://docs.getdbt.com/docs/build/data-tests) a thorough read as we only pulled high-level content from it.:

1. Not null
1. Unique
1. Relationships
1. Accepted Values

Default test outcomes are:

- Pass: 0 rows found
- Fail: 1+ rows found

dbt example:

```YAML
models:
  - name: orders
    columns:
      - name: order_id
        data_tests:
          - unique
          - not_null
      - name: status
        data_tests:
          - accepted_values:
              values: ['placed', 'shipped', 'completed']
      - name: customer_id
        data_tests:
          - relationships:
              to: ref('customers')
    data_tests:
      - unique:
          column_name: "(customer_id || '-' || order_date)"
```

In dbt you execute tests with either of the following:

- dbt test (tests models only)
- dbt build (builds and tests models)

Sample results from the YAML config above

``` S
23:52:21  1 of 4 START test unique_orders__order_id_ ........... [RUN]
23:52:21  2 of 4 START test not_null_orders__order_id_ ......... [RUN]
23:52:21  3 of 4 START test accepted_values_orders__status_ .... [RUN]
23:52:21  1 of 4 PASS unique_orders__order_id_ ................. [PASS in 0.69s]
23:52:21  4 of 4 START test relationships_orders__customer_id_ . [RUN]
23:52:22  2 of 4 PASS not_null_orders__order_id_ ............... [PASS in 0.78s]
23:52:22  3 of 4 PASS accepted_values_orders__status_ .......... [PASS in 0.74s]
23:52:22  4 of 4 PASS relationships_orders__customer_id_ ....... [PASS in 0.57s]
23:52:22
23:52:22  Finished running 4 tests in 0 hours 0 minutes and 2.81 seconds (2.81s).
23:52:22
23:52:22  Completed successfully
23:52:22
23:52:22  Done. PASS=4 WARN=0 ERROR=0 SKIP=0 TOTAL=4
```

[Test severity](https://docs.getdbt.com/reference/resource-configs/severity) can be configured like so:

- error: test will pass or fail (default)
- warn: test will pass or warn

Tests with a severity of “error” can also have warnings configured.

dbt example:

```YAML
columns:
  - name: controller_id
    data_tests:
      - not_null

  - name: controller_type
    data_tests:
      - not_null:
          config:
            severity: warn
```

Thresholds can be configured with *error_if* and *warn_if* options. The default is *error_if*:  `> 0`
When working with Snowflake you can use any supported comparison syntax like so: `= 0`, `<> 15`, or `between 10 and 20`.
Also, note that *error_if* will be ignored if severity is warn!

dbt example:

```YAML
columns:
  - name: controller_id
    data_tests:
      - not_null

  - name: controller_type
    data_tests:
      - not_null:
          config:
            severity: warn

  - name: district
    data_tests:
      - not_null:
          config:
            error_if: ">10"
            warn_if: ">5"
```

For people who are familiar with transactional databases, you might be curious why tests like this are ever
needed (i.e., why don’t we handle it using constraints?). In a traditional transactional database like
postgres or SQL Server, you can have a uniqueness constraint on a column. Snowflake does not respect
uniqueness constraints and most OLAP databases do not either. Primary keys and foreign keys are examples of
unique columns that are respected in OLTP databases that are not in OLAP databases. If you're interested there
is [more reading](https://cagov.github.io/data-infrastructure/learning/cloud-data-warehouses/#primary-keys-and-constraints) available on this topic.

### Referring to sources and models

Instead of directly referring to the database, schema, and table/view names, we use macros in dbt called `source` and `ref`.

It can be initially confusing to people that we don’t directly refer to the names of the other data models, and instead do it via the `source` and `ref` macros. There are a few reasons for this:

1. By explicitly linking your sources and models using the `source` and `ref` macros, you help dbt in constructing a data lineage graph (i.e., which tables depend on which others). This allows you to do things like “rebuild a model and all of its upstream dependencies”, or “test a model and all of its downstream dependents”.
1. It becomes easier to rename a data source. This can be especially useful if the data source comes to you with unhelpful names.
1. Source and refs become context aware. For example, in a development context, your personal development schema is templated into the SQL queries, but in a production context the final production schema is templated in. This allows for safer development of new models.

The syntax for this is to replace the raw names `database.schema.view_name/table_name` with a template directive like this: `{{ source('source_name', 'table_name') }}`

The curly braces are a syntax for _Jinja_ templating. The expression within the curly braces is a Python (ish) function which gets evaluated and inserted into the SQL file. There are lots of things we can do with Jinja to help generate our SQL queries, including basic math, custom Python functions, loops, and if-else statements. Most of the time, you will just need to be able to use the `source` and `ref` macros.

#### source()

This function creates dependencies between source data and the current model (usually staging) referencing it. Your dbt project will depend on raw data stored in your database. Since this data is normally loaded by other tools than dbt, the structure of it can change over time – tables and columns may be added, removed, or renamed. When this happens, it is easier to update models if raw data is only referenced in one place.

**Example:** replace `RAW_DEV.WATER_QUALITY.LAB_RESULTS` with `{{ source('WATER_QUALITY', 'LAB_RESULTS') }}`

#### ref()

This function is how you reference a model from another: it allows you to build more complex models by referring to other ones and constructing a data lineage graph. Under the hood this function is actually doing two important things. First, it is interpolating the schema into your model file to allow you to change your deployment schema via configuration. Second, it is using these references between models to automatically build the dependency graph. This will enable dbt to deploy models in the correct order when using dbt run.

**Example:** Replace `stg_water_quality__stations` with `{{ ref(‘stg_water_quality__stations’) }}`

### Practice

#### Use the `source()` macro

!!! abstract "Change source references in your staging models"

    Here you’ll write YAML configuration for the two staging models you built.

    1. If not already on your working branch, switch to it: `git switch <your-first-name>-dbt-training`
    1. Open `transform/models/staging/training/stg_water_quality__stations.sql` and change the reference to our source data by using the `source()` macro we just learned about instead of directly referring to the table name

    **Stuck?** Check out [the answer](answer-key.md#answer-for-use-the-source-macro) for this exercise.

#### Edit YAML docs and write data tests

!!! abstract "Write YAML for your staging models and add data tests to `stg_water_quality__stations`"

    1. Open and review `transform/models/_sources.yml`. We filled this out as an example of a correct YAML file. Notice the indentation at each level of nesting.
    1. Next, open `transform/models/staging/training/_stg_water_quality.yml` and write some docs for the fields the model outputs
        1. Add column names
        1. Add column descriptions

    In the same file, write some data integrity tests for just your `stg_water_quality__stations` model.

    1. Add a not null test for STATION_ID
    1. Add a unique test for COUNTY_NAME. This one should fail!
    1. In your dbt Platform command line, run `dbt test --select stg_water_quality__stations`
    1. After observing the test results, remove only the unique test

    !!! note
        The grain at which the stations data is collected results in duplicate county names so the unique test is not a good test for this column.

    **Stuck?** Check out [the answer](answer-key.md#answer-for-edit-yaml-docs-and-write-data-tests) for this exercise.

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
    1. Don't open a PR just yet, we'll do that later

=== "dbt Platform"

    1. Click the _Lint_ and _Fix_ buttons to check and edit your files
    1. Save any changes made by clicking "Save" or using a keyboard shortcut
    1. Commit and sync your code
    1. Leave a concise, yet descriptive commit message

### Knowledge check

#### Question #1

<div class="quiz-container">
  <div class="quiz-question">What is the purpose of using the <code>source()</code> and <code>ref()</code> macros in dbt?</div>
  <ul class="quiz-options">
    <li class="quiz-option" data-correct="false">To make SQL queries run faster</li>
    <li class="quiz-option" data-correct="true">To build data lineage graphs and enable context-aware deployments</li>
    <li class="quiz-option" data-correct="false">To automatically generate documentation</li>
    <li class="quiz-option" data-correct="false">To validate data quality</li>
  </ul>
  <div class="quiz-explanation">
    <strong>Explanation:</strong> The <code>source()</code> and <code>ref()</code> macros help dbt construct a data lineage graph, making it easier to rebuild dependencies and enabling context-aware deployments (e.g., using development schemas in dev environments and production schemas in production).
  </div>
</div>

#### Question #2

<div class="quiz-container">
  <div class="quiz-question">Which of the following is NOT one of dbt's four built-in generic data tests?</div>
  <ul class="quiz-options">
    <li class="quiz-option" data-correct="false">not_null</li>
    <li class="quiz-option" data-correct="false">unique</li>
    <li class="quiz-option" data-correct="true">greater_than</li>
    <li class="quiz-option" data-correct="false">relationships</li>
  </ul>
  <div class="quiz-explanation">
    <strong>Explanation:</strong> The four built-in generic tests in dbt are: not_null, unique, relationships, and accepted_values. While you can create custom tests for conditions like greater_than, it is not a built-in test.
  </div>
</div>

#### Question #3

<div class="quiz-container">
  <div class="quiz-question">In YAML, what is the correct way to indent nested elements?</div>
  <ul class="quiz-options">
    <li class="quiz-option" data-correct="true">Use 2 spaces per level of nesting</li>
    <li class="quiz-option" data-correct="false">Use 1 tab per level of nesting</li>
    <li class="quiz-option" data-correct="false">Use 4 spaces per level of nesting</li>
    <li class="quiz-option" data-correct="false">Indentation does not matter in YAML</li>
  </ul>
  <div class="quiz-explanation">
    <strong>Explanation:</strong> YAML requires consistent indentation to define structure, and the standard practice in dbt is to use 2 spaces (not tabs) per level of nesting. Indentation is meaningful in YAML and affects how the file is parsed.
  </div>
</div>

### References

#### Sources

- [Modularity and ref functions](https://platform.thinkific.com/videoproxy/v1/play/cefo4lqgv9ite187s6pg)
- [What are sources?](https://platform.thinkific.com/videoproxy/v1/play/c6mfkh840bhpn3t0c730)
- [Configure and select from sources](https://platform.thinkific.com/videoproxy/v1/play/ce4cj9s69iu53jbdif6g)
- [Documenting sources](https://platform.thinkific.com/videoproxy/v1/play/ce2dbtnf17fhkgqdq580)

#### Testing

- [What is testing?](https://platform.thinkific.com/videoproxy/v1/play/c71iuqg40bhpn3t11pcg)
- [Generic tests](https://platform.thinkific.com/videoproxy/v1/play/ce9kjv0r715nknv53nhg)

<!-- code for page navigation -->
<div class="page-navigation">
  <a href="../pt-i/" class="nav-button prev">Part I</a>
  <a href="../pt-iii/" class="nav-button next">Part III</a>
</div>
