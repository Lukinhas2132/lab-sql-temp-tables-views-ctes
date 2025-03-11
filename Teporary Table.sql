Use sakila

/**Creating a View – Customer Rental Summary**/

CREATE VIEW customer_rental_summary AS
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r 
       ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

/**Create a Temporary Table – Summing Payments**/
CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT 
    crs.customer_id,
    SUM(p.amount) AS total_paid
FROM customer_rental_summary crs
LEFT JOIN payment p 
       ON crs.customer_id = p.customer_id
GROUP BY crs.customer_id;

/**Creating a CTE and Generate the Final Customer Summary**/
WITH customer_summary AS (
    SELECT 
        crs.customer_id,
        CONCAT(crs.first_name, ' ', crs.last_name) AS customer_name,
        crs.email,
        crs.rental_count,
        IFNULL(cps.total_paid, 0) AS total_paid
    FROM customer_rental_summary crs
    JOIN customer_payment_summary cps 
        ON crs.customer_id = cps.customer_id
)
SELECT 
    customer_name,
    email,
    rental_count,
    total_paid,
    CASE
        WHEN rental_count = 0 THEN 0
        ELSE total_paid / rental_count
    END AS average_payment_per_rental
FROM customer_summary
ORDER BY customer_name;

/**Final Query: Customer Summary Report**/
CREATE VIEW customer_summary AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(p.amount) AS total_paid
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id;

SELECT * 
FROM customer_summary
WHERE total_paid > 50;

