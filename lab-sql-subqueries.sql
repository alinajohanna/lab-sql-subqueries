# LAB | SQL Subqueries
-- Use advanced SQL queries (e.g., subqueries, window functions) to perform more complex data manipulations and analysis.
#Before this starting this lab, you should have learnt about:
#- SELECT, FROM, ORDER BY, LIMIT, WHERE, GROUP BY, and HAVING clauses. DISTINCT, AS keywords.
#- Built-in SQL functions such as COUNT, MAX, MIN, AVG, ROUND, DATEDIFF, or DATE_FORMAT.
#- JOIN to combine data from multiple tables.
#- Subqueries
 
## Challenge

#Write SQL queries to perform the following tasks using the Sakila database:
USE sakila;

#1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT COUNT(i.inventory_id) AS "copies_of_hunchback_impossible"
FROM inventory i
JOIN film f ON f.film_id = i.film_id
WHERE f.title = "Hunchback Impossible";

#2. List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT title, length
FROM film
WHERE length > (
	SELECT avg(length) AS 'average_length'
	FROM film
);

#3. Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT film_id
FROM film
WHERE title = "Alone Trip";

SELECT fa.actor_id, a.first_name, a.last_name
FROM film_actor fa
LEFT JOIN actor a ON a.actor_id = fa.actor_id
WHERE film_id IN (
	SELECT f.film_id
	FROM film f
	WHERE f.title = "Alone Trip"
);

#**Bonus**:

#4. Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films. 
SELECT c.name AS "category", f.title AS "film_title"
FROM category c
LEFT JOIN film_category fc ON fc.category_id = c.category_id
LEFT JOIN film f ON f.film_id = fc.film_id
WHERE c.name = "Family";

#5. Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.
SELECT cu.first_name, cu.email, co.country_id
FROM customer cu
LEFT JOIN address a ON a.address_id = cu.address_id
LEFT JOIN city ci ON ci.city_id = a.city_id
LEFT JOIN country co ON co.country_id = ci.country_id
WHERE co.country = "Canada";

-- or using a subquery:
SELECT full_customer_info.first_name, full_customer_info.email 
FROM (
	SELECT cu.first_name, cu.email, co.country_id, co.country
    FROM country co
    RIGHT JOIN city ci ON co.country_id = ci.country_id
    RIGHT JOIN address a ON ci.city_id = a.city_id
	RIGHT JOIN customer cu ON a.address_id = cu.address_id) full_customer_info
WHERE full_customer_info.country = "Canada";
    
#6. Determine which films were starred by the most prolific actor in the Sakila database. 
# A prolific actor is defined as the actor who has acted in the most number of films. 
#First, you will need to find the most prolific actor 
# and then use that actor_id to find the different films that he or she starred in.

SELECT f.title
FROM film_actor fa
JOIN film f ON f.film_id = fa.film_id
WHERE actor_id = (
	SELECT actor_id
	FROM film_actor
	GROUP BY 1
	ORDER BY count(film_id) DESC
	LIMIT 1);

-- prolific actor and count of films
SELECT actor_id, count(film_id)
	FROM film_actor
	GROUP BY 1
	ORDER BY count(film_id) DESC
	LIMIT 1;

#7. Find the films rented by the most profitable customer in the Sakila database. 
#You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.
SELECT f.title
FROM rental r
LEFT JOIN inventory i ON i.inventory_id = r.inventory_id
LEFT JOIN film f ON f.film_id = i.film_id
WHERE r.customer_id = (
	SELECT p.customer_id
	FROM payment p
	GROUP BY 1
	ORDER BY sum(p.amount) DESC
	LIMIT 1
    );

-- gives customer id and count of rentals to check on previous query
SELECT p.customer_id, count(p.rental_id)
FROM payment p
JOIN customer c ON c.customer_id = p.customer_id
GROUP BY 1
ORDER BY sum(p.amount) DESC
LIMIT 1;

8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.
