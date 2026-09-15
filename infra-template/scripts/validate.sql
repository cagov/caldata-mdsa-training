-- Manual Snowflake validation for the training environment.
-- Run in a Snowsight worksheet (or via `snow sql -f scripts/validate.sql`) as a
-- role that can see account objects (e.g. SYSADMIN). Replace DEV if you used a
-- different environment suffix.

-- 1. The single training database exists.
SHOW DATABASES LIKE 'TRAINING_DEV';

-- 2. The three X-Small warehouses exist.
SHOW WAREHOUSES LIKE 'LOADING_XS_DEV';
SHOW WAREHOUSES LIKE 'TRANSFORMING_XS_DEV';
SHOW WAREHOUSES LIKE 'REPORTING_XS_DEV';

-- 3. The three functional roles exist.
SHOW ROLES LIKE 'LOADER_DEV';
SHOW ROLES LIKE 'TRANSFORMER_DEV';
SHOW ROLES LIKE 'REPORTER_DEV';

-- 4. The dbt service user exists and has a public key registered.
DESCRIBE USER DBT_SVC_USER_DEV;

-- 5. Grants function: the transformer role can use its warehouse and database.
USE ROLE TRANSFORMER_DEV;
USE WAREHOUSE TRANSFORMING_XS_DEV;
USE DATABASE TRAINING_DEV;
CREATE SCHEMA IF NOT EXISTS TRAINING_DEV._validation;
CREATE OR REPLACE TABLE TRAINING_DEV._validation.t (id int);
INSERT INTO TRAINING_DEV._validation.t VALUES (1);
SELECT * FROM TRAINING_DEV._validation.t;
DROP SCHEMA TRAINING_DEV._validation;
