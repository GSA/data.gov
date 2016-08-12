REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE USAGE ON SCHEMA public FROM PUBLIC;

GRANT CREATE ON SCHEMA public TO :wuser;
GRANT USAGE ON SCHEMA public TO :wuser;

-- grant select permissions for read-only user
GRANT CONNECT ON DATABASE :datastoredb TO :rouser;
GRANT USAGE ON SCHEMA public TO :rouser;

-- grant access to current tables and views to read-only user
GRANT SELECT ON ALL TABLES IN SCHEMA public TO :rouser;

-- grant access to new tables and views by default
---- the permissions will be set when the write user creates a table
ALTER DEFAULT PRIVILEGES FOR USER :wuser IN SCHEMA public
   GRANT SELECT ON TABLES TO :rouser;