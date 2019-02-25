libname case2"/folders/myfolders/SAS Master Case Study-2";
PROC IMPORT datafile="/folders/myfolders/SAS Master Case Study-2/POS_Q1.csv" out=case2.POS_Q1 dbms=csv replace; getnames=Yes;
PROC IMPORT datafile="/folders/myfolders/SAS Master Case Study-2/POS_Q2.csv" out=case2.POS_Q2 dbms=csv replace; getnames=Yes;
PROC IMPORT datafile="/folders/myfolders/SAS Master Case Study-2/POS_Q3.csv" out=case2.POS_Q3 dbms=csv replace; getnames=Yes;
PROC IMPORT datafile="/folders/myfolders/SAS Master Case Study-2/POS_Q4.csv" out=case2.POS_Q4 dbms=csv replace; getnames=Yes;
PROC IMPORT datafile="/folders/myfolders/SAS Master Case Study-2/Laptops.csv" out=case2.Laptops dbms=csv replace; getnames=Yes;
PROC IMPORT datafile="/folders/myfolders/SAS Master Case Study-2/London_postal_codes.csv" out=case2.London_postal_codes dbms=csv replace; getnames=Yes;
PROC IMPORT datafile="/folders/myfolders/SAS Master Case Study-2/Store_Locations.csv" out=case2.Store_Locations dbms=csv replace; getnames=Yes;
data POS_Qa;
set case2.POS_Q1;
data POS_Qb;
set case2.POS_Q2;
data POS_Qc;
set case2.POS_Q3;
data POS_Qd;
set case2.POS_Q4;
proc append base=POS_Qd data=POS_Qc force;
proc append base=POS_Qd data=POS_Qb force;
proc append base=POS_Qd data=POS_Qa force;
data POS_Combined;
set POS_Qd;
proc sort data=POS_Combined;
by Configuration;
run;
data Laptops_1;
set case2.Laptops;
proc sort data=Laptops_1;
by Configuration;
run;
data combined_1;
merge POS_Combined Laptops_1;
by Configuration;
run;
data London_postal_codes_1;
rename postcode=Customer_Postcode os_x=customer_x os_y=customer_y; 
set case2.London_postal_codes;
proc sort data=London_postal_codes_1;
by Customer_Postcode;
proc sort data=combined_1;
by Customer_Postcode;
data combined_2;
merge combined_1 London_postal_codes_1;
by Customer_Postcode;
run;
data Store_Locations_1;
rename postcode=Store_Postcode os_x=store_x os_y=store_y; 
set case2.Store_Locations;
proc sort data=Store_Locations_1;
by Store_Postcode;
proc sort data=combined_2;
by Store_Postcode;
data combined_master;
merge combined_2 Store_Locations_1;
by Store_Postcode;
run;
/*format given to months as abbr*/
proc Format;
Value M_abbr
1="Jan"
2="Feb"
3="Mar"
4="Apr"
5="May"
6="Jun"
7="July"
8="Aug"
9="Sep"
10="Oct"
11="Nov"
12="Dec"
;
run;
data combined_master1;
set combined_master;
format month M_abbr.;
run;

/*laptop price changes with time*/
proc tabulate data=combined_master1;
class month Configuration;
var Retail_Price;
table Configuration, month;
run;
proc tabulate data=combined_master1;
class month Configuration;
var Retail_Price;
table Configuration,(Retail_Price)*(mean)*month;
run;
proc sql;
select month,mean(Retail_Price) as Avg_Retail_Price from combined_master1
where Configuration = 61 group by month;
quit;

