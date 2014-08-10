/* create library Fitness */
libname fitness "C:\Users\Ivan.Liuyanfeng\Desktop\Data_Mining_Work_Space\Fitness_clients_regression";
run;

/* redirect log to handle the log limitations */
proc printto log="C:\Users\Ivan.Liuyanfeng\Desktop\Data_Mining_Work_Space\Fitness_clients_regression\fitness_reg.log";
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

/* Model selection by all_reg, forward, backward and stepwise */
ods listing close;
ods pdf file = 'C:\Users\Ivan.Liuyanfeng\Desktop\Data_Mining_Work_Space\Fitness_clients_regression\model_select.pdf';

proc reg data=fitness.b_fitness;
   title h=2 'Best=4 Models Using All Regression Option';

   ALL_REG: model oxygen_consumption 
                    = performance runtime age weight
                      run_pulse rest_pulse maximum_pulse
            / selection=rsquare adjrsq cp best=4;
   plot cp.*np. /
        nomodel nostat
        vaxis=0 to 30 by 5
        haxis=2 to 7 by 1 /* p=0,p=1 do not add information */
        cmallows=red
        chocking=blue;
   symbol v=plus color=green h=2;

   title 'Stepwise Regression Methods';

   FORWARD: model oxygen_consumption
                    = performance runtime age weight
                      run_pulse rest_pulse maximum_pulse
                    / selection=forward;
   BACKWARD: model oxygen_consumption
                    = performance runtime age weight
                      run_pulse rest_pulse maximum_pulse
                    / selection=backward;
   STEPWISE: model oxygen_consumption
                    = performance runtime age weight
                      run_pulse rest_pulse maximum_pulse
                    / selection=stepwise;


run;
quit;

ods pdf close;
ods listing;

/* 1. Residual examination */
ods listing close;
ods pdf file = 'C:\Users\Ivan.Liuyanfeng\Desktop\Data_Mining_Work_Space\Fitness_clients_regression\model_diag_residual.pdf';

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
ods pdf file = 'C:\Users\Ivan.Liuyanfeng\Desktop\Data_Mining_Work_Space\Fitness_clients_regression\model_diag_outlier.pdf';
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
ods pdf file = 'C:\Users\Ivan.Liuyanfeng\Desktop\Data_Mining_Work_Space\Fitness_clients_regression\model_diag_collinearity.pdf';

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


