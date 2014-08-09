/* create library Fitness */
libname fitness "C:\Users\Ivan.Liuyanfeng\Desktop\Data_Mining_Work_Space\Fitness_clients_regression";
run;

/* redirect log to handle the log limitations */
proc printto log="C:\Users\Ivan.Liuyanfeng\Desktop\Data_Mining_Work_Space\Fitness_clients_regression\fitness.log";
run;

/* 1. Fit test (PP plot) */
ods listing close;
ods pdf file = 'C:\Users\Ivan.Liuyanfeng\Desktop\Data_Mining_Work_Space\Fitness_clients_regression\fitness_unistats.pdf';

proc univariate data=fitness.b_fitness;
   var Runtime -- Performance;
   histogram Runtime -- Performance / normal;
   probplot  Runtime -- Performance
             / normal (mu=est sigma=est color=red w=2);
   title 'Univariate Statistics of sasuser.b_fitness';
run;

ods pdf close;
ods listing;

/* 2.Scatter plot */
ods pdf file = 'C:\Users\Ivan.Liuyanfeng\Desktop\Data_Mining_Work_Space\Fitness_clients_regression\scatter_plot.pdf';

options ps=20 ls=34;
goptions reset=all gunit=pct border
         fontres=presentation ftext=swissb;

axis1 length=50 w=2 color=blue label=(h=2) value=(h=2);
axis2 length=50 w=2 color=blue label=(h=2) value=(h=2);

proc gplot data=fitness.b_fitness;
   plot oxygen_consumption * (runtime age weight run_pulse
        rest_pulse maximum_pulse performance)
        / vaxis=axis1 haxis=axis2;
   symbol1 v=dot h=2 w=4 color=red;
   title h=5 color=green 'Plot of Oxygen Consumption by Other Variables';
run;
quit;

ods pdf close;

/* 3.Correlation coefficient */
ods pdf file = 'C:\Users\Ivan.Liuyanfeng\Desktop\Data_Mining_Work_Space\Fitness_clients_regression\correlation.pdf';

proc corr data=fitness.b_fitness rank;
   var runtime age weight run_pulse rest_pulse maximum_pulse
       performance;
   with oxygen_consumption;
   title 'PROC CORR: oxygen_consumption with predictor variables';
run;

ods pdf close;
ods listing;
