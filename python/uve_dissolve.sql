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
-- Name: uve_dissolve(text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION uve_dissolve("table" text) RETURNS text
    LANGUAGE plpythonu
    AS $$n_table = 'dissolve_'+table

SQL = "create table as "+ n_table \
"SELECT * from "+table

return 'ToDo'$$;


ALTER FUNCTION public.uve_dissolve("table" text) OWNER TO admin;

--
-- PostgreSQL database dump complete
--

