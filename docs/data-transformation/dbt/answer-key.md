# Training answer key

## Part I

### Answer for create a staging model using the `STATIONS` data

```sql
with stations as (

    select
        to_varchar(station_id) as station_id,

        full_station_name,
        station_type,
        latitude,
        longitude,
        county_name,

        to_timestamp(sample_date_min, 'MM/DD/YYYY HH24:MI') as first_sample_timestamp,
        to_timestamp(sample_date_max, 'MM/DD/YYYY HH24:MI') as last_sample_timestamp

    from RAW_DEV.WATER_QUALITY.STATIONS
)

select * from stations

```

### Answer for create a staging model using the `LAB_RESULTS` data

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
        method_name

    from RAW_DEV.WATER_QUALITY.LAB_RESULTS
)

select * from lab_results

```

## Part II

### Answer for use the `source()` macro

Change `from RAW_DEV.WATER_QUALITY.STATIONS` to `from {{ source('WATER_QUALITY', 'stations') }}`

### Answer for write YAML docs and data tests

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
      - name: station_type
        description: |
          General description of sampling site location,
          i.e., surface water, groundwater, or other.
      - name: latitude
        description: Latitude (NAD83).
      - name: longitude
        description: Longitude (NAD83).
      - name: county_name
        description: County where sample was collected.
        # we commented out the two lines below because we ask you to remove this test after you run it and observe the results
        # data_tests:
          # - unique
      - name: first_sample_timestamp
        description: |
          Date of the first sample collection event on record
          for a given DWR sampling location.
      - name: last_sample_timestamp
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
      - name: method_name
        description: The analytical method by which the constituent was measured.

```

## Part III

### Answer for create an enriched intermediate model and docs

**SQL**

```SQL
with stations as (
    select * from {{ ref('stg_water_quality__stations') }}
),

lab_results as (
    select * from {{ ref('stg_water_quality__lab_results') }}
),

lab_results_enriched as (
    select
        lr.station_id,
        s.full_station_name,
        s.station_type,
        s.latitude,
        s.longitude,
        s.county_name,
        lr.sample_code,
        s.first_sample_timestamp,
        s.last_sample_timestamp,
        lr.sample_timestamp,
        lr.sample_depth,
        lr.sample_depth_units,
        lr.parameter,
        lr.method_name,
        lr.status,
        datediff(day, s.last_sample_timestamp, CURRENT_DATE) as days_since_last_sample

    from lab_results as lr
    -- by default this is an inner join
    -- https://docs.snowflake.com/en/sql-reference/constructs/join
    join stations as s
        on lr.station_id = s.station_id
)

select * from lab_results_enriched
```

**YAML**

```YAML
version: 2

models:
  - name: int_water_quality__lab_results_enriched
    description: |
      Intermediate model that enriches lab results with
      metadata from the stations table.
    config:
      materialized: table
    columns:
      - name: station_id
        description: A unique identifier for stations.
      - name: full_station_name
        description: |
          The (full) station name describing the sampling location
          based on DWR station naming conventions.
      - name: station_type
        description: |
          General description of sampling site location,
          i.e., surface water, groundwater, or other.
      - name: latitude
        description: Latitude (NAD83).
      - name: longitude
        description: Longitude (NAD83).
      - name: county_name
        description: County where sample was collected.
      - name: sample_code
        description: Unique DWR lab and field data sample code.
      - name: first_sample_timestamp
        description: |
          Date of the first sample collection event on record
          for a given DWR sampling location.
      - name: last_sample_timestamp
        description: |
          Date of the last sample collection event on record
          for a given DWR sampling location.
      - name: sample_timestamp
        description: The date and time a sample was collected.
      - name: sample_depth
        description: The depth below the water surface at which the sample was collected.
      - name: sample_depth_units
        description: The unit of measurement of sample_depth, e.g. feet
      - name: parameter
        description: The chemical analyte or physical parameter that was measured.
      - name: method_name
        description: The analytical method by which the constituent was measured.
      - name: status
        description: Data review status.
      - name: days_since_last_sample
        description: the number of days that have passed, in whole numbers, since the last sample collection.

```

## Part IV

### Answer for create a mart model and YAML docs

**SQL**

```SQL
with source_data as (
    select * from {{ ref('int_water_quality__lab_results_enriched') }}
),

station_metrics as (
    select
        station_id,
        any_value(full_station_name) as full_station_name,
        any_value(station_type) as station_type,
        any_value(county_name) as county_name,
        any_value(latitude) as latitude,
        any_value(longitude) as longitude,
        count(*) as total_samples,
        count(distinct parameter) as unique_parameters_tested,
        any_value(first_sample_timestamp) as first_sample_timestamp,
        any_value(last_sample_timestamp) as last_sample_timestamp,
        any_value(days_since_last_sample) as days_since_last_sample

    from source_data
    group by station_id
),

top_parameters as (
    select
        station_id,
        parameter as top_parameter,
        count(*) as top_parameter_sample_count

    from source_data
    group by station_id, parameter
    qualify rank() over (
        partition by station_id
        order by count(*) desc
    ) = 1
),

-- The 2 CTEs below are another way to do what the top_parameters CTE above is doing

-- parameter_metrics as (
--     select
--         station_id,
--         parameter,
--         count(*) as parameter_sample_count,
--         rank() over (
--             partition by station_id
--             order by count(*) desc,
--         ) as parameter_rank

--     from source_data
--     group by station_id, parameter
-- ),

-- top_parameters as (
--     select
--         station_id,
--         parameter as top_parameter,
--         parameter_sample_count as top_parameter_sample_count

--     from parameter_metrics
--     where parameter_rank = 1
-- ),

stations_final as (
    select
        sm.station_id,
        sm.full_station_name,
        sm.station_type,
        sm.county_name,
        sm.latitude,
        sm.longitude,
        sm.total_samples,
        sm.unique_parameters_tested,
        tp.top_parameter,
        tp.top_parameter_sample_count,
        sm.first_sample_timestamp,
        sm.last_sample_timestamp,
        sm.days_since_last_sample

    from station_metrics as sm
    left join top_parameters as tp
        on sm.station_id = tp.station_id
)

select * from stations_final
order by total_samples desc

```

**YAML**

```YAML
version: 2

models:
  - name: stations
    description: |
      Mart model representing water quality monitoring stations.
      Each row represents one station with aggregated metrics.
    columns:
      - name: station_id
        description: A unique identifier for stations.
      - name: full_station_name
        description: |
          The (full) station name describing the sampling location
          based on DWR station naming conventions.
      - name: station_type
        description: |
          General description of sampling site location,
          i.e., surface water, groundwater, or other.
      - name: county_name
        description: County where sample was collected.
      - name: latitude
        description: Latitude (NAD83).
      - name: longitude
        description: Longitude (NAD83).
      - name: total_samples
        description: Total count of all samples collected at this station.
      - name: unique_parameters_tested
        description: Number of distinct water quality parameters tested at this station.
      - name: top_parameter
        description: The most frequently tested water quality parameter at this station.
      - name: top_parameter_sample_count
        description: Number of samples collected for the most frequently tested parameter at this station.
      - name: first_sample_timestamp
        description:  |
          Date of the first sample collection event on record
          for a given DWR sampling location.
      - name: last_sample_timestamp
        description:  |
          Date of the last sample collection event on record
          for a given DWR sampling location.
      - name: days_since_last_sample
        description: the number of days that have passed, in whole numbers, since the last sample collection.
```
