----Tables for the Month of Mar-Apr-2016

----Exploring sleep table
--SELECT Id, COUNT(date) AS NumSleepEntries 
--FROM dbo.minuteSleep_merged_03_04_2016 
--GROUP BY Id ORDER BY Id;

--SELECT * FROM dbo.minuteSleep_merged_03_04_2016 WHERE Id = (SELECT TOP 1 Id FROM dbo.minuteSleep_merged_03_04_2016)

---Looking at entries when start and end of sleep cycle were not the same (the times ended up being wrong, look below)
--SELECT * FROM 
--(SELECT Id, logId, TOP 1 ST.DATE AS StartDATE,  min(Time) as starthours, max(ST.DATE) AS endDATE, max(Time) as endhours, AVG(CAST(Value as float)) as Avg_Value FROM
--	(SELECT Id,
--		CAST(date as DATE) AS DATE, 
--		CAST(date as time) AS Time, 
--		Value,
--		logId
--	FROM dbo.minuteSleep_merged_03_04_2016) ST
--GROUP BY Id, logId
--) LM
--WHERE LM.StartDATE != LM.endDATE
--ORDER BY Id, StartDATE

--SELECT * from dbo.minuteSleep_merged_03_04_2016 where logId=11232921147 -- 1 logid from list above to understand how these entries progressed
---- as it turns out the minimum of the timestamp for a given logId was being chosen in the query above irrespective of the actual start of sleep.. 
---- Below is the correct query.
SELECT Id, logId,
	CAST(min(date) as DATE) AS startDATE, 
	CAST(min(date) as time) AS startTime, 
	CAST(max(date) as DATE) AS endDATE, 
	CAST(max(date) as time) AS endTime, 
	AVG(CAST(Value as DECIMAL)) AS AvgValue,
	CAST(DATEDIFF(MINUTE,min(date),max(date)) AS DECIMAL)/60 AS TotalSleepHrs
FROM dbo.minuteSleep_merged_03_04_2016
GROUP BY Id, logId
ORDER BY Id, logId

--Creating info similar to what is available in next month's sleepDay file
SELECT Id, 
	CAST(min(date) as DATE) AS SleepDay, 
	COUNT(CASE WHEN Value=1 THEN 1 END) as TotalMinutesAsleep,-- as each record is one minute long
	COUNT(*) as TotalTimeInBed,
	logId
FROM dbo.minuteSleep_merged_03_04_2016
GROUP BY Id, logId
ORDER BY Id, logId 

-- Sometimes there are multiple sleep records per SleepDay,
-- possibly because, only a continuous stretch of sleep was assigned a unique logId.
-- And it is possible that the individual woke up in his sleep, or took a nap during the day.

SELECT Id, SleepDay, COUNT(DISTINCT logId) AS TotalSleepRecords,
	   SUM(TotalMinutesAsleep) AS TotalMinutesAsleep,
	   SUM(TotalTimeInBed) AS TotalTimeInBed
INTO dbo.DailySleep_Calculated_03_04_2016
FROM (
	SELECT Id, 
		CAST(min(date) as DATE) AS SleepDay, 
		COUNT(CASE WHEN Value=1 THEN 1 END) as TotalMinutesAsleep,-- as each record is one minute long
		COUNT(*) as TotalTimeInBed,
		logId
	FROM dbo.minuteSleep_merged_03_04_2016
	GROUP BY Id, logId) DS
GROUP BY Id, SleepDay
ORDER BY Id, SleepDay
-- Query output was also saved as DailySleep_Calculated_03_04_2016.csv


---Exploring Heart Rate Table
---- Hourly Avg Heart Rate: This was computed but not needed or used.
--SELECT Id, DATE, hour, AVG(Value) as Avg_Hourly_HR 
--INTO dbo.HourlyHeartRate_Calculated_03_04_2016
--FROM
--	(SELECT Id, 
--		CAST(Time as DATE) AS DATE, 
--		DATEPART(HOUR,CAST(Time as time)) AS hour, 
--		Value 
--	FROM dbo.heartrate_seconds_merged_03_04_2016) HR
--GROUP BY Id, DATE, hour
--ORDER BY Id, DATE, hour

-- Daily Avg Heart Rate
-- Results are saved as AverageDailyHeartRateCalculated_03_04_2016.csv
SELECT AVG(Value) FROM dbo.heartrate_seconds_merged_03_04_2016 

