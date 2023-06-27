/*
This project aims to analyze Olympic Games data, comprising approximately 300,000 rows, 
to extract meaningful insights using advanced SQL techniques. 
The skills employed in this analysis include JOINs, window functions, analytical functions, 
GROUP BY, subqueries, and Common Table Expressions (CTEs).

Table Descriptions:

events_tbl: This table contains essential information about the Olympic events. 
Its columns consist of athlete_id, year of the Olympics, city, sport, event, and medal.

teams_tbl: 
This table provides detailed athlete information, including athlete_id, athlete_name, 
country_name (team), and additional pertinent columns.

Objective:
By using SQL skills, we will explore the Olympic Games data to uncover valuable insights 
and trends, enabling a comprehensive analysis of the dataset.
*/


-- Q.1 Which team has won the maximum gold medals over the years.

SELECT team,count(medal) _gold_medal_counts FROM 
(SELECT athlete_id , year , medal FROM events_tbl WHERE medal='Gold') A
INNER JOIN
(SELECT id,team FROM teams_tbl) B
ON
A.athlete_id=B.id
GROUP BY team ORDER BY count(medal) desc;

/*Q.2 for each team print total silver medals and year in which they won maximum silver medal.
   output 3 columns team,total_silver_medals, year_of_max_silver. */

SELECT tbl_1.team, tbl_1.silver_medal_count, tbl_2.year AS year_of_max_silver
FROM
(SELECT team , COUNT(medal) as silver_medal_count FROM
(SELECT athlete_id,year,medal FROM events_tbl WHERE medal='Silver') A
INNER JOIN 
(SELECT id,team FROM teams_tbl) B
ON 
A.athlete_id=B.id
GROUP BY team ) tbl_1
INNER JOIN
(SELECT * FROM 
(select * ,
DENSE_RANK() OVER(PARTITION BY team  ORDER BY silver_count,year DESC) AS rnk
FROM
(SELECT team,year,count(medal) as silver_count
FROM 
(SELECT athlete_id,year,medal FROM events_tbl WHERE medal='Silver') A
INNER JOIN 
(SELECT id,team FROM teams_tbl) B
ON 
A.athlete_id=B.id
GROUP BY team,year) temp) temp_1
WHERE rnk=1) tbl_2
ON
tbl_1.team=tbl_2.team

/* Q.3 which player has won maximum gold medals  amongst the players which have won only gold 
medal (never won silver or bronze) over the years */

SELECT TOP 1 name , SUM(gold_count) as total_gold FROM 
(SELECT name,
COUNT(CASE WHEN medal='Gold' THEN medal END) AS gold_count,
COUNT(CASE WHEN medal='Silver' THEN medal END ) AS Silver_count,
COUNT(CASE WHEN medal='Bronze' THEN medal END) AS Bronze_count
FROM
(SELECT medal,name FROM
(SELECT athlete_id,year,medal FROM events_tbl  WHERE medal NOT IN ('NA')) A
INNER JOIN 
(SELECT id,team,name FROM teams_tbl) B
ON 
A.athlete_id=B.id) 
temp_1 
GROUP BY name) temp_2 
WHERE Silver_count = '0' AND Bronze_count = '0'
GROUP BY name 
ORDER BY SUM(gold_count) DESC


/* Q.4 in each year which player has won maximum gold medal . Write a query to print year,player name 
 and no of golds won in that year . In case of a tie print comma separated player names.*/

SELECT Year , STRING_AGG(name,',')AS Player_name, gold_count AS max_gold_won_by_player FROM
(SELECT *,
DENSE_RANK() OVER (PARTITION BY Year ORDER BY gold_count DESC) AS rnk 
FROM 
(SELECT name,year,count(medal) gold_count FROM 
(SELECT athlete_id,year,medal FROM events_tbl  WHERE medal = 'Gold' )A
INNER JOIN 
(SELECT id,team,name FROM teams_tbl) B
ON 
A.athlete_id=B.id
GROUP BY name , year) temp_1) temp_2 
WHERE rnk=1  GROUP BY  YEAR,gold_count ORDER BY Year


/* Q.5 In which event and year India has won its first gold medal,first silver medal 
     and first bronze medalprint 3 columns medal,year,sport. */

SELECT  DISTINCT medal , year , event FROM
(SELECT * ,
DENSE_RANK() OVER(PARTITION BY medal ORDER BY year asc) AS rnk
FROM
(SELECT medal,year,event,team 
FROM 
events_tbl E INNER JOIN teams_tbl T 
ON E.athlete_id =T.id
WHERE team = 'India' AND medal IN ('Gold' , 'Silver' , 'Bronze')) temp_1) temp_2
WHERE rnk =1

/* Q.6 find players who won gold medal in summer and winter olympics both */

SELECT name FROM 
(SELECT DISTINCT name , medal , season
FROM 
events_tbl E INNER JOIN teams_tbl T 
ON E.athlete_id =T.id
WHERE medal = 'GOLD' AND SEASON IN('Summer','Winter')) temp_1
GROUP BY name HAVING COUNT(season)=2 

