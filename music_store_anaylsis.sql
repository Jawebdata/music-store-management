-- all tables
SELECT * FROM public.album;
SELECT * FROM public.artist;
SELECT * FROM public.customer;
SELECT * FROM public.employee;
SELECT * FROM public.genre;
SELECT * FROM public.invoice;
SELECT * FROM public.invoice_line;
SELECT * FROM public.media_type;
SELECT * FROM public.playlist;
SELECT * FROM public.playlist_track;
SELECT * FROM public.track;

-- 1 Who is the most senior employee in the company?
select * from employee 
order by levels desc
limit 1;

-- 2 Which countries have generated the most invoices?
select * from invoice;
select billing_country,count(*) as inv from invoice
group by billing_country
order by inv desc;

 -- 3 what are top 3 values of total invoice?
select total from invoice
order by total desc;

 -- 4 Which city has the best customers based on total invoice sales?
 select * from customer;
 select * from invoice;
 select billing_city, sum(total) from invoice
 group by billing_city
 order by sum desc;
 
 -- 5 Who is the best customer by total spending?
select c.customer_id,c.first_name,c.last_name,sum(inv.total) as total_sum from customer as c
join invoice as inv
on c.customer_id=inv.customer_id
group by c.customer_id
order by total_sum desc;
select * from invoice;
select * from customer;

-- 6 Which customers listen to Rock music (with their emails & names)?
select * from genre;
 select * from track;
 select * from customer;

 -- we need to connect together but how
 -- we customers with invoice
 -- invoice with invoice line
 -- then track with genre so together connect then directly connect with customer with genre
select c.email,c.first_name,c.last_name from customer as c
join invoice as i
on c.customer_id=i.customer_id
join invoice_line as il
on i.invoice_id=il.invoice_id
where track_id in(
SELECT t.track_id
FROM track AS t
JOIN genre AS g
ON t.genre_id = g.genre_id
WHERE g.name LIKE '%Rock%'
) order by email;

-- 7 Who are the top 10 artists with the most Rock tracks?

SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS total_track_count
FROM track AS t
JOIN album AS al ON t.album_id = al.album_id
JOIN artist ON al.artist_id = artist.artist_id
JOIN genre AS g ON t.genre_id = g.genre_id
WHERE g.name LIKE '%Rock%'
GROUP BY artist.artist_id, artist.name
ORDER BY total_track_count DESC
LIMIT 10;


-- 8 Which songs are longer than the average song length?
select name,milliseconds from track 
where milliseconds > (
select avg(milliseconds) as avg_of_track
from track
)
order by milliseconds desc;


-- 9 How much did each customer spend on the top 5 artists?

with best_artist as (
select artist.artist_id, artist.name as artist_name ,sum(invoice_line.unit_price * invoice_line.quantity) as total_sales from invoice_line
join track on invoice_line.track_id= track.track_id
join album on track.album_id=album.album_id
join artist on album.artist_id=artist.artist_id
group by artist.artist_id, artist.name
order by total_sales desc
limit 5
)
select c.customer_id,c.first_name,c.last_name,best_artist.artist_name,
sum(invoice_line.unit_price * invoice_line.quantity) as amount_spent from customer as c
join invoice on c.customer_id=invoice.customer_id 
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
join track on invoice_line.track_id= track.track_id
join album on track.album_id=album.album_id

join best_artist on album.artist_id=best_artist.artist_id
 group by c.customer_id,c.first_name,c.last_name,best_artist.artist_name
 order by amount_spent desc;


-- 10 What is the most popular music genre in each country based on purchases?
with Pg as (
select customer.country,genre.name,genre.genre_id, count(invoice_line.quantity) from invoice_line
join invoice on invoice_line.invoice_id=invoice.invoice_id
join customer on invoice.customer_id= customer.customer_id
join track on track.track_id=invoice_line.track_id
join genre on track.genre_id=genre.genre_id
group by customer.country,genre.name,genre.genre_id
order by count(invoice_line.quantity) desc
)
select * from Pg;







 
 
