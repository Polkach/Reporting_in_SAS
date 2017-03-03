proc sql;
	/*Выбираем из каждой записи зарплату, пол и возрастную группу (по 3 года)*/
	create table report as
		select (year('01JAN2007'd)-1-year(birth_date)) as age,
			salary, gender
		from hw.employees;
		
	/*Подготавливаем таблицу для создания формата age_category*/
	create table for_format as
		select distinct age as start,
			'age_category' as FmtName,
			cat((int(age/3.0)*3.0),'-',((int(age/3.0)+1)*3)) as Label
		from report;
quit;

/*Создаем формат age_category*/
proc format
	CNTLIN=for_format;
run;

/*Создаем формат $gender*/
proc format;
	value $gender
		"M"="Мужчины"
		"F"="Женщины";
run;

/*Сохраняем сегодняшнюю дату в макропеременную*/
data _null_;
	format a ddmmyys10.;
	a = today();
	b = put(a, ddmmyys10.);
	call symputx('dt',b);
run;

/*Указываем формат и место сохранения*/
ods pdf file='/folders/myfolders/Komkov_SAS_2016.pdf';

/*Создаем требуемый отчет*/
proc tabulate data=report format=dollar10.;
	format gender $gender.
		age age_category.;
	class gender age;
	CLASSLEV gender / S=[foreground=black background=light_grey]; 
	CLASSLEV age / S=[foreground=black background=light_grey]; 
	var salary;
	table age=' ' 
		all={label='Без учета возраста' S=[foreground=black background=light_grey]}*{style={background=pink}},
		gender=' '*salary=' '*(mean) 
		salary=' '*all={label='Без учета пола' S=[foreground=black background=light_grey]}*(mean*{style={background=pink}}) /
		box={label='Возрастная категория' S=[foreground=black background=light_grey]};
	keylabel mean=' ';
	title 'Средние зарплаты в компании';
	footnote "Дата формирования отчета: &dt";
run;

ods pdf close;

/*Удаляем вспомогательные таблицы*/
proc sql;
	drop table report,for_format;
quit;