-- Function: gpt_count_features(text, text, text, text, text)

-- DROP FUNCTION gpt_count_features(text, text, text, text, text);

CREATE OR REPLACE FUNCTION gpt_count_features(layer1 text, layer2 text, new_layer text, new_col text, where_clause text)
  RETURNS integer AS
  $BODY$#################################################
  # Geopeto Project (see at github)
  #################################################
  #-- Function: gpt_count_features
  #-- Description:
  #   Count features of the 'layer2' filtered by 'where_clause' and intersects features of 'layer1'
  #   A layer 'new_layer' is created with the 'new_col' column with the counting (and geometries of layer1)
  #
  #-- NOTE: Layers must have "gid" column
  #################################################
  #-- AUTHOR: Nacho Varela
  #-- DATE: 2012/05
  #################################################

  sql = "SELECT a.gid, count(b.gid) \
  FROM "+ layer1 +" a LEFT JOIN "+ layer2 +" b \
  ON (a.the_geom && b.the_geom AND st_intersects(a.the_geom, b.the_geom)) \
  WHERE "+where_clause+" \
  GROUP BY a.gid"

  stmt = "CREATE TABLE "+new_layer+" AS (" + sql + ")"

  ret= plpy.execute(stmt)

  return 1
$BODY$

LANGUAGE plpythonu VOLATILE COST 100;
ALTER FUNCTION gpt_count_features(text, text, text, text, text) OWNER TO otsix;
	