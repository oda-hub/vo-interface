#!/bin/bash
set -e

# Update and install necessary packages
apt-get update && apt-get install -y vim \
                                    build-essential \
                                    software-properties-common \
                                    git \
                                    make \
                                    gcc-9 \
                                    postgresql-server-dev-16 \
                                    bison \
                                    byacc \
                                    clang-13

# Install the PostgreSQL extension for pgsphere
git clone --branch aiprdbms16 https://github.com/kimakan/pgsphere.git /pgsphere

cd /pgsphere && \
    make USE_PGXS=1 PG_CONFIG=/usr/bin/pg_config && \
    make USE_PGXS=1 PG_CONFIG=/usr/bin/pg_config install

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
	CREATE DATABASE mmoda_pg_prod;
    \c mmoda_pg_prod;
    CREATE SCHEMA IF NOT EXISTS mmoda_pg_prod;
    SET search_path = mmoda_pg_prod, public;
    CREATE EXTENSION pg_sphere;
EOSQL
