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