SELECT Id, DATE, AVG(Value) as Avg_Daily_HR 
INTO AverageDailyHeartRateCalculated_03_04_2016
FROM
	(SELECT Id, 
		CAST(Time as DATE) AS DATE, 
		DATEPART(HOUR,CAST(Time as time)) AS hour, 
		Value 
	FROM dbo.heartrate_seconds_merged_03_04_2016) HR
GROUP BY Id, DATE
ORDER BY Id, DATE
-- Results are saved as AverageDailyHeartRateCalculated_03_04_2016.csv


--Mering all different merits with the Daily activities table
SELECT * FROM dbo.AverageDailyHeartRateCalculated_03_04_2016
SELECT * FROM dbo.DailySleep_Calculated_03_04_2016 ORDER BY Id,SleepDay
SELECT * FROM dbo.weightLogInfo_merged_03_04_2016 --table with records of daily weight
---Exploring Activity Table
SELECT * FROM dbo.dailyActivity_merged_03_04_2016

SELECT  CASE WHEN ACT.Id IS NOT NULL THEN ACT.Id
			WHEN (ACT.Id IS NULL AND SLEEP.Id IS NOT NULL) THEN SLEEP.Id
			WHEN (ACT.Id IS NULL AND SLEEP.Id IS NULL AND HR.Id IS NOT NULL) THEN HR.Id END
			AS overall_Id, 
		CASE WHEN ACT.ActivityDate IS NOT NULL THEN ACT.ActivityDate
			WHEN (ACT.ActivityDate IS NULL AND SLEEP.SleepDay IS NOT NULL) THEN SLEEP.SleepDay
			WHEN (ACT.ActivityDate IS NULL AND SLEEP.SleepDay IS NULL AND HR.DATE IS NOT NULL) THEN HR.DATE END
			AS overall_date,
			ACT.Id AS Activity_Id,
			ActivityDate,TotalSteps,TotalDistance,TrackerDistance,LoggedActivitiesDistance,
			VeryActiveDistance,ModeratelyActiveDistance,LightActiveDistance,SedentaryActiveDistance,
			VeryActiveMinutes,FairlyActiveMinutes,LightlyActiveMinutes,SedentaryMinutes,Calories,
			SLEEP.Id AS Sleep_Id,
			SleepDay AS SleepDate,
			TotalMinutesAsleep, TotalTimeInBed,
			HR.Id AS HR_Id,
			HR.DATE AS HR_Date, Avg_Daily_HR,
			Weight_Id,Weight_Date,WeightKg,WeightPounds,Fat,BMI,IsManualReport
INTO dbo.TotalDailyActivityTracking_03_04_2016
FROM dbo.dailyActivity_merged_03_04_2016 ACT
FULL OUTER JOIN dbo.AverageDailyHeartRateCalculated_03_04_2016 HR ON (ACT.Id = HR.Id AND ACT.ActivityDate=HR.DATE)
FULL OUTER JOIN (SELECT Id as Weight_Id, CAST(Date as DATE) as Weight_Date,WeightKg,WeightPounds,
								Fat, BMI,IsManualReport FROM dbo.weightLogInfo_merged_03_04_2016)WEIGHT ON (ACT.Id = WEIGHT.Weight_Id AND ACT.ActivityDate=WEIGHT.Weight_Date)
FULL OUTER JOIN dbo.DailySleep_Calculated_03_04_2016 SLEEP ON (ACT.Id = SLEEP.Id AND ACT.ActivityDate=SLEEP.SleepDay)
ORDER BY overall_Id,overall_date
--Query output saved as TotalDailyActivityTracking_03_04_2016.csv by commenting out the INTO part of the query


SELECT min(overall_date), max(overall_date), COUNT( distinct overall_date) AS NUMBER_Days_Tracked  
FROM TotalDailyActivityTracking_03_04_2016

SELECT  FROM TotalDailyActivityTracking_03_04_2016
SELECT  DATEDIFF(DAY,min(overall_date),max(overall_date)) NUMBER_Days_Tracked FROM TotalDailyActivityTracking_03_04_2016

--Following was used to test a case where multiple records were observed for a single ID
--As it turns out, this was because some people took naps and 
--those were recorded as separate sleep records for the same day
--This was corrected by merging sleep records for one day for an ID together before joining 
--SELECT * FROM dbo.dailyActivity_merged_03_04_2016 
--WHERE id= 1927972279

