/* Cricket analytics with sql*/

/* Here in this case study we are going analysis on sachin tendulkar's ODI performance and 
will find out insights from it. */

/* DATASET DOWNLOAD LINK - https://docs.google.com/spreadsheets/d/1-utCWJ4PseJjLipW15Gm9lVG5J6FrmOR/edit#gid=390450519 */


--1. Total ODI matches.
SELECT COUNT(*) FROM sachin_cric;

--2. First ODI debut 

SELECT * FROM sachin_cric WHERE match_date = (SELECT min(match_date) FROM sachin_cric);

--3. Number of ODI matches played against each team order the numbers in desc.

SELECT Versus, count(1) AS matches_played FROM sachin_cric GROUP BY Versus ORDER BY count(1) DESC;

--4. Total number of 100's in ODI 

SELECT COUNT(1) FROM sachin_cric WHERE Runs>=100;

--5. Find count of 100's against each country

SELECT Versus,COUNT(1) AS number_of_100 FROM sachin_cric WHERE Runs>=100 GROUP BY Versus ORDER BY COUNT(1) DESC;

--6. What is average strike rate of sachin when he scored 100 or more than 100.

SELECT AVG(strike_rate) as average_strike_rate FROM sachin_cric WHERE Runs>=100;

--7. Find average strike rate against each country.

SELECT Versus as country ,AVG(strike_rate) avg_strike_rate FROM sachin_cric GROUP BY Versus;



--8. WC 2011 performance.
/* 
* Now we will find overall perfomance of sachin tendulkar in WC 2011. 
* For that we have to find duration of WC 2011 . Then we have to create CTE for that.
* From google i have found that WC 2011 was held between 19 February 2011 and 2 April 2011.
*/

WITH WC_2011 AS 
(SELECT * FROM sachin_cric WHERE match_date BETWEEN  '2011-02-19' AND '2011-04-02')
SELECT COUNT(match) as matches_played,
SUM(Runs) AS total_runs,
AVG(strike_rate) AS avg_strike_rate,
COUNT(CASE WHEN Runs>=100 THEN Runs END) AS total_centuries,
COUNT(CASE WHEN How_Dismissed LIKE 'c%' THEN How_Dismissed END) as catch_out,
COUNT(CASE WHEN How_Dismissed LIKE 'l%' THEN How_Dismissed END) as lbw,
COUNT(CASE WHEN How_Dismissed LIKE 'r%' THEN How_Dismissed END) as run_out
FROM WC_2011

/*9. Here we have created a new feature home/abroad which tells us that which mathches are played
in INDIA and other country.*/;

-- Here we created a table called place which shows that matches played in india and out of india.
WITH CTE AS 
(SELECT match as sr,
CASE WHEN Ground IN 
('Arun Jaitley Stadium','Barabati Stadium','Captain Roop Singh Stadium','Dr YS Rajasekhara Reddy Cricket Stadium','Eden Gardens',
'Gandhi Sports Complex Ground','Gandhi Stadium','Green Park','Indira Priyadarshini Stadium',
'Jawaharlal Nehru Stadium (Delhi)','Keenan Stadium','Lal Bahadur Shastri Stadium','M Chinnaswamy Stadium',
'MA Chidambaram Stadium','Madhavrao Scindia Cricket Ground','Nahar Singh Stadium',
'Narendra Modi Stadium','Nehru Stadium (Guwahati)','Nehru Stadium (Indore)','Nehru Stadium (Kochi)',
'Nehru Stadium (Margao)','Nehru Stadium (Pune)','Punjab Cricket Association IS Bindra Stadium',
'Rajiv Gandhi International Cricket Stadium','Sector 16 Stadium','Sawai Mansingh Stadium',
'Reliance Stadium','Vidarbha Cricket Association Ground','Vidarbha Cricket Association Stadium',
'Wankhede Stadium') THEN 'HOME' ELSE 'ABROAD' END AS VENUE
FROM sachin_cric)
SELECT * INTO place FROM CTE


/* Now we have additional data about mathces played in india and outside india. So we can do more 
analysis based on that */

--Q.10 How many ODI matches did he played in india and abroad?

SELECT VENUE,COUNT(1) as matches_played FROM 
(SELECT * FROM sachin_cric T1 INNER JOIN place T2 ON T1.Match=T2.sr) temp_1
GROUP BY VENUE;

--Q.11 What is the average strike rate while playing in India and abroad.

SELECT VENUE , AVG(strike_rate) AS avg_strike_rate FROM 
(SELECT * FROM sachin_cric T1 INNER JOIN place T2 ON T1.Match=T2.sr) temp_1
GROUP BY VENUE

