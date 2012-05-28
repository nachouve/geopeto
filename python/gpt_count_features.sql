-- Function: gpt_count_features(text, text, text, text, text)

-- DROP FUNCTION gpt_count_features(text, text, text, text, text);

CREATE OR REPLACE FUNCTION gpt_count_features(layer1 text, layer2 text, new_layer text, new_col text, where_clause text)
  RETURNS integer AS
  $BODY$
  tmp_lyr = new_layer+"__tmp"

  ret= plpy.execute("DROP TABLE IF EXISTS "+tmp_lyr)

  sql = 'SELECT a.gid, count(b.gid) as "'+new_col+'"'\
  "FROM "+ layer1 +" a LEFT JOIN "+ layer2 +" b \
  ON (a.the_geom && b.the_geom AND st_intersects(a.the_geom, b.the_geom)) \
  WHERE "+where_clause+" \
  GROUP BY a.gid"

  stmt = "CREATE TABLE "+tmp_lyr+" AS (" + sql + ")"
  ret= plpy.execute(stmt)

  sql = 'SELECT a.*, b."'+new_col+'"'\
  "FROM "+ layer1 +" a LEFT JOIN "+ tmp_lyr +" b \
  ON (a.gid = b.gid)"

  stmt = "CREATE TABLE "+new_layer+" AS (" + sql + ")"
  ret= plpy.execute(stmt)

  ### Update geometry_columns
  stmt = "DELETE FROM geometry_columns WHERE f_table_name = '"+new_layer+"'"
  ret= plpy.execute(stmt)

  stmt = "INSERT INTO geometry_columns \
  (SELECT f_table_catalog, f_table_schema, '"+new_layer+"', f_geometry_column, \
  coord_dimension, srid, type \
  FROM geometry_columns \
  WHERE f_table_name = '"+layer1+"')"
  ret= plpy.execute(stmt)

  ret= plpy.execute("DROP TABLE IF EXISTS "+tmp_lyr)

  return 1$BODY$
    LANGUAGE plpythonu VOLATILE
      COST 100;
      ALTER FUNCTION gpt_count_features(text, text, text, text, text)
        OWNER TO otsix;
	COMMENT ON FUNCTION gpt_inpolygon_aggregate(text, text, text, text, text, text) IS '
	#################################################
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
