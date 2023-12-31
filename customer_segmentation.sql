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