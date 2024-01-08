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
 *  Ticket management
 **************************************/

-- create a batch of tickets of multiple seats and multiple seat types
drop function if exists save_tickets_batch(id_projections INT[], id_seatTypes INT[], id_users INT[], prices NUMERIC[], seat_numbers INT[], seat_rows INT[], seat_columns INT[], statuses TEXT[]);
CREATE OR REPLACE FUNCTION save_tickets_batch(id_projections INT[], id_seatTypes INT[], id_users INT[], prices NUMERIC[], seat_numbers INT[], seat_rows INT[], seat_columns INT[], statuses TEXT[])
RETURNS VOID AS $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..array_length(id_projections, 1)
    LOOP
        INSERT INTO ticket (id_projection, id_seatType, id_user, price, seat_number, seat_row, seat_column, status)
        VALUES (id_projections[i], id_seatTypes[i], id_users[i], prices[i], seat_numbers[i], seat_rows[i], seat_columns[i], statuses[i]);
    END LOOP;
END; $$ LANGUAGE plpgsql;

-- create a new ticket
drop function if exists save_ticket(par_projection_id INT, par_seatType_id INT, par_user_id UUID, par_price FLOAT, par_seat_number INT, par_seat_row INT, par_seat_column INT, par_status VARCHAR);
CREATE OR REPLACE FUNCTION save_ticket(par_projection_id INT, par_seatType_id INT, par_user_id UUID, par_price FLOAT, par_seat_number INT, par_seat_row INT, par_seat_column INT, par_status VARCHAR)
RETURNS VOID AS $$
BEGIN
    INSERT INTO ticket (id_projection, id_seatType, id_user, price, seat_number, seat_row, seat_column, status)
    VALUES (par_projection_id, par_seatType_id, par_user_id, par_price, par_seat_number, par_seat_row, par_seat_column, par_status);
END; $$ LANGUAGE plpgsql;

-- select all tickets of a user
drop function if exists get_tickets_by_user(par_user_id UUID);
CREATE OR REPLACE FUNCTION get_tickets_by_user(par_user_id UUID)
RETURNS SETOF ticket AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ticket WHERE id_user = par_user_id;
END; $$ LANGUAGE plpgsql;

-- select all tickets of a projection
drop function if exists get_tickets_by_projection(par_projection_id INT);
CREATE OR REPLACE FUNCTION get_tickets_by_projection(par_projection_id INT)
RETURNS SETOF ticket AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ticket WHERE id_projection = par_projection_id;
END; $$ LANGUAGE plpgsql;

-- update a ticket
drop function if exists update_ticket(par_ticket_id INT, par_projection_id INT, par_seatType_id INT, par_user_id UUID, par_price FLOAT, par_seat_number INT, par_seat_row INT, par_seat_column INT, par_status VARCHAR);
CREATE OR REPLACE FUNCTION update_ticket(par_ticket_id INT, par_projection_id INT, par_seatType_id INT, par_user_id UUID, par_price FLOAT, par_seat_number INT, par_seat_row INT, par_seat_column INT, par_status VARCHAR)
RETURNS VOID AS $$
BEGIN
    UPDATE ticket
    SET 
        id_projection = par_projection_id,
        id_seatType = par_seatType_id,
        id_user = par_user_id,
        price = par_price,
        seat_number = par_seat_number,
        seat_row = par_seat_row,
        seat_column = par_seat_column,
        status = par_status
    WHERE id = par_ticket_id;
END; $$ LANGUAGE plpgsql;

-- delete a ticket
drop function if exists delete_ticket(par_ticket_id INT);
CREATE OR REPLACE FUNCTION delete_ticket(par_ticket_id INT)
RETURNS VOID AS $$
BEGIN
    DELETE FROM ticket
    WHERE id = par_ticket_id;
END; $$ LANGUAGE plpgsql;