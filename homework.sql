use sakila;

-- 1a. You need a list of all the actors who have Display the first and last names
-- of all actors from the table actor

select first_name, last_name
from actor
where first_name is not null and
last_name is not null;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select concat(first_name,' ', last_name) as 'Actor Name'
from actor;