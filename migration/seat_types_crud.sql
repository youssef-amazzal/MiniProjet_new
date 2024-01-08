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
 *  Seat type management
 **************************************/

drop function if exists save_seat_type(name VARCHAR, price FLOAT, description VARCHAR, color VARCHAR, cinema_id uuid);
drop function if exists update_seat_type(seat_type_id INT, name VARCHAR, price FLOAT, description VARCHAR, color VARCHAR, cinema_id uuid);
drop function if exists get_seat_types_by_cinema(cinema_id uuid);
drop function if exists delete_seat_type(seat_type_id INT);


-- create a new seat type
drop function if exists save_seat_type(par_name VARCHAR, par_price FLOAT, par_description VARCHAR, par_color VARCHAR, par_cinema_id uuid);
CREATE OR REPLACE FUNCTION save_seat_type(par_name VARCHAR, par_price FLOAT, par_description VARCHAR, par_color VARCHAR, par_cinema_id uuid)
RETURNS VOID AS $$
BEGIN
    INSERT INTO seatType (name, price, description, color, id_cinema)
    VALUES (par_name, par_price, par_description, par_color, par_cinema_id);
END; $$ LANGUAGE plpgsql;

-- update a seat type
drop function if exists update_seat_type(par_seat_type_id INT, par_name VARCHAR, par_price FLOAT, par_description VARCHAR, par_color VARCHAR, par_cinema_id uuid);
CREATE OR REPLACE FUNCTION update_seat_type(par_seat_type_id INT, par_name VARCHAR, par_price FLOAT, par_description VARCHAR, par_color VARCHAR, par_cinema_id uuid)
RETURNS VOID AS $$
BEGIN
    UPDATE seatType
    SET 
        name = par_name,
        price = par_price,
        description = par_description,
        color = par_color,
        id_cinema = par_cinema_id
    WHERE id = par_seat_type_id;
END; $$ LANGUAGE plpgsql;

-- select all seat types of a cinema
drop function if exists get_seat_types_by_cinema(par_cinema_id uuid);
CREATE OR REPLACE FUNCTION get_seat_types_by_cinema(par_cinema_id uuid)
RETURNS SETOF seatType AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM seatType WHERE id_cinema = par_cinema_id;
END; $$ LANGUAGE plpgsql;

-- delete a seat type
drop function if exists delete_seat_type(par_seat_type_id INT);
CREATE OR REPLACE FUNCTION delete_seat_type(par_seat_type_id INT)
RETURNS VOID AS $$
BEGIN
    DELETE FROM seatType
    WHERE id = par_seat_type_id;
END; $$ LANGUAGE plpgsql;