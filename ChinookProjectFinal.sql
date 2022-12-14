
/*
The Chinook database contains 11 tables. The following query will fetch the list of  all tables :
*/
Select table_name
from INFORMATION_SCHEMA.TABLES
where table_type ='BASE TABLE'

/***
This datanalysis project is aimed to help Chinook Digital music store with insight to optimize their 
business opportunities and answer business related questions.I am using this databasein order to explore
and analyze six fictional business questions.

***/

 1) Chinook wants to know which artist has contributed with the maximum no of songs.
	We will display the artist name and the no of albums.

 with cte as
    (select ar.name as artist_name, count(1) as no_of_songs
     , rank() over (order by count(1) desc) as rnk
    from track t
    join Album al on al.albumid = t.albumid
    join artist ar on ar.artistid = al.artistid
    group by ar.name)
select artist_name, no_of_songs
from cte
where rnk = 1

2) Suppose Chinook wants to increase its sales .
 He is know conducting a research to get the most popular and least popular genre, to understand where to invest the most.
 -- Popularity is defined based on which genre was purchased the most

 with cte as
    (select g.name as genre_name, count(1) as no_of_purchase
    , rank() over(order by count(1) desc) rnk
    from invoiceline il--
    join track t on t.trackid = il.trackid
    join genre g on g.genreid = t.genreid
    group by g.name)
select genre_name, 'Most Popular' as Popularity
from cte
where rnk = 1
union
select genre_name, 'Least Popular' as Popularity
from cte
where rnk = (select max(rnk) from cte)

3)Chinook digital store is looking  for any artist who has performed in multiple genres. 
 He wants the aritst name and the genre to be displayed.

--first come up with a query that will show each artist and the genre
with cte as
        (select distinct ar.name as artist_name, g.name as genre_name
		--we used distinct because there are some artists with multipe
		--tracks but from the same genre.We are avoiding duplicate values.
        from track t
        join album al on al.albumid = t.albumid
        join artist ar on ar.artistid = al.artistid
        join genre g on g.genreid = t.genreid),
    multiple_genre as
        (select artist_name, count(1) as genre
        from cte
        group by artist_name
        having count(1) > 1)
select mg.artist_name, cte.genre_name
from multiple_genre mg
join cte on cte.artist_name = mg.artist_name
order by 1,2;

4) Chinook is looking to identify the 5 most popular artists for the most popular genre.
    Popularity is defined based on how many songs an artist has performed in for the particular genre.
     The artist name along with the no of songs will be displayed.

with cte as
        (select g.genreid, g.name as genre_name, count(1) as no_of_purchase
        , rank() over(order by count(1) desc) rnk
        from invoiceline il
        join track t on t.trackid = il.trackid
        join genre g on g.genreid = t.genreid
        group by g.genreid, g.name),
    most_popular_genre as
        (select genreid, genre_name from cte where rnk = 1 )  ,
    final_data as
        (select  ar.name as artist_name, count(1) as no_of_songs
         , rank() over (order by count(1) desc) as rnk
        from track t
        join album al on al.albumid = t.albumid
        join artist ar on ar.artistid = al.artistid
        join most_popular_genre pop on pop.genreid = t.genreid
        group by ar.name)
select artist_name, no_of_songs
from final_data
where rnk < 6;

 5) Imagine Chinook is planning to expand its business within some locations. 
	He is looking for the first three cities with the best customers?

  With cte as(

Select C.City, Sum(I.Total) Total_Purchase
, rank() over(order by Sum(I.Total) desc) rnk
from Customer C
join Invoice I
on C.CustomerId= I.CustomerId
group by C.City
)
Select *
from cte
where rnk <=3

6)Chinook is reviewing countries where its businesses are located  and wants to know which country has the highest 
number of invoices?

 With cte as(
Select C.Country, SUM(I.InvoiceId) No_Invoice
, rank() over(order by Sum(I.InvoiceId) desc) rnk
from Customer C
join Invoice I
on C.CustomerId= I.CustomerId
join InvoiceLine IL
on IL.InvoiceId = I.InvoiceId
group by C.Country
)
Select *
from cte
where rnk = 1

7)  Chinook is  assessing  the umbers of its customers by country, the total value of its sales, and total number of orders so far.

With cte as(
Select C.Country as Country, SUM(I.Total) Total_purchases,count(Distinct(c.customerId)) Total_Customers,
       Count(i.invoiceId) Total_Orders
from Customer C
join Invoice I
on C.CustomerId= I.CustomerId
group by C.Country
)
Select *
from cte
order by 4


