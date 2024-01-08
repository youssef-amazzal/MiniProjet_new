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
*  City management
**************************************/

-- create a new city
drop function if exists save_city(varchar, int);
CREATE OR REPLACE FUNCTION save_city(par_name VARCHAR, par_country_id INT)
RETURNS VOID AS $$
BEGIN
    INSERT INTO city (name, country_id)
    VALUES (par_name, par_country_id);
END; $$ LANGUAGE plpgsql;

-- update a city
drop function if exists update_city(int, varchar, int);
CREATE OR REPLACE FUNCTION update_city(par_city_id INT, par_name VARCHAR, par_country_id INT)
RETURNS VOID AS $$
BEGIN
    UPDATE city
    SET 
        name = name,
        country_id = country_id
    WHERE id = par_city_id;
END; $$ LANGUAGE plpgsql;

-- select all cities of a country
drop function if exists get_cities_by_country(int);
CREATE OR REPLACE FUNCTION get_cities_by_country(par_country_id INT)
RETURNS SETOF city AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM city WHERE country_id = par_country_id;
END; $$ LANGUAGE plpgsql;

-- delete a city
drop function if exists delete_city(int);
CREATE OR REPLACE FUNCTION delete_city(par_city_id INT)
RETURNS VOID AS $$
BEGIN
    DELETE FROM city
    WHERE id = par_city_id;
END; $$ LANGUAGE plpgsql;