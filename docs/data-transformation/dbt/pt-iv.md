# dbt (data build tool)

## Part IV: dbt docs and mart models

### dbt Docs

A key feature of dbt is the automated generation of documentation and lineage from your project.
The framework reads your SQL models and YAML configuration files and produces a static HTML document from them.
This documentation can then be hosted in a number of places, including dbt Cloud, GitHub Pages, or Azure Static Web Apps.
Depending on platforms we are using for the project, we will demonstrate dbt docs using one of the following:

1. Hosted in dbt Cloud. This can be useful if you are writing docs in a branch and want to visualize how they are rendered.
1. If we are using GitHub, we’ll demonstrate how the docs can be built from the repository and hosted on GitHub Pages.
1. If we are using Azure DevOps, we’ll demonstrate how the docs can be built from the repository and hosted using Azure Static Web Apps.
1. If we are using Bitbucket and are okay with public-facing docs, we'll demonstrate how the docs can be built and hosted using Bitbucket Cloud.
1. If we are using none of the above, we'll show you how to generate and view the docs locally.

### Mart models

**Purpose:** Create consumable datasets tailored for specific business or program needs.

**Key characteristics:**
- Represent a specific entity or concept at its unique grain
- Wide and denormalized (fewer joins for end users)
- Business-friendly naming
- Optimized for querying and reporting

**Also called:**
- Entity layer
- Concept layer
- Business layer

**Examples:**
- `incidents` (one row per incident)
- `customers` (one row per customer)
- `orders` (one row per order)
- `water_quality_monitoring` (one row per station)

**Naming convention:**
- Plain English based on the entity/concept
- No prefixes needed
- Example: `customers.sql`, not `mart_customers.sql`

**Organization:**
- Saved in a `marts/` subdirectory
- Often organized by business domain (e.g., `marts/finance/`, `marts/operations/`)

**Materialization:**
- Always tables (marts need to be fast for end users)
- Consider incremental for very large datasets

### Designing good mart models

**1. Clear grain**

- One row per what?
- Document the grain explicitly

**2. Business-friendly names**

- Avoid abbreviations: `customer_name` not `cust_nm`
- Avoid technical jargon: `created_date` not `sys_crt_ts`

**3. Complete context**

- Include all fields users need
- Don't make them join to other tables

**4. Well tested**

- Test the grain (uniqueness on primary key)
- Test relationships to upstream models
- Test accepted values for categorical fields

**5. Well documented**

- Explain what the mart represents
- Document calculated fields
- Note any limitations or filters applied

## Summary of the three layers (staging, intermediate, mart)

| Layer | Purpose | Transformations | Naming | Materialization |
|-------|---------|-----------------|--------|-----------------|
| **Staging** | One-to-one with source | Renaming, type casting | `stg_<source>__<entity>` | View |
| **Intermediate** | Reusable business logic | Joins, aggregations | `int_<description>` | View or Table |
| **Mart** | Business-ready datasets | Denormalization, final calcs | Plain English | Table |

### Part IV: practice

Click either link for [<u>dbt Cloud</u>](https://cagov.github.io/caldata-mdsa-training/data-transformation/dbt-cloud-practice/#day-4) or [<u>dbt Core</u>](https://cagov.github.io/caldata-mdsa-training/data-transformation/dbt-core-practice/#day-4) practice.

### Part IV: references

#### Documentation

- [What is documentation?](https://platform.thinkific.com/videoproxy/v1/play/c71iuqg40bhpn3t11p80)
- [Writing documentation and doc blocks](https://platform.thinkific.com/videoproxy/v1/play/ce2dchnf17fhkgqdq59g)
