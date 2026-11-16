-- Administrator prerequisite (run once per account).
-- The Snowflake Terraform provider does not manage session policies, so an admin
-- applies this via SQL. Sets a 60-minute idle timeout, matching ODI policy.
-- Run in a Snowsight worksheet or: snow sql -f scripts/session_policy.sql

USE ROLE SYSADMIN;
CREATE DATABASE IF NOT EXISTS policies;
CREATE SESSION POLICY IF NOT EXISTS policies.public.training_session_policy
  SESSION_IDLE_TIMEOUT_MINS = 60
  SESSION_UI_IDLE_TIMEOUT_MINS = 60;

USE ROLE ACCOUNTADMIN;
-- ALTER ACCOUNT UNSET SESSION POLICY;  -- run first if a policy is already set
ALTER ACCOUNT SET SESSION POLICY policies.public.training_session_policy;
