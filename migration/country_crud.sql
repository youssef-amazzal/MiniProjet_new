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
*  Country management
**************************************/

-- create a new country
CREATE OR REPLACE FUNCTION save_country(par_name VARCHAR)
RETURNS VOID AS $$
BEGIN
    INSERT INTO country (name)
    VALUES (par_name);
END; $$ LANGUAGE plpgsql;

-- update a country
CREATE OR REPLACE FUNCTION update_country(par_country_id INT, par_name VARCHAR)
RETURNS VOID AS $$
BEGIN
    UPDATE country
    SET
        name = par_name
    WHERE id = par_country_id;
END; $$ LANGUAGE plpgsql;

-- select all countries
CREATE OR REPLACE FUNCTION get_countries()
RETURNS SETOF country AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM country;
END; $$ LANGUAGE plpgsql;

-- delete a country
CREATE OR REPLACE FUNCTION delete_country(par_country_id INT)
RETURNS VOID AS $$
BEGIN
    DELETE FROM country
    WHERE id = par_country_id;
END; $$ LANGUAGE plpgsql;


