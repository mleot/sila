-- SET ROLE CONTEXT
USE ROLE accountadmin;

-- SET DATABASE SCHEMA CONTEXT
CREATE DATABASE IF NOT EXISTS sila_demo_db;
USE DATABASE sila_demo_db;
CREATE SCHEMA IF NOT EXISTS sila_demo_db.notebooks;
USE SCHEMA sila_demo_db.notebooks;

-- SET WAREHOUSE CONTEXT
CREATE WAREHOUSE IF NOT EXISTS sila_demo_wh 
    WAREHOUSE_SIZE = xsmall
    AUTO_SUSPEND = 60;
USE WAREHOUSE sila_demo_wh;

-- CREATE GIT SECRET
CREATE SECRET IF NOT EXISTS github_secret
    TYPE = password
    USERNAME = '<Github Username>' 
    PASSWORD = '<Personal Access Token (classic)>'; 

-- CREATE API INTEGRATION
CREATE API INTEGRATION IF NOT EXISTS git_api_integration
    API_PROVIDER = git_https_api
    API_ALLOWED_PREFIXES = ('https://github.com/sfc-gh-smorris/') 
    ALLOWED_AUTHENTICATION_SECRETS = (github_secret)
    ENABLED = true;

-- CREATE GIT REPOSITORY
CREATE GIT REPOSITORY IF NOT EXISTS sila_repo
    API_INTEGRATION = git_api_integration
    GIT_CREDENTIALS = github_secret
    ORIGIN = 'https://github.com/sfc-gh-smorris/sila';

-- SHOW REPO
SHOW git repositories;

-- FETCH REPO UPDATES
ALTER git repository sila_repo FETCH;

-- SHOW BRANCHES
SHOW git branches IN git repository sila_repo;

-- LIST FILES
LIST @sila_repo/branches/main;

-- SHOW CODE IN FILE
SELECT $1 FROM @sila_repo/branches/main/create_notebook.sql;

-- CREATE NOTEBOOK FROM CODE IN REPO
EXECUTE IMMEDIATE FROM @sila_repo/branches/main/create_notebook.sql;

-- SHOW NOTEBOOKS
SHOW notebooks;

-- ADD LIVE VERSION
ALTER NOTEBOOK sila_demo_db.notebooks.pybamm ADD LIVE VERSION FROM LAST;

-- EXECUTE NOTEBOOK
// EXECUTE NOTEBOOK pybamm();
