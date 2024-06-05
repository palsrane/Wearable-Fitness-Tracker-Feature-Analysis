** Data Overview:
** ------------
The data was acquired from publicly available dataset on kaggle https://www.kaggle.com/datasets/arashnic/fitbit.
The data consisted of two separate folders one for the month of Mar-Apr and second for the month of Apr-May 2016.

(Following information was extracted after the initial cleaning processing and joining the differnt matrics tables)
There are a 33 distinct users in the 03-04 month files and 35 distinct users in the 04-05 month.
The 03-04 records contained data from 35 users, spanned over 2016-03-11 and 2016-04-12, a total of 33 days.
The 04-05 records contained data from 33 users, spanned over 2016-04-12 and 2016-05-12, a total of 31 days.

There was an overlap of 2016-04-12 in between both the months. 
However, since the 04-05 contained data from two additional users (User Ids 2891001357 and 6391747486), the records were kept as is for 
the sake of monthwise analysis.


The data consisted of:
|:---------------------------------|:-------------------------------------------|
| 03 to 04 2016                    | 04 to 05 2016                    		|
|:---------------------------------|:-------------------------------------------|
|dailyActivity_merged.csv          |dailyActivity_merged.csv	      		|
|heartrate_seconds_merged.csv	   |dailyCalories_merged.csv	      		|
|hourlyCalories_merged.csv         |dailyIntensities_merged.csv	      		|
|hourlyIntensities_merged.csv      |dailySteps_merged.csv		  	|
|hourlySteps_merged.csv            |heartrate_seconds_merged.csv	  	|
|minuteCaloriesNarrow_merged.csv   |hourlyCalories_merged.csv		  	|
|minuteIntensitiesNarrow_merged.csv|hourlyIntensities_merged.csv	  	|
|minuteMETsNarrow_merged.csv       |hourlySteps_merged.csv		  	|
|minuteSleep_merged.csv		   |minuteCaloriesNarrow_merged.csv	  	|
|minuteStepsNarrow_merged.csv	   |minuteCaloriesWide_merged.csv	  	|
|weightLogInfo_merged.csv	   |minuteIntensitiesNarrow_merged.csv	  	|
|				   |minuteIntensitiesWide_merged.csv  	  	|
|				   |minuteMETsNarrow_merged.csv		  	|
|				   |minuteSleep_merged.csv			|
|				   |minuteStepsNarrow_merged.csv      		|
|				   |minuteStepsWide_merged.csv		  	|
|				   |sleepDay_merged.csv			      	|
|				   |weightLogInfo_merged.csv	      		|
|:---------------------------------|:-------------------------------------------|

At first glance it appeared as if there were a lot more metrics available for the second month. However, 
upon closer inspection it was noted that most of the files contained duplicated information presented in 
different formats such as narrow and wide tables for minute by minute intensities, calories, sleep, and steps.

However, since focus of this study was look at feature use, metrics summarized over a day were sufficient.

The daily activity file (dailyActivity_merged.csv) from both months had the following parameters summarised by the day 
for each of the users. 
Id	ActivityDate	TotalSteps	TotalDistance	TrackerDistance	LoggedActivitiesDistance	
VeryActiveDistance	ModeratelyActiveDistance	LightActiveDistance	SedentaryActiveDistance	
VeryActiveMinutes	FairlyActiveMinutes	LightlyActiveMinutes	SedentaryMinutes	Calories

They were missing the weight, heart rate and sleep from the metrics. 

** Loading and Cleaning:
** ------------------------
The initial cleaning and formatting process was performed in SQL with MS SQL Server Management Studio. 

dailyActivity_merged.csv, heartrate_seconds_merged.csv, minuteSleep_merged.csv, and weightLogInfo_merged.csv from the 03-04 folder, and 
dailyActivity_merged.csv, heartrate_seconds_merged.csv, weightLogInfo_merged.csv, and sleepDay_merged.csv from 04-05 folder were loaded
into MS SQL studio using the 'Import Flat files' option with Schema=dbo. 

For the 

