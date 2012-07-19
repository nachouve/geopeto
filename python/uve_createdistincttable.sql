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
-- Name: uve_createdistincttable(text, text); Type: FUNCTION; Schema: public; Owner: otsix
--

CREATE FUNCTION uve_createdistincttable("table" text, "column" text) RETURNS text
    LANGUAGE plpythonu
    AS $_$plpy.info(">>>>>>> Starting uve_createdistincttable...")

schema = 'public'
tablename = table
dot_idx = table.find('.')
if (dot_idx > -1):
   schema = table[:dot_idx]
   tablename = table[(dot_idx+1):]


##################################################
## two variables fails... :/
#stmt = "SELECT DISTINCT $1 FROM $2"
#prep = plpy.prepare(stmt, ["text", "text"])
#plpy.execute(prep, [table, column])
##################################################

plpy.info(column)

tb = "uve_distinctvalues_"+str(tablename)

plpy.execute("DROP TABLE IF EXISTS "+tb)
stmt = "CREATE TABLE "+tb+" (id serial PRIMARY KEY, value text)"
plpy.execute(stmt)

stmt = "SELECT DISTINCT "+column+" FROM "+table
dstnct = plpy.execute(stmt)

i = 0
for row in dstnct:
    stmt = "INSERT INTO "+tb+" (value) VALUES ('"+str(row[column])+"')"
    plpy.info(stmt)
    plpy.execute(stmt)
    i = i + 1 

return tb

$_$;


ALTER FUNCTION public.uve_createdistincttable("table" text, "column" text) OWNER TO otsix;

--
-- PostgreSQL database dump complete
--

