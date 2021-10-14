

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



