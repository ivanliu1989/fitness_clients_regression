/* create library Fitness */
libname fitness "C:\Users\Ivan.Liuyanfeng\Desktop\Data_Mining_Work_Space\Fitness_clients_regression";
run;

/* redirect log to handle the log limitations */
proc printto log="C:\Users\Ivan.Liuyanfeng\Desktop\Data_Mining_Work_Space\Fitness_clients_regression\4. model_diag\model_select.log";
run;

/* 1. Residual examination */
ods listing close;
ods pdf file = 'C:\Users\Ivan.Liuyanfeng\Desktop\Data_Mining_Work_Space\Fitness_clients_regression\4. model_diag\model_diag_residual.pdf';

proc reg data=fitness.b_fitness;
   PREDICT: model oxygen_consumption 
                  = runtime age run_pulse maximum_pulse;
   plot r.*(p. runtime age run_pulse maximum_pulse);
   plot student.*obs. / vref=3 2 -2 -3
                        haxis=0 to 32 by 1;
   plot nqq.*student.; /**student. is residuals divided by their standard errors***/
   symbol v=dot;
   title 'PREDICT Model - Plots of Diagnostic Statistics';
run;
quit;

ods pdf close;

/* 2.Outlier detection */
ods pdf file = 'C:\Users\Ivan.Liuyanfeng\Desktop\Data_Mining_Work_Space\Fitness_clients_regression\4. model_diag\model_diag_outlier.pdf';
proc reg data=fitness.b_fitness;
   PREDICT: model oxygen_consumption
                      = runtime age run_pulse maximum_pulse
                      / r influence;
   id name;
   output out=ck4outliers 
          rstudent=rstud dffits=dfits cookd=cooksd;
   title;
run;
quit;

ods pdf close;
/*  set the values of these macro variables, */
/*  based on your data and model.            */
%let numparms = 5;  /* # of predictor variables + 1 */ 
%let numobs = 31;   /* # of observations */
%let idvars = name; /* relevant identification variable(s) */

data fitness.influential;
  set ck4outliers; 
	
   cutdifts = 2*(sqrt(&numparms/&numobs));
   cutcookd = 4/&numobs;

   rstud_i = (abs(rstud)>3);
   dfits_i = (abs(dfits)>cutdifts);
   cookd_i = (cooksd>cutcookd);
   sum_i = rstud_i + dfits_i + cookd_i;
   if sum_i > 0;
run;

/* 3.Collinearity */
ods pdf file = 'C:\Users\Ivan.Liuyanfeng\Desktop\Data_Mining_Work_Space\Fitness_clients_regression\4. model_diag\model_diag_collinearity.pdf';

proc reg data=fitness.b_fitness;
   FULLMODL: model oxygen_consumption
                         =  runtime age 
                           run_pulse  maximum_pulse 
                         / vif collin collinoint; /*variance inflation,where vif>2 will be considered collinearity*/
   title 'Collinearity -- Full Model';
run;
quit;
ods pdf close;
ods listing;



