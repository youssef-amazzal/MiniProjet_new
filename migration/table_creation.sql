-- Layout
drop function if exists save_layout(name varchar, seat_map json, cinema_id uuid);
drop function if exists update_layout(layout_id int, name varchar, seat_map json, cinema_id uuid);
drop function if exists get_layouts_by_cinema(cinema_id uuid);
drop function if exists delete_layout(layout_id int);
drop function if exists get_layout_by_id(layout_id int);
drop function if exists update_seat_map_position(layout_id int, "row" int, "col" int, seat_type int);
drop function if exists update_seat_map_dimensions(layout_id int, rows_count int, columns_count int);

-- Projection
drop function if exists save_projection(int, int, int, timestamp, timestamp);
drop function if exists update_projection(int, int, int, int, timestamp, timestamp);
drop function if exists get_projections_by_movie(int);
drop function if exists get_projections_by_theater(int);
drop function if exists get_projections_by_cinema(int);
drop function if exists delete_projection(int);

-- Seat Type
drop function if exists save_seat_type(name VARCHAR, price FLOAT, description VARCHAR, color VARCHAR, cinema_id uuid);
drop function if exists update_seat_type(seat_type_id INT, name VARCHAR, price FLOAT, description VARCHAR, color VARCHAR, cinema_id uuid);
drop function if exists get_seat_types_by_cinema(cinema_id uuid);
drop function if exists delete_seat_type(seat_type_id INT);

-- Theater
drop function if exists get_theaters_by_cinema(int);
drop function if exists get_theater_by_id(int);
drop function if exists create_theater(varchar, int, int);
drop function if exists update_theater(int, varchar, int, int);
drop function if exists delete_theater(int);

-- Ticket
drop function if exists save_tickets_batch(id_projections INT[], id_seatTypes INT[], id_users INT[], prices NUMERIC[], seat_numbers INT[], seat_rows INT[], seat_columns INT[], statuses TEXT[]);
drop function if exists save_ticket(id_projection INT, id_seatType INT, id_user UUID, price FLOAT, seat_number INT, seat_row INT, seat_column INT, status VARCHAR);
drop function if exists get_tickets_by_user(user_id UUID);
drop function if exists get_tickets_by_projection(projection_id INT);
drop function if exists update_ticket(ticket_id INT, id_projection INT, id_seatType INT, id_user UUID, price FLOAT, seat_number INT, seat_row INT, seat_column INT, status VARCHAR);
drop function if exists delete_ticket(ticket_id INT);

-- Country
drop function if exists save_country(name VARCHAR);
drop function if exists update_country(country_id INT, name VARCHAR);
drop function if exists get_countries();
drop function if exists delete_country(country_id INT);

-- City
drop function if exists save_city(name VARCHAR, country_id INT);
drop function if exists update_city(city_id INT, name VARCHAR, country_id INT);
drop function if exists get_cities_by_country(country_id INT);
drop function if exists delete_city(city_id INT);

-- Cinema
drop function if exists save_cinema(name VARCHAR, city_id INT);
drop function if exists update_cinema(cinema_id uuid, name VARCHAR, city_id INT);
drop function if exists get_cinemas_by_city(city_id INT);
drop function if exists delete_cinema(cinema_id uuid);
drop function if exists get_all_cinemas();

-- Seed
drop function if exists get_rand_cinema();
drop function if exists seed_cinema(n integer);

drop function if exists get_rand_city();
drop function if exists seed_city(n integer);

drop function if exists get_rand_country();
drop function if exists seed_country(n integer);

drop table if exists ticket;
drop table if exists projection;
drop table if exists theater;
drop table if exists layout;
drop table if exists seatType;
drop table if exists movie;
drop table if exists cinema;
drop table if exists city;
drop table if exists country;
drop table if exists profile;


create table country(
    id serial primary key,
    name varchar(50) not null
);

create table city(
    id serial primary key,
    name varchar(50) not null,
    country_id int not null references country(id)
);

create table cinema(
    id uuid primary key,
    name varchar(50) not null,
    city_id int not null references city(id)
);

create table movie(
    id serial primary key,
    tmdb_id int not null,
    id_cinema uuid not null references cinema(id)
);

create table seatType(
    id serial primary key,
    name varchar(50) not null,
    price float not null,
    description varchar(100),
    color varchar(10),
    id_cinema uuid not null references cinema(id)
);

create table layout(
    id serial primary key,
    name varchar(50) not null,
    seat_map json,
    id_cinema uuid not null references cinema(id)
);

create table theater(
    id serial primary key,
    name varchar(50) not null,
    id_cinema uuid not null references cinema(id),
    id_layout int not null references layout(id)
);

create table projection(
    id serial primary key,
    id_movie int,
    id_tmdb int,
    id_theater int not null references theater(id),
    id_layout int not null references layout(id),
    start_time timestamp not null,
    end_time timestamp not null,
    constraint fk_movie_projection foreign key (id_movie) references movie(id) on delete cascade
);

create table profile(
    id uuid primary key,
    first_name varchar(50) not null,
    role char(1) not null default 'U' check ( role in ('U', 'C', 'A') ),
    constraint fk_user_profile foreign key (id) references auth.users (id) on delete cascade
);

create table ticket(
    id serial primary key,
    id_projection int not null references projection(id),
    id_seatType int not null references seatType(id),
    id_user uuid not null references profile(id),
    price float not null,
    seat_number int not null,
    seat_row int not null,
    seat_column int not null,
    status varchar(50) not null
);

