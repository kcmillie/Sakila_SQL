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

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
-- What is one query would you use to obtain this information?
select actor_id, first_name, last_name
from actor
where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN
select actor_id, first_name, last_name
from actor
where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time,
-- order the rows by last name and first name, in that order:
select actor_id, first_name, last_name
from actor
where last_name like '%LI%'
order by last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country
from country
where country IN ('Afghanistan', 'Bangladesh','China')