--SELECT * FROM dbo.TotalDailyActivityTracking_03_04_2016
--WHERE overall_Id=1927972279 AND ActivityDate IS NOT NULL

--SELECT * FROM dbo.DailySleep_Calculated_03_04_2016 
--WHERE id= 1927972279 AND SleepDay = '2016-04-10'

--SELECT * FROM dbo.minuteSleep_merged_03_04_2016
--WHERE id= 1927972279 AND (date LIKE '2016-04-10%') OR 
--	logId = 11355585833


-- TotalDailyTracking Averaged over the whole month
--Looking at use of different features
SELECT TOP 100 * FROM dbo.TotalDailyActivityTracking_03_04_2016

SELECT overall_Id,
	COUNT(DISTINCT ActivityDate) as NumActivityRecords,
	COUNT(CASE WHEN (LoggedActivitiesDistance IS NOT NULL AND LoggedActivitiesDistance !=0) THEN 1 END) AS NumLoggedActDistRecords,
	COUNT(CASE WHEN (SedentaryActiveDistance IS NOT NULL AND SedentaryActiveDistance !=0) THEN 1 END) AS NumSedentaryActDistRecords,
	COUNT(DISTINCT SleepDate) as NumSleepRecords,
	COUNT(DISTINCT HR_Date) as NumHRRecords,
	COUNT(DISTINCT Weight_Date) as NumWeightRecords,
	COUNT(IsManualReport) as NumManualWeightRecords,
	COUNT(Fat) as NumFatRecords,
	AVG(TotalSteps) as AvgStepsPerDay,
	AVG(Calories) as AvgCaloriesPerDay,
	AVG(TotalMinutesAsleep) as AvgSleepMins,
	AVG(TotalTimeInBed) as AvgTimeInBedPerDay,
	AVG(Avg_Daily_HR) as AvgHRPerDay,
	AVG(WeightKg) as AverageWeight,
	AVG(BMI) as AverageBMI
FROM dbo.TotalDailyActivityTracking_03_04_2016
GROUP BY overall_Id
ORDER BY overall_Id

SELECT 
COUNT(DISTINCT overall_Id) as NumOfParticipants,
COUNT(CASE WHEN NumActivityRecords !=0 THEN 1 END) as NumberOfPeopleRecordingActivity,
COUNT(CASE WHEN NumLoggedActDistRecords !=0 THEN 1 END) as NumberOfPeopleLoggingActiveDistiance,
COUNT(CASE WHEN NumSedentaryActDistRecords !=0 THEN 1 END) as NumberOfPeopleLoggingSedentaryDistiance,
COUNT(CASE WHEN NumSleepRecords !=0 THEN 1 END) as NumberOfPeopleRecordingSleep,
COUNT(CASE WHEN NumHRRecords !=0 THEN 1 END) as NumberOfPeopleRecordingHeartRate,
COUNT(CASE WHEN NumWeightRecords !=0 THEN 1 END) as NumberOfPeopleRecordingWeight,
COUNT(CASE WHEN NumManualWeightRecords !=0 THEN 1 END) as NumberOfPeopleRecordingWeightManually
FROM
(SELECT overall_Id,
	COUNT(DISTINCT ActivityDate) as NumActivityRecords,
	COUNT(CASE WHEN (LoggedActivitiesDistance IS NOT NULL AND LoggedActivitiesDistance !=0) THEN 1 END) AS NumLoggedActDistRecords,
	COUNT(CASE WHEN (SedentaryActiveDistance IS NOT NULL AND SedentaryActiveDistance !=0) THEN 1 END) AS NumSedentaryActDistRecords,
	COUNT(DISTINCT SleepDate) as NumSleepRecords,
	COUNT(DISTINCT HR_Date) as NumHRRecords,
	COUNT(DISTINCT Weight_Date) as NumWeightRecords,
	COUNT(IsManualReport) as NumManualWeightRecords,
	COUNT(Fat) as NumFatRecords,
	AVG(TotalSteps) as AvgStepsPerDay,
	AVG(Calories) as AvgCaloriesPerDay,
	AVG(TotalMinutesAsleep) as AvgSleepMins,
	AVG(TotalTimeInBed) as AvgTimeInBedPerDay,
	AVG(Avg_Daily_HR) as AvgHRPerDay,
	AVG(WeightKg) as AverageWeight,
	AVG(BMI) as AverageBMI
FROM dbo.TotalDailyActivityTracking_03_04_2016
GROUP BY overall_Id) TD






