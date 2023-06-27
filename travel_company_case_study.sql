












--Q.1 

SELECT E1.Segment,E2.total_user_count,E1.users_booked_flight_in_apr_2022
FROM
(SELECT Segment , COUNT(1) AS users_booked_flight_in_apr_2022 FROM
(SELECT DISTINCT user_id,Segment FROM
(SELECT t2.user_id,Segment FROM 
(SELECT * FROM booking_table WHERE Line_of_business='Flight' AND Booking_date BETWEEN '2022-04-01' AND '2022-04-30') t1
INNER JOIN 
user_table t2 
ON t1.user_id=t2.user_id) temp_1) temp_2
GROUP BY Segment) E1
INNER JOIN
(SELECT Segment,COUNT(1) AS total_user_count FROM user_table GROUP BY Segment) E2
ON E1.Segment=E2.Segment;


--Q.2 
SELECT user_id FROM 
(SELECT *,
DENSE_RANK() OVER(PARTITION BY user_id ORDER BY Booking_date) AS rnk
FROM booking_table) temp_1
WHERE Line_of_business='Hotel' AND rnk=1


--Q.3
SELECT user_id,DATEDIFF(day,first_booking,last_booking) as days 
FROM
(SELECT user_id,MIN(booking_date)AS first_booking,MAX(Booking_date) AS last_booking
FROM booking_table GROUP BY user_id) temp_1


--Q.4
SELECT Segment,
COUNT(CASE WHEN line_of_business='Flight' THEN user_id END) AS flight_cnt,
COUNT(CASE WHEN line_of_business='Hotel' THEN user_id END) AS hotel_cnt
FROM 
(SELECT t1.User_id,t1.Segment,t2.Booking_date,t2.Line_of_business FROM user_table t1
INNER JOIN
booking_table t2
ON t1.User_id=t2.User_id) temp_1 GROUP BY Segment 


