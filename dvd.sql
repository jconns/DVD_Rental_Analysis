### customer segmentation: Most Rented DVDs per Customer ###
select customer.customer_id, customer.email, customer.first_name, customer.last_name, count(rental.rental_id) as rental_count
from rental
join customer on rental.customer_id = customer.customer_id
group by customer.customer_id, customer.first_name, customer.last_name
order by rental_count desc;

### Revenue per customer
select customer.email, customer.customer_id, sum(payment.amount) as total_revenue
from customer
join payment on payment.customer_id = customer.customer_id
group by customer.customer_id, customer.email
order by total_revenue desc

### identify top actors toward our most valued customer ###
SELECT cu.email, act.last_name, count(act.last_name)
FROM customer as cu
JOIN rental as ren ON cu.customer_id = ren.customer_id
JOIN inventory as inv ON ren.inventory_id = inv.inventory_id
JOIN film_actor as fil ON inv.film_id = fil.film_id
JOIN actor as act ON act.actor_id = fil.actor_id
where cu.email = 'eleanor.hunt@sakilacustomer.org'
group by cu.email,act.last_name
order by count desc

Select x.email,x.last_name,x.count from (
        SELECT cu.email, act.last_name, count(act.last_name)
        ,row_number() over(partition by email order by COUNT(act.last_name) DESC )
          FROM customer as cu
          JOIN rental as ren ON cu.customer_id = ren.customer_id
          JOIN inventory as inv ON ren.inventory_id = inv.inventory_id
          JOIN film_actor as fil ON inv.film_id = fil.film_id
          JOIN actor as act ON act.actor_id = fil.actor_id
	where cu.email = 'eleanor.hunt@sakilacustomer.org'
          group by cu.email,act.last_name
          ) as x 
         where row_number = 1
         ORDER BY x.count DESC;
		 
### inventory management ###
### outstanding liability / past due 
select rental.rental_id, film.film_id, rental.customer_id,
    film.rental_rate AS film_rental_rate,
    rental.return_date IS NULL AS is_unreturned,
    film.rental_rate AS cost_if_unreturned,
    (select sum (film.rental_rate)
     from rental
     cross join film
     where rental.return_date is NULL) as total_outstanding_liability
from rental
cross join film
where rental.return_date is NULL;

### past due DVDs ###
select rental.rental_id, film.film_id,
    rental.customer_id,
    film.rental_rate as film_rental_rate,
    film.rental_rate as cost_if_past_due
from rental
join film on rental.inventory_id = film.film_id
where rental.return_date is not NULL
    and rental.return_date > rental.return_date + INTERVAL '3 days';

### movie genre analysis
select category.name as genre, count(payment.payment_id) as rental_count
from category
left join film_category on category.category_id = film_category.category_id
left join film on film_category.film_id = film.film_id
left join inventory on film.film_id = inventory.film_id
left join rental on inventory.inventory_id = rental.inventory_id
left join payment on rental.rental_id = payment.rental_id
group by category.name
order by rental_count desc;

### customer lifetime value
select c.customer_id, c.first_name, c.last_name, sum(p.amount) AS lifetime_value
from customer as c
left join payment as p
on c.customer_id = p.customer_id
group by c.customer_id, c.first_name, c.last_name
order by lifetime_value desc;

### advanced analytics
### consumer behavior
SELECT r1.inventory_id AS dvd1_id,
       r2.inventory_id AS dvd2_id,
       COUNT(*) AS rental_count
FROM rental r1
JOIN rental r2 ON r1.rental_id = r2.rental_id AND r1.inventory_id < r2.inventory_id
WHERE r1.inventory_id <> r2.inventory_id
GROUP BY r1.inventory_id, r2.inventory_id
HAVING COUNT(*) >= 2
ORDER BY rental_count DESC;


### hypothesis testing
-- Create a table to assign customers to groups
CREATE TABLE customer_groups AS
SELECT 
    customer_id, 
    CASE WHEN random() < 0.5 THEN 'Group A' ELSE 'Group B' END AS group_assignment
FROM customer;

-- Create a table to track rental frequencies for each group
CREATE TABLE rental_frequencies AS
SELECT
    cg.group_assignment,
    COUNT(r.rental_id) AS rental_count
FROM customer_groups cg
LEFT JOIN rental r ON cg.customer_id = r.customer_id
GROUP BY cg.group_assignment;

-- Display rental frequencies for each group
SELECT * FROM rental_frequencies;

SELECT 
    'Group A' AS group_name,
    AVG(rental_count) AS mean_count,
    STDDEV(rental_count) AS stddev_count
FROM rental_frequencies
WHERE group_assignment = 'Group A'
UNION ALL
-- Calculate mean and standard deviation for Group B
SELECT 
    'Group B' AS group_name,
    AVG(rental_count) AS mean_count,
    STDDEV(rental_count) AS stddev_count
FROM rental_frequencies
WHERE group_assignment = 'Group B';

-- Calculate the t-statistic and p-value for the two-sample t-test
-- Calculate the t-statistic for the two-sample t-test
WITH subquery_a AS (
    SELECT 
        AVG(rental_count) AS mean_a,
        STDDEV(rental_count) AS stddev_a,
        COUNT(*) AS count_a
    FROM rental_frequencies
    WHERE group_assignment = 'Group A'
), subquery_b AS (
    SELECT 
        AVG(rental_count) AS mean_b,
        STDDEV(rental_count) AS stddev_b,
        COUNT(*) AS count_b
    FROM rental_frequencies
    WHERE group_assignment = 'Group B'
)
SELECT 
    'Group A vs. Group B' AS comparison,
    (mean_a - mean_b) / SQRT((stddev_a * stddev_a / count_a) + (stddev_b * stddev_b / count_b)) AS t_statistic
FROM subquery_a, subquery_b;

		 