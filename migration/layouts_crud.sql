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
 *  Layout management
 **************************************/
drop function if exists save_layout(VARCHAR, JSON, uuid);
drop function if exists update_layout(int, VARCHAR, JSON, uuid);
drop function if exists get_layouts_by_cinema(uuid);
drop function if exists delete_layout(int);
drop function if exists get_layout_by_id(int);
drop function if exists update_seat_map_position(int, int, int, int);
drop function if exists update_seat_map_dimensions(int, int, int);


-- create a new layout
CREATE OR REPLACE FUNCTION save_layout(param_name VARCHAR, param_seat_map JSON, param_cinema_id uuid)
RETURNS VOID AS $$
BEGIN
    INSERT INTO layout (name, seat_map, id_cinema)
    VALUES (param_name, param_seat_map, param_cinema_id);
END; $$ LANGUAGE plpgsql;

-- update a layout
CREATE OR REPLACE FUNCTION update_layout(param_layout_id INT, param_name VARCHAR, param_seat_map JSON, param_cinema_id uuid)
RETURNS VOID AS $$
BEGIN
    UPDATE layout
    SET 
        name = param_name,
        seat_map = param_seat_map,
        id_cinema = param_cinema_id
    WHERE id = param_layout_id;
END; $$ LANGUAGE plpgsql;

-- select all layouts of a cinema
CREATE OR REPLACE FUNCTION get_layouts_by_cinema(param_cinema_id uuid)
RETURNS SETOF layout AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM layout WHERE id_cinema = param_cinema_id;
END; $$ LANGUAGE plpgsql;

-- delete a layout
CREATE OR REPLACE FUNCTION delete_layout(param_layout_id INT)
RETURNS VOID AS $$
BEGIN
    DELETE FROM layout
    WHERE id = param_layout_id;
END; $$ LANGUAGE plpgsql;


/* seat_map example
[
    [2, 2, 0, 2, 2],
    [2, 2, 0, 2, 2],
    [3, 3, 3, 3, 3],
    [3, 3, 3, 3, 3]
]
*/

 -- Return a layout by id and with the number of seats, rows and columns, seats are represented by non-zero numbers
CREATE OR REPLACE FUNCTION get_layout_by_id(param_layout_id INT)
RETURNS TABLE (
    id INT,
    name VARCHAR(50),
    seat_map JSON,
    id_cinema uuid,
    seats_count INT,
    rows_count INT,
    columns_count INT
) AS $$
DECLARE
    seat_count INT;
BEGIN
    SELECT 
        l.id,
        l.name,
        l.seat_map,
        l.id_cinema,
        json_array_length(l.seat_map) AS rows_count,
        json_array_length(l.seat_map -> 0) AS columns_count
    INTO 
        id, name, seat_map, id_cinema, rows_count, columns_count
    FROM 
        layout l
    WHERE 
        l.id = param_layout_id;

    SELECT COUNT(*)
    INTO seat_count
    FROM jsonb_array_elements_text(to_jsonb(seat_map)) AS j
    WHERE j::INT != 0;

    seats_count := seat_count;

    RETURN NEXT;
END; $$ LANGUAGE plpgsql;

-- update a seat map position by id and position
CREATE OR REPLACE FUNCTION update_seat_map_position(param_layout_id INT, param_row INT, param_col INT, param_seat_type INT)
RETURNS VOID AS $$
DECLARE
    seat_map_var JSONB;
BEGIN
    SELECT 
        l.seat_map::jsonb
    INTO 
        seat_map_var
    FROM 
        layout l
    WHERE 
        l.id = param_layout_id;

    seat_map_var := jsonb_set(seat_map_var, ARRAY[param_row::TEXT, param_col::TEXT], param_seat_type::TEXT::JSONB);

    UPDATE layout
    SET seat_map = seat_map_var
    WHERE id = param_layout_id;
END; $$ LANGUAGE plpgsql;

-- update a seat map dimensions by id and dimensions without losing data
CREATE OR REPLACE FUNCTION update_seat_map_dimensions(param_layout_id INT, param_rows_count INT, param_columns_count INT)
RETURNS VOID AS $$
DECLARE
    seat_map JSON;
    new_seat_map JSON;
    "row" INT;
    "col" INT;
BEGIN
    SELECT 
        l.seat_map
    INTO 
        seat_map
    FROM 
        layout l
    WHERE 
        l.id = param_layout_id;

    new_seat_map := jsonb_build_array();

    FOR row IN 0..param_rows_count-1 LOOP
        new_seat_map := new_seat_map || jsonb_build_array();
        FOR "col" IN 0..param_columns_count-1 LOOP
            IF row < json_array_length(seat_map) AND "col" < json_array_length(seat_map -> 0) THEN
                new_seat_map := new_seat_map || seat_map -> row::TEXT -> "col"::TEXT;
            ELSE
                new_seat_map := new_seat_map || 0;
            END IF;
        END LOOP;
    END LOOP;

    UPDATE layout
    SET seat_map = new_seat_map
    WHERE id = param_layout_id;
END; $$ LANGUAGE plpgsql;

-- calculate the number of seats in a layout
CREATE OR REPLACE FUNCTION get_seats_count(param_layout_id INT)
RETURNS INT AS $$
DECLARE
    seat_count INT;
BEGIN
    SELECT COUNT(*)
    INTO seat_count
    FROM jsonb_array_elements((SELECT seat_map FROM layout WHERE id = param_layout_id)::jsonb) AS j
    WHERE (j::jsonb ? '0') IS FALSE;

    RETURN seat_count;
END; $$ LANGUAGE plpgsql;

select get_seats_count(520);