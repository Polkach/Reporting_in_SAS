%macro topn(category,n);
	proc sql noprint;
		/*Вычислим сумму остатков на всех счетах для каждого клиента
		требуемой категории*/
		create table help as
			select distinct customer, sum(sum) as money
			from balance
			where category="&category"
			group by customer;
		/*Вычислим сумму остатков на всех счетах клиентов
		выбранной категории*/
		select sum(money) format dollar10. into :total from help;
	quit;
	
	/*Отсортируем по убыванию*/
	proc sort data=help;
		by descending money;
	run;
	
	/*Выберем первые n строк*/
	data help_top;
		set help;
		retain i 0;
		i+1;
		if i<=&n then output;
	run;
	
	/*В зависимости от требуемого числа клиентов различаются окончания
	слов в заголовке отчета*/
	data slovo;
		n=&n;
		if mod(n,10)=0 or ((11<=mod(n,100)) and (mod(n,100)<=14)) then
		    a = "крупнейших клиентов";
		else do;
			if mod(n,10)=1 then a = "крупнейший клиент";
			else do;
				if (2<=mod(n,10)) and (mod(n,10)<=4) then a = "крупнейших клиента";
				else a = "крупнейших клиентов";
    		end;
    	end;
	run;
	
	/*Сохраняем слова в нужных формах в макропеременную*/
	proc sql noprint;
		select a into :a from slovo;
	quit;
	
	/*Создаем требуемый отчет*/
	proc print data=help_top split='*';
		id i;
		sum money;
		var customer money;
		label customer='Клиент'
			money='Сумма'
			i='Позиция';
		format money dollar10.;
		title1 "&n &a в категории &category";
		title2 "(сумма остатков по всем клиентам данной категории составляет &total)";
	run;
	
	proc sql;
		drop table help,help_top,slovo;
	quit;
%mend topn;

%topn(BANK,10);