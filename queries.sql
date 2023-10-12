select COUNT(customer_id) as customers_count from  customers
--- Запрос подсчитывает кол-во записей в столбце customer_ID таблицы customers

with tab as (select s.sales_person_id as id,
ROUND(AVG(quantity*price)) as average_income
from sales s 
inner join products p on s.product_id = p.product_id 
group by s.sales_person_id
order by average_income desc)
select CONCAT(e.first_name,' ',e.last_name) as name,
average_income from tab
INNER join employees e on tab.id = e.employee_id 
where average_income < (select avg(average_income) from tab)
order by average_income
---информация о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам.
--- Таблица отсортирована по выручке по возрастанию.


with tab as (Select s.sales_person_id  as id,
extract(DOW from s.sale_date) as weekdaynum,
ROUND(SUM(s.quantity * p.price)) as income
from sales s 
inner join products p on s.product_id = p.product_id 
group by s.sales_person_id, extract(DOW from s.sale_date))
select CONCAT(e.first_name,' ',e.last_name) as name,
CASE
WHEN weekdaynum = 0 THEN 'Monday'
WHEN weekdaynum = 1 THEN 'Tuesday'
WHEN weekdaynum = 2 THEN 'Wednesday'
WHEN weekdaynum = 3 THEN 'Thursday'
WHEN weekdaynum = 4 THEN 'Friday'
WHEN weekdaynum = 5 THEN 'Saturday'
else 'Sunday'
END Weekday,
income
from tab
inner join employees e on tab.id = e.employee_id
order by weekdaynum, name 
---Третий отчет содержит информацию о выручке по дням недели. Каждая запись содержит имя и фамилию продавца, день недели и суммарную выручку.
--- Отсортируйте данные по порядковому номеру дня недели и name
