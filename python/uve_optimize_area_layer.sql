-- Function: uve_optimize_area_layer(text, integer)

-- DROP FUNCTION uve_optimize_area_layer(text, integer);

CREATE OR REPLACE FUNCTION uve_optimize_area_layer("table" text, tolerance integer)
  RETURNS boolean AS
$BODY$schema = 'public'
tablename = table
dot_idx = table.find('.')
if (dot_idx > -1):
   schema = table[:dot_idx]
   tablename = table[(dot_idx+1):]

## Detect previousspatial index
stmt= "select indexname from pg_indexes where tablename = '"+tablename+"' AND indexdef like '% gist%';"
ret= plpy.execute(stmt)
if (len(ret)>0):
    schema_if_it_has = ''
    if (len(schema)>0):
	schema_if_it_has = schema+'.'
    for i in range(len(ret)):
	plpy.info("DROP INDEX "+schema_if_it_has+ret[i]["indexname"])
	plpy.execute("DROP INDEX "+schema_if_it_has+ret[i]["indexname"])

plpy.info("## Buffer 0.0 and simplify geometry");
## Buffer 0.0 and simplify geometry
stmt = "update "+table+" SET the_geom=st_multi(ST_SimplifyPreserveTopology(\
	st_buffer(the_geom,0.0), "+str(tolerance)+"));"
plpy.execute(stmt)


plpy.info("## Create new spatial index");
## Create new spatial index

idx_name = tablename+"_the_geom_gist" 
stmt= "CREATE INDEX "+idx_name+" ON "+table+" USING GIST (the_geom)"
plpy.execute(stmt)

plpy.info("## Cluster for near storage");
## Cluster for near storage
plpy.execute("CLUSTER "+table+" USING "+idx_name)
plpy.info("## Remenber to do VACUUM "+ table);
#--plpy.execute("VACUUM "+table)
#--plpy.execute("ANALYZE "+table)

return True
$BODY$
  LANGUAGE plpythonu VOLATILE
  COST 100;
ALTER FUNCTION uve_optimize_area_layer(text, integer)
  OWNER TO admin;
