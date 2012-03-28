-- Function: uve_createdistincttable(text, text)

-- DROP FUNCTION uve_createdistincttable(text, text);

CREATE OR REPLACE FUNCTION uve_createdistincttable("table" text, "column" text)
  RETURNS text AS
$BODY$plpy.info(">>>>>>> Starting uve_createdistincttable...")

schema = 'public'
tablename = table
dot_idx = table.find('.')
if (dot_idx > -1):
   schema = table[:dot_idx]
   tablename = table[(dot_idx+1):]


##################################################
## two variables fails... :/
#stmt = "SELECT DISTINCT $1 FROM $2"
#prep = plpy.prepare(stmt, ["text", "text"])
#plpy.execute(prep, [table, column])
##################################################

plpy.info(column)

tb = "uve_distinctvalues_"+str(tablename)

plpy.execute("DROP TABLE IF EXISTS "+tb)
stmt = "CREATE TABLE "+tb+" (id serial PRIMARY KEY, value text)"
plpy.execute(stmt)

stmt = "SELECT DISTINCT "+column+" FROM "+table
dstnct = plpy.execute(stmt)

i = 0
for row in dstnct:
    stmt = "INSERT INTO "+tb+" (value) VALUES ('"+str(row[column])+"')"
    plpy.info(stmt)
    plpy.execute(stmt)
    i = i + 1 

return tb

$BODY$
  LANGUAGE plpythonu VOLATILE
  COST 100;
ALTER FUNCTION uve_createdistincttable(text, text)
  OWNER TO otsix;