dailyActivity_merged.csv
|:------------------------------|:--------------|:--------------|:--------------|
|Column Name			| Data Type	|Primary Key	|Allow Nulls	|
|:------------------------------|:--------------|:--------------|:--------------|
|Id				|bigint		|False		|False		|
|ActivityDate			|date		|False		|False		|
|TotalSteps			|smallint	|False		|False		|
|TotalDistance			|float		|False		|False		|
|TrackerDistance		|float		|False		|False		|
|LoggedActivitiesDistance	|float		|False		|False		|
|VeryActiveDistance		|float		|False		|False		|
|ModeratelyActiveDistance	|float		|False		|False		|
|LightActiveDistance		|float		|False		|False		|
|SedentaryActiveDistance	|float		|False		|False		|
|VeryActiveMinutes		|tinyint	|False		|False		|
|FairlyActiveMinutes		|smallint	|False		|False		|
|LightlyActiveMinutes		|smallint	|False		|False		|
|SedentaryMinutes		|smallint	|False		|False		|
|Calories			|smallint	|False		|False		|
|:------------------------------|:--------------|:--------------|:--------------|

heartrate_seconds_merged.csv 
The Id column data type had to be adjusted to bigint (originally autodetected 'int' was leading to dropped records)
|:------------------------------|:--------------|:--------------|:--------------|
|Column Name			| Data Type	|Primary Key	|Allow Nulls	|
|:------------------------------|:--------------|:--------------|:--------------|
|Id				|bigint		|False		|False		|
|Time				|datetime2	|False		|False		|
|Value				|tinyint	|False		|False		|
|:------------------------------|:--------------|:--------------|:--------------|

minuteSleep_merged.csv
The Id column data type had to be adjusted to bigint (originally autodetected 'int' was leading to dropped records)
|:------------------------------|:--------------|:--------------|:--------------|
|Column Name			| Data Type	|Primary Key	|Allow Nulls	|
|:------------------------------|:--------------|:--------------|:--------------|
|Id				|bigint		|False		|False		|
|Time				|datetime2	|False		|False		|
|Value				|tinyint	|False		|False		|
|logId				|bigint		|False		|False		|
|:------------------------------|:--------------|:--------------|:--------------|

