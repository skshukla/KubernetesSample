
-- drop table xyz;

create table abcd(
    id SERIAL PRIMARY KEY,
    name varchar(100),
    update_ts timestamp default current_timestamp
);

--  insert into abcd(name) values('Sachin-1');
-- insert into xyz(name) values('Sachin-2');
-- insert into xyz(name) values('Sachin-3');
