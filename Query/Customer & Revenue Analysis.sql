---1. Who is the senior most employee based on job title? 
SELECT * FROM employee
ORDER BY hire_date
LIMIT 1;

--Which countries have the most Invoices?
SELECT billing_country, COUNT(invoice_id) AS total_invoices
FROM invoice
GROUP BY billing_country
ORDER BY total_invoices DESC;

--3. What are top 3 values of total invoice?
SELECT DISTINCT total
FROM invoice
ORDER BY total DESC
LIMIT 3;

/*4. Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that
has the highest sum of invoice totals. Return both the city name & sum of all invoice
totals*/
SELECT c.city, SUM(i.total) AS Total_revenue 
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.city 
ORDER BY total_revenue DESC LIMIT 1;


/*5.Who is the best customer? The customer who has spent the most money will be
declared the best customer. Write a query that returns the person who has spent the
most money*/

SELECT c.customer_id, (c.first_name || ' ' || c.last_name) AS Customer_name, 
SUM(i.total) AS Total_spent 
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name 
ORDER BY total_spent DESC LIMIT 1;

/*6.Write query to return the email, first name, last name, & Genre of all Rock Music
listeners. Return your list ordered alphabetically by email starting with A*/

SELECT DISTINCT c.email, c.first_name, c.last_name, g.name AS genre
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
ORDER BY email ASC;


/*7.Let's invite the artists who have written the most rock music in our dataset. Write a
query that returns the Artist name and total track count of the top 10 rock bands*/
SELECT a.name AS artist_name, COUNT(track_id) AS total_rock_tracks
FROM artist a
JOIN album al ON a.artist_id = al.artist_id
JOIN track t ON  al.album_id = t.album_id
JOIN genre g ON  t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY a.artist_id, a.name
ORDER BY total_rock_tracks DESC LIMIT 10;


/*8Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track. Order by the song length with the
longest songs listed first*/


SELECT  name, milliseconds FROM track 
WHERE milliseconds > (
SELECT AVG(milliseconds) AS average_length FROM track
)
ORDER BY milliseconds DESC;

/*9Find how much amount spent by each customer on artists? Write a query to return 
customer name, artist name and total spent*/

SELECT (c.first_name || ' ' || c.last_name) AS Customer_name, ar.name, 
SUM(il.unit_price * il.quantity) AS total_spent 
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album a ON t.album_id = a.album_id
JOIN artist ar ON a.artist_id = ar.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, ar.artist_id, ar.name
ORDER BY customer_name;


/*10We want to find out the most popular music Genre for each country. We determine the
most popular genre as the genre with the highest amount of purchases. Write a query
that returns each country along with the top Genre. For countries where the maximum
number of purchases is shared return all Genres*/


WITH genre_purchases AS (
    SELECT 
        c.country,
        g.name AS genre,
        COUNT(il.invoice_line_id) AS purchase_count,
        RANK() OVER (
            PARTITION BY c.country 
            ORDER BY COUNT(il.invoice_line_id) DESC
        ) AS rank_in_country
    FROM customer c
    JOIN invoice i 
        ON c.customer_id = i.customer_id
    JOIN invoice_line il 
        ON i.invoice_id = il.invoice_id
    JOIN track t 
        ON il.track_id = t.track_id
    JOIN genre g 
        ON t.genre_id = g.genre_id
    GROUP BY c.country, g.name
)

SELECT country, genre, purchase_count
FROM genre_purchases
WHERE rank_in_country = 1
ORDER BY country;

/*11.Write a query that determines the customer that has spent the most on music for each
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all
customers who spent this amount*/

WITH customer_spending AS (
    SELECT 
        c.country,
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        SUM(i.total) AS total_spent,
        RANK() OVER (
            PARTITION BY c.country
            ORDER BY SUM(i.total) DESC
        ) AS rank_in_country
    FROM customer c
    JOIN invoice i 
        ON c.customer_id = i.customer_id
    GROUP BY c.country, c.customer_id, c.first_name, c.last_name
)

SELECT country, customer_name, total_spent
FROM customer_spending
WHERE rank_in_country = 1
ORDER BY country;


















