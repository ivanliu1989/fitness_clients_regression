/* create library Fitness */
libname fitness "C:\Users\Ivan.Liuyanfeng\Desktop\Data_Mining_Work_Space\Fitness_clients_regression";
run;

/* redirect log to handle the log limitations */
proc printto log="C:\Users\Ivan.Liuyanfeng\Desktop\Data_Mining_Work_Space\Fitness_clients_regression\one_reg.log";
run;

/* simple linear regression */
ods listing close;
ods pdf file = 'C:\Users\Ivan.Liuyanfeng\Desktop\Data_Mining_Work_Space\Fitness_clients_regression\sim_lr.pdf';

proc reg data=fitness.b_fitness;
   model oxygen_consumption=performance;
   title 'Simple Linear Regression of Oxygen Consumption ' 
         'and Performance';
run;
quit;

ods pdf close;

/* 2.Pridiction and confidence interval */
ods pdf file = 'C:\Users\Ivan.Liuyanfeng\Desktop\Data_Mining_Work_Space\Fitness_clients_regression\prid_conf.pdf';

data need_predictions;
   input performance @@;
   datalines;
0 3 6 9 12
;
run;

data predoxy;
   set fitness.b_fitness 
       need_predictions;
run;

proc reg data=predoxy;
   model oxygen_consumption=performance / p;
   id performance;
   title 'Oxygen_Consumption=Performance with Predicted Values';   
run;
quit;


options ps=50 ls=76;
goptions reset=all fontres=presentation ftext=swissb htext=1.5;

proc reg data=predoxy;
   model oxygen_consumption=performance / clm cli alpha=.05;
   id name performance;
   plot oxygen_consumption*performance / conf pred;
   symbol1 c=red v=dot;
   symbol2 c=red;
   symbol3 c=blue;
   symbol4 c=blue;
   symbol5 c=green;
   symbol6 c=green;
   title;
run;
quit;
ods pdf close;
ods listing;