/*Avg Retail price across store and Do store with lower avg pricing sell more*/
/*All stores do not sell all configuration*/
/*Price over retail outlets are not consistent by configuration and stores*/
proc tabulate data=combined_master1;
class Store_Postcode Configuration;
var Retail_Price;
table Configuration,(Retail_Price)*(Mean)*Store_Postcode;
run;
proc tabulate data=combined_master1;
class  Store_Postcode Configuration;
var Retail_Price;
table Configuration, Store_Postcode ;
run;
/*Retail Price changes over months by each stores*/
proc tabulate data=combined_master1;
class month Store_Postcode;
var Retail_Price;
table (Retail_Price)*(Mean)*Store_Postcode,month;
run;
/* Stores selling the most*/
proc report data=combined_master1;
column Store_Postcode Configuration Sale_in_Percentage;
define Store_Postcode/group;
define Configuration/n;
compute Sale_in_Percentage;
Sale_in_Percentage=(Configuration.n/297572)*100;
endcomp;
rbreak after/ skip summarize;
run;
/*Avg Retail Prices by Configuration*/
/*Avg Retail price by changing the configuration type*/
proc Format;
Value Ram
1="low"
2="low"
4="High"
;
value battry
4="Low"
5="Medium"
6="High"
;
value Process
1.5="Slow"
2="Slow"
2.4="Fast"
;
value hd
40="less"
80="less"
120="More"
300="More"
;
run;
data combined_master2;
SET combined_master1;
format RAM__GB_ Ram. Processor_Speeds__GHz_ Process. Battery_Life__Hours_ battry. HD_Size__GB_ hd.;
run;
/*How does configuration effect laptop prices*/
/*Avg Retail Price Changes by screen and over months*/
proc tabulate data=combined_master2;
class month Screen_Size__Inches_;
var Retail_Price;
table (Retail_Price)*(Mean)*month,Screen_Size__Inches_;
run;
/*Avg Retail Price changes by Battery life and over months*/
proc tabulate data=combined_master2;
class month Battery_Life__Hours_;
var Retail_Price;
table (Retail_Price)*(Mean)*month,Battery_Life__Hours_;
run;
/*Avg Retail Price changes by Ram and over months*/
proc tabulate data=combined_master2;
class month RAM__GB_;
var Retail_Price;
table (Retail_Price)*(Mean)*month,RAM__GB_;
run;
/*Avg Retail Price changes by Processor Speeds GHz and over months*/
proc tabulate data=combined_master2;
class month Processor_Speeds__GHz_;
var Retail_Price;
table (Retail_Price)*(Mean)*month,Processor_Speeds__GHz_;
run;
/*Avg Retail Price changes by Integrated Wireless and over months*/
proc tabulate data=combined_master2;
class month Integrated_Wireless_;
var Retail_Price;
table (Retail_Price)*(Mean)*month,Integrated_Wireless_;
run;
/*Avg Retail Price changes by HD Size and over months*/
proc tabulate data=combined_master2;
class month HD_Size__GB_;
var Retail_Price;
table (Retail_Price)*(Mean)*month,HD_Size__GB_;
run;
/*Avg Retail Price changes by Bundled application and over months*/
proc tabulate data=combined_master2;
class month Bundled_Applications_;
var Retail_Price;
table month,(Retail_Price)*(Mean)*Bundled_Applications_;
run;
/*Configuration is influence prices of laptops*/
proc tabulate data=combined_master2;
class month Screen_Size__Inches_ Battery_Life__Hours_ RAM__GB_ Processor_Speeds__GHz_ Integrated_Wireless_ HD_Size__GB_ Bundled_Applications_;
var Retail_Price;
table month,(Retail_Price)*(Mean)*(Screen_Size__Inches_ Battery_Life__Hours_ RAM__GB_ Processor_Speeds__GHz_  Integrated_Wireless_ HD_Size__GB_ Bundled_Applications_);
run;
/*Sell by all configurations and store*/
proc tabulate data=combined_master2;
class Store_Postcode month;
var Configuration;
table Store_Postcode,(Configuration)*(N)*month;
Keylabel n=Count;
run;
/*Revenue Contribution by configuration*/
proc sql;
create table test1 as select distinct(Configuration) as rank,Screen_Size__Inches_,Battery_Life__Hours_,
RAM__GB_,Processor_Speeds__GHz_,Integrated_Wireless_,HD_Size__GB_,Bundled_Applications_,
avg(Retail_Price) as Avg_Retail_Price
from  combined_master2 group by Configuration;
quit;
proc print data=work.test1;
run;
/*How does location influence sales*/
data combined_master3;
set combined_master2;
Dist1 =(customer_x - store_x);
Dist2 =(customer_y - store_y);
Dist3 =(Dist1)*(Dist1);
Dist4 =(Dist2)*(Dist2);
Dist5=(Dist3+Dist4);
EuclidDist=sqrt(Dist5);
run;
proc Format;
Value EuclidDistt
0 - 1000="within onekm"
1000 - 2000="one to twokm"
2000 - 3000="two to threekm"
3000 - 4000="three to fourkm"
4000 - 5000="four to fivekm"
5000 - 6000="five to sixkm"
6000 - 7000="six to sevenkm"
7000 - 8000="seven to eightkm"
8000 - 9000="eight to ninekm"
9000 - 10000="nine to tenkm"
10000 - 11000="ten to elevenkm"
11000 - 12000="eleven to twelvekm"
12000 - 13000="twelve to thirteenkm"
13000 - 14000="thirteen to fourteenkm"
14000 - 15000="fourteen to fifteenkm"
15000 - 16000="fifteen to sixteenkm"
16000 - 17000="sixteen to seventeenkm"
17000 - 18000="seventeen to eighteenkm"
18000 - 19000="eighteen to nineteenkm"
19000 - 20000="nineteen to twentykm"
;
run;
data combined_master4;
SET combined_master3;
format EuclidDist EuclidDistt.;
run;
Data combined_master5;
set combined_master4;
proc sort data=combined_master5;
by EuclidDist;
run;
proc report data=combined_master5;
column EuclidDist Configuration Sale_in_Percentage;
define EuclidDist/group;
define Configuration/n;
compute Sale_in_Percentage;
Sale_in_Percentage=(Configuration.n/174495)*100;
endcomp;
rbreak after/ skip summarize;
run;
