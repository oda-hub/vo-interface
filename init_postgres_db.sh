#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
	CREATE DATABASE $POSTGRESQL_DB_NAME;
    \c $POSTGRESQL_DB_NAME;
    CREATE SCHEMA IF NOT EXISTS $POSTGRESQL_DB_SCHEMA;
    SET search_path = $POSTGRESQL_DB_SCHEMA, public;
    CREATE EXTENSION pg_sphere;
EOSQL

cd /pgloader && \
    ./build/bin/pgloader mysql://$GALLERY_DB_USER:$GALLERY_DB_PASSWORD@$GALLERY_DB_HOST:$GALLERY_DB_PORT/$GALLERY_DB_NAME
                         postgresql://$POSTGRESQL_USER:$POSTGRESQL_PASSWORD@$POSTGRESQL_HOST:$POSTGRESQL_PORT/$POSTGRESQL_DB_NAME

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    -- Create the view
    CREATE VIEW data_product_table_view_v AS
    SELECT 
        node_field_data.nid AS nid,
        node_field_data.title AS title,
        path_alias.alias AS path_alias,
        path_alias.path AS path,
        node__field_product_id.field_product_id_value AS product_id,
        node__field_e1_kev.field_e1_kev_value AS e1_kev,
        node__field_e2_kev.field_e2_kev_value AS e2_kev,
        node__field_ra.field_ra_value AS ra,
        node__field_dec.field_dec_value AS dec,
        node__field_time_bin.field_time_bin_value AS time_bin,
        tax1.name AS instrument_name,
        tax1.description__value AS instrument_description_value,
        tax2.name AS product_type_name,
        tax2.description__value AS product_type_description_value,
        node__field_rev1.field_rev1_value AS rev1,
        node__field_rev2.field_rev2_value AS rev2,
        node__field_timerange.field_timerange_value AS timerange,
        node__field_timerange.field_timerange_end_value AS timerange_end,
        string_agg(node__field_obsid.field_obsid_value::text, ', ') AS proposal_id,
        string_agg(node__field_source_name.field_source_name_value::text, ', ') AS sources,
        string_agg(node__field_fits_file.field_fits_file_target_id::text, ', ') AS file_target_id,
        string_agg(file_managed.filename::text, ', ') AS file_name,
        string_agg(SUBSTRING(file_managed.uri FROM 10), ', ') AS file_uri
    FROM
        node_field_data
        LEFT JOIN node__field_time_bin ON node_field_data.nid = node__field_time_bin.entity_id
        LEFT JOIN node__field_product_id ON node_field_data.nid = node__field_product_id.entity_id
        LEFT JOIN node__field_e1_kev ON node_field_data.nid = node__field_e1_kev.entity_id
        LEFT JOIN node__field_e2_kev ON node_field_data.nid = node__field_e2_kev.entity_id
        LEFT JOIN node__field_ra ON node_field_data.nid = node__field_ra.entity_id
        LEFT JOIN node__field_dec ON node_field_data.nid = node__field_dec.entity_id
        LEFT JOIN node__field_instrumentused ON node_field_data.nid = node__field_instrumentused.entity_id
        LEFT JOIN taxonomy_term_field_data tax1 ON node__field_instrumentused.field_instrumentused_target_id = tax1.tid
        LEFT JOIN node__field_data_product_type ON node_field_data.nid = node__field_data_product_type.entity_id
        LEFT JOIN taxonomy_term_field_data tax2 ON node__field_data_product_type.field_data_product_type_target_id = tax2.tid
        LEFT JOIN node__field_derived_from_observation ON node_field_data.nid = node__field_derived_from_observation.entity_id
        LEFT JOIN node_field_data obs ON obs.nid = node__field_derived_from_observation.field_derived_from_observation_target_id
        LEFT JOIN node__field_rev1 ON obs.nid = node__field_rev1.entity_id
        LEFT JOIN node__field_rev2 ON obs.nid = node__field_rev2.entity_id
        LEFT JOIN node__field_timerange ON obs.nid = node__field_timerange.entity_id
        LEFT JOIN node__field_obsid ON obs.nid = node__field_obsid.entity_id
        LEFT JOIN node__field_describes_astro_entity ON node_field_data.nid = node__field_describes_astro_entity.entity_id
        LEFT JOIN node_field_data sources ON sources.nid = node__field_describes_astro_entity.field_describes_astro_entity_target_id
        LEFT JOIN node__field_source_name ON sources.nid = node__field_source_name.entity_id
        LEFT JOIN path_alias ON path_alias.path::text LIKE ('/node/'::text || node_field_data.nid::text)
        LEFT JOIN node__field_fits_file ON node_field_data.nid = node__field_fits_file.entity_id
        LEFT JOIN file_managed ON node__field_fits_file.field_fits_file_target_id = file_managed.fid
    WHERE
        node_field_data.status = '1'::smallint
        AND node_field_data.type::text = 'data_product'::text
    GROUP BY 
        node_field_data.nid, 
        node_field_data.title, 
        path_alias.alias, 
        path_alias.path, 
        node__field_product_id.field_product_id_value, 
        node__field_e1_kev.field_e1_kev_value, 
        node__field_e2_kev.field_e2_kev_value, 
        node__field_ra.field_ra_value, 
        node__field_dec.field_dec_value, 
        node__field_time_bin.field_time_bin_value, 
        tax1.name, 
        tax1.description__value, 
        tax2.name, 
        tax2.description__value, 
        node__field_rev1.field_rev1_value, 
        node__field_rev2.field_rev2_value, 
        node__field_timerange.field_timerange_value, 
        node__field_timerange.field_timerange_end_value;
EOSQL