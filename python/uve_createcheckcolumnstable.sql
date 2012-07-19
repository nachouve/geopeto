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
-- Name: uve_createcheckcolumnstable(text, text, text, text[]); Type: FUNCTION; Schema: public; Owner: otsix
--

CREATE FUNCTION uve_createcheckcolumnstable("table" text, "column" text, new_table text, new_columns text[]) RETURNS boolean
    LANGUAGE plpythonu
    AS $$idx_tb= plpy.execute("SELECT uve_createdistincttable('"+table+"', '"+column+"');")

values = plpy.execute("SELECT "+column+" from "+idx_tb)

new_cols = list()
for value in values:
    plpy.info(value)
    for col in new_columns:
        if (col.startswith("num")):
            new_cols.append(col+str(value[column])+" int4")
        else:
	    new_cols.append(col+str(value[column])+" double precision")

plpy.info(str(new_cols))$$;


ALTER FUNCTION public.uve_createcheckcolumnstable("table" text, "column" text, new_table text, new_columns text[]) OWNER TO otsix;

--
-- PostgreSQL database dump complete
--

