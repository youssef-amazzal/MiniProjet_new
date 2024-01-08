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
 *  Auth trigger
 **************************************/
drop trigger if exists on_auth_user_profile_created on auth.users;
drop trigger if exists on_auth_user_cinema_created on auth.users;

drop function if exists public.handle_new_user();
drop function if exists public.handle_new_cinema();

-- inserts a row into public.profiles
create function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
    if lower(new.raw_user_meta_data ->> 'role') = 'u' then
        insert into public.profile (id, first_name, role)
        values (new.id, new.raw_user_meta_data ->> 'first_name', new.raw_user_meta_data ->> 'role');
    end if;
    return new;
end;
$$;

create function public.handle_new_cinema()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
    if lower(new.raw_user_meta_data ->> 'role') = 'c' then
        insert into public.cinema (id, name, city_id)
        values (new.id, new.raw_user_meta_data ->> 'name', new.raw_user_meta_data ->> 'city_id');
    end if;
    return new;
end;
$$;

create trigger on_auth_user_profile_created
after insert on auth.users
for each row
execute procedure public.handle_new_user();

create trigger on_auth_user_cinema_created
after insert on auth.users
for each row
execute procedure public.handle_new_cinema();