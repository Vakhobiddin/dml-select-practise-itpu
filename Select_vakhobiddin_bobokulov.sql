-- First version
CREATE VIEW StaffRevenue2017 AS
SELECT
    s.staff_id,
    s.store_id,
    SUM(p.amount) AS revenue
FROM payment p
         JOIN staff s ON p.staff_id = s.staff_id
WHERE EXTRACT(YEAR FROM p.payment_date) = 2017
GROUP BY s.staff_id, s.store_id;

SELECT
    s.staff_id,
    s.first_name,
    s.last_name,
    s.store_id,
    sr.revenue
FROM StaffRevenue2017 sr
         JOIN staff s ON sr.staff_id = s.staff_id
WHERE (sr.store_id, sr.revenue) IN (
    SELECT store_id, MAX(revenue) AS max_revenue
    FROM StaffRevenue2017
    GROUP BY store_id
)
ORDER BY s.store_id;

-- second version
WITH StaffRevenue AS (
    SELECT
        s.staff_id,
        s.store_id,
        SUM(p.amount) AS revenue
    FROM payment p
             JOIN staff s ON p.staff_id = s.staff_id
    WHERE EXTRACT(YEAR FROM p.payment_date) = 2017
    GROUP BY s.staff_id, s.store_id
),
     MaxStoreRevenues AS (
         SELECT
             store_id,
             MAX(revenue) OVER (PARTITION BY store_id) AS max_revenue
         FROM StaffRevenue
     )
SELECT
    s.staff_id,
    s.first_name,
    s.last_name,
    s.store_id,
    sr.revenue
FROM StaffRevenue sr
         JOIN MaxStoreRevenues mr ON sr.store_id = mr.store_id
         JOIN staff s ON sr.staff_id = s.staff_id
WHERE sr.revenue = mr.max_revenue
ORDER BY s.store_id;


--Which five movies were rented more than the others, and what is the expected age of the audience for these movies?

-- First version
SELECT
    f.film_id,
    COUNT(r.rental_id) AS rental_count,
    f.title,
    CASE f.rating
        WHEN 'G' THEN 'ALL AGES'
        WHEN 'PG' THEN '7+'
        WHEN 'PG-13' THEN '13+'
        WHEN 'NC-17' THEN '18+'
        ELSE 'UNKNOWN'
        END AS Expected_age
FROM film f
         JOIN inventory i ON f.film_id = i.film_id
         JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.film_id, f.title
ORDER BY rental_count DESC
LIMIT 5;



--Which actors/actresses didn't act for a longer period of time than the others?

WITH ActorActivity AS (
    SELECT
        actor.actor_id,
        first_name,
        last_name,
        MAX(film.release_year) AS most_recent,
        MIN(film.release_year) AS least_recent
    FROM actor
             JOIN film_actor ON actor.actor_id = film_actor.actor_id
             JOIN film ON film_actor.film_id = film.film_id
    GROUP BY actor.actor_id, actor.first_name, actor.last_name
)
SELECT
    actor_id,
    first_name,
    last_name,
    most_recent - least_recent AS career_period,
    most_recent as last_film_year
FROM ActorActivity order by career_period;


CREATE VIEW ActorCareerInfo AS
SELECT
    actor.actor_id,
    actor.first_name,
    actor.last_name,
    MAX(film.release_year) - MIN(film.release_year) AS career_period,
    MAX(film.release_year) AS last_film_year
FROM actor
         JOIN film_actor ON actor.actor_id = film_actor.actor_id
         JOIN film ON film_actor.film_id = film.film_id
GROUP BY actor.actor_id, actor.first_name, actor.last_name;

SELECT
    actor_id,
    first_name,
    last_name,
    career_period,
    last_film_year
FROM ActorCareerInfo
ORDER BY career_period;






	
