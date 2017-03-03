/*Создаем формат декады*/
proc format;
	value decade
		10-19='10-19'
		20-29='20-29'
		30-39='30-39'
		40-49='40-49'
		50-59='50-59'
		60-69='60-69'
		70-79='70-79'
		80-89='80-89';
		

proc sql;
	/*Создаем таблицу с продажами*/
	create table orders as
		select customer_id as id, order_date as date, total_retail_price as money
		from hw.order_fact;
	/*Создаем таблицу с покупателями*/
	create table customers as
		select customer_id as id, birth_date as birth
		from hw.customer;
	/*Объединяем таблицы так, чтобы для каждой покупки было указано, к какой возрастной
	декаде относится клиент*/
	create table merged as
		select c.id,
		(int((o.date-c.birth)/365.25)-mod(int((o.date-c.birth)/365.25),10)) as age format=decade.,
		year(o.date) as year, o.money
		from customers as c
		left join orders as o on c.ID=o.ID;
	/*Агрегируем данные, группируя по возрастной декаде и году продажи, вычисляя
	число уникальных клиентов и сумму продаж*/
	create table info as
		select year label="Год", age label="Возраст",
			sum(money) as total label="Суммарная выручка от продаж",
			count(distinct id) as uniq label="Количество уникальных клиентов"
		from merged
		where year^=.
		group by year, age;
	/*Удаляем вспомогательные таблицы*/
	drop table orders,customers,merged;
quit;

ods graphics / reset imagemap;

/*Требуемая пузырьковая диаграмма*/
proc sgplot data=WORK.INFO;
	title H=11pt 'Объемы продаж в разрезе года и возраста клиентов';

	bubble x=year y=age size=total/ colorresponse=uniq colormodel=(CXff0000 
		CXffff00 CX00ff00) name='Bubble';

	xaxis grid;

	yaxis grid;

	gradlegend / position=right;
run;

ods graphics / reset;
title;
