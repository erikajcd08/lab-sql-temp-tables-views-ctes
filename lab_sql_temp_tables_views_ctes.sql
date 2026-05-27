USE sakila;

-- Borramos la vista anterior para poder recrearla
DROP VIEW vista_customers_rental;

-- Paso 1: Vista con CONCAT y GROUP BY completo
CREATE VIEW vista_customers_rental AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(*) AS rental_count
FROM customer AS c
INNER JOIN rental AS r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

-- Paso 2: Tabla Temporal con la ruta correcta (vista → rental → payment)
CREATE TEMPORARY TABLE temporary_table_cpayment AS
SELECT v.customer_id, SUM(p.amount) AS total_paid
FROM vista_customers_rental AS v
INNER JOIN rental AS r ON v.customer_id = r.customer_id
INNER JOIN payment AS p ON r.rental_id = p.rental_id
GROUP BY v.customer_id;

-- Paso 3: CTE + Reporte Final con columnas explícitas
WITH customer_summary AS (
    SELECT 
        v.customer_name,
        v.email,
        v.rental_count,
        t.total_paid,
        t.total_paid / v.rental_count AS average_payment_per_rental
    FROM vista_customers_rental AS v
    INNER JOIN temporary_table_cpayment AS t ON v.customer_id = t.customer_id
)
SELECT 
    customer_name,
    email,
    rental_count,
    total_paid,
    average_payment_per_rental
FROM customer_summary;