SELECT *
FROM employees;

SELECT *
FROM sales;

--Find the employees whose salary is higher than the average salary of all employees.

SELECT *
FROM employees
WHERE salary >
(SELECT AVG(salary) 
FROM employees);


--Find the second-highest salary among all employees.

with high_sal AS
(
SELECT *,DENSE_RANK() OVER(ORDER BY salary DESC) AS highest_salary
FROM employees
)
SELECT *
FROM high_sal
WHERE highest_salary=2;


--Find the highest-paid employee in each department.

WITH dept_paid AS
(
SELECT *,ROW_NUMBER() OVER(PARTITION BY department ORDER BY salary DESC) AS dept_highpaid
FROM employees
)
SELECT *
FROM dept_paid
WHERE dept_highpaid=1;


--Rank all employees based on their salary from highest to lowest.

SELECT *,ROW_NUMBER() OVER(ORDER BY salary DESC) AS rank_salary
FROM employees;


--Find the top 3 highest-paid employees in each department.

WITH dept_salary AS
(
SELECT *,ROW_NUMBER() OVER(PARTITION BY department ORDER BY salary DESC) AS dept_rank
FROM employees
)
SELECT *
FROM dept_salary
WHERE dept_rank<=3;


--For each employee, find their previous sale amount based on the sale date.

SELECT *,LAG(amount) OVER(PARTITION BY employee_id ORDER BY sale_date) AS prev_sale_amount
FROM sales;


--Calculate the running total of sales for each employee.

SELECT *,SUM(amount) OVER(PARTITION BY employee_id ORDER BY sale_date) AS running_total
FROM sales;


--Find the total sales for each month.

SELECT EXTRACT(year FROM sale_date) AS year, EXTRACT(month FROM sale_date) AS month, SUM(amount) AS total_sales
FROM sales
GROUP BY month,year
ORDER BY year,month;


--Calculate the month-over-month sales growth percentage.
WITH month_sales AS
(
SELECT EXTRACT(year FROM sale_date) AS year, EXTRACT(month FROM sale_date) AS month, SUM(amount) AS total_sales
FROM sales
GROUP BY month,year
ORDER BY year,month
),
prev_month AS
(
SELECT *,LAG(total_sales)OVER(PARTITION BY year ORDER BY month) AS previous_month_sales
FROM month_sales
)
SELECT *,ROUND(100*((total_sales)-(previous_month_sales))/previous_month_sales,2) AS growth_percentage
FROM prev_month;


--Find the percentage contribution of each employee's total sales to the overall sales.

WITH employee_sales AS (
SELECT e.name,
SUM(s.amount) AS total_sales
FROM sales s
JOIN employees e
ON s.employee_id = e.employee_id
GROUP BY e.name
)
SELECT name,total_sales,ROUND(100.0 * total_sales / SUM(total_sales) OVER (),2) AS percentage_contribution
FROM employee_sales
ORDER BY percentage_contribution DESC;


--For each department, find the highest-paid employee, their salary, and the average salary of that department.

WITH high_paid AS
(
SELECT name, salary,department, ROW_NUMBER() OVER(PARTITION BY department ORDER BY salary DESC) AS high_paid_emp,
ROUND(AVG(salary) OVER(PARTITION BY department),2) AS avg_dept_sal
FROM employees
)
SELECT *
FROM high_paid
WHERE high_paid_emp=1;sss