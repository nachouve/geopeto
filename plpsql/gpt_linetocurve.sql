-- Function: gpt_linetocurve(geometry)

    -- DROP FUNCTION gpt_linetocurve(geometry);

CREATE OR REPLACE FUNCTION gpt_linetocurve(geom geometry)
    RETURNS geometry AS
    $BODY$DECLARE

curve geometry;
num_points int;
p1 geometry;
p2 geometry;
x1 double precision;
y1 double precision;
x2 double precision;
y2 double precision;
xm double precision;
ym double precision;
xp double precision;
yp double precision;

m double precision;
d double precision;

BEGIN
    curve = geom;
num_points := ST_NumPoints(geom);
IF (num_points < 2) THEN
    RAISE EXCEPTION 'Linestring must have at least 2 points.';
END IF;

p1 := st_startpoint(geom);
p2 := st_endpoint(geom);
d := st_length(geom);

x1 := st_x(p1);
y1 := st_y(p1);
x2 := st_x(p2);
y2 := st_y(p2);

--Median point
xm := (x1+x2)/2;
ym := (y1+y2)/2;
m := (y2-y1)/(x2-x1);

--RAISE NOTICE '------------';
--RAISE NOTICE 'Distance: %',d;
--RAISE NOTICE 'Pendiente: %',m;
--RAISE NOTICE 'x1: %',x1;
--RAISE NOTICE 'y1: %',y1;
--RAISE NOTICE 'xm: %',xm;
--RAISE NOTICE 'ym: %',ym;

-- Curve point
xp := xm - (m * d/10);
yp := ym - (-1 * d/10);

curve := st_curvetoline(st_geometry('CIRCULARSTRING('||x1::text||' '||y1::text||', '||xp::text||' '||yp::text||', '||x2::text||' '||y2::text||')'));

RETURN curve;
END$BODY$
    LANGUAGE plpgsql VOLATILE
    COST 100;
ALTER FUNCTION gpt_linetocurve(geometry)
    OWNER TO postgres;
																				 