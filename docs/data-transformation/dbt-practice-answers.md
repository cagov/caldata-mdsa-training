# Training answer key

## Day 1

### Answer for Practice A: Create your first dbt staging model for the `stations` data

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

    from {{ source('WATER_QUALITY', 'stations') }}
)

select * from stations

```

### Answer for Practice B: Create your second staging model for the `lab_results` data

```sql
with lab_results as (

    select
        to_varchar("station_id") as station_id,
        "status" as status,
        "sample_code" as sample_code,

        to_timestamp("sample_date", 'MM/DD/YYYY HH24:MI') as sample_timestamp,

        date_from_parts(
            substr("sample_date", 7, 4)::INT,
            left("sample_date", 2)::INT,
            substr("sample_date", 4, 2)::INT
        ) as sample_date,

        "sample_depth" as sample_depth,
        "sample_depth_units" as sample_depth_units,
        "parameter" as parameter,
        "result" as result,
        "reporting_limit" as reporting_limit,
        "units" as units,
        "method_name" as method_name

    from {{ source('WATER_QUALITY', 'lab_results') }}
)

select * from lab_results

```

## Day 2

### Answers for Practice A and B

Reminder:

- Practice A: Write YAML for your source data and staging models
- Practice B: Write tests for the `stg_water_quality__stations` model

YAML for your source data

```YAML
version: 2

sources:
  - name: WATER_QUALITY
    database: RAW_DEV
    schema: WATER_QUALITY
    description: |
      The California Department of Water Resources (DWR) discrete (vs. continuous)
      water quality datasets contains DWR-collected, current and historical, chemical
      and physical parameters found in routine environmental, regulatory compliance
      monitoring, and special studies throughout the state.
    tables:
      - name: lab_results
        description: The source data for lab results.
        columns:
          - name: station_id
            description: A unique identifier for stations.
          - name: station_name
            description: |
              Abbreviated Long Station Name or a unique code
              assigned to the sampling location. Limit 20 characters.
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
          - name: status
            description: Data review status.
          - name: county_name
            description: County where sample collected.
          - name: sample_code
            description: Unique DWR lab and field data sample code.
          - name: sample_date
            description: The date and time a sample was collected.
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
      - name: stations
        description: The source data for stations.
        columns:
          - name: station_id
            description: A unique identifier for stations.
          - name: station_name
            description: |
              Abbreviated Long Station Name or a unique code
              assigned to the sampling location. Limit 20 characters.
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

```

YAML for your staging models

```YAML
version: 2

models:
  - name: stg_water_quality__stations
    description: Staging model for stations.
    config:
      materialized: table
    tests:
      - dbt_utils.equal_rowcount:
          compare_model: source('WATER_QUALITY', 'stations')
    columns:
      - name: station_id
        description: A unique identifier for stations.
        tests:
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
        tests:
          - unique
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

## Day 3

### Answer for Practice: Create an intermediate dbt model

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
        year(l.sample_date) = 2024
        and l.parameter = 'Dissolved Chloride'
    group by s.county_name
)

select * from stations_per_county_with_parameter_2023_counted
order by station_count desc

```

## Day 4

No answer key.
