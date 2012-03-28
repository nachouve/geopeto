-- Function: uve_create_groupsby_proximity(text, text, double precision)

-- DROP FUNCTION uve_create_groupsby_proximity(text, text, double precision);

CREATE OR REPLACE FUNCTION uve_create_groupsby_proximity("table" text, id_col text, tolerance double precision)
  RETURNS text AS
$BODY$from sys import maxint

schema = 'public'
tablename = table
dot_idx = table.find('.')
if (dot_idx > -1):
   schema = table[:dot_idx]
   tablename = table[(dot_idx+1):]

out_tbl = "group_prox_"+tablename

plpy.execute("DROP TABLE IF EXISTS "+out_tbl+" cascade;")

stmt = "CREATE TABLE "+out_tbl+" AS select "+id_col+" as id, -1 as groupid, the_geom from "+table+" ORDER BY "+id_col+";" 
result = plpy.execute(stmt)

stmt = "select id from "+out_tbl+" ORDER BY id;" 
result = plpy.execute(stmt)

group_id_count = 1
for res in result:
    id = res["id"]
    plpy.info(str(id))

    groups_sql = "(select distinct t2.groupid as groupid from "+out_tbl+" as t1, "+out_tbl+" as t2 " +\
"WHERE t1.id = '"+str(id)+"' AND t2.groupid != -1 AND st_dwithin(t1.the_geom, t2.the_geom, "+str(tolerance)+"))"
    g_result = plpy.execute(groups_sql)
    
    min_group = maxint
    groups_list = list()

    if (len(g_result)==0):
	group_id = group_id_count
	group_id_count = group_id_count+1
	plpy.info("----> DIO ZERO ----> NEW group: " + str(group_id))
    
    for g_res in g_result:
	group_id = g_res["groupid"]
	if (group_id == None):
            group_id = group_id_count
	    group_id_count = group_id_count+1
	    plpy.info("----> NEW group: " + str(group_id))
	else:
	    plpy.info("FOUND group: " + str(group_id))
	    
	groups_list.append(group_id)
	if (min_group > group_id):
	    min_group = group_id
    
    where_sql = "(select t2.id from "+out_tbl+" as t1, "+out_tbl+" as t2 " +\
"WHERE t1.id = '"+str(id)+"' AND st_dwithin(t1.the_geom, t2.the_geom, "+str(tolerance)+"))"
    update_sql = "UPDATE "+out_tbl+" SET groupid = "+str(group_id)+" WHERE id IN "+where_sql
    plpy.info(update_sql)
    plpy.execute(update_sql)

    if (len(groups_list)>1):
        groups_list.remove(group_id)
	where_sql = str(tuple(groups_list)).replace(',)',')')
	update_sql = "UPDATE "+out_tbl+" SET groupid = "+str(group_id)+" WHERE groupid IN "+where_sql
	plpy.info(update_sql)
	plpy.execute(update_sql)


plpy.info('########################')

return out_tbl+' --> See Message tab'$BODY$
  LANGUAGE plpythonu VOLATILE
  COST 100;
ALTER FUNCTION uve_create_groupsby_proximity(text, text, double precision)
  OWNER TO otsix;
COMMENT ON FUNCTION uve_create_groupsby_proximity(text, text, double precision) IS 'IMPORTANT: the col_id must be a PRIMARY KEY or at least be unique!';
