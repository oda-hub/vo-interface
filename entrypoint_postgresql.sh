#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
	CREATE DATABASE mmoda_pg_prod;
    \c mmoda_pg_prod;
    CREATE SCHEMA IF NOT EXISTS mmoda_pg_prod;
    SET search_path = mmoda_pg_prod, public;
    CREATE EXTENSION pg_sphere;
EOSQL
