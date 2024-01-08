/**************************************
 *  Brief schema
 **************************************/

-- country(id serial, name varchar)
-- city(id serial, name varchar, country_id int)
-- cinema(id serial, name varchar, city_id int)
-- movie(id serial, cinema_id uuid)
-- seatType(id serial, name varchar, price float, description varchar, color varchar, cinema_id uuid)
-- layout(id serial, name varchar, seat_map json, cinema_id uuid)
-- theater(id serial, name varchar, cinema_id uuid, id_layout int)
-- projection(id serial, id_movie int, id_theater int, id_layout int, start_time timestamp, end_time timestamp)
-- profile(id uuid, first_name varchar, role varchar)
-- ticket(id serial, id_projection int, id_seatType int, id_user uuid, price float, seat_number int, seat_row int, seat_column int, status varchar)

/**************************************
 *  Seed data
 **************************************/

-- function that fills the country table with n countries named country n, using save_country function
CREATE OR REPLACE FUNCTION seed_country(n INT)
RETURNS VOID AS $$
DECLARE
    i INT := 1;
BEGIN
    WHILE i <= n LOOP
        PERFORM save_country('country ' || i);
        i := i + 1;
    END LOOP;
END; $$ LANGUAGE plpgsql;

-- get_rand_country function that returns a random country
CREATE OR REPLACE FUNCTION get_rand_country()
RETURNS country AS $$
DECLARE
    rand_country country;
BEGIN
    SELECT * FROM country
    ORDER BY random()
    LIMIT 1
    INTO rand_country;
    RETURN rand_country;
END; $$ LANGUAGE plpgsql;

-- function that fills the city table with n cities named city n, using save_city function
CREATE OR REPLACE FUNCTION seed_city(n INT)
RETURNS VOID AS $$
DECLARE
    i INT := 1;
    country_id INT;
BEGIN
    WHILE i <= n LOOP
        country_id := (select id from get_rand_country());
        PERFORM save_city('city ' || i, country_id);
        i := i + 1;
    END LOOP;
END; $$ LANGUAGE plpgsql;

-- get_rand_city function that returns a random city
CREATE OR REPLACE FUNCTION get_rand_city()
RETURNS city AS $$
DECLARE
    rand_city city;
BEGIN
    SELECT * FROM city
    ORDER BY random()
    LIMIT 1
    INTO rand_city;
    RETURN rand_city;
END; $$ LANGUAGE plpgsql;

-- function that fills the cinema table with n cinemas named cinema n, using save_cinema function
CREATE OR REPLACE FUNCTION seed_cinema(n INT)
RETURNS VOID AS $$
DECLARE
    i INT := 1;
    city_id INT;
BEGIN
    WHILE i <= n LOOP
        city_id := (select id from get_rand_city());
        PERFORM save_cinema('cinema ' || i, city_id);
        i := i + 1;
    END LOOP;
END; $$ LANGUAGE plpgsql;

-- get_rand_cinema function that returns a random cinema
CREATE OR REPLACE FUNCTION get_rand_cinema()
RETURNS cinema AS $$
DECLARE
    rand_cinema cinema;
BEGIN
    SELECT * FROM cinema
    ORDER BY random()
    LIMIT 1
    INTO rand_cinema;
    RETURN rand_cinema;
END; $$ LANGUAGE plpgsql;
    
delete from cinema cascade;
delete from city cascade;
delete from country cascade;

SELECT seed_country(3);
SELECT seed_city(15);
SELECT seed_cinema(100);


drop function if exists generate_seat_map(uuid);

drop function if exists seed_seatType_all();
drop function if exists seed_seatType(uuid);
drop function if exists seed_layout_all();
drop function if exists seed_layout(uuid, int);
drop function if exists seed_theater_all();
drop function if exists seed_theater(uuid, int);

-- function that fills seatType table of a cinema with 3 seatTypes standard, vip and accessibility, using save_seatType function
CREATE OR REPLACE FUNCTION seed_seatType(par_cinema_id uuid)
RETURNS VOID AS $$
BEGIN
    PERFORM save_seat_type('standard', 10, 'standard seat', '#81ff30', par_cinema_id);
    PERFORM save_seat_type('vip', 20, 'vip seat', '#ff9c30', par_cinema_id);
    PERFORM save_seat_type('accessibility', 10, 'accessibility seat', '#af50ff', par_cinema_id);
END; $$ LANGUAGE plpgsql;

-- iterate over all cinemas and fill their seatType table
CREATE OR REPLACE FUNCTION seed_seatType_all()
RETURNS VOID AS $$
DECLARE
    cinema cinema;
BEGIN
    FOR cinema IN SELECT * FROM cinema LOOP
        PERFORM seed_seatType(cinema.id);
    END LOOP;
END; $$ LANGUAGE plpgsql;

/*
seat map
[
    [0, 0, 1, 1, 1, 1, 1, 0, 0],    row 0
    [0, 0, 1, 1, 1, 1, 1, 0, 0],    row 1
    [1, 1, 1, 1, 1, 1, 1, 1, 1,     row 2
    [1, 1, 1, 1, 1, 1, 1, 1, 1,     row 3
    [1, 1, 1, 1, 1, 1, 1, 1, 1,     row 4
    [1, 1, 1, 1, 1, 1, 1, 1, 1,     row 5
    [0, 0, 1, 1, 1, 1, 1, 0, 0],    row 6
    [0, 0, 1, 1, 1, 1, 1, 0, 0,     row 7
    [0, 0, 1, 1, 1, 1, 1, 0, 0]     row 8
]
*/

