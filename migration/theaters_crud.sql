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
 *  Theaters management
 **************************************/

-- Get all theaters in a cinema
CREATE OR REPLACE FUNCTION get_theaters_by_cinema(par_cinema_id uuid)
RETURNS TABLE(id int, name varchar, id_cinema uuid, id_layout int) AS $$
BEGIN
    RETURN QUERY SELECT t.id, t.name, t.id_cinema, t.id_layout FROM theater t WHERE t.id_cinema = par_cinema_id;
END;
$$ LANGUAGE plpgsql;

select * from get_theaters_by_cinema('99bd76cd-a0bf-4ebb-be55-94791ac9c581');

-- Get a theater by id
CREATE OR REPLACE FUNCTION get_theater_by_id(par_theater_id int)
RETURNS TABLE(id int, name varchar, id_cinema uuid, id_layout int) AS $$
BEGIN
    RETURN QUERY SELECT id, name, id_cinema, id_layout FROM theater WHERE id = par_theater_id;
END;
$$ LANGUAGE plpgsql;

-- Create a theater
drop function if exists save_theater(par_theater_name varchar, par_cinema_id uuid, par_layout_id int);
CREATE OR REPLACE FUNCTION save_theater(par_theater_name varchar, par_cinema_id uuid, par_layout_id int)
RETURNS void
AS $$
BEGIN
    INSERT INTO theater(name, id_cinema, id_layout) VALUES(par_theater_name, par_cinema_id, par_layout_id);
END;
$$ LANGUAGE plpgsql;

-- Update a theater
drop function if exists update_theater(par_theater_id int, par_theater_name varchar, par_cinema_id uuid, par_layout_id int);
CREATE OR REPLACE FUNCTION update_theater(par_theater_id int, par_theater_name varchar, par_cinema_id uuid, par_layout_id int)
RETURNS TABLE(id int, name varchar, id_cinema uuid, id_layout int) AS $$
BEGIN
    RETURN QUERY UPDATE theater SET name = par_theater_name, id_cinema = par_cinema_id, id_layout = par_layout_id WHERE id = par_theater_id RETURNING id, name, id_cinema, id_layout;
END;
$$ LANGUAGE plpgsql;

-- Delete a theater
drop function if exists delete_theater(par_theater_id int);
CREATE OR REPLACE FUNCTION delete_theater(par_theater_id int)
RETURNS TABLE(id int, name varchar, id_cinema uuid, id_layout int) AS $$
BEGIN
    RETURN QUERY DELETE FROM theater WHERE id = par_theater_id RETURNING id, name, id_cinema, id_layout;
END;
$$ LANGUAGE plpgsql;



