-- SET ROLE CONTEXT
USE ROLE accountadmin;

-- SET DABATASE SCHEMA CONTEXT
USE SCHEMA sila_demo_db.notebooks;

-- SET WAREHOUSE CONTEXT
USE WAREHOUSE sila_demo_wh;

-- CREATE COMPUTE POOL
CREATE COMPUTE POOL IF NOT EXISTS cpu_xs_5_nodes
    MIN_NODES = 1
    MAX_NODES = 5
    INSTANCE_FAMILY = CPU_X64_XS;

-- CREATE NETWORK RULE
CREATE NETWORK RULE IF NOT EXISTS allow_all_rule
    TYPE = 'HOST_PORT'
    MODE= 'EGRESS'
    VALUE_LIST = ('0.0.0.0:443','0.0.0.0:80');

-- CREATE EXTERNAL ACCESS INTEGRATION
CREATE EXTERNAL ACCESS INTEGRATION IF NOT EXISTS allow_all_integration
    ALLOWED_NETWORK_RULES = (allow_all_rule)
    ENABLED = true;

-- CREATE NETWORK RULE
CREATE NETWORK RULE IF NOT EXISTS pypi_network_rule
  MODE = EGRESS
  TYPE = HOST_PORT
  VALUE_LIST = ('pypi.org', 'pypi.python.org', 'pythonhosted.org',  'files.pythonhosted.org');

-- CREATE EXTERNAL ACCESS INTEGRATION
CREATE EXTERNAL ACCESS INTEGRATION IF NOT EXISTS pypi_access_integration
  ALLOWED_NETWORK_RULES = (pypi_network_rule)
  ENABLED = true;

-- GRANT TO SYSADMIN
GRANT USAGE ON DATABASE sila_demo_db TO ROLE sysadmin;
GRANT ALL ON SCHEMA sila_demo_db.notebooks TO ROLE sysadmin;
GRANT CREATE STAGE ON SCHEMA sila_demo_db.notebooks TO ROLE sysadmin;
GRANT CREATE NOTEBOOK ON SCHEMA sila_demo_db.notebooks TO ROLE sysadmin;
GRANT CREATE SERVICE ON SCHEMA sila_demo_db.notebooks TO ROLE sysadmin;
GRANT ALL ON WAREHOUSE sila_demo_wh TO ROLE sysadmin;
GRANT READ, WRITE ON GIT REPOSITORY sila_demo_db.notebooks.sila_repo TO ROLE sysadmin;
GRANT USAGE ON COMPUTE POOL cpu_xs_5_nodes TO ROLE sysadmin;
GRANT USAGE ON INTEGRATION allow_all_integration TO ROLE sysadmin;
GRANT USAGE ON INTEGRATION pypi_access_integration TO ROLE sysadmin;

-- SET ROLE CONTEXT
USE ROLE sysadmin;

-- SET DATABASE SCHEMA CONTEXT
USE SCHEMA sila_demo_db.notebooks;

-- SET WAREHOUSE CONTEXT
USE WAREHOUSE sila_demo_wh;

-- CREATE NOTEBOOK
CREATE NOTEBOOK IF NOT EXISTS sila_demo_db.notebooks.pybamm
FROM '@sila_repo/branches/main'
    MAIN_FILE = 'PyBaMM.ipynb' 
    QUERY_WAREHOUSE = sila_demo_wh
    RUNTIME_NAME = 'SYSTEM$BASIC_RUNTIME' 
    COMPUTE_POOL = 'CPU_XS_5_NODES'
    EXTERNAL_ACCESS_INTEGRATIONS = ('PYPI_ACCESS_INTEGRATION');
