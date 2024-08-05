proc contents data= projlib.glu_g varnum;
run;

* Demographics;
data work.demo;
set projlib.demo_g;
keep SEQN RIAGENDR RIDAGEYR;
run;

* HDL;
data work.hdl;
set projlib.hdl_g;
keep SEQN LBDHDD;
run;

* LDL;
data work.ldl;
set projlib.trigly_g;
keep SEQN LBDLDL;
run;

* Physical activity;
data work.phyact;
set projlib.paq_g;
keep PAQ635 SEQN;
if PAQ635 = 7 or PAQ635 = 9 then delete;
if PAQ635 = 2  then PAQ635 = 0;
run;


proc freq data=work.phyact;
    tables PAQ635;
    where PAQ635 in (1, 0);
run;


* Alocohol;
data work.alcohol;
set projlib.alq_g;
keep SEQN ALQ130;
if ALQ130 = 777 or ALQ130 = 999 then delete;
run;


*Weight;
data work.wtg;
set projlib.whq_g;
keep SEQN WHD020 WHQ030;
if WHD020 = 7777 or WHD020 = 9999 then delete;
if WHQ030 = 7 or WHQ030 = 9 then delete;
run;



* Blood Pressure;
data work.bp;
set projlib.bpq_g;
keep SEQN BPQ020;
if BPQ020= 2 then BPQ020 = 0;
if BPQ020 = 7 or BPQ020 = 9 then delete;
run;

* Diabetes;
data work.diabetes;
set projlib.diq_g;
keep SEQN DIQ010;
  if DIQ010 =3 or DIQ010 = 7 or DIQ010 = 9  then delete;
  if DIQ010 = 2 then DIQ010 = 0;
run; 

proc freq data=work.diabetes;
    tables DIQ010;
    where DIQ010 in (1, 0);
run;



* Insulin;
data work.glucose;
set projlib.glu_g;
keep SEQN LBXIN LBXGLU;
run;


* Merge all datasets on SEQN;
proc sort data=work.demo; 
by SEQN;
run;
proc sort data=work.hdl; 
by SEQN; 
run;
proc sort data=work.ldl; 
by SEQN; 
run;
proc sort data=work.phyact; 
by SEQN; 
run;
proc sort data=work.alcohol; 
by SEQN; 
run;
proc sort data=work.wtg; 
by SEQN; 
run;
proc sort data=work.bp; 
by SEQN; 
run;
proc sort data=work.diabetes; 
by SEQN; 
run;  
proc sort data=work.glucose; 
by SEQN; 
run;

data work.merged_data;
    merge work.demo
          work.hdl
          work.ldl
          work.phyact
          work.alcohol
          work.wtg
          work.bp
          work.diabetes
          work.glucose;
    by SEQN;
run;

* Print first 10 obs;
proc print data=merged_data(obs=10);
run;

* Print contents;
proc contents data=merged_data varnum;
run;

 

****************************;



******************************;
****************Formats;
* Define a format for the gender variable;
proc format;
    value GenderFmt
        1 = 'Male'
        2 = 'Female';
run;

* Define a format for the diabetes variable;
proc format;
    value DiabFmt
        1 = 'Diabetic'
        0 = 'Not Diabetic';
run;


* Define a format for the ALCOHOL30 variable;
proc format;
    value WHQ030Fmt
        1 = 'Overweight'
        2 = 'Underweight'
        3 = 'Normal';
run;

proc format;
value BPFmt
	1 = 'Hypertensive'
	0 = 'Not Hyptertensive';
run;

proc format;
value PAQFmt
	1 = 'Yes'
	0 = 'No';
run;




* EDA;
* Summary statistics;
proc means data=merged_data min max q1 median q3 maxdec =2;
    var LBDHDD LBDLDL ALQ130 WHD020 LBXGLU LBXIN;
run;


* Diabetes by gender
* Frequency distributions;
title "Percentage of People with Diabetes by Gender";
proc freq data=merged_data;
 format RIAGENDR GenderFmt.; 
     format DIQ010  DiabFmt.;
    tables DIQ010*RIAGENDR / norow nocol out=DG;
    ODS NoProctitle;
run;



* Creating a stacked vertical bar chart for Diabetes with formatted gender labels;

proc sgplot data=DG;
    styleattrs datacolors=(blue red);
    vbar DIQ010 / response=count group=RIAGENDR groupdisplay=stack stat=percent;
    xaxis label='Diabetes Status';
    yaxis label='Percentage';
run;


* Diabetes by physical exercise
* Frequency distributions;
title "Percentage of People with Diabetes by Physical Exercise";
proc freq data=merged_data;
 format PAQ635 PAQFmt.; 
   format DIQ010  DiabFmt.;
    tables DIQ010*PAQ635 / norow nocol out=DP;
    ODS NoProctitle;