/* Q.7 find players who won gold, silver and bronze medal in a single olympics. print player name along 
  with year. */
SELECT name , year
FROM
(SELECT DISTINCT name , year , medal 
FROM 
events_tbl E INNER JOIN teams_tbl T 
ON E.athlete_id =T.id 
WHERE medal IN ('Gold' , 'Silver' , 'Bronze')) temp
GROUP BY name , year
HAVING COUNT(medal)=3

/* Q.8 find players who have won gold medals in consecutive 3 summer olympics in the same event . 
Consider only olympics 2000 onwards. Assume summer olympics happens every 4 year starting 2000. 
print player name and event name.*/

SELECT name , year, event FROM
(SELECT * ,
MAX(rn) OVER(PARTITION BY name) as MAX_rn FROM
(SELECT *,
ROW_NUMBER() OVER(PARTITION BY name  ORDER BY year) AS rn
FROM
(SELECT * ,
Year-
(LAG(year,1) OVER(PARTITION BY name  ORDER BY year)) AS year_gap
FROM
(SELECT DISTINCT name , year , medal , event
FROM 
events_tbl E INNER JOIN teams_tbl T 
ON E.athlete_id =T.id 
WHERE year>=2000 AND season='Summer' AND medal='Gold') temp_1) temp_2
WHERE year_gap=4 ) temp_3) temp_4
WHERE max_rn=3


/* Q.9 find country wise count of each medal won by that country i,e Output should contain following columns
 country_name , Gold_count , Silver_count , Bronze_count Order should be country who won highest gold 
 should be at top. */

 SELECT * FROM
 (SELECT team , 
 COUNT(CASE WHEN medal='Gold' THEN medal END) AS Gold_count,
 COUNT(CASE WHEN medal='Silver' THEN medal END) AS Silver_count,
 COUNT(CASE WHEN medal='Bronze' THEN medal END) AS Bronze_count
 FROM
 (SELECT team,medal FROM
 events_tbl E INNER JOIN teams_tbl T 
 ON E.athlete_id = T.id ) temp_1 GROUP BY team) temp_2 ORDER BY team;

/* Q.10 Find year wise medal counts for india */

 SELECT * FROM
 (SELECT year,
 COUNT(CASE WHEN medal='Gold' THEN medal END) AS Gold_count,
 COUNT(CASE WHEN medal='Silver' THEN medal END) AS Silver_count,
 COUNT(CASE WHEN medal='Bronze' THEN medal END) AS Bronze_count
 FROM
 (SELECT team,medal,year FROM
 events_tbl E INNER JOIN teams_tbl T 
 ON E.athlete_id = T.id  WHERE team='India') temp_1 GROUP BY year) temp_2 ORDER BY year;


/* Q.11 Find total medal won by india in each sports events. */

SELECT event AS Sports , COUNT(medal) AS medals_won FROM
 events_tbl E INNER JOIN teams_tbl T 
 ON E.athlete_id = T.id WHERE team='India' AND medal IN ('Gold' , 'Silver' , 'Bronze')
GROUP BY event;


/* Q.12 Find country wise count of medals won by womens and mens */

SELECT team, 
COUNT(CASE WHEN sex='M' THEN medal END) medals_won_by_mens,
COUNT(CASE WHEN sex='F' THEN medal END) medals_won_by_womens
FROM
(SELECT * 
FROM
events_tbl E INNER JOIN teams_tbl T 
ON E.athlete_id = T.id WHERE medal IN ('Gold' , 'Silver' , 'Bronze')) tbl
GROUP BY team ORDER BY team


/* Q.13  Find countrys where medals won by womens are greater than medals won by mens.*/

SELECT * FROM
(SELECT team, 
COUNT(CASE WHEN sex='M' THEN medal END) medals_won_by_mens,
COUNT(CASE WHEN sex='F' THEN medal END) medals_won_by_womens
FROM
(SELECT * 
FROM
events_tbl E INNER JOIN teams_tbl T 
ON E.athlete_id = T.id WHERE medal IN ('Gold' , 'Silver' , 'Bronze')) as temp_1
GROUP BY team ) AS temp_2
WHERE medals_won_by_mens < medals_won_by_womens
ORDER BY team;


/* Q.14 Write a query to get year and in which city/country olympics was held for that year.*/

SELECT DISTINCT YEAR,City
FROM
events_tbl E INNER JOIN teams_tbl T 
ON E.athlete_id = T.id 
ORDER BY year;

/* Q.15. write a query to find names of palyers from india who won gold medal */

SELECT * FROM events_tbl E1 
INNER JOIN 
teams_tbl E2 
ON E1.athlete_id=E2.id WHERE team = 'India' AND medal='GOLD';

/* Q.16 write a query to find that which city has hold olympics more than 1 time. */

SELECT city FROM 
(SELECT DISTINCT city , year FROM 
(SELECT * FROM events_tbl E1 
INNER JOIN 
teams_tbl E2 
ON E1.athlete_id=E2.id) tbl_1) tbl_2 GROUP BY city HAVING COUNT(year)>1;




























































