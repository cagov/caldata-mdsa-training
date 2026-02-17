# Training answer key

## Part I

### Answer for create your first staging model

```sql
with stations as (

    select
        to_varchar(station_id) as station_id,

        full_station_name,
        station_number,
        station_type,
        latitude,
        longitude,
        county_name,
        sample_count,

        to_timestamp(sample_date_min, 'MM/DD/YYYY HH24:MI') as sample_timestamp_min,
        to_timestamp(sample_date_max, 'MM/DD/YYYY HH24:MI') as sample_timestamp_max

    from RAW_DEV.WATER_QUALITY.STATIONS -- or {{ source('WATER_QUALITY', 'stations') }}
)

select * from stations

```

### Answer for create your second staging model

```sql
with lab_results as (

    select
        to_varchar(station_id) as station_id,
        status,
        sample_code,

        to_timestamp(sample_date, 'MM/DD/YYYY HH24:MI') as sample_timestamp,

        date_from_parts(
            substr(sample_date, 7, 4)::INT,
            left(sample_date, 2)::INT,
            substr(sample_date, 4, 2)::INT
        ) as sample_date,

        sample_depth,
        sample_depth_units,
        parameter,
        result,
        reporting_limit,
        units,
        method_name

    from RAW_DEV.WATER_QUALITY.LAB_RESULTS -- or {{ source('WATER_QUALITY', 'lab_results') }}
)

select * from lab_results

```

## Part II

### Answer for use the `source()` macro

Change `from RAW_DEV.WATER_QUALITY.STATIONS` to `from {{ source('WATER_QUALITY', 'stations') }}`

### Answer for edit YAML docs and write data tests

```YAML
version: 2

models:
  - name: stg_water_quality__stations
    description: Staging model for stations.
    config:
      materialized: table
    columns:
      - name: station_id
        description: A unique identifier for stations.
        data_tests:
          - not_null
      - name: full_station_name
        description: |
          The (full) station name describing the sampling location
          based on DWR station naming conventions.
      - name: station_number
        description: |
          Unique DWR station code based on DWR station numbering
          conventions.
      - name: station_type
        description: |
          General description of sampling site location,
          i.e., surface water, groundwater, or other.
      - name: latitude
        description: Latitude (NAD83).
      - name: longitude
        description: Longitude (NAD83).
      - name: county_name
        description: County where sample collected.
        data_tests:
          # - unique # we commented this out because we ask you to remove it after you run the test and observe the results
      - name: sample_code
        description: Unique DWR lab and field data sample code.
      - name: sample_date_min
        description: |
          Date of the first sample collection event on record
          for a given DWR sampling location.
      - name: sample_date_max
        description: |
          Date of the last sample collection event on record
          for a given DWR sampling location.

  - name: stg_water_quality__lab_results
    description: Statging model for lab results.
    columns:
      - name: station_id
        description: A unique identifier for stations.
      - name: status
        description: Data review status.
      - name: sample_code
        description: Unique DWR lab and field data sample code.
      - name: sample_timestamp
        description: The date and time a sample was collected.
      - name: sample_date
        description: The date a sample was collected.
      - name: sample_depth
        description: The depth below the water surface at which the sample was collected.
      - name: sample_depth_units
        description: The unit of measurement of sample_depth, e.g. feet
      - name: parameter
        description: The chemical analyte or physical parameter that was measured.
      - name: result
        description: The measured result of the constituent.
      - name: reporting_limit
        description: The lowest quantifiable detection limit of measure.
      - name: units
        description: Units of measure for the result.
      - name: method_name
        description: The analytical method by which the constituent was measured.

```

## Part III

### Answer for create first intermediate model and YAML docs

**SQL**

```SQL
with stations as (
    select * from {{ ref('stg_water_quality__stations') }}
),

lab_results as (
    select * from {{ ref('stg_water_quality__lab_results') }}
),

stations_per_county as (
    select
        station_id,
        county_name

    from stations
    group by station_id, county_name
),

stations_per_county_with_parameter_2023_counted as (
    select
        s.county_name,
        count(distinct l.station_id) as station_count

    from stations_per_county as s
    inner join lab_results as l
        on s.station_id = l.station_id

    where
        year(l.sample_date) = 2023
        and l.parameter = 'Dissolved Chloride'
    group by s.county_name
)

select * from stations_per_county_with_parameter_2023_counted
order by station_count desc

```

**YAML**

```YAML
version: 2

models:
  - name: int_water_quality__stations_per_county_with_parameter_2023_counted
    description: |
      This model returns a count of the stations per county that
      reported a parameter of Dissolved Chloride for the year
      2023 sorted from greatest to least.
    columns:
      - name: county_name
        description: County where sample collected.
      - name: station_count
        description: Count of stations that reported a parameter of Dissolved Chloride.

```

### Answer for create second intermediate model and YAML docs

**SQL**

```SQL
with stations as (
      select * from RAW_DEV.WATER_QUALITY.STATIONS
  ),

  lab_results as (
      select * from RAW_DEV.WATER_QUALITY.LAB_RESULTS
  ),

  joined_data as (
      select
          s.station_id,
          s.county_name,
          lr.parameter,
          lr.result,
          lr.sample_date
      from stations as s
      inner join lab_results as lr
          on s.station_id = lr.station_id
      where s.county_name = 'Los Angeles'

  ),

  parameter_stats as (
      select
          station_id,
          county_name,
          parameter,
          count(*) as sample_count
      from joined_data
      group by station_id, county_name, parameter
      having count(*) >= 10
  ),

  -- select * from parameter_stats

  ranked_parameters as (
      select
          station_id,
          parameter,
          sample_count,
          row_number() over (
              partition by station_id
              order by sample_count desc
          ) as parameter_rank
      from parameter_stats
  ),

  top_parameters_per_station as (
      select
          station_id,
          parameter,
          sample_count
      from ranked_parameters
      where parameter_rank = 1
  )

select * from top_parameters_per_station
order by station_id
```

**YAML**


## Part IV

```YAML
version: 2

models:
  - name: int_water_quality__stations_per_county_with_parameter_2023_counted
    config:
      schema: statistics
    ...
```
