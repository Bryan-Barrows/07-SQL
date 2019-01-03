USE sakila;

-- display first and last names of all actors
SELECT first_name, last_name FROM actor;

-- display first and last names of each actor in a single column in upper case letters; name column ACTOR NAME
SELECT CONCAT(first_name," ", last_name) as "Actor Name" FROM actor;

-- find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe"
SELECT actor_id, first_name, last_name FROM actor WHERE first_name="Joe";

-- find Find all actors whose last name contain the letters GEN
SELECT * FROM actor WHERE last_name LIKE '%gen%';

-- Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name FROM actor WHERE last_name LIKE '%LI%';

-- Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China
SELECT country_id, country FROM country WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- create a column in the table actor named description
ALTER TABLE actor ADD description blob;

-- Delete the description column
ALTER TABLE actor DROP COLUMN description;

-- List the last names of actors, as well as how many actors have that last name
SELECT last_name, Count(*) FROM actor GROUP BY last_name;

-- List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, Count(*) AS last_name_frequency FROM actor GROUP BY last_name HAVING last_name_frequency >= 2;

-- The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record
UPDATE actor SET first_name = "HARPO" WHERE first_name = "GROUCHO" and last_name="WILLIAMS";

-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO
UPDATE actor SET first_name = "GROUCHO" WHERE actor_id = 172;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
DESCRIBE sakila.address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- 		Use the tables staff and address
SELECT first_name, last_name, address
FROM staff
LEFT JOIN address ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- 		Use tables staff and payment
SELECT payment.staff_id, sum(amount)
FROM payment
LEFT JOIN staff ON payment.staff_id = staff.staff_id
GROUP BY payment.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT title, count(actor_id)
FROM film
INNER JOIN film_actor on film.film_id = film_actor.film_id
GROUP BY film.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT title, count(inventory_id) AS '# of Copies'
FROM film
INNER JOIN inventory USING(film_id)
WHERE title = "Hunchback Impossible"
GROUP BY title;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- 		List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, sum(p.amount) AS 'Total Amount Paid'
FROM payment AS p
JOIN customer AS c on p.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name;

-- 7a. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title FROM film WHERE title LIKE 'K%' OR title LIKE 'Q%' AND language_id IN
(SELECT language_id from language WHERE name = 'English');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
SELECT actor_id
FROM film_actor
WHERE film_id =
(
	SELECT film_id
    FROM film
    WHERE title = "Alone Trip"
)
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- 		Use joins to retrieve this information
SELECT cus.first_name, cus.last_name, cus.email
FROM customer cus
JOIN address a
ON (cus.address_id = a.address_id)
JOIN city cty
ON (cty.city_id = a.city_id)
JOIN country ctr
ON (ctr.country_id = cty.country_id)
WHERE ctr.country = 'Canada';
    
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- 		Identify all movies categorized as family films.
SELECT title, description FROM film
WHERE film_id IN 
(
SELECT film_id FROM film_category
WHERE category_id IN
(
SELECT category_id FROM category
WHERE name = "Family"
));

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(rental_id) AS 'Times Rented'
FROM rental r
JOIN inventory i 
ON (r.inventory_id = i.inventory_id)
JOIN film f
ON (i.film_id = f.film_id)
GROUP BY f.title
ORDER BY COUNT(rental_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(amount) as 'Revenue'
FROM payment p
JOIN rental r
ON (p.rental_id = r.rental_id)
JOIN inventory i 
ON (i.inventory_id = r.inventory_id)
JOIN store s
ON (s.store_id = i.store_id)
GROUP BY s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, cty.city, ctr.country 
FROM store s 
JOIN address a 
ON (s.address_id = a.address_id)
JOIN city cty
ON (a.city_id = cty.city_id)
JOIN country ctr
ON (cty.country_id = ctr.country_id);

-- 7h. List the top five genres in gross revenue in descending order. 
-- 	(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name AS 'Genre', SUM(p.amount) AS 'Gross Revenue'
FROM category c
JOIN film_category fc
ON (c.category_id = fc.category_id)
JOIN inventory i 
ON (fc.film_id = i.film_id)
JOIN rental r 
ON (i.inventory_id = r.inventory_id)
JOIN payment p
ON (r.rental_id = p.rental_id)
GROUP BY c.name
ORDER BY SUM(p.amount) DESC LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- 		Use the solution from the problem above to create a view.
CREATE VIEW genre_revenue AS
SELECT c.name AS 'Genre', SUM(p.amount) AS 'Gross'
FROM category c
JOIN film_category fc
ON (c.category_id = fc.category_id)
JOIN inventory i
ON (fc.film_id = i.film_id)
JOIN rental r
ON (i.inventory_id = r.inventory_id)
JOIN payment p
ON (r.rental_id = p.rental_id)
GROUP BY c.name ORDER BY Gross DESC Limit 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM genre_revenue;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW genre_revenue;
