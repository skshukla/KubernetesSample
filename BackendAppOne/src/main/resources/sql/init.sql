drop table if exists employee
;

create table if not exists employee(
 id bigserial primary key,
 name varchar(100)
)
;

--Insert Data

delete from employee;
--insert into employee(name) values ('Sachin-1');
--insert into employee(name) values ('Sachin-2');
;