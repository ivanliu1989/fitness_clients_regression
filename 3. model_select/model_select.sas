/* create library Fitness */
libname fitness "C:\Users\Ivan.Liuyanfeng\Desktop\Data_Mining_Work_Space\Fitness_clients_regression";
run;

/* redirect log to handle the log limitations */
proc printto log="C:\Users\Ivan.Liuyanfeng\Desktop\Data_Mining_Work_Space\Fitness_clients_regression\model_select.log";
run;

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
