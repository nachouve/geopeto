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
-- Name: uve_add_gid_pk(text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION uve_add_gid_pk("table" text) RETURNS boolean
    LANGUAGE plpythonu
    AS $$schema = 'public'
tablename = table
dot_idx = table.find('.')
if (dot_idx > -1):
    schema = table[:dot_idx]
    tablename = table[(dot_idx+1):]


stmt ='ALTER TABLE "'+schema+'"."'+tablename+'" ADD COLUMN "gid" INTEGER;'
plpy.execute(stmt)
stmt ='DROP SEQUENCE IF EXISTS  "'+schema+'"."'+tablename+'_gid_seq" CASCADE;'
plpy.execute(stmt)
stmt ='CREATE SEQUENCE "'+schema+'"."'+tablename+'_gid_seq";'
plpy.execute(stmt)
stmt ='UPDATE  "'+schema+'"."'+tablename+'"'+" SET gid = nextval('\""+schema+"\".\""+tablename+"_gid_seq\"');"
plpy.execute(stmt)
stmt ='ALTER TABLE "'+schema+'"."'+tablename+'"'+" ALTER COLUMN \"gid\" SET DEFAULT nextval('\""+schema+"\".\""+tablename+"_gid_seq\"');"
plpy.execute(stmt)
stmt ='ALTER TABLE "'+schema+'"."'+tablename+'" ALTER COLUMN "gid" SET NOT NULL;'
plpy.execute(stmt)
stmt ='ALTER TABLE "'+schema+'"."'+tablename+'" ADD UNIQUE ("gid");'
plpy.execute(stmt)
stmt ='ALTER TABLE "'+schema+'"."'+tablename+'" DROP CONSTRAINT "'+tablename+'_gid_key" RESTRICT;'
plpy.execute(stmt)
stmt ='ALTER TABLE "'+schema+'"."'+tablename+'"  ADD PRIMARY KEY ("gid");'
plpy.execute(stmt)$$;


ALTER FUNCTION public.uve_add_gid_pk("table" text) OWNER TO admin;

--
-- PostgreSQL database dump complete
--

