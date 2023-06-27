-- FIND NAME OF STUDENTS WHO SCORED MORE THAN AVERAGE MARKS IN EACH SUBJECT

SELECT studentname FROM 
(SELECT *,
AVG(marks) OVER(PARTITION BY subject) AS avg_marks
FROM students) temp_1
WHERE marks>avg_marks;

-- FIND PERCENTAGE OF STUDENTS WHO SCORED MORE THAN 90 IN ANY SUBJECTS AMONGST TOTAL STUDENTS.

SELECT CAST(NUM AS float)/NUM_1*100 FROM 
(SELECT COUNT(DISTINCT(studentid)) as num,ROW_NUMBER() OVER(ORDER BY count(1)) as rn  FROM students WHERE marks>90) e1
INNER JOIN
(SELECT COUNT(DISTINCT(studentid)) as num_1 ,ROW_NUMBER() OVER(ORDER BY count(1)) as rn FROM students) e2
ON e1.rn=e2.rn;

-- WRITE A SQL QUERY TO GET SECOND HIGHEST AND SECOND LOWEST SALARY IN EACH SUBJECT

SELECT H1.subject,second_highest_marks,second_lowest_marks
FROM 
(SELECT subject,marks as second_highest_marks FROM 
(SELECT *,
DENSE_RANK() OVER(PARTITION BY subject ORDER BY marks DESC) as rnk
FROM students) temp_1
WHERE rnk=2) H1
INNER JOIN 
(SELECT subject,marks as second_lowest_marks FROM 
(SELECT *,
DENSE_RANK() OVER(PARTITION BY subject ORDER BY marks) as rnk
FROM students) temp_1
WHERE rnk=2) L1
ON H1.subject=L1.subject


-- FOR EACH STUDENT FIND THAT THEIR MARKS ARE INCREASED OR DECREASED FROM PREVIOUS TEST.

SELECT * ,
CASE
WHEN progress<=0 THEN 'dec' ELSE 'inc' END AS status
FROM
(SELECT studentname,ISNULL(progress,0) as progress FROM 
(SELECT studentname , marks-PREV_MARKS AS progress FROM 
(SELECT studentname,subject,marks,testdate,
LAG(marks) OVER(PARTITION BY studentid ORDER BY testdate,subject) PREV_MARKS
FROM students) temp_1) temp_1) temp_2




