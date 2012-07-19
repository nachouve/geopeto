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
-- Name: gpt_version(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION gpt_version() RETURNS text
    LANGUAGE plpythonu
    AS $$VERSION = 'alpha0.1-20120719'
return VERSION
$$;


ALTER FUNCTION public.gpt_version() OWNER TO admin;

--
-- PostgreSQL database dump complete
--

