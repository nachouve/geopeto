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
-- Name: uve_prepare_nogeo_columns(text[]); Type: FUNCTION; Schema: public; Owner: otsix
--

CREATE FUNCTION uve_prepare_nogeo_columns(tables text[]) RETURNS text
    LANGUAGE plpythonu
    AS $_$def add2set(the_cols, element, preffix, count):
    values=element.split('.')
    column_name=''
    table=''
    column=''
    if (len(values)==2):
       table=values[0]
       column=values[1]
    column = str(preffix*count)+column
    #plpy.info(column +" count: "+str(count))
    if (set([column])<set(the_cols.values())):
	count = count +1
	column = add2set(the_cols, element, preffix, count)
    #column = column.replace('"','')
    the_cols[element]=column
    return column

#stmt = "SELECT column_name FROM information_schema.columns WHERE table_name = $1 AND table_schema= $2;"
#prep = plpy.prepare(stmt, ["text", "text"])

tbs = tables[1:-1]
tbs = tbs.replace("'","")
tbs = tbs.split(',')

#plpy.info(str(tbs))

mycols = dict()

prep_cols = ''

for tb in tbs:
    schema = 'public'
    tablename = tb
    dot_idx = tb.find('.')
    if (dot_idx > -1):
        schema = tb[:dot_idx]
        tablename = tb[(dot_idx+1):]

    #cols = plpy.execute(prep, [tb,schema])
    sql = "SELECT column_name FROM information_schema.columns WHERE table_name = '"+tablename+"' AND table_schema='"+schema+"';"
    cols = plpy.execute(sql)
    plpy.info(sql)
    for col in cols:
	colname = col['column_name']
	if (colname!='the_geom'):
	    tb_col = tablename+'.'+colname
	    aux_col = add2set(mycols, tb_col, 'b_', 0)
	    #tb_col = '"'+tb+'"."'+colname+'"'
	    tb_col = schema+'."'+tablename+'"."'+colname+'"'
	    prep_cols = prep_cols+tb_col+' as '+aux_col+',' 

plpy.info(prep_cols[:-1])
return prep_cols[:-1]$_$;


ALTER FUNCTION public.uve_prepare_nogeo_columns(tables text[]) OWNER TO otsix;

--
-- PostgreSQL database dump complete
--