--Q.12 How many centuries did sachin scored in INDIAN grounds and foreign grounds.

SELECT * , (no_of_centuries_in_abroad+no_of_centuries_in_india) AS total_centuries
FROM
(SELECT 
COUNT(CASE WHEN VENUE='ABROAD' AND RUNS>=100 THEN Runs END) AS no_of_centuries_in_abroad,
COUNT(CASE WHEN VENUE='HOME' AND RUNS>=100 THEN Runs END) AS no_of_centuries_in_india
FROM 
(SELECT * FROM sachin_cric T1 INNER JOIN place T2 ON T1.Match=T2.sr) temp_1) temp_2;

--Q.13 Sachin's milestone of runs.

SELECT Match,innings,
CASE
WHEN milestone>=15000 THEN 15000 
WHEN milestone>=10000 THEN 10000 
WHEN milestone>=5000 THEN 5000 
WHEN milestone>=1000 THEN 1000 
END AS milestone
FROM
(SELECT Match,innings,milestone FROM 
(SELECT Match,Innings,milestone,
DENSE_RANK() OVER(PARTITION BY cnt ORDER BY milestone) AS rnk
FROM 
(SELECT Match,Innings,milestone,
CASE 
WHEN milestone BETWEEN 0 AND 999 THEN 0
WHEN milestone BETWEEN 1000 AND 4999 THEN 1
WHEN milestone BETWEEN 5000 AND 9999 THEN 2
WHEN milestone BETWEEN 10000 AND 14999 THEN 3
END AS cnt
FROM 
(SELECT Match,Innings,Runs,
SUM(Runs) OVER(ORDER BY Match) milestone
FROM sachin_cric) temp_1 WHERE milestone>=1000
) temp_2) temp_3 
WHERE rnk=1) temp_4 
ORDER BY milestone 

--Q.14 Percentage of hitting century against each country.

SELECT t1.Versus,CAST(number_of_100 AS float)/total_mathces*100 FROM
(SELECT Versus , count(1) AS total_mathces FROM sachin_cric GROUP BY Versus) as t1
LEFT JOIN
(SELECT Versus,COUNT(1) AS number_of_100 FROM sachin_cric WHERE Runs>=100 GROUP BY Versus ) as t2
ON t1.Versus=t2.Versus;

--Q.15 Analysis on icc world cup season played by sachin.
/*For that we have to gather some information about his world cup mathces in his entire carrier, 
after collecting some information we will create a another table which will gives us additional info
about world cup matches played by him.

We gathered some information about each icc world cup tournment's date based on that we created a table*/

WITH wc AS
(SELECT match,'wc_1992' AS world_cup FROM sachin_cric WHERE match_date BETWEEN  '1992-02-22' AND '1992-03-25'
UNION ALL
SELECT match,'wc_1996' AS world_cup FROM sachin_cric WHERE match_date BETWEEN  '1996-02-14' AND '1996-03-17'
UNION ALL
SELECT match,'wc_1999' AS world_cup FROM sachin_cric WHERE match_date BETWEEN  '1999-05-14' AND '1999-06-20'
UNION ALL
SELECT match,'wc_2003' AS world_cup FROM sachin_cric WHERE match_date BETWEEN  '2003-02-09' AND '2003-03-23'
UNION ALL
SELECT match,'wc_2007' AS world_cup FROM sachin_cric WHERE match_date BETWEEN  '2007-03-13' AND '2007-04-28'
UNION ALL
SELECT match,'wc_2011' AS world_cup FROM sachin_cric WHERE match_date BETWEEN  '2011-02-19' AND '2011-04-02')
SELECT * INTO sachin_wc FROM wc

/* Here we created another table from above query which gives us info about his icc world cup matches.*/

SELECT * FROM sachin_cric T1 INNER JOIN  sachin_wc T2 ON T1.Match=T2.Match;

-- Total icc_world_cup tournment played by sachin

SELECT DISTINCT world_cup FROM sachin_cric T1 INNER JOIN  sachin_wc T2 ON T1.Match=T2.Match GROUP BY T2.world_cup;

-- Overall summary of sachin tendulkar's performance in icc world cup events

SELECT DISTINCT world_cup,
COUNT(T1.Match) AS total_matches_played,
COUNT(innings) AS total_innings_played,
AVG(strike_rate) as avg_strike_rate,
AVG(runs) AS avg_runs,
SUM(runs) AS total_runs,
SUM(balls_faced) AS total_balls_faced,
COUNT(CASE WHEN Runs>=100 THEN Runs END) AS total_centuries
FROM sachin_cric T1 INNER JOIN  sachin_wc T2 ON T1.Match=T2.Match GROUP BY T2.world_cup;




















































