-- Function: uve_createcheckcolumnstable(text, text, text, text[])

-- DROP FUNCTION uve_createcheckcolumnstable(text, text, text, text[]);

CREATE OR REPLACE FUNCTION uve_createcheckcolumnstable("table" text, "column" text, new_table text, new_columns text[])
  RETURNS boolean AS
$BODY$idx_tb= plpy.execute("SELECT uve_createdistincttable('"+table+"', '"+column+"');")

values = plpy.execute("SELECT "+column+" from "+idx_tb)

new_cols = list()
for value in values:
    plpy.info(value)
    for col in new_columns:
        if (col.startswith("num")):
            new_cols.append(col+str(value[column])+" int4")
        else:
	    new_cols.append(col+str(value[column])+" double precision")

plpy.info(str(new_cols))$BODY$
  LANGUAGE plpythonu VOLATILE
  COST 100;
ALTER FUNCTION uve_createcheckcolumnstable(text, text, text, text[])
  OWNER TO otsix;
