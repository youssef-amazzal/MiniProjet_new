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
 *  Cinema management
 **************************************/

-- create a cinema
CREATE OR REPLACE FUNCTION save_cinema(par_name VARCHAR, par_city_id INT)
RETURNS VOID AS $$
BEGIN
    INSERT INTO cinema(id, name, city_id)
    VALUES (uuid_generate_v4(), par_name, par_city_id);
END; $$ LANGUAGE plpgsql;

-- update a cinema
CREATE OR REPLACE FUNCTION update_cinema(par_cinema_id uuid, par_name VARCHAR, par_city_id INT)
RETURNS VOID AS $$
BEGIN
    UPDATE cinema
    SET 
        name = par_name,
        city_id = par_city_id
    WHERE id = par_cinema_id;
END; $$ LANGUAGE plpgsql;

-- select all cinemas of a city
CREATE OR REPLACE FUNCTION get_cinemas_by_city(id_city INT)
RETURNS SETOF cinema AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM cinema WHERE city_id = id_city;
END; $$ LANGUAGE plpgsql;

-- select all cinemas
CREATE OR REPLACE FUNCTION get_all_cinemas()
RETURNS SETOF cinema AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM cinema;
END; $$ LANGUAGE plpgsql;

-- delete a cinema
CREATE OR REPLACE FUNCTION delete_cinema(cinema_id uuid)
RETURNS VOID AS $$
BEGIN
    DELETE FROM cinema
    WHERE id = cinema_id;
END; $$ LANGUAGE plpgsql;