---Records for Apr-May 2016
SELECT * FROM dbo.dailyActivity_merged_04_05_2016 
SELECT * FROM dbo.weightLogInfo_merged_04_05_2016
SELECT * FROM dbo.sleepDay_merged_04_05_2016

SELECT * FROM dbo.heartrate_seconds_merged_04_05_2016
SELECT AVG(Value) FROM dbo.heartrate_seconds_merged_04_05_2016

SELECT Id, DATE, 
	   AVG(Value) as Avg_Daily_HR 
INTO dbo.AverageDailyHeartRateCalculated_04_05_2016
FROM
	(SELECT Id, 
		CAST(Time as DATE) AS DATE, 
		DATEPART(HOUR,CAST(Time as time)) AS hour, 
		Value 
	FROM dbo.heartrate_seconds_merged_04_05_2016) HR
GROUP BY Id, DATE
ORDER BY Id, DATE
--Also saved as AverageDailyHeartRateCalculated_04_05_2016.csv

SELECT  CASE WHEN ACT.Id IS NOT NULL THEN ACT.Id
			WHEN (ACT.Id IS NULL AND SLEEP.Id IS NOT NULL) THEN SLEEP.Id
			WHEN (ACT.Id IS NULL AND SLEEP.Id IS NULL AND HR.Id IS NOT NULL) THEN HR.Id END
			AS overall_Id, 
		CASE WHEN ACT.ActivityDate IS NOT NULL THEN ACT.ActivityDate
			WHEN (ACT.ActivityDate IS NULL AND SLEEP.SleepDay IS NOT NULL) THEN SLEEP.SleepDay
			WHEN (ACT.ActivityDate IS NULL AND SLEEP.SleepDay IS NULL AND HR.DATE IS NOT NULL) THEN HR.DATE END
			AS overall_date,
			ACT.Id AS Activity_Id,
			ActivityDate,TotalSteps,TotalDistance,TrackerDistance,LoggedActivitiesDistance,
			VeryActiveDistance,ModeratelyActiveDistance,LightActiveDistance,SedentaryActiveDistance,
			VeryActiveMinutes,FairlyActiveMinutes,LightlyActiveMinutes,SedentaryMinutes,Calories,
			SLEEP.Id AS Sleep_Id,
			SleepDay AS SleepDate,
			TotalMinutesAsleep, TotalTimeInBed,
			HR.Id AS HR_Id,
			HR.DATE AS HR_Date, Avg_Daily_HR,
			Weight_Id,Weight_Date,WeightKg,WeightPounds,Fat,BMI,IsManualReport
INTO dbo.TotalDailyActivityTracking_04_05_2016
FROM dbo.dailyActivity_merged_04_05_2016 ACT
FULL OUTER JOIN dbo.AverageDailyHeartRateCalculated_04_05_2016 HR ON (ACT.Id = HR.Id AND ACT.ActivityDate=HR.DATE)
FULL OUTER JOIN (SELECT Id as Weight_Id, CAST(Date as DATE) as Weight_Date,WeightKg,WeightPounds,
								Fat, BMI,IsManualReport FROM dbo.weightLogInfo_merged_04_05_2016) WEIGHT ON (ACT.Id = WEIGHT.Weight_Id AND ACT.ActivityDate=WEIGHT.Weight_Date)
FULL OUTER JOIN (SELECT Id, SleepDay, SUM(TotalMinutesAsleep) AS TotalMinutesAsleep,
						SUM(TotalTimeInBed) AS TotalTimeInBed
				 FROM dbo.sleepDay_merged_04_05_2016
				 GROUP BY Id, SleepDay) SLEEP ON (ACT.Id = SLEEP.Id AND ACT.ActivityDate=SLEEP.SleepDay)
ORDER BY overall_Id,overall_date
--also saved as TotalDailyActivityTracking_04_05_2016.csv

SELECT min(overall_date), max(overall_date), COUNT( distinct overall_date) AS NUMBER_Days_Tracked  
FROM TotalDailyActivityTracking_04_05_2016

