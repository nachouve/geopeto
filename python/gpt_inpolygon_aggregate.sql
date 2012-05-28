-- Function: gpt_inpolygon_aggregate(text, text, text, text, text, text)

-- DROP FUNCTION gpt_inpolygon_aggregate(text, text, text, text, text, text);

CREATE OR REPLACE FUNCTION gpt_inpolygon_aggregate(layer1 text, layer2 text, new_layer text, new_col text, aggregate_expr text, where_clause text)
  RETURNS boolean AS
  $BODY$tmp_lyr = new_layer+"__tmp"

  ret= plpy.execute("DROP TABLE IF EXISTS "+tmp_lyr)

  sql = 'SELECT a.gid, '+aggregate_expr+' as "'+new_col+'"'\
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

  return True$BODY$
    LANGUAGE plpythonu VOLATILE
      COST 100;
      ALTER FUNCTION gpt_inpolygon_aggregate(text, text, text, text, text, text)
        OWNER TO otsix;
	COMMENT ON FUNCTION gpt_inpolygon_aggregate(text, text, text, text, text, text) IS '
	#################################################
	# Geopeto Project (see at github)
	#################################################
	#-- Function: gpt_inpolygon_aggregate
	#-- Description:
	#   Apply ''aggregation_expr'' on the ''layer2'' filtered by ''where_clause'' and intersects features of ''layer1''
	#   A layer ''new_layer'' is created with the ''new_col'' column with the counting (and geometries of layer1)
	#
	#   ''aggregation_expr'' should be like ''sum(b.area)'',''round(sum(b.sup)::NUMERIC,1)'',  ''count(b.*)'',
	#         etc. The ''b'' is the alias for layer2 inside the function.
	#
	#-- NOTE: Layers must have "gid" column
	#################################################
	#-- AUTHOR: Nacho Varela
	#-- DATE: 2012/05
	#################################################';
	