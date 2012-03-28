-- Function: uve_spatial_percent(text, text, text, text)

-- DROP FUNCTION uve_spatial_percent(text, text, text, text);

CREATE OR REPLACE FUNCTION uve_spatial_percent(table_territ_unit text, cols_territ_unit text, table_values text, cols_values text)
  RETURNS text AS
$BODY$plpy.info(">>>>>>> Starting uve_spatial_percent...")


### Creating aux table
tb_tu = "uve_spatial_percent_aux1"
stmt = "DROP TABLE IF EXISTS "+tb_tu+" CASCADE;"
plpy.execute(stmt)
stmt = "DROP TABLE IF EXISTS "+tb_tu+"_b CASCADE;"
plpy.execute(stmt)

stmt = "CREATE TABLE "+tb_tu+" AS "\
+ " SELECT the_geom, "+cols_territ_unit+" as id, "+cols_territ_unit+", st_area(the_geom) as territ_unit_area"\
+ " FROM "+table_territ_unit

plpy.execute(stmt)
plpy.execute("select uve_optimize_area_layer(\'" +tb_tu+"\', 1);")

result =plpy.execute("SELECT uve_split('"+tb_tu+"', '"+table_values+"') as tb")
plpy.info(">> HERE")

split_tb = result[0]["tb"]

plpy.info(">>>>>>>>>>>>>>>>>>>>>>>>> CHECK WRONG RESULTS")
stmt = "SELECT count(*) as count from "+split_tb+" where st_geometrytype(the_geom) = 'ST_Unknown'"
wg_result = plpy.execute(stmt)
wrong_geoms = wg_result[0]["count"]
if (wrong_geoms > 0):
    plpy.info(">>>>>>>>>>>>>>>>>>>>>>>>> Wrong geoms: " + str(wrong_geoms))
    stmt = "DELETE FROM "+split_tb +" where st_geometrytype(the_geom) = 'ST_Unknown'"
    #plpy.execute(stmt)
plpy.info(">>>>>>>>>>>>>>>>>>>>>>>>>")


plpy.info(">> HERE")

## crear un diccionario de 
result = plpy.execute("SELECT uve_createdistincttable('"+str(table_values)+"', '"+str(cols_values)+"') as tb")
result = plpy.execute("SELECT * FROM "+result[0]["tb"])

plpy.info(">> ADDING columns...")
for r in result:
    col = r["value"]
    plpy.execute("ALTER TABLE "+tb_tu+" ADD COLUMN \"num_"+col+"\" int4")
    plpy.execute("ALTER TABLE "+tb_tu+" ADD COLUMN \"area_"+col+"\" double precision")
    plpy.execute("ALTER TABLE "+tb_tu+" ADD COLUMN \"perc_"+col+"\" double precision")

plpy.execute("DELETE FROM geometry_columns WHERE f_table_name ='"+tb_tu+"'")
stmt="INSERT INTO geometry_columns(\
            f_table_catalog, f_table_schema, f_table_name, f_geometry_column, \
            coord_dimension, srid, type)\
    VALUES ('', 'public','"+tb_tu+"' , 'the_geom', 2, '23029', 'MULTIPOLYGON');"

plpy.execute(stmt)

### Create a empty table for the results #### BUG: needed add a geo_borrar column to avoid wrong inserts!!!
plpy.execute("create table "+tb_tu+"_b as SELECT *, the_geom as geo_borrar FROM "+tb_tu)

plpy.execute("select uve_add_gid_pk('"+tb_tu+"_b')")

plpy.execute("DELETE FROM geometry_columns WHERE f_table_name ='" +tb_tu+"_b'")
stmt="INSERT INTO geometry_columns(\
            f_table_catalog, f_table_schema, f_table_name, f_geometry_column, \
            coord_dimension, srid, type)\
    VALUES ('', 'public','"+tb_tu+"_b' , 'the_geom', 2, '23029', 'MULTIPOLYGON');"

plpy.execute(stmt)


plpy.info(">>>>>>>>>>>>>>>>>>>>>>>>> CHECK WRONG RESULTS tb_tu")
stmt = "SELECT count(*) as count from "+tb_tu+" where st_geometrytype(the_geom) = 'ST_Unknown'"
wg_result = plpy.execute(stmt)
wrong_geoms = wg_result[0]["count"]
if (wrong_geoms > 0):
    plpy.info(">>>>>>>>>>>>>>>>>>>>>>>>> Wrong geoms: " + str(wrong_geoms))
    stmt = "DELETE FROM "+tb_tu+" where st_geometrytype(the_geom) = 'ST_Unknown'";
    #plpy.execute(stmt)