SELECT overall_Id,
	COUNT(DISTINCT ActivityDate) as NumActivityRecords,
	COUNT(CASE WHEN (LoggedActivitiesDistance IS NOT NULL AND LoggedActivitiesDistance !=0) THEN 1 END) AS NumLoggedActDistRecords,
	COUNT(CASE WHEN (SedentaryActiveDistance IS NOT NULL AND SedentaryActiveDistance !=0) THEN 1 END) AS NumSedentaryActDistRecords,
	COUNT(DISTINCT SleepDate) as NumSleepRecords,
	COUNT(DISTINCT HR_Date) as NumHRRecords,
	COUNT(DISTINCT Weight_Date) as NumWeightRecords,
	COUNT(IsManualReport) as NumManualWeightRecords,
	COUNT(Fat) as NumFatRecords,
	AVG(TotalSteps) as AvgStepsPerDay,
	AVG(Calories) as AvgCaloriesPerDay,
	AVG(TotalMinutesAsleep) as AvgSleepMins,
	AVG(TotalTimeInBed) as AvgTimeInBedPerDay,
	AVG(Avg_Daily_HR) as AvgHRPerDay,
	AVG(WeightKg) as AverageWeight,
	AVG(BMI) as AverageBMI
FROM dbo.TotalDailyActivityTracking_04_05_2016
GROUP BY overall_Id
ORDER BY overall_Id
-- Saved as TotalDailyActivitySummedUp_04_05_2016.csv

SELECT 
COUNT(DISTINCT overall_Id) as NumOfParticipants,
COUNT(CASE WHEN NumActivityRecords !=0 THEN 1 END) as NumberOfPeopleRecordingActivity,
COUNT(CASE WHEN NumLoggedActDistRecords !=0 THEN 1 END) as NumberOfPeopleLoggingActiveDistiance,
COUNT(CASE WHEN NumSedentaryActDistRecords !=0 THEN 1 END) as NumberOfPeopleLoggingSedentaryDistiance,
COUNT(CASE WHEN NumSleepRecords !=0 THEN 1 END) as NumberOfPeopleRecordingSleep,
COUNT(CASE WHEN NumHRRecords !=0 THEN 1 END) as NumberOfPeopleRecordingHeartRate,
COUNT(CASE WHEN NumWeightRecords !=0 THEN 1 END) as NumberOfPeopleRecordingWeight,
COUNT(CASE WHEN NumManualWeightRecords !=0 THEN 1 END) as NumberOfPeopleRecordingWeightManually
FROM
(SELECT overall_Id,
	COUNT(DISTINCT ActivityDate) as NumActivityRecords,
	COUNT(CASE WHEN (LoggedActivitiesDistance IS NOT NULL AND LoggedActivitiesDistance !=0) THEN 1 END) AS NumLoggedActDistRecords,
	COUNT(CASE WHEN (SedentaryActiveDistance IS NOT NULL AND SedentaryActiveDistance !=0) THEN 1 END) AS NumSedentaryActDistRecords,
	COUNT(DISTINCT SleepDate) as NumSleepRecords,
	COUNT(DISTINCT HR_Date) as NumHRRecords,
	COUNT(DISTINCT Weight_Date) as NumWeightRecords,
	COUNT(IsManualReport) as NumManualWeightRecords,
	COUNT(Fat) as NumFatRecords,
	AVG(TotalSteps) as AvgStepsPerDay,
	AVG(Calories) as AvgCaloriesPerDay,
	AVG(TotalMinutesAsleep) as AvgSleepMins,
	AVG(TotalTimeInBed) as AvgTimeInBedPerDay,
	AVG(Avg_Daily_HR) as AvgHRPerDay,
	AVG(WeightKg) as AverageWeight,
	AVG(BMI) as AverageBMI
FROM dbo.TotalDailyActivityTracking_04_05_2016
GROUP BY overall_Id) TD
--Saved as FeatureUse_04_05_2016.csv

-- Checking for overlap between the distinct user Ids between the two months.
SELECT DISTINCT overall_id FROM TotalDailyActivityTracking_04_05_2016
WHERE overall_id NOT IN (SELECT DISTINCT overall_id FROM TotalDailyActivityTracking_03_04_2016)

SELECT DISTINCT overall_id FROM TotalDailyActivityTracking_03_04_2016
WHERE overall_id NOT IN (SELECT DISTINCT overall_id FROM TotalDailyActivityTracking_04_05_2016)

