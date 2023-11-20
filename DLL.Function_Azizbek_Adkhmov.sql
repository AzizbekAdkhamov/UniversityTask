-- Create a view called "sales_revenue_by_category_qtr"
CREATE VIEW sales_revenue_by_category_qtr AS
SELECT
    c.category_name,
    SUM(p.amount) AS total_sales_revenue
FROM
    payment p
    JOIN rental r ON p.rental_id = r.rental_id
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category c ON fc.category_id = c.category_id
WHERE
    p.payment_date >= DATE_TRUNC('quarter', CURRENT_DATE)
GROUP BY
    c.category_name;

-- Create a query language function called "get_sales_revenue_by_category_qtr"
CREATE OR REPLACE FUNCTION get_sales_revenue_by_category_qtr(current_quarter INT)
RETURNS TABLE(category_name VARCHAR, total_sales_revenue DECIMAL) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.category_name,
        SUM(p.amount) AS total_sales_revenue
    FROM
        payment p
        JOIN rental r ON p.rental_id = r.rental_id
        JOIN inventory i ON r.inventory_id = i.inventory_id
        JOIN film f ON i.film_id = f.film_id
        JOIN film_category fc ON f.film_id = fc.film_id
        JOIN category c ON fc.category_id = c.category_id
    WHERE
        p.payment_date >= DATE_TRUNC('quarter', CURRENT_DATE)
    GROUP BY
        c.category_name;
END;
$$ LANGUAGE plpgsql;

-- Create a procedure language function called "new_movie"
CREATE OR REPLACE FUNCTION new_movie(movie_title VARCHAR)
RETURNS VOID AS $$
DECLARE
    new_film_id INT;
BEGIN
    -- Generate a new unique film ID
    SELECT MAX(film_id) + 1 INTO new_film_id FROM film;

    -- Set default values
    INSERT INTO film (film_id, title, rental_rate, rental_duration, replacement_cost, release_year, language_id)
    VALUES (new_film_id, movie_title, 4.99, 3, 19.99, EXTRACT(YEAR FROM CURRENT_DATE), (SELECT language_id FROM language WHERE name = 'Klingon'));

    -- Verify that the language exists in the "language" table
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Language not found in the language table.';
    END IF;
END;
$$ LANGUAGE plpgsql;
