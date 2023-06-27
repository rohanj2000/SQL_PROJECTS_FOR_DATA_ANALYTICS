-- Spotify case study 



--Script to create and insert data:
/*CREATE table activity
(
user_id INT(20),
event_name varchar(20),
event_date datetime,
country varchar(20)
);

insert into activity values (1,'app-installed','2022-01-01','India')
,(1,'app-purchase','2022-01-02','India')
,(2,'app-installed','2022-01-01','USA')
,(3,'app-installed','2022-01-01','USA')
,(3,'app-purchase','2022-01-03','USA')
,(4,'app-installed','2022-01-03','India')
,(4,'app-purchase','2022-01-03','India')
,(5,'app-installed','2022-01-03','SL')
,(5,'app-purchase','2022-01-03','SL')
,(6,'app-installed','2022-01-04','Pakistan')
,(6,'app-purchase','2022-01-04','Pakistan')*/


/*Q.1 Find total active users each day,active users means each day users who installed the app or 
purchased it.
2022-01-01 - 3
2022-01-02 - 1
2022-01-03 - 3
2022-01-04 - 1
*/

SELECT event_date,COUNT(DISTINCT(user_id)) AS active_users FROM activity GROUP BY event_date;

/*Q.2 Find total active users each week.

week_num  active_users
1           3
2           5
*/

SELECT week , COUNT(DISTINCT user_id) as active_users FROM 
(SELECT *, DATEPART(WEEK,event_date) as week FROM activity) temp_1 GROUP BY week;


/*Q.3 Datewise total number of customers who purchased and installed on same day
2022-01-01 - 0
2022-01-02 - 0
2022-01-03 - 2
2022-01-04 - 1
*/

SELECT installed_date,
COUNT(CASE WHEN installed_date=purchase_date THEN purchase_date END) same_day_purchase_count
FROM 
(SELECT user_id,event_date as installed_date,
LEAD(event_date) OVER(PARTITION BY user_id ORDER BY event_date) AS purchase_date
FROM activity) temp_1 
GROUP BY installed_date;


/* Q.4 Percentage of paid users in India , USA and other country should be tagged as others 
country percentage_users.
INDIA   40 
USA     20 
OTHERS  40
*/

SELECT country , CAST(COUNT(1) AS float)/5*100 AS percentage_users FROM 
(SELECT ISNULL(country_name,'others') AS country 
FROM 
(SELECT *,
CASE 
WHEN country = 'India' THEN 'India'
WHEN country = 'USA' THEN 'USA'
END AS country_name
FROM activity
WHERE event_name='app-purchase') temp_1) temp_2
GROUP BY country;

/* Q.5 Find the users who installed on same day and purchased on very next day */

SELECT user_id FROM
(SELECT user_id , DATEDIFF(day,prev_day,event_date) purchase_gap FROM
(SELECT *,
LAG(event_date) OVER(PARTITION BY user_id ORDER BY event_date) as prev_day
FROM activity) temp_1) temp_2 
WHERE purchase_gap=1










