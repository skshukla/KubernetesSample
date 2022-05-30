

drop table if exists public.kafka_connect_test_table
;

CREATE TABLE public.kafka_connect_test_table (
     id              SERIAL PRIMARY KEY,
     title           VARCHAR(100) not NULL,
     author          VARCHAR(100) not NULL,
     author_age	  integer not null,
     update_ts		  TIMESTAMP with time zone default now() not null
    )
;

insert into public.kafka_connect_test_table (title, author,author_age) values ('title-1', 'author-1',50)
;
insert into public.kafka_connect_test_table (title, author,author_age) values ('title-2', 'author-2',30)
;
insert into public.kafka_connect_test_table (title, author,author_age) values ('title-3', 'author-3',60)
;



drop table if exists public.user_address_tbl
;

drop table if exists public.user_tbl
;


create table user_tbl(
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) not NULL,
    last_name VARCHAR(100) not NULL,
    email VARCHAR(30) not NULL
)
;
create table user_address_tbl(
    id SERIAL PRIMARY KEY,
    address VARCHAR(100) not NULL,
    city VARCHAR(100) not NULL,
    zip INT not NULL,
    user_id INT REFERENCES user_tbl ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_user FOREIGN KEY(user_id) REFERENCES user_tbl(id)
)
;
insert into user_tbl (first_name, last_name, email) values ('Sachin-1', 'Shukla-1', 'e1@gmail.com');
insert into user_tbl (first_name, last_name, email) values ('Sachin-2', 'Shukla-2', 'e2@gmail.com');
insert into user_tbl (first_name, last_name, email) values ('Sachin-3', 'Shukla-3', 'e3@gmail.com');
;
insert into user_address_tbl (id, address, city, zip, user_id) values (101, 'A1', 'City-1', 10001, (select id from user_tbl where first_name='Sachin-1') );
insert into user_address_tbl (id, address, city, zip, user_id) values (102, 'A2', 'City-2', 10002, (select id from user_tbl where first_name='Sachin-2') );
insert into user_address_tbl (id, address, city, zip, user_id) values (103, 'A3', 'City-3', 10003, (select id from user_tbl where first_name='Sachin-3') );
;

ALTER TABLE user_tbl REPLICA IDENTITY FULL
;
ALTER TABLE user_address_tbl REPLICA IDENTITY FULL
;




