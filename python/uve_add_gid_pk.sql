-- Function: uve_add_gid_pk(text)

-- DROP FUNCTION uve_add_gid_pk(text);

CREATE OR REPLACE FUNCTION uve_add_gid_pk("table" text)
  RETURNS boolean AS
$BODY$schema = 'public'
tablename = table
dot_idx = table.find('.')
if (dot_idx > -1):
    schema = table[:dot_idx]
    tablename = table[(dot_idx+1):]


stmt ='ALTER TABLE "'+schema+'"."'+tablename+'" ADD COLUMN "gid" INTEGER;'
plpy.execute(stmt)
stmt ='DROP SEQUENCE IF EXISTS  "'+schema+'"."'+tablename+'_gid_seq" CASCADE;'
plpy.execute(stmt)
stmt ='CREATE SEQUENCE "'+schema+'"."'+tablename+'_gid_seq";'
plpy.execute(stmt)
stmt ='UPDATE  "'+schema+'"."'+tablename+'"'+" SET gid = nextval('\""+schema+"\".\""+tablename+"_gid_seq\"');"
plpy.execute(stmt)
stmt ='ALTER TABLE "'+schema+'"."'+tablename+'"'+" ALTER COLUMN \"gid\" SET DEFAULT nextval('\""+schema+"\".\""+tablename+"_gid_seq\"');"
plpy.execute(stmt)
stmt ='ALTER TABLE "'+schema+'"."'+tablename+'" ALTER COLUMN "gid" SET NOT NULL;'
plpy.execute(stmt)
stmt ='ALTER TABLE "'+schema+'"."'+tablename+'" ADD UNIQUE ("gid");'
plpy.execute(stmt)
stmt ='ALTER TABLE "'+schema+'"."'+tablename+'" DROP CONSTRAINT "'+tablename+'_gid_key" RESTRICT;'
plpy.execute(stmt)
stmt ='ALTER TABLE "'+schema+'"."'+tablename+'"  ADD PRIMARY KEY ("gid");'
plpy.execute(stmt)$BODY$
  LANGUAGE plpythonu VOLATILE
  COST 100;
ALTER FUNCTION uve_add_gid_pk(text)
  OWNER TO admin;
