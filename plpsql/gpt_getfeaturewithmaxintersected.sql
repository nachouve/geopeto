-- Function: gpt_getfeaturewithmaxareaintersected(text, text, text, text)
-- DROP FUNCTION gpt_getfeaturewithmaxareaintersected(text, text, text, text);

CREATE OR REPLACE FUNCTION gpt_getfeaturewithmaxareaintersected(layer_a text, id_a text, layer_b text, id_b text, output_layer text)
  RETURNS text AS
$BODY$
DECLARE
   aux varchar(100); 
   lyr_a ALIAS FOR $1;
   code_a ALIAS FOR $2;
   lyr_b ALIAS FOR $3;
   code_b ALIAS FOR $4;
   query_string VARCHAR(1000);

BEGIN
   
   EXECUTE 'DROP TABLE IF EXISTS "'|| output_layer ||'";';

   aux = 'DROP TABLE IF EXISTS tmp_'||output_layer||';';
   EXECUTE aux;

   aux = '"tmp_'||output_layer||'"';
   query_string = 'CREATE TABLE '||aux||' AS SELECT a.*, b.'||code_b||'  as "code_lyr_b", st_intersection(a.the_geom, b.the_geom) as "the_geom_diff", b.the_geom as "the_geom_b" FROM '
               || quote_ident(lyr_a) || ' a , ' || quote_ident(lyr_b) || ' b WHERE a.the_geom && b.the_geom AND st_intersects(a.the_geom,b.the_geom)';

RAISE NOTICE 'Running query... %', query_string;
   
   EXECUTE query_string;

   EXECUTE 'CREATE INDEX "tmp_'||output_layer||'_idx" ON '||aux||'('||code_a||');';
   
RAISE NOTICE 'Num intersections... ';
   EXECUTE 'ALTER TABLE '||aux||' ADD COLUMN num_inters integer;';
   EXECUTE 'UPDATE '||aux||' SET num_inters = (SELECT count(*) FROM '||aux||' b WHERE b.'||code_a||' ='||aux||'.'||code_a||');';

RAISE NOTICE 'Num intersection area percent... ';
   EXECUTE 'ALTER TABLE '||aux||' ADD COLUMN porc_inters double precision;';
   EXECUTE 'UPDATE '||aux||' SET porc_inters = 100*st_area(the_geom_diff)/st_area(the_geom)';

RAISE NOTICE 'Area differences coef... ';
   EXECUTE 'ALTER TABLE '||aux||' ADD COLUMN dif_sup_coe double precision;';
   EXECUTE 'UPDATE '||aux||' SET dif_sup_coe = (st_area(the_geom_b) - st_area(the_geom))/st_area(the_geom)';

   EXECUTE 'CREATE INDEX "tmp_'||output_layer||'_idx2" ON '||aux||'('||code_a||', porc_inters);';
   query_string = 'CREATE TABLE '|| output_layer || ' AS '||
   'select l.* from (select distinct '||code_a||' from '|| aux ||') lo, '|| aux ||' l
    where lo.'||code_a||'=l.'||code_a||' AND l.code_lyr_b = 
    	    (SELECT code_lyr_b from tmp_z li where li.'||code_a||' = lo.'||code_a||' ORDER BY porc_inters DESC LIMIT 1)';

RAISE NOTICE 'Running query... %', query_string;
   EXECUTE query_string;
   EXECUTE 'CREATE INDEX "'||output_layer||'_idx" ON '||output_layer||'('||code_a||');';
   EXECUTE 'ALTER TABLE '||output_layer||' ADD PRIMARY KEY ('||code_a||');';
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
COMMENT ON FUNCTION gpt_getfeaturewithmaxareaintersected(text, text, text, text) IS 'Returns a new layer copy of layerA with the next fields:

    * "num_inters": numero de features que intersecan con esa feature de layerB
    * "code_lyr_b": de la feature de mayor % de intersection
    * "porc_inters": % de interseccion de la featA con la ftB (mayor % de interseccion)
    * "dif_sup_coe": difference of the areas coeficient (values near 0 means areas intersected are similar; negatives featA are bigger than featB';
