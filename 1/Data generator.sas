/*  Создание тестового набора данных */
data balance;
  length customer $4 category $10 account $6 sum 8;
  format customer $4. category $10. account $6. sum ollar10.;
  array cat1 [1:6]  8  _TEMPORARY_ (1, 2, 2, 3, 3, 3);
  array cat2 [1:3] $10 _TEMPORARY_ ('BANK', 'COMPANY', 'INDIVIDUAL');
  array acc  [1:3]  8  _TEMPORARY_ (5, 3, 2);
  array sumsize [1:3, 1:10] 8  _TEMPORARY_
    (0, 0,  0,   0,   0,   10,  100,  1000, 10000, 100000,
     0, 0,  0, 100, 100, 1000, 1000, 10000, 10000,  50000,
     0, 0, 10,  50, 100,  500, 1000,  5000, 10000,  20000);
  do i=1 to 1000;
    customer=put(i,z4.);  
    rc=cat1[floor(ranuni(0)*(dim(cat1)-1)+0.5)+1];
    category=cat2[rc];  
    accounts=floor(ranuni(0)*acc[rc]+0.5)+1;
    do j=1 to accounts;
      accountn+1;
      account=put(accountn,z6.);
      sum=(ranuni(0)*sumsize[rc,floor(ranuni(0)*10)+1]);
      output;
    end;
  end;
  drop rc i j accountn accounts;
run;

/* Вывод отчета с 10 записями (для проверки того, что было сгенерировано */

proc print data=balance(obs=10);
run;
