# Loading your training data

These instructions are intended for just one person on the team. This one person should have the correct permissions to load data into the `RAW_DEV` database and create schemas. After this step is complete the entire team going through this training will be able to use this data.

Below we walk you through two ways to load the training data. The first is through the Snowflake UI so you can get familiar with the UI and that capability. The second is with a python script so you can learn this pythonic process. The Lab Results csv is also too large to be loaded using the Snowflake UI.

## Loading Stations data

1. Click the following links to download the training data as a `.csv` file
    1. [Stations](https://data.ca.gov/dataset/water-quality-data/resource/07ba626a-0bc8-4ce9-b6ac-3f29ce3c8e6f)
1. In Snowflake, on the bottom of the left pane beneath your name/initials, switch to the `LOADER_DEV` role
1. Navigate to _Catalog_ on the left pane and click on the `RAW_DEV` database
    1. Click the blue _+ Schema_ button at the top right
    1. Input `WATER_QUALITY` then click _Create_
1. Next, navigate to the top of the left pane and click the `+` symbol
    1. Scroll to _Table_ then click _From File_
![Example of Snowflake's UI to create a table from file](../images/snowflake-ui-table-from-file.png)
1. Select/input the following:
    Warehouse: `LOADING_XS_DEV`
    Database: `RAW_DEV`
    Schema: `WATER_QUALITY`
    Create new table > Name: `STATIONS`
1. Review load settings, then click _Next_
1. On the next screen, make sure _Delimited Files (CSV or TSV)_ is selected for _File format_
1. Leave everything else unchanged and click _Load_

## Loading Lab Results data

Please follow the steps for loading stations data first before loading lab results data.

1. Set up environment variables for Snowflake authentication. Add these to your shell config (`~/.zshrc`, `~/.bashrc`, or `~/.bash_profile`):

   ```bash
   export SNOWFLAKE_ACCOUNT=<org_name>-<account_name>
   export SNOWFLAKE_USER=<your-username>
   export SNOWFLAKE_AUTHENTICATOR=externalbrowser  # or username_password_mfa
   export SNOWFLAKE_DATABASE=RAW_DEV
   export SNOWFLAKE_WAREHOUSE=LOADING_XS_DEV
   export SNOWFLAKE_ROLE=LOADER_DEV
   ```

   Open a new terminal or run `source ~/.zshrc` (or your shell config file) to apply the changes.

2. In your terminal, run the Python script to load the data:

   ```bash
   cd caldata-mdsa-training-practice
   uv sync  # Install dependencies if you haven't already
   uv run python python/load_water_quality_data.py
   ```

!!! note
    This script downloads lab results data from data.ca.gov and loads it into `RAW_DEV.WATER_QUALITY.LAB_RESULTS`. The download may take a few minutes.

**Checkpoint:** Verify that both tables have loaded to Snowflake by navigating to _Catalog_ > `RAW_DEV` database > `WATER_QUALITY` schema. Click _Data Preview_ to review each table. Validate row counts match with what you see on the data.ca.gov links above.
