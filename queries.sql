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

select '16-25' as age_category, (select count(*) from customers c 
where Age >= 16 and age <=25)  as count
UNION
select '26-40' as age_category, (select count(*) from customers c 
where Age >= 26 and age <=40)  as count
UNION
select '40+' as age_category, (select count(*) from customers c 
where Age > 40)  as count
order by age_category

---Первый отчет - количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+. 
---Итоговая таблица должна быть отсортирована по возрастным группам и содержать следующие поля: age_category и count 


with tab as (select extract(year from s.sale_date) as years,
extract(Month from s.sale_date) as months,
count(distinct s.customer_id) as total_customers,
ROUND(SUM(s.quantity*p.price)) as income from sales s 
inner join products p on s.product_id = p.product_id 
group by years,months
order by years,months)

select concat(years,'-', months) as date, total_customers, income from tab

---Во втором отчете предоставьте данные по количеству уникальных покупателей и выручке, которую они принесли. 
---Сгруппируйте данные по дате, которая представлена в числовом виде ГОД-МЕСЯЦ. 
---Итоговая таблица должна быть отсортирована по дате по возрастанию и содержать следующие поля: date, total_customers, income 

with tab as (select distinct s.customer_id  as customer,
first_value(s.sale_date) over(partition by s.customer_id order by s.sale_date) as sale_date,
s.sales_person_id  as seller from sales s
inner join products p on s.product_id = p.product_id  where p.price = 0
order by s.customer_id)

select  concat(c.first_name,' ',c.last_name) as customer,
sale_date,
concat(e.first_name,' ',e.last_name) as seller
from tab
inner join customers c on c.customer_id  = tab.customer 
INNER join employees e on e.employee_id = tab.seller

---Третий отчет следует составить о покупателях, первая покупка которых была в ходе проведения акций (акционные товары отпускали со стоимостью равной 0).
--- Итоговая таблица должна быть отсортирована по id покупателя. Таблица состоит из следующих полей:

---customer - имя и фамилия покупателя
---sale_date - дата покупки
---seller - имя и фамилия продавца
