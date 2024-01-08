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
-- projection(id serial, id_movie int, id_tmdb int, id_theater int, id_layout int, start_time timestamp, end_time timestamp)
-- profile(id uuid, first_name varchar, role varchar)
-- ticket(id serial, id_projection int, id_seatType int, id_user uuid, price float, seat_number int, seat_row int, seat_column int, status varchar)


/**************************************
 *  Projection management
 **************************************/

drop function if exists save_projection(int, int, int, timestamp, timestamp);
drop function if exists update_projection(int, int, int, int, timestamp, timestamp);
drop function if exists get_projections_by_movie(int);
drop function if exists get_projections_by_theater(int);
drop function if exists get_projections_by_cinema(int);
drop function if exists delete_projection(int);


-- create a new projection
CREATE OR REPLACE FUNCTION save_projection(param_id_movie INT, param_id_tmdb INT, param_id_theater INT, param_id_layout INT, param_start_time TIMESTAMP, param_end_time TIMESTAMP)
RETURNS INT AS $$
DECLARE
    new_id INT;
BEGIN
    INSERT INTO projection (id_movie, id_tmdb, id_theater, id_layout, start_time, end_time)
    VALUES (param_id_movie, param_id_tmdb, param_id_theater, param_id_layout, param_start_time, param_end_time)
    RETURNING id INTO new_id;

    RETURN new_id;
END; $$ LANGUAGE plpgsql;

-- update a projection
CREATE OR REPLACE FUNCTION update_projection(param_id INT, param_id_movie INT, param_id_tmdb INT, param_id_theater INT, param_id_layout INT, param_start_time TIMESTAMP, param_end_time TIMESTAMP)
RETURNS VOID AS $$
BEGIN
    UPDATE projection
    SET 
        id_movie = param_id_movie,
        id_tmdb = param_id_tmdb,
        id_theater = param_id_theater,
        id_layout = param_id_layout,
        start_time = param_start_time,
        end_time = param_end_time
    WHERE id = param_id;
END; $$ LANGUAGE plpgsql;

drop type if exists projection_with_layout;
CREATE TYPE projection_with_layout AS (
    id INT,
    id_movie INT,
    id_tmdb INT,
    id_layout INT,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    cinema varchar,
    seat_map JSON,
    seat_types seattype[]
);
-- select all projections of a movie
drop function if exists get_projections_by_movie(int, boolean);
CREATE OR REPLACE FUNCTION get_projections_by_movie(param_movie_id INT, param_with_layout BOOLEAN DEFAULT FALSE)
RETURNS SETOF projection_with_layout AS $$
BEGIN
    IF param_with_layout THEN
        RETURN QUERY
        SELECT p.id, p.id_movie, p.id_tmdb, p.id_layout, p.start_time, p.end_time, 
        (
            SELECT c.name
            FROM cinema c
            INNER JOIN layout l ON l.id_cinema = c.id
            WHERE l.id = p.id_layout
        ) AS cinema,
        l.seat_map::json,
        (
            SELECT array_agg(st)
            FROM seattype st
            WHERE st.id_cinema = (
                SELECT id_cinema
                FROM layout
                WHERE id = p.id_layout
            )
        ) AS seat_types
        FROM projection p
        INNER JOIN layout l ON p.id_layout = l.id
        INNER JOIN cinema c ON l.id_cinema = c.id
        WHERE (p.id_movie = param_movie_id or p.id_tmdb = param_movie_id) and p.start_time > now();
    ELSE
        RETURN QUERY
        SELECT * FROM projection WHERE (id_movie = param_movie_id or id_tmdb = param_movie_id) and start_time > now();
    END IF;
END; $$ LANGUAGE plpgsql;

SELECT * FROM get_projections_by_movie(572802, TRUE);

-- select all projections of a theater
CREATE OR REPLACE FUNCTION get_projections_by_theater(param_theater_id INT)
RETURNS SETOF projection AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM projection WHERE id_theater = param_theater_id;
END; $$ LANGUAGE plpgsql;

-- select all projections of a cinema
drop function if exists get_projections_by_cinema(int);
drop type if exists projection_by_cinema;
-- theater(id serial, name varchar, cinema_id uuid, id_layout int)
-- layout(id serial, name varchar, seat_map json, cinema_id uuid)
create type projection_by_cinema as (
    id int,
    id_movie int,
    id_tmdb INT,
    start_time timestamp,
    end_time timestamp,
    theater theater,
    layout layout,
    revenue FLOAT,
    tickets_count INT,
    seats_count INT
);

drop function if exists get_projections_by_cinema(uuid);
CREATE OR REPLACE FUNCTION get_projections_by_cinema(par_cinema_id uuid)
RETURNS SETOF projection_by_cinema AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.id_movie,
        p.id_tmdb,
        p.start_time,
        p.end_time,
        t AS theater, -- return the entire theater row
        l AS layout, -- return the entire layout row
        (
            SELECT COALESCE(SUM(t.price), 0)
            FROM ticket t
            WHERE t.id_projection = p.id
        ) AS revenue,
        (
            SELECT CAST(COUNT(t.id) AS INTEGER)
            FROM ticket t
            WHERE t.id_projection = p.id
        ) AS tickets_count,
        (SELECT get_seats_count(p.id_layout)) AS seats_count
    FROM projection p
    INNER JOIN theater t ON p.id_theater = t.id
    INNER JOIN layout l ON p.id_layout = l.id
    WHERE t.id_cinema = par_cinema_id;
END; $$ LANGUAGE plpgsql;

select * from get_projections_by_cinema('99bd76cd-a0bf-4ebb-be55-94791ac9c581');

-- delete a projection
CREATE OR REPLACE FUNCTION delete_projection(param_projection_id INT)
RETURNS VOID AS $$
BEGIN
    DELETE FROM projection
    WHERE id = param_projection_id;
END; $$ LANGUAGE plpgsql;


-- get all projections of a cinema with