/*
 -- Insert value into a jsonb
-- auto-generated definition
create function jsonb_insert(jsonb_in unknown, path unknown, replacement unknown, insert_after unknown default false) returns unknown
    immutable
    strict
    cost 1
    language internal
as
$$begin
-- missing source code
end;$$;
 */
CREATE OR REPLACE FUNCTION generate_seat_map(par_cinema_id uuid)
RETURNS jsonb AS $$
DECLARE
    seat_map jsonb;
    seat_map_row jsonb;
    seatType seatType;
    count_row INT := floor(random() * 10 + 10);
    count_column INT := floor(random() * 10 + 10);
BEGIN
    seat_map := '[]'::jsonb;
    FOR i IN 0..count_row LOOP
        seat_map_row := '[]'::jsonb;
        FOR j IN 0..count_column LOOP
            select * from seatType where id_cinema = par_cinema_id order by random() limit 1 into seatType;
            seat_map_row := jsonb_insert(seat_map_row, ARRAY[j::text], to_jsonb(seatType.id), true);
        END LOOP;
        seat_map := jsonb_insert(seat_map, ARRAY[i::text], seat_map_row, true);
    END LOOP;

    RETURN seat_map;
END; $$ LANGUAGE plpgsql;

-- test generate_seat_map function
select generate_seat_map((select id from cinema limit 1));

-- function that fills layout table of a cinema with n layouts named layout n, using save_layout function
CREATE OR REPLACE FUNCTION seed_layout(par_cinema_id uuid, n INT)
RETURNS VOID AS $$
DECLARE
    i INT := 1;
    seat_map jsonb;
BEGIN
    WHILE i <= n LOOP
        seat_map := generate_seat_map(par_cinema_id);
        PERFORM save_layout(('layout ' || i)::varchar, seat_map::JSON, par_cinema_id);
        i := i + 1;
    END LOOP;
END; $$ LANGUAGE plpgsql;

-- iterate over all cinemas and fill their layout table
CREATE OR REPLACE FUNCTION seed_layout_all()
RETURNS VOID AS $$
DECLARE
    cinema cinema;
BEGIN
    FOR cinema IN SELECT * FROM cinema LOOP
        PERFORM seed_layout(cinema.id, floor(random() * 5 + 1)::INT);
    END LOOP;
END; $$ LANGUAGE plpgsql;

-- function that fills the theater table of a cinema with n theaters named theater n, using save_theater function
CREATE OR REPLACE FUNCTION seed_theater(par_cinema_id uuid, n INT)
RETURNS VOID AS $$
DECLARE
    i INT := 1;
    layout_record layout;
BEGIN
    WHILE i <= n LOOP
        SELECT * FROM layout WHERE id_cinema = par_cinema_id ORDER BY random() LIMIT 1 INTO layout_record;
        PERFORM save_theater('theater ' || i, par_cinema_id, layout_record.id);
        i := i + 1;
    END LOOP;
END; $$ LANGUAGE plpgsql;

-- iterate over all cinemas and fill their theater table
CREATE OR REPLACE FUNCTION seed_theater_all()
RETURNS VOID AS $$
DECLARE
    cinema_record cinema;
BEGIN
    FOR cinema_record IN SELECT * FROM cinema LOOP
        PERFORM seed_theater(cinema_record.id, floor(random() * 5 + 1)::INT);
    END LOOP;
END; $$ LANGUAGE plpgsql;

SELECT seed_seatType_all();
SELECT seed_layout_all();
SELECT seed_theater_all();


-- function that fills the projection table of a cinema with n projections named projection min < x < max, using save_projection function
/*
 available id_tmdb
 695721, 848326, 572802, 891699, 1029575, 787699, 1071215, 466420, 930564, 520758, 897087, 956920, 901362, 1131755, 726209, 940551, 1022796, 940721, 983507, 678512
 */
CREATE OR REPLACE FUNCTION seed_projection(par_cinema_id uuid, min_n INT, max_n INT)
RETURNS VOID AS $$
DECLARE
    theater theater;
    tmdb_id INT;
    start_time timestamp;
    end_time timestamp;
BEGIN
    FOR i IN 1..(floor(random() * (max_n - min_n) + min_n)::INT) LOOP
        SELECT * FROM theater WHERE id_cinema = par_cinema_id ORDER BY random() LIMIT 1 INTO theater;
        tmdb_id := (select id from (values (695721), (848326), (572802), (891699), (1029575), (787699), (1071215), (466420), (930564), (520758), (897087), (956920), (901362), (1131755), (726209), (940551), (1022796), (940721), (983507), (678512)) as t(id) order by random() limit 1);
        -- now() + random days + random hours + random minutes, with random duration from 1 hour 40 minutes to 2 hours
        start_time := now() + (floor(random() * 13)::INT) * interval '1 day' + (floor(random() * 24)::INT) * interval '1 hour' + (floor(random() * 60)::INT) * interval '1 minute';
        end_time := start_time + (floor(random() * 20 + 100)::INT) * interval '1 minute';
        PERFORM save_projection(null, tmdb_id, theater.id, theater.id_layout, start_time, end_time);
    END LOOP;
END; $$ LANGUAGE plpgsql;

-- iterate over all cinemas and fill their projection table
CREATE OR REPLACE FUNCTION seed_projection_all()
RETURNS VOID AS $$
DECLARE
    cinema cinema;
BEGIN
    FOR cinema IN SELECT * FROM cinema LOOP
        PERFORM seed_projection(cinema.id, 15, 25);
    END LOOP;
END; $$ LANGUAGE plpgsql;

delete from projection cascade;
SELECT seed_projection_all();