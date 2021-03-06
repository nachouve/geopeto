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
-- Name: uve_split(text, text); Type: FUNCTION; Schema: public; Owner: otsix
--

CREATE FUNCTION uve_split(layer1 text, layer2 text) RETURNS text
    LANGUAGE plpythonu
    AS $$plpy.info(">>>>>>> Starting uve_split...")

schema1 = 'public'
tablename1 = layer1
dot_idx = layer1.find('.')
if (dot_idx > -1):
   schema1 = layer1[:dot_idx]
   tablename1 = layer1[(dot_idx+1):]

schema2 = 'public'
tablename2 = layer2
dot_idx = layer2.find('.')
if (dot_idx > -1):
   schema2 = layer2[:dot_idx]
   tablename2 = layer2[(dot_idx+1):]


out_lyr="_split_"+tablename1+"_and_"+tablename2
plpy.execute("DROP TABLE IF EXISTS "+out_lyr + " CASCADE")

cols_result = plpy.execute("select uve_prepare_nogeo_columns(ARRAY['"+layer1+"','"+layer2+"']) as cols;")
cols = cols_result[0]["cols"]

#stmt = "CREATE TABLE "+out_lyr+" AS " \
#" SELECT "+cols+", (st_dump(st_split("+layer1+".the_geom, "+layer2+".the_geom))).geom as the_geom" \
#" FROM "+layer1 +", "+layer2 + \
#" WHERE intersects(st_split("+layer1+".the_geom, "+layer2+".the_geom))"

stmt = "CREATE TABLE "+out_lyr+" AS " \
" SELECT "+layer1+".the_geom as old_geom, "+cols+", (st_dump(st_intersection("+layer1+".the_geom, "+layer2+".the_geom))).geom as the_geom" \
" FROM "+layer1 +", "+layer2 + \
" WHERE intersects("+layer1+".the_geom, "+layer2+".the_geom)"

plpy.info(stmt)
plpy.execute(stmt)

#plpy.execute("select uve_repairarealayer(\'" +out_lyr+"\', 1);")
#plpy.execute("DELETE FROM geometry_columns WHERE f_table_name =\'" +out_lyr+"\'")
#stmt="INSERT INTO geometry_columns(\
#            f_table_catalog, f_table_schema, f_table_name, f_geometry_column, \
#            coord_dimension, srid, type)\
#    VALUES ('', 'public','"+out_lyr+"' , 'the_geom', 2, '23029', 'POLYGON');"
#plpy.execute(stmt)

return out_lyr$$;


ALTER FUNCTION public.uve_split(layer1 text, layer2 text) OWNER TO otsix;

--
-- PostgreSQL database dump complete
--

