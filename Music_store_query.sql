/* Q1: Who is the senior most employee based on job title? */

SELECT employee_id, first_name, last_name, title, levels FROM employee
ORDER BY levels DESC
LIMIT 1

/* Q2: Which countries have the most Invoices? */

SELECT billing_country, COUNT(*) AS highest_billing_country FROM invoice
GROUP BY billing_country
ORDER BY highest_billing_country DESC

/* Q3: What are top 3 values of total invoice? */

SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city, SUM(total) AS total_invoice FROM invoice
GROUP BY billing_city
ORDER BY total_invoice DESC
LIMIT 1

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

/*USING JOINS*/

SELECT customer.first_name, customer.last_name, SUM(invoice.total) AS total_spending FROM customer
LEFT JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spending DESC
LIMIT 1

/*USING SUBQUERY*/

SELECT customer_id, first_name, last_name
FROM customer
WHERE customer_id = (
    SELECT customer_id
    FROM (
        SELECT customer_id, SUM(total) as total_spending
        FROM invoice
        GROUP BY customer_id
        ORDER BY total_spending DESC
        LIMIT 1
    ) as customer_id
);

/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT DISTINCT email, first_name, last_name, genre.name as genre_name FROM customer
LEFT JOIN invoice ON customer.customer_id = invoice.customer_id
LEFT JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
LEFT JOIN track ON invoice_line.track_id = track.track_id
LEFT JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email

/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT artist.artist_id, artist.name, COUNT(*) AS track_count FROM artist
LEFT JOIN album ON artist.artist_id = album.artist_id
LEFT JOIN track ON album.album_id = track.album_id
LEFT JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name like 'Rock'
GROUP BY artist.artist_id
ORDER BY track_count DESC
LIMIT 10

/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name AS track_name, milliseconds AS song_duration FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) FROM track
)
ORDER BY song_duration DESC;

/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

SELECT customer.customer_id, customer.first_name, customer.last_name, artist.name, SUM(invoice_line.unit_price * invoice_line.quantity) AS total_cost FROM customer
LEFT JOIN invoice ON customer.customer_id = invoice.customer_id
LEFT JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
LEFT JOIN track ON invoice_line.track_id = track.track_id
LEFT JOIN album ON track.album_id = album .album_id
LEFT JOIN artist ON album.artist_id = artist.artist_id
GROUP BY 1, 4
ORDER BY 5 DESC

/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH popular_genre AS 
(
	SELECT COUNT(invoice_line.quantity) as purchases, invoice.billing_country, genre.name,
	ROW_NUMBER() OVER(PARTITION BY invoice.billing_country ORDER BY COUNT(invoice_line.quantity) DESC) AS row_no
	FROM invoice_line
	LEFT JOIN invoice ON invoice_line.invoice_id = invoice.invoice_id
	LEFT JOIN track ON invoice_line.track_id = track.track_id
	LEFT JOIN genre ON track.genre_id = genre.genre_id
	GROUP BY 2, 3
	ORDER BY 1 DESC
)
SELECT * FROM popular_genre WHERE row_no <= 1

/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH best_customer AS
(
	SELECT customer.customer_id, customer.first_name, customer.last_name, customer.country, 
	SUM(invoice.total) AS total_spending, ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY SUM(invoice.total) DESC) AS row_no
	FROM customer
	JOIN invoice ON customer.customer_id = invoice.customer_id
	GROUP BY 1, 4
	ORDER BY 4 ASC, 5 DESC
)
SELECT * FROM best_customer WHERE row_no <= 1