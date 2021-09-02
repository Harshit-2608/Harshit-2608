

-- 1. Coverting start_station_id and end_station_id from june 2020 to November 2020 data type to nvarchar so that we can union all the data properly.


--Syntex used in each dataframe is shown below
ALTER TABLE Cyclistic_database..June_2020
	ALTER COLUMN start_station_id nvarchar(50);

ALTER TABLE Cyclistic_database..June_2020	
	ALTER COLUMN end_station_id nvarchar(50);












-- 2. Joining  12 individual data frames into one big data frame using CREATE and UNION function.

DROP TABLE if exists Cyclistic_database..Combined_Data
CREATE TABLE Cyclistic_database..Combined_Data
(
	ride_id nvarchar(50),
	rideable_type nvarchar(50),
    started_at datetime,
    ended_at datetime,
    start_station_name nvarchar(100),
    start_station_id nvarchar(50),
    end_station_name nvarchar(100),
    end_station_id nvarchar(50),
    start_lat float,
    start_lng float,
    end_lat float,
    end_lng float,
    member_casual nvarchar(50)
)
INSERT INTO Cyclistic_database..Combined_Data

	SELECT *
	FROM Cyclistic_database..June_2020

	UNION
	.
	-- Truncating code here as it just contains 12 different dataframes in  union function 
	.
	UNION

	SELECT *
	FROM Cyclistic_database..May_2021









	-- 3. Remove Unwanted Columns
	-- Syntex used for each Column is shown below

	ALTER TABLE Cyclistic_database..Combined_Data
	DROP COLUMN start_lat;











-- 4. Add columns that list the date,month, day, year of each ride.

	
	 SELECT CAST(started_at as date) AS Date,
		DATEPART(day,started_at) AS Day,
		DATEPART(month,started_at) AS Month,
		DATEPART(year,started_at) AS Year,
		DATEPART(weekday,started_at) AS Day_of_Week
	FROM Cyclistic_database..Combined_Data

 -- Now i will be using the syntex given below to add all the above columns into combined data
 
	ALTER TABLE Cyclistic_database..Combined_Data
	ADD Day int;

	UPDATE Cyclistic_database..Combined_Data
	SET Day = DATEPART(day,started_at)












-- 5. Calculate the "Ride_length" and add a new column

	SELECT DATEDIFF(minute,started_at,ended_at) AS ride_length
	FROM Cyclistic_database..Combined_Data

	-- Adding Ride_length column to combined data

	ALTER TABLE Cyclistic_database..Combined_Data
	ADD Ride_length float;

	UPDATE Cyclistic_database..Combined_Data
	SET Ride_length = CAST((DATEDIFF(second,started_at,ended_at)/ 60.0) AS NUMERIC(10, 2))












-- 6. Removing trips for which ride length is <= 0 or more than one day (24 * 60 = 1440 minutes)

	DELETE 
	FROM Cyclistic_database..Combined_Data
	WHERE Ride_length <= 0 
		OR Ride_length > 1440;

-- We have combined and cleaned the data and it is now ready to analysis.











--7. Descriptive Analysis of ride length

	SELECT MIN(Ride_length) AS Minimun_Ride_length,
			MAX(Ride_length) AS Maximun_Ride_length,
			AVG(Ride_length) AS Average_Ride_length,
				(SELECT TOP 1 Ride_length
				FROM Cyclistic_database..Combined_Data
				GROUP BY Ride_length
				ORDER BY COUNT(Ride_length) DESC
				)As Mode_Ride_length
	FROM Cyclistic_database..Combined_Data

	/*
		Result of Analysis of ride length
		Minimum Ride Length = 1.2 seconds
		Maximum Ride Length = 1 Day
		Average Ride Length = 23 min 36 sec
		Ride Length Mode = 6 min 43 sec
	*/












-- 8.  Comparing ride length between members and casual riders

	SELECT	member_casual,
		MIN(Ride_length) AS Minimun_Ride_length,
		MAX(Ride_length) AS Maximun_Ride_length,
		AVG(Ride_length) AS Average_Ride_length
	FROM Cyclistic_database..Combined_Data
	GROUP BY member_casual

	/*
		Result of Analysis 
		Average Ride Length of members = 15 min 17 sec
		Average Ride Length of casuals = 35 min 3 sec
		We can clearly see average ride length of casuals is very high as compared to members.
	*/













--9. average ride length by each day of week for members vs. casual riders

	SELECT	member_casual,
			Day_of_Week,
			AVG(Ride_length) AS Average_Ride_length
	FROM Cyclistic_database..Combined_Data
	GROUP BY member_casual,Day_of_Week
	ORDER BY Day_of_Week,member_casual

	/*
		Result of Analysis 
		We can see that there is an increase in average ride length during weekends as compared to weekdays
	*/








	

-- 10. Number of rides between members and casual riders for each day of week

	SELECT	member_casual,
		Day_of_week,
		Count(ride_id) AS Number_of_rides
	FROM Cyclistic_database..Combined_Data
	GROUP BY member_casual,Day_of_week
	ORDER BY Day_of_week,member_casual

	/*
		Result of Analysis 
		We can see number of rides gradually increases from monday to sunday with saturday having highest number of rides.
	*/













-- 11. # Number of rides between members and casual riders for each month

	SELECT	member_casual,
		Month,
		Count(ride_id) AS Number_of_rides
	FROM Cyclistic_database..Combined_Data
	GROUP BY member_casual,Month
	ORDER BY Month,member_casual












-- 12. Comparing general bike type preference between members and casual riders

	SELECT	rideable_type,
		member_casual,
		Count(ride_id) AS Number_of_rides
	FROM Cyclistic_database..Combined_Data
	GROUP BY member_casual,rideable_type
	ORDER BY rideable_type,member_casual











-- 13. Last Step is to make visualizations on the data analysis which we did above. i will be making visualisations in tableau.





