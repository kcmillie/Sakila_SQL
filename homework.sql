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

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name.
-- Hint: you will need to specify the data type.
alter table actor
add middle_name varchar(50) AFTER first_name;

-- 3b. You realize that some of these actors have tremendously long last names.
-- Change the data type of the middle_name column to blobs.
alter table actor
modify column middle_name blob;

-- 3c. Now delete the middle_name column.
alter table actor
drop column middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name)
from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name,
-- but only for names that are shared by at least two actors
select last_name, count(last_name)
from actor
group by last_name
having count(last_name) > 2;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as
-- GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
where first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO.
-- It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor
-- is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is
-- exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY
-- ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)

UPDATE actor
SET first_name =
    CASE
        WHEN first_name = 'HARPO'
        THEN 'GROUCHO'
        ELSE 'MUCHO GROUCHO'
    END
WHERE actor_id = 172;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT first_name, last_name, address
FROM staff as s
JOIN address as a
ON (s.address_id = a.address_id);

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT first_name, last_name, sum(amount) as total_amount
FROM staff as s
JOIN payment as p
ON (s.staff_id = p.staff_id)
GROUP BY first_name, last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT title, count(actor_id)
FROM film AS f
INNER JOIN film_actor AS fa
ON f.film_id = fa.film_id
GROUP BY title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT title, count(title)
FROM film AS f
JOIN inventory AS i
ON (f.film_id = i.film_id)
WHERE title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer.
-- List the customers alphabetically by last name:
SELECT first_name, last_name, sum(amount) as 'total_paid'
FROM customer AS c
JOIN payment AS p
ON (c.customer_id = p.customer_id)
GROUP BY first_name, last_name;

 -- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence,
 -- films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies
 -- starting with the letters K and Q whose language is English.

SELECT title
FROM film AS f
JOIN language AS l
ON (f.language_id = l.language_id)
WHERE (title LIKE 'K%' OR title LIKE 'Q%')
AND name = 'English';

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor AS a
JOIN (
    SELECT actor_id
    FROM film as f
    JOIN film_actor AS fa
    ON(f.film_id = fa.film_id)
    WHERE title = 'Alone Trip'
) AS B
ON (a.actor_id = B.actor_id);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names
-- and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email
FROM customer AS cu
JOIN (
    SELECT address_id
    from address as a
    JOIN (
        SELECT city_id
        FROM city AS ci
        JOIN (
            SELECT country_id
            FROM country
            WHERE country = 'Canada'
        ) AS co
    ON (ci.country_id = co.country_id)
    ) as cid
    ON a.city_id = cid.city_id
)
AS co
ON cu.address_id = co.address_id;

 -- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
-- Identify all movies categorized as famiy films.

select title
from film as f
join(
    select film_id
    from film_category as fc
    join (
        select category_id
        from category
        where name = 'Family'
    ) as c
    on fc.category_id = c.category_id
) as fid
ON f.film_id = fid.film_id;

-- 7e. Display the most frequently rented movies in descending order.

select title, total_rented
from film as f
join (
    select film_id, count(film_id) as total_rented
    from rental as r
    join inventory as i
    on (r.inventory_id = i.inventory_id)
    group by film_id
) as r
on (f.film_id = r.film_id)
order by total_rented desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

select store_id, concat('$', format(total_business, 2))
from staff as s
join (
    select staff_id, sum(amount) as total_business
    from payment
    group by staff_id
) as p
on s.staff_id = p.staff_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select store_id, city, country
from store as s
join (
    select address_id, city, country
    from address as a
    join (
        select city_id, city, country
        from city as ci
        join country as co
        on ci.country_id = co.country_id
    ) as c
    on a.city_id = c.city_id
) as c
on s.address_id = c.address_id;


-- 7h. List the top five genres in gross revenue in descending order.
 -- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select name, concat('$', format(Amount,2)) as gross_revenue
from category as c
join (
    select category_id, sum(total) as Amount
    from film_category as fc
    join (
        select film_id, sum(amount) as total
        from inventory as i
        join (
            select inventory_id, amount
            from rental as r
            join payment as p
            on r.rental_id = p.rental_id
        ) as p
        on i.inventory_id = p.inventory_id
        group by film_id
    ) as t
    on fc.film_id = t.film_id
    group by category_id
) as a
on c.category_id = a.category_id
order by Amount desc
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the
-- Top five genres by gross revenue. Use the solution from the problem above to create a view.
-- If you haven't solved 7h, you can substitute another query to create a view.
create view top_five_genres as
select name, concat('$', format(Amount,2)) as gross_revenue
from category as c
join (
    select category_id, sum(total
    ) as Amount
    from film_category as fc
    join (
        select film_id, sum(amount) as total
        from inventory as i
        join (
            select inventory_id, amount
            from rental as r
            join payment as p
            on r.rental_id = p.rental_id
        ) as p
        on i.inventory_id = p.inventory_id
        group by film_id
    ) as t
    on fc.film_id = t.film_id
    group by category_id
) as a
on c.category_id = a.category_id
order by Amount desc
limit 5;

-- 8b. How would you display the view that you created in 8a?
select * from top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top_five_genres;







