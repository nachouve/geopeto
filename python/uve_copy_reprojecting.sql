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
-- Name: uve_copy_reprojecting(text, text, integer); Type: FUNCTION; Schema: public; Owner: otsix
--

CREATE FUNCTION uve_copy_reprojecting(layer_org text, layer_dst text, srid_dst integer) RETURNS boolean
    LANGUAGE plpythonu
    AS $$result = plpy.execute("SELECT srid from geometry_columns WHERE f_table_name = '"+layer_org+"'")

srid_org = -1
if (len(result)==1):
    srid_org = result[0]["srid"]
else:
    return False

## Or maybe do it anyway!!!!
if (srid_org == srid_dst):
    return False

stmt = "CREATE TABLE "+layer_dst+" AS "\
+" select * from "+ layer_org

plpy.execute(stmt)

#plpy.execute("UPDATE "+layer_dst+" SET the_geom = st_transform(the_geom, "+srid_dst+")")
plpy.execute("UpdateGeometrySRID("+layer_dst+", the_geom, "+srid_dst+");")$$;


ALTER FUNCTION public.uve_copy_reprojecting(layer_org text, layer_dst text, srid_dst integer) OWNER TO otsix;

--
-- PostgreSQL database dump complete
--

