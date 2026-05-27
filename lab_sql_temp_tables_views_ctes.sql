USE sakila;

-- Paso 1: Vista
CREATE VIEW vista_customers_rental AS
SELECT c.customer_id, c.first_name, c.last_name, c.email,
COUNT(rental_id) AS rental_count
FROM customer AS c
INNER JOIN rental AS r ON c.customer_id = r.customer_id
GROUP BY c.customer_id;

-- Paso 2: Tabla Temporal
CREATE TEMPORARY TABLE temporary_table_cpayment AS
SELECT v.customer_id, SUM(amount) AS total_paid
FROM vista_customers_rental AS v
INNER JOIN payment AS p ON v.customer_id = p.customer_id
GROUP BY v.customer_id;

-- Paso 3: CTE + Reporte Final
WITH customer_summary AS (
    SELECT v.first_name, v.last_name, v.email, 
           v.rental_count, t.total_paid,
           t.total_paid / v.rental_count AS average_payment_per_rental
    FROM vista_customers_rental AS v
    INNER JOIN temporary_table_cpayment AS t ON v.customer_id = t.customer_id
)
SELECT *
FROM customer_summary;