weightLogInfo_merged.csv
The Id column data type had to be adjusted to bigint (originally autodetected 'int' was leading to dropped records)
|:------------------------------|:--------------|:--------------|:--------------|
|Column Name			| Data Type	|Primary Key	|Allow Nulls	|
|:------------------------------|:--------------|:--------------|:--------------|
|Id				|bigint		|False		|False		|
|Date				|datetime2	|False		|False		|
|WeightKg			|float		|False		|False		|
|WeightPounds			|float		|False		|False		|
|Fat				|tinyint	|False		|*True*		|
|BMI				|float		|False		|False		|
|IsManualReport`		|bit		|False		|False		|
|logId				|bigint		|False		|False		|
|:------------------------------|:--------------|:--------------|:--------------|

sleepDay_merged.csv
|:------------------------------|:--------------|:--------------|:--------------|
|Column Name			| Data Type	|Primary Key	|Allow Nulls	|
|:------------------------------|:--------------|:--------------|:--------------|
|Id				|bigint		|False		|False		|
|SleepDay			|datetime2	|False		|False		|
|TotalSleepRecords		|tinyint	|False		|False		|
|TotalMinutesAsleep		|smallint	|False		|False		|
|TotalTimeInBed			|smallint	|False		|False		|
|:------------------------------|:--------------|:--------------|:--------------|


* Data Modification:
* -------------------------------
In order to add the sleep, heart rate, and weight, those matrics needed to be in the 'per day' format. 

** Understanding how sleep data was summarized by the day:
In sleepDay_merged.csv table for 04-05, there are 5 columns. The columns were compared to the minuteSleep_merged.csv 
file for the same month to conclude that 
Each strech of continuous sleep was assigned a new logId.
The column TotalMinutesAsleep represents all the minutes for a given SleepDay summed up whenever the value=1.
The TotalTimeInBed represented all the time for a SleepDay, irrespective of what the value was.
The TotalSleepRecords were the distinct logIds for each user for a given day.
** Summarizing Mar-Apr minute-by-minute sleep data the same way as available in:
The minuteSleep_merged.csv table from 03-04 was summed up in the same way as sleepDay_merged.csv table for 04-05: 
The data was grouped by Id and logId.
Minimum date for each unique Id - logId combination was assigned as SleepDay.
Number of minutes that had the value=1 were counted as TotalMinutesAsleep.
Total number of minuted per Id, logId wwas stored as TotalTimeInBed.
Finally, the TotalMinutesAsleep and TotalTimeInBed were summed up for each day for each Id, and number of distinct 
logIds per SleepDay were stored as TotalSleepRecords. The outptu of this query was written into table 
DailySleepCalculated_03_04_2016, and also saved into DailySleepCalculated_03_04_2016.csv for referencing.

** Computing average daily heart rate:
The same procedure was followed for heartrate_seconds_merged.csv from both months.
Upon investigating the files, it was apparent that the records were collected every 5 seconds. However, 
the averages of the value column was 77 and 79 minutes. Given that a healthy human can not beat that many times in 
5 seconds, it was concluded that those were most possibly beats-per-minute, computed on a rolling basis. 

The 'Time' column for each record was casted as DATE to remove the time element from it. The records were 
grouped by Id and DATE, and the Value was averaged to get Avg_Daily_HR. The query results were saved as 
AverageDailyHeartRateCalculated_03_04_2016.csv and AverageDailyHeartRateCalculated_04_05_2016.csv

HourlyHeartRate_Calculated_04_05_2016.csv was also generated by changing the above query a little. The 'Time' 
column was casted as DATE and as HOUR. Records were groupped by Id, Date, and Hour to compute average hourly heart rate.

** Generating merged daily tables:
For each month, the dailyActivity_merged table was joined with daily sleep, heart rate, and weight tables ON Id and date
with a FULL OUTER JOIN in order to keep all the records from all the  records from all tables. 
Two additional columns, overall_Id and overall_date, were added to this table by copying Id and date from Activity, Sleep, 
heart rate, and weight tables into it. The query results were saved INTO tables TotalDailyActivityTracking_03_04_2016 and
TotalDailyActivityTracking_04_05_2016, and also as csv files with those same names.

** Generating summed up tables over the each of the months
The TotalDailyActivityTracking tables from each month were summarized by grouping by Id and counting the number of non-NULL
records for Activity, Logged Activities Distance, Sedentary Activities Distance, Sleep, Heart Rate, Weight, Manual Weight, 
and Fat for each overall_id, and averaging Steps, calories, sleep minutes, time in bed, Heart Rate, weight, and BMI over the
days in each of the month creating TotalDailyActivitySummedUp_03_04_2016 and TotalDailyActivitySummedUp_03_04_2016, and also 
saving each as a CSV file. 
Given that COUNT and AVG functions from MS SQL server were used, any NAs would be ignored in the counting and averaging process.

** Summarizing feature use
In order to look at metric use, number of users that used each of the metrics atleast once was counted for each of the 
Activity, Logged Activities Distance, Sedentary Activities Distance, Sleep, Heart Rate, Weight, and Manual Weight.
Records for each month were saved as FeatureUse_03_04_2016 and FeatureUse_04_05_2016, and corresponding csv files. 

* Data Analysis in Excel:
* -----------------------
The TotalDailyActivitySummedUp_03_04_2016.csv and TotalDailyActivitySummedUp_04_05_2016.csv files were opened in Excel and saved as
.xlsx files. 

The Activity, Logged Activities Distance, Sleep, Heart Rate, Weight, Manual Weight, and Fat columns for each user were used for analysis.

-- Sunburst plot
A summary code for each user was generated with following formula 
=CONCATENATE(SWITCH(B2,0,"_","A_"),SWITCH(C2,0,"_","Lad_"),SWITCH(E2,0,"_","Sl_"),SWITCH(F2,0,"_","Hr_"),SWITCH(G2,0,"_","Wt_"),SWITCH(H2,0,"_","M_"),SWITCH(I2,0,"_","F"))

The resulting code column was converted into a pivot table to assess how many people used each feature. 

The Pivot table was used to generate a sunburst plot of feature use.

-- Heat plot
The columns representing the different metrics mentioned above and their monthly use by each user were copied into a separate sheet, 
and conditional formatting was used to color the cells based on their values.

Conditionally formatted cells were copied in another table, and each column in this table was ordered by values in each column.

-- Scatter plot
Scatter plot was generated by adding jitter to the same metrics as above using the RAND() *0.5 to each value in order to improve 
the visualization of overlapping points, and plotting them against the mectrics on x axis. 