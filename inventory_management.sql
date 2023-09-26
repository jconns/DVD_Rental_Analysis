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