plpy.info(">>>>>>>>>>>>>>>>>>>>>>>>>")

plpy.info(">>>>>>>>>>>>>>>>>>>>>>>>> CHECK WRONG RESULTS tb_tu_b")
stmt = "SELECT count(*) as count from "+tb_tu+"_b where st_geometrytype(the_geom) = 'ST_Unknown'";
wg_result = plpy.execute(stmt)
wrong_geoms = wg_result[0]["count"]
if (wrong_geoms > 0):
    plpy.info(">>>>>>>>>>>>>>>>>>>>>>>>> Wrong geoms: " + str(wrong_geoms) + "   " + tb_tu + "_b")
    stmt = "DELETE FROM "+tb_tu+"_b where st_geometrytype(the_geom) = 'ST_Unknown'";
    #plpy.execute(stmt)
    plpy.execute("SELECT referencia as count from "+tb_tu+"_b where st_geometrytype(the_geom) = 'ST_Unknown';")
plpy.info(">>>>>>>>>>>>>>>>>>>>>>>>>")


#########################################
## crear un diccionario de 
result_tu = plpy.execute("SELECT uve_createdistincttable('"+tb_tu+"', '"+str(cols_territ_unit)+"') as tb")
result_tu = plpy.execute("SELECT * FROM "+result_tu[0]["tb"])

for r_tu in result_tu:
    tu = r_tu["value"]
    
    for r in result:
        col = r["value"]
        stmt = "UPDATE "+tb_tu+"_b SET \"num_"+col+"\" = "\
+" (SELECT count(*) " \
+"         FROM "+split_tb+" WHERE \""+cols_territ_unit+"\"='"+tu+"' AND " +cols_values+" = '"+col+"'"\
+"         GROUP BY "+cols_territ_unit+") "\
+"  WHERE \""+cols_territ_unit+"\"='"+tu+"'"
	plpy.execute(stmt)
        stmt = "UPDATE "+tb_tu+"_b SET \"area_"+col+"\" = "\
+" (SELECT sum(st_area(the_geom))" \
+"         FROM "+split_tb+" WHERE \""+cols_territ_unit+"\"='"+tu+"' AND " +cols_values+" = '"+col+"'"\
+"         GROUP BY "+cols_territ_unit+") "\
+"  WHERE \""+cols_territ_unit+"\"='"+tu+"'"

        plpy.execute(stmt)

plpy.info(">>>>>>>>>>>>>>>>>>>>>>>>> CHECK WRONG RESULTS tb_tu")
stmt = "SELECT count(*) as count from "+tb_tu+" where st_geometrytype(the_geom) = 'ST_Unknown'"
wg_result = plpy.execute(stmt)
wrong_geoms = wg_result[0]["count"]
if (wrong_geoms > 0):
    plpy.info(">>>>>>>>>>>>>>>>>>>>>>>>> Wrong geoms: " + str(wrong_geoms))
    stmt = "DELETE FROM "+tb_tu+" where st_geometrytype(the_geom) = 'ST_Unknown'";
    #plpy.execute(stmt)
plpy.info(">>>>>>>>>>>>>>>>>>>>>>>>>")

plpy.info(">>>>>>>>>>>>>>>>>>>>>>>>> CHECK WRONG RESULTS tb_tu_b")
stmt = "SELECT count(*) as count from "+tb_tu+"_b where st_geometrytype(the_geom) = 'ST_Unknown'"
wg_result = plpy.execute(stmt)
wrong_geoms = wg_result[0]["count"]
if (wrong_geoms > 0):
    plpy.info(">>>>>>>>>>>>>>>>>>>>>>>>> Wrong geoms: " + str(wrong_geoms))
    stmt = "DELETE FROM "+tb_tu+"_b where st_geometrytype(the_geom) = 'ST_Unknown'"
    #plpy.execute(stmt)
plpy.info(">>>>>>>>>>>>>>>>>>>>>>>>>")

for r in result:
     col = r["value"]
     stmt = "UPDATE "+tb_tu+"_b SET \"perc_"+col+"\" "\
+" = \"area_"+col+"\"*100/st_area(the_geom)" 
     plpy.execute(stmt)

stmt = "ALTER TABLE "+tb_tu+"_b DROP COLUMN geo_borrar"
plpy.execute(stmt)


plpy.info("Result layer: "+ tb_tu+"_b")$BODY$
  LANGUAGE plpythonu VOLATILE
  COST 100;
ALTER FUNCTION uve_spatial_percent(text, text, text, text)
  OWNER TO otsix;
