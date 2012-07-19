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
-- Name: uve_testgeometries(text); Type: FUNCTION; Schema: public; Owner: otsix
--

CREATE FUNCTION uve_testgeometries(tablename text) RETURNS text
    LANGUAGE plpythonu
    AS $$plpy.info(">>>>>>>>>>>>>>>>>>>>>>>>> CHECK WRONG RESULTS")
stmt = "SELECT count(*) as count from "+tablename+" where st_geometrytype(the_geom) = 'ST_Unknown'";
wg_result = plpy.execute(stmt)
wrong_geoms = wg_result[0]["count"]
if (wrong_geoms > 0):
    plpy.info(">>>>>>>>>>>>>>>>>>>>>>>>> Unknows geoms: " + str(wrong_geoms))
    #stmt = "DELETE FROM "+tablename+" where st_geometrytype(the_geom) = 'ST_Unknown'";
    #plpy.execute(stmt)
plpy.info(">>>>>>>>>>>>>>>>>>>>>>>>>")


stmt = "select isvalid(the_geom) as valid, count(*) as novalidgeoms from "+tablename+" GROUP BY valid HAVING isvalid(the_geom) = false"
result = plpy.execute(stmt)

if (result == 1):
    plpy.info("No valid geoms: " + result[0]["novalidgeoms"])
else:
    plpy.info("All geometries are valid!!! ")

stmt = "select st_geometrytype(the_geom) as type, count(*) as num from "+tablename+" GROUP BY type;"
result = plpy.execute(stmt)

for r in result:
    plpy.info(r["type"] + "[" + str(r["num"]) + "]")

return "Check info on MessageTab."$$;


ALTER FUNCTION public.uve_testgeometries(tablename text) OWNER TO otsix;

--
-- PostgreSQL database dump complete
--

