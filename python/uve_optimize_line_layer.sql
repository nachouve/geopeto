--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

--
-- Name: uve_optimize_line_layer(text, integer); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION uve_optimize_line_layer("table" text, tolerance integer) RETURNS boolean
    LANGUAGE plpythonu
    AS $$schema = 'public'
tablename = table
dot_idx = table.find('.')
if (dot_idx > -1):
   schema = table[:dot_idx]
   tablename = table[(dot_idx+1):]

## Detect previousspatial index
stmt= "select indexname from pg_indexes where tablename = '"+tablename+"' AND indexdef like '% gist%';"
ret= plpy.execute(stmt)
if (len(ret)>0):
    schema_if_it_has = ''
    if (len(schema)>0):
	schema_if_it_has = schema+'.'
    for i in range(len(ret)):
	plpy.info("DROP INDEX "+schema_if_it_has+ret[i]["indexname"])
	plpy.execute("DROP INDEX "+schema_if_it_has+ret[i]["indexname"])

plpy.info("## Buffer 0.0 and simplify geometry");
## Buffer 0.0 and simplify geometry
stmt = "update "+table+" SET the_geom=st_multi(ST_SimplifyPreserveTopology(\
	the_geom, "+str(tolerance)+"));"
plpy.execute(stmt)


plpy.info("## Create new spatial index");
## Create new spatial index

idx_name = tablename+"_the_geom_gist" 
stmt= "CREATE INDEX "+idx_name+" ON "+table+" USING GIST (the_geom)"
plpy.execute(stmt)

plpy.info("## Cluster for near storage");
## Cluster for near storage
plpy.execute("CLUSTER "+table+" USING "+idx_name)
plpy.info("## Remenber to do VACUUM "+ table);
#--plpy.execute("VACUUM "+table)
#--plpy.execute("ANALYZE "+table)

return True
$$;


ALTER FUNCTION public.uve_optimize_line_layer("table" text, tolerance integer) OWNER TO admin;

--
-- PostgreSQL database dump complete
--

