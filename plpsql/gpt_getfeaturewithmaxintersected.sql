-- Function: gpt_getfeaturewithmaxareaintersected(text, text, text, text)
-- DROP FUNCTION gpt_getfeaturewithmaxareaintersected(text, text, text, text);

CREATE OR REPLACE FUNCTION gpt_getfeaturewithmaxareaintersected(layer_a text, layer_b text, id_b text, output_layer text)
    RETURNS text AS
    $BODY$
    DECLARE
    aux varchar(100);
lyr_a ALIAS FOR $1;
lyr_b ALIAS FOR $2;
code ALIAS FOR $3;
query_string VARCHAR(1000);

BEGIN

PERFORM 'DROP TABLE IF EXISTS "'|| output_layer ||'";';

aux = 'DROP TABLE IF EXISTS tmp_'||output_layer||';';
EXECUTE aux;

aux = '"tmp_'||output_layer||'"';
query_string = 'CREATE TABLE '||aux||' AS SELECT a.*, b.codigo as "code_lyr_b", st_intersection(a.the_geom, b.the_geom) as "the_geom2" FROM '
    || quote_ident(lyr_a) || ' a , ' || quote_ident(lyr_b) || ' b WHERE a.the_geom && b.the_geom AND st_intersects(a.the_geom,b.the_geom)';

RAISE NOTICE 'Runing query... %', query_string;

EXECUTE query_string;

RAISE NOTICE 'Num intersections... %', query_string;
EXECUTE 'ALTER TABLE '||aux||' ADD COLUMN num_inters integer;';
EXECUTE 'UPDATE '||aux||' SET num_inters = (SELECT count(*) FROM '||aux||' b WHERE b.codigo='||aux||'.codigo);';

RAISE NOTICE 'Num intersections... %', query_string;
EXECUTE 'ALTER TABLE '||aux||' ADD COLUMN porc_inters double precision;';
EXECUTE 'UPDATE '||aux||' SET porc_inters = 100*st_area(the_geom2)/st_area(the_geom)';

EXECUTE 'CREATE INDEX '||aux||'_idx ON ('||code||', porc_inters);';
query_string = 'CREATE TABLE '|| output_layer || ' AS '||
    'select l.* from (select distinct codigo from '|| aux ||') lo, '|| aux ||'l
     where lo.'||code||'=l.'||code||' AND l.code_lyr_b =(SELECT code_lyr_b from tmp_z li where li.'||code||' = lo.'||code||' ORDER BY porc_inters DESC LIMIT 1)';

RAISE NOTICE 'Runing query... %', query_string;
EXECUTE query_string;
--FETCH input_refc into int_test;
--CLOSE input_refc;

aux = 'DROP TABLE IF EXISTS tmp_'||output_layer||';';
EXECUTE aux;

RETURN output_layer;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    NULL;
WHEN OTHERS THEN
    -- Consider logging the error and then re-raise
    RAISE;
END;
$BODY$
    LANGUAGE plpgsql VOLATILE
    COST 100;
ALTER FUNCTION gpt_getfeaturewithmaxareaintersected(text, text, text, text)
    OWNER TO postgres;
COMMENT ON FUNCTION gpt_getfeaturewithmaxareaintersected(text, text, text, text) IS 'Devuelve una capa réplica de layerA con los siguientes capas:
* "num_inters": numero de features que intersecan con esa feature de layerB
* "codigo": de la feature de mayor % de intersección
* "porc_inters": % de intersección de la featA con la featB (mayor % de intersección)';