run;


* Creating a stacked vertical bar chart for Diabetes with formatted physical exercise labels;

proc sgplot data=DP;
    styleattrs datacolors=(green yellow);
    vbar DIQ010 / response=count group=PAQ635 groupdisplay=stack stat=percent;
    xaxis label='Diabetes Status';
    yaxis label='Percentage';
run;

* Diabetes by weight status
* Frequency distributions;
title "Percentage of People with Diabetes by Weight Category";
proc freq data=merged_data;
 format WHQ030 WHQ030Fmt.; 
   format DIQ010  DiabFmt.;
    tables DIQ010*WHQ030 / norow nocol out=DA;
    ODS NoProctitle;
run;


* Creating a stacked vertical bar chart for Diabetes with formatted Weight labels ;
proc sgplot data=DA;
    styleattrs datacolors=(violet blue biyg);
    vbar DIQ010 / response=count group=WHQ030 groupdisplay=cluster stat=percent;
    xaxis label='Diabetes Status';
    yaxis label='Percentage';
run;


* Diabetes by blood pressure status
* Frequency distributions;
title "Percentage of People with Diabetes by BP Status";
proc freq data=merged_data;
 format BPQ020 BPFmt.; 
   format DIQ010  DiabFmt.;
    tables DIQ010*BPQ020 / norow nocol out=DBP;
    ODS NoProctitle;
run;


* Creating a stacked vertical bar chart for Diabetes with formatted BP labels;
proc sgplot data=DBP;
    styleattrs datacolors=(blue biyg);
    vbar DIQ010 / response=count group=BPQ020 groupdisplay=cluster stat=percent;
    xaxis label='Diabetes Status';
    yaxis label='Percentage';
run;

* Histograms;
proc sgplot data=merged_data;
    histogram LBXIN / binwidth=10  fillattrs=(color=yellow);
    title 'Histogram of Insulin (uU/mL)';
    xaxis label='Insulin';
    yaxis label='Frequency';
run;

proc sgplot data=merged_data;
    histogram  LBXGLU / binwidth=10  fillattrs=(color=blue);
    title 'Histogram of Fasting Glucose (mg/dL)';
    xaxis label='Fasting Glucose';
    yaxis label='Frequency';
run;

proc sgplot data=merged_data;
    histogram LBDHDD / binwidth=10  fillattrs=(color=blueviolet);
    title 'Histogram of Direct HDL-Cholesterol(mg/dL)';
    xaxis label='HDL';
    yaxis label='Frequency';
run;

proc sgplot data=merged_data;
    histogram LBDLDL / binwidth=10  fillattrs=(color=green);
    title 'Histogram of LDL-Cholesterol(mg/dL)';
    xaxis label='LDL';
    yaxis label='Frequency';
run;

proc sgplot data=merged_data;
    histogram WHD020 / binwidth=10  fillattrs=(color=orange);
    title 'Histogram of Weight';
    xaxis label='Weight(Pounds)';
    yaxis label='Frequency';
run;


* Correlation Analysis;
proc corr data=merged_data; 
    var RIDAGEYR LBDHDD LBDLDL WHD020 LBXGLU LBXIN  ALQ130 ;
run;


* Missing vlaues;
data merged_data_clean;
    set merged_data; 
    if cmiss(of _all_) = 0;
run;

* Print contents;
proc contents data=merged_data_clean varnum;
run;


* Create a sample data set with 60% of the records;
proc surveyselect data=merged_data_clean out=sample_data
    method=srs /* Simple Random Sample */
    samprate=0.6 /* 60% for training */
    outall /* Outputs all records, selected or not */
    seed=12345; /* Seed for reproducibility */
run;

* Split data into training (60%) and testing (40%) sets;
data training testing;
    set sample_data;
    if Selected = 1 then output training;
    else output testing;
run;

proc contents data=testing; 
run;

proc contents data=training; 
run;



*Logistic Regression on merged_data_clean with DIQ010 as the outcome;
proc logistic data=training descending outmodel=LogitModel;
    class RIAGENDR (ref='1') 
          PAQ635 (ref='1')     
          BPQ020 (ref='1'); 
    model DIQ010(event='1') = RIAGENDR RIDAGEYR LBDHDD LBDLDL WHD020 LBXGLU LBXIN PAQ635 ALQ130 WHD020 BPQ020;
    roc;
run;



* Validate the model on the testing set;
proc logistic inmodel=LogitModel;
    score data=testing out=testing_pred;
run;

* Print first 20 obs;
proc print data=testing_pred(obs=5);
run;
 


































