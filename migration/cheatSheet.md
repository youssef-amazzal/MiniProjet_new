-----------------------
-   Brief schema
-----------------------

```sql
- country(id serial, name varchar)
- city(id serial, name varchar, country_id int)
- cinema(id uuid, name varchar, city_id int)
- movie(id serial, tmdb_id int, id_cinema uuid)
- seatType(id serial, name varchar, price float, description varchar, color varchar, id_cinema uuid)
- layout(id serial, name varchar, seat_map json, id_cinema uuid)
- theater(id serial, name varchar, id_cinema uuid, id_layout int)
- projection(id serial, id_movie int, id_tmdb int, id_theater int, id_layout int, start_time timestamp, end_time timestamp)
- profile(id uuid, first_name varchar, role char)
- ticket(id serial, id_projection int, id_seatType int, id_user uuid, price float, seat_number int, seat_row int, seat_column int, status varchar)
```
```sql
-- Layout
save_layout(name varchar, seat_map json, cinema_id uuid);
update_layout(layout_id int, name varchar, seat_map json, cinema_id uuid);
get_layouts_by_cinema(cinema_id uuid);
delete_layout(layout_id int);
get_layout_by_id(layout_id int);
update_seat_map_position(layout_id int, "row" int, "col" int, seat_type int);
update_seat_map_dimensions(layout_id int, rows_count int, columns_count int);

-- Projection
save_projection(int, int, int, int, timestamp, timestamp);
update_projection(int, int, int, int, int, timestamp, timestamp);
get_projections_by_movie(int);
get_projections_by_theater(int);
get_projections_by_cinema(int);
delete_projection(int);

-- Seat Type
save_seat_type(name VARCHAR, price FLOAT, description VARCHAR, color VARCHAR, cinema_id uuid);
update_seat_type(seat_type_id INT, name VARCHAR, price FLOAT, description VARCHAR, color VARCHAR, cinema_id uuid);
get_seat_types_by_cinema(cinema_id uuid);
delete_seat_type(seat_type_id INT);

-- Theater
get_theaters_by_cinema(int);
get_theater_by_id(int);
create_theater(varchar, int, int);
update_theater(int, varchar, int, int);
delete_theater(int);

-- Ticket
save_tickets_batch(id_projections INT[], id_seatTypes INT[], id_users INT[], prices NUMERIC[], seat_numbers INT[], seat_rows INT[], seat_columns INT[], statuses TEXT[]);
save_ticket(id_projection INT, id_seatType INT, id_user UUID, price FLOAT, seat_number INT, seat_row INT, seat_column INT, status VARCHAR);
get_tickets_by_user(user_id UUID);
get_tickets_by_projection(projection_id INT);
update_ticket(ticket_id INT, id_projection INT, id_seatType INT, id_user UUID, price FLOAT, seat_number INT, seat_row INT, seat_column INT, status VARCHAR);
delete_ticket(ticket_id INT);

-- Country
save_country(name VARCHAR);
update_country(country_id INT, name VARCHAR);
get_countries();
delete_country(country_id INT);

-- City
save_city(name VARCHAR, country_id INT);
update_city(city_id INT, name VARCHAR, country_id INT);
get_cities_by_country(country_id INT);
delete_city(city_id INT);

-- Cinema
save_cinema(name VARCHAR, city_id INT);
update_cinema(cinema_id uuid, name VARCHAR, city_id INT);
get_cinemas_by_city(city_id INT);
delete_cinema(cinema_id uuid);
get_rand_cinema();

-- seed
seed_cinema();
get_rand_cinema();

seed_country();
get_rand_country();

seed_city();
get_rand_city();
```
