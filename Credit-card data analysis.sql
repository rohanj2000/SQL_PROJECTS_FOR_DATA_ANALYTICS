/*
Credit Card  Data Exploration 

Skills used: Joins, Windows Functions, Aggregate Functions, Converting Data Types.
*/

SELECT * FROM creditcard_tbl

--Total rows in table.

SELECT COUNT(1) AS number_of_rows FROM creditcard_tbl;

--How many cities are there in given dataset.

SELECT COUNT(DISTINCT CITY) AS number_of_cities FROM creditcard_tbl;
  
-- Find TOP 5 cities with highest number of transactions done.

SELECT TOP 5 city , COUNT(1) as number_of_transactions FROM creditcard_tbl GROUP BY city ORDER BY
COUNT(1) DESC;

-- Find on which expence type the most amount was spend.

SELECT TOP 1 exp_type,SUM(amount) AS total_amount FROM creditcard_tbl GROUP BY exp_type 
ORDER BY SUM(amount) DESC;


--top 5 cities with highest spends and their percentage contribution of total credit card spends. 

--approach 1
SELECT TOP 5 city, amount_spent_per_city,
(amount_spent_per_city)/(SUM(amount_spent_per_city) OVER ())*100 AS percent_contribution
FROM
(SELECT city , SUM(amount) AS amount_spent_per_city FROM creditcard_tbl GROUP BY city ) temp_tbl 
ORDER BY amount_spent_per_city DESC;

--approach 2

SELECT TOP 5 * , 
(amount_spent_per_city/(SELECT SUM(amount) FROM creditcard_tbl))*100 AS percentage_contribution
FROM
(SELECT city , SUM(amount) AS amount_spent_per_city FROM creditcard_tbl GROUP BY city ) temp_tbl
ORDER BY amount_spent_per_city DESC;


-- Query to find spend on each exp_type as per city.

--method_1: Using PIVOT

SELECT * FROM
(SELECT city,exp_type,amount FROM creditcard_tbl)T1
PIVOT
(SUM(amount) FOR exp_type IN (Entertainment,Food,Bill,Fuel,Travel,Grocery)) T2
ORDER BY city

--method_2: Using CASE WHEN

SELECT city,
SUM(CASE WHEN exp_type='Entertainment' THEN amount END) AS Entertainment,
SUM(CASE WHEN exp_type='Food' THEN amount END) AS Food,
SUM(CASE WHEN exp_type='Bills' THEN amount END) AS Bills,
SUM(CASE WHEN exp_type='Fuel' THEN amount END) AS Fuel,
SUM(CASE WHEN exp_type='Travel' THEN amount END) AS Travel,
SUM(CASE WHEN exp_type='Grocery' THEN amount END) AS Grocery
FROM creditcard_tbl GROUP BY city ORDER BY city;


-- Query to print 3 columns:  city, highest_expense_type , lowest_expense_type 
--(example format : Delhi , bills, Fuel)

SELECT A.city , A.low_exp ,B.high_exp FROM
(SELECT city,exp_type AS low_exp FROM 
(SELECT city, exp_type, SUM(amount) AS total_amount,
DENSE_RANK() OVER (PARTITION BY city ORDER BY SUM(amount)) AS rnk
FROM creditcard_tbl GROUP BY city , exp_type) tbl WHERE rnk=1) A
INNER JOIN 
(SELECT city,exp_type AS high_exp FROM 
(SELECT city, exp_type, SUM(amount) AS total_amount,
DENSE_RANK() OVER (PARTITION BY city ORDER BY SUM(amount) DESC) AS rnk
FROM creditcard_tbl GROUP BY city , exp_type) tbl WHERE rnk=1) B
ON A.city=B.city ORDER BY B.city;


--Find percentage contribution of spends by females for each expense type. 

SELECT A.exp_type, gender, (A.spend/B.total_amount)*100 AS percent_contribution FROM
(SELECT exp_type , gender , SUM(amount) spend FROM creditcard_tbl GROUP BY exp_type, gender ) A 
INNER JOIN
(SELECT exp_type ,SUM(amount) AS total_amount FROM creditcard_tbl GROUP BY exp_type) B
ON A.exp_type=B.exp_type 
WHERE A.gender='F' ORDER BY percent_contribution DESC;


--Highest spend month in each year.

SELECT * FROM 
(SELECT Years , Months ,SUM(amount) AS total_amount,
DENSE_RANK() OVER (PARTITION BY Years ORDER BY SUM(amount) DESC) AS rnk
FROM 
(SELECT  DATEPART(YEAR , transaction_date) AS Years, DATEPART(MONTH , transaction_date) AS Months,
amount FROM creditcard_tbl) tbl GROUP BY Years , Months ) temp WHERE rnk=1;


--Which card and expense type combination saw highest month over month growth in Jan-2014.

--approach_1

SELECT TOP 1 A.card_type , A.exp_type , (total_spend_jan-total_spend_dec) AS growth_rate FROM
(SELECT card_type, exp_type, SUM(amount) AS total_spend_dec , ROW_NUMBER() OVER(ORDER BY card_type,exp_type) AS row_num FROM creditcard_tbl WHERE transaction_date BETWEEN '2013-12-01' AND '2013-12-31' GROUP BY card_type,exp_type) A
INNER JOIN 
(SELECT card_type, exp_type, SUM(amount) AS total_spend_jan , ROW_NUMBER() OVER(ORDER BY card_type,exp_type) AS row_num FROM creditcard_tbl WHERE transaction_date BETWEEN '2014-01-01' AND '2014-01-31' GROUP BY card_type,exp_type)B
ON A.row_num=B.row_num ORDER BY growth_rate DESC;

--approach_2

SELECT TOP 1 * , (total_spend-lst_month_sale) AS growth FROM
(SELECT *,
LAG(total_spend,1) OVER (PARTITION BY card_type,exp_type ORDER BY yer,moth) AS lst_month_sale
FROM 
(SELECT card_type, exp_type, DATEPART(YEAR , transaction_date) AS yer , 
DATEPART(month , transaction_date) AS moth , SUM(amount) AS total_spend
FROM creditcard_tbl  
GROUP BY card_type,exp_type, DATEPART(YEAR , transaction_date),
DATEPART(month , transaction_date)) tbl WHERE (yer=2013 AND moth=12) OR (yer=2014 AND moth=1)) tbl_1
ORDER BY (total_spend-lst_month_sale) DESC;


--which city took least number of days to reach its 500th transaction after the first transaction in that city.

SELECT TOP 1 A.City, transaction_500th, transaction_1st ,
DATEDIFF(DAY ,transaction_1st , transaction_500th) days_for_500th_transcation
FROM 
(SELECT City, transaction_date AS transaction_500th FROM 
(SELECT City , transaction_date ,
ROW_NUMBER() OVER (PARTITION BY City ORDER BY transaction_date) rn
FROM creditcard_tbl) tbl_1 WHERE rn=500) A
INNER JOIN 
(SELECT City, transaction_date AS transaction_1st FROM 
(SELECT City , transaction_date ,
ROW_NUMBER() OVER (PARTITION BY City ORDER BY transaction_date) rn
FROM creditcard_tbl) tbl_1 WHERE rn=1) B
ON A.City=B.City
ORDER BY DATEDIFF(DAY ,transaction_1st , transaction_500th);













