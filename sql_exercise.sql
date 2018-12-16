--1a. Display the first and last names of all actors from the table actor.

SELECT first_name,last_name
FROM actor;

--1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

SELECT UPPER(CONCAT(first_name," ",last_name)) AS "Actor Name"
FROM actor;

--2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT actor_id,first_name,last_name
FROM actor
WHERE first_name= "Joe";
--2b. Find all actors whose last name contain the letters GEN:

SELECT actor_id,last_name
FROM actor
WHERE last_name LIKE "%gen%";
--2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

SELECT actor_id,first_name, last_name
FROM actor
WHERE last_name LIKE "%li%"
ORDER BY last_name,first_name;
--2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id,country
FROM country
WHERE country IN ("Afghanistan","Bangladesh","China");
--3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

ALTER TABLE actor
ADD COLUMN description BLOB NOT NULL;
--3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.

ALTER TABLE actor
DROP COLUMN description;
--4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name,COUNT(last_name) AS num_of_actors
FROM actor
GROUP BY last_name;
--4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT last_name,COUNT(last_name) AS num_of_actors
FROM actor
GROUP BY last_name
HAVING COUNT(last_name)>1;
--4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

UPDATE actor
SET first_name= "Harpo"
WHERE first_name="Groucho"
AND last_name= "Williams";
--4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

UPDATE actor
SET first_name= "Groucho"
WHERE first_name="Harpo"
AND last_name= "Williams";
--5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

SHOW CREATE Table address;

--6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

SELECT CONCAT(staff.first_name," ",staff.last_name) AS Name, address.address As address
FROM staff
Join address 
ON address.address_id=staff.address_id
Group BY staff.last_name;

--6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

SELECT CONCAT(staff.first_name," ",staff.last_name) AS Name, SUM(payment.amount) As Total
FROM payment
JOIN staff
ON staff.staff_id=payment.staff_id
WHERE payment_date LIKE "2005-08-%"
Group BY staff.last_name;

--6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT film.title AS Title, COUNT(film_actor.actor_id) As Number_of_Actors
FROM film_actor
INNER Join film
ON film.film_id=film_actor.film_id
GROUP BY film.title;

--6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT film.title, COUNT(inventory.film_id) AS Number_of_Copies
from inventory
JOIN film
ON film.film_id= inventory.film_id
WHERE film.title= "Hunchback Impossible";

--6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT customer.first_name,customer.last_name,SUM(payment.amount) AS "Total Amount Paid"
FROM customer
JOIN payment
ON payment.customer_id=customer.customer_id
Group BY customer.last_name
ORDER BY customer.last_name ASC;

--7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT title,language_id
FROM film
WHERE language_id IN (
SELECT language_id
FROM language
WHERE name= "English"
)
HAVING title LIKE "K%"
OR title LIKE "Q%";
--7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT first_name,last_name
FROM actor
WHERE actor_id IN (
SELECT film_id
FROM film_actor
WHERE film_id IN  (
SELECT film_id
FROM film
WHERE title ="Alone Trip"));

--7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT customer.first_name,customer.last_name,customer.email
FROM customer
JOIN address
ON address.address_id=customer.address_id
JOIN city
ON city.city_id= address.city_id
JOIN country 
ON country.country_id = city.country_id
WHERE country="Canada";

--7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT title As "Family films"
FROM film
WHERE film_id IN (
SELECT film_id
FROM film_category
WHERE category_id IN (
SELECT category_id
FROM category
WHERE name = "Family"))
Group by title;

--7e. Display the most frequently rented movies in descending order.

SELECT title,COUNT(title) AS "Frequently rented films"
FROM film 
JOIN inventory 
ON film.film_id = inventory.film_id
JOIN rental 
ON inventory.inventory_id = rental.inventory_id
GROUP BY film.title
ORDER BY COUNT(title) DESC;

--7f. Write a query to display how much business, in dollars, each store brought in.

SELECT s.store_id,SUM(amount) AS Total
FROM store s
JOIN inventory i
ON i.store_id=s.store_id
JOIN rental r
ON r.inventory_id=i.inventory_id
JOIN payment p
ON p.rental_id=r.rental_id
GROUP BY store_id
ORDER BY SUM(amount);
--7g. Write a query to display for each store its store ID, city, and country.

SELECT s.store_id,c.city,y.country
FROM store s
JOIN address a
ON a.address_id=s.address_id
JOIN city c
ON c.city_id=a.city_id
JOIN country y
ON y.country_id=c.country_id;
--7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT c.name AS Genre,SUM(amount) AS "Gross revenue"
FROM category c
JOIN film_category f
ON f.category_id=c.category_id
JOIN inventory i
ON i.film_id=f.film_id
JOIN rental r
ON r.inventory_id=i.inventory_id
JOIN payment p
ON p.rental_id=r.rental_id
Group BY c.name
ORDER BY SUM(amount) DESC
LIMIT 5;
--8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_five_genres AS
SELECT c.name AS Genre,SUM(amount) AS "Gross revenue"
FROM category c
JOIN film_category f
ON f.category_id=c.category_id
JOIN inventory i
ON i.film_id=f.film_id
JOIN rental r
ON r.inventory_id=i.inventory_id
JOIN payment p
ON p.rental_id=r.rental_id
Group BY c.name
ORDER BY SUM(amount) DESC
LIMIT 5;
--8b. How would you display the view that you created in 8a?

SELECT * FROM sakila.top_five_genres;

--8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW IF EXISTS sakila.top_five_genres;