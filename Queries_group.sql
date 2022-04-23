Select * from actor;

select * from director;

select * from genre;

select * from movie ORDER BY BUDGET DESC;

select * from rating;

select * from reviewer;


COPY movie (movie_id,movie_title,movie_time,movie_lang,release_date,budget,genre_id,actor_id,director_id,
			movie_completion_year,total_earnings) FROM 'C:\Users\hp\Documents\Sql\movie_data_group_project.csv'  
			WITH DELIMITER ',' CSV HEADER;
					
--QUERY 1
--Show the count of movies completed year-wise.
WITH movie_count_per_year AS (SELECT movie_completion_year, COUNT(*) AS movie_count
FROM movie
GROUP BY movie_completion_year
)
SELECT movie_title, moy.*
FROM movie mov 
INNER JOIN movie_count_per_year moy 
ON mov.movie_completion_year=moy.movie_completion_year
ORDER BY moy.movie_completion_year;

--QUERY 2
--Display the movie which has made highest profit(total_earnings-budget) among all.
SELECT * 
FROM movie 
WHERE (total_earnings-budget)=(SELECT MAX(ABS(total_earnings-budget))
FROM movie)

--QUERY 3
--Display movies which were made with high budget but failed at box office

SELECT * 
FROM rating rat 
INNER JOIN movie mov 
ON mov.movie_id=rat.movie_id
WHERE budget IN (SELECT budget FROM movie order by budget desc LIMIT 5)
AND rev_stars IN (SELECT rev_stars FROM rating order by rev_stars  LIMIT 5)

--Query 4
--Display top 5 genre-id under which most of the movies are released.

SELECT M.genre_id,genre_title,COUNT(*) movie_count
FROM movie M 
INNER JOIN genre G
on M.genre_id=G.genre_id
GROUP BY M.genre_id,G.genre_title
ORDER BY movie_count desc
LIMIT 5

--QUERY 5
---Display movie titles starting with 'B' released under different genre along with director details.
SELECT movie_ID,movie_title,gen.genre_id,genre_title,dir.director_id, 
CONCAT_WS (' ',dir_first_name,dir_last_name) AS director_name
FROM movie mov
INNER JOIN genre gen
ON mov.genre_id=gen.genre_id
INNER JOIN director dir
ON mov.director_id=dir.director_id
WHERE movie_title LIKE 'B%'

--QUERY 6
--Using a view find the most active reviewer and display number of movies they rated.
CREATE VIEW  count_rev AS 
(SELECT MAX(x.counter) AS rev_count
FROM ( SELECT reviewer_id,COUNT(*) AS counter 
	  FROM rating 
	  GROUP BY reviewer_id)x )

SELECT rat.reviewer_id,reviewer_name,COUNT(*) AS counter 
FROM rating rat 
INNER JOIN reviewer rev 
ON rat.reviewer_id=rev.reviewer_id
GROUP BY rat.reviewer_id,reviewer_name
HAVING COUNT(*)= (SELECT rev_count FROM count_rev )

--QUERY 7
---Display movies which has been released later an year after its completion

SELECT movie_id,movie_title,movie_completion_year,
EXTRACT (year FROM release_date) AS release_year 
FROM movie
WHERE EXTRACT (year FROM release_date)-movie_completion_year>1

--QUERY 8
--SORT MOVIES AS Blockbuster,Good, Average and Below Average according to their rating and name 
--the new column as 'box_office_performance'.

SELECT movie_title,rev_stars,
CASE 
WHEN rev_stars >8 THEN 'Blockbuster'
WHEN rev_stars BETWEEN 6 AND 8 THEN 'Good'
WHEN rev_stars BETWEEN 5 AND 6 THEN 'Average'
ELSE 'Below Average'
END AS box_office_performance
FROM movie mov
INNER JOIN rating rat
ON mov.movie_id=rat.movie_id
ORDER BY rev_stars DESC;

--QUERY 9
--Display actor-director combination that repeated more than once.

WITH act_dir_mov_count AS (SELECT actor_id,director_id,
						   COUNT(*) OVER (PARTITION BY actor_id,director_id )
AS movie_count
FROM movie )
SELECT DISTINCT CONCAT_WS (' ',actor_first_name,actor_last_name) AS actor_name,
CONCAT_WS (' ',dir_first_name,dir_last_name) AS director_name,
movie_count
FROM act_dir_mov_count mov
INNER JOIN actor act
ON mov.actor_id=act.actor_id
INNER JOIN director dir
ON mov.director_id=dir.director_id
WHERE movie_count>1 
ORDER BY movie_count DESC;

--Query 10
--Divide movies according to their budget in 5 different buckets.

SELECT WIDTH_BUCKET(BUDGET, 
					(SELECT MIN(budget) FROM movie), (SELECT MAX(budget) FROM movie), 5) AS BUCKET, 
					COUNT (*) AS MOVIE_COUNT
FROM movie
GROUP BY 
WIDTH_BUCKET(BUDGET, (SELECT MIN(budget) FROM movie), (SELECT MAX(budget) FROM movie), 5)
ORDER BY MOVIE_COUNT DESC;

--QUERY 11
SELECT *
FROM reviewer rev
INNER JOIN rating rat
ON rev.reviewer_id=rat.reviewer_id
WHERE rat.rev_stars>=8

--QUERY 12
--Write a SQL query to compute the average time and count number of movies for each genre. 

SELECT genre_title, ROUND(AVG(movie_time),2) AS Average_time,COUNT(genre_title)
FROM movie mov
INNER JOIN genre gen ON 
mov.genre_id=gen.genre_id
GROUP BY genre_title;


