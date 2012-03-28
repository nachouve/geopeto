-- Function: uve_copy_reprojecting(text, text, integer)

-- DROP FUNCTION uve_copy_reprojecting(text, text, integer);

CREATE OR REPLACE FUNCTION uve_copy_reprojecting(layer_org text, layer_dst text, srid_dst integer)
  RETURNS boolean AS
$BODY$result = plpy.execute("SELECT srid from geometry_columns WHERE f_table_name = '"+layer_org+"'")

srid_org = -1
if (len(result)==1):
    srid_org = result[0]["srid"]
else:
    return False

## Or maybe do it anyway!!!!
if (srid_org == srid_dst):
    return False

stmt = "CREATE TABLE "+layer_dst+" AS "\
+" select * from "+ layer_org

plpy.execute(stmt)

#plpy.execute("UPDATE "+layer_dst+" SET the_geom = st_transform(the_geom, "+srid_dst+")")
plpy.execute("UpdateGeometrySRID("+layer_dst+", the_geom, "+srid_dst+");")$BODY$
  LANGUAGE plpythonu VOLATILE
  COST 100;
ALTER FUNCTION uve_copy_reprojecting(text, text, integer)
  OWNER TO otsix;

