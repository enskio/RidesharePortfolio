USE cyclistic_bikeshare;

-- Combine all the tables
SELECT *
INTO combined_trip
FROM(
    SELECT * FROM [202204] 
    UNION ALL
    SELECT * FROM [202205]
    UNION ALL
    SELECT * FROM [202206]
    UNION ALL
    SELECT * FROM [202207]
    UNION ALL
    SELECT * FROM [202208]
    UNION ALL
    SELECT * FROM [202209]
    UNION ALL
    SELECT * FROM [202210]
    UNION ALL
    SELECT * FROM [202211]
    UNION ALL
    SELECT * FROM [202212]
    UNION ALL
    SELECT * FROM [202301]
    UNION ALL
    SELECT * FROM [202302]
    UNION ALL
    SELECT * FROM [202303]
) AS t;



-- temp table method
-- completed
CREATE TABLE #TempTableStart
(	
    start_lat DECIMAL(18, 10),
    start_lng DECIMAL(18, 10),
    start_station_name NVARCHAR(MAX),
    start_station_id NVARCHAR(50)
);

-- completed, start only
INSERT INTO #TempTableStart (start_lat, start_lng, start_station_name, start_station_id)
SELECT DISTINCT start_lat, start_lng, start_station_name, start_station_id
FROM cyclistic_bikeshare..combined_trip
WHERE start_station_name IS NOT NULL
	AND start_station_id IS NOT NULL
	AND start_lat IS NOT NULL
	AND start_lng IS NOT NULL;


-- ending station
CREATE TABLE #TempTableEnd
(	
    end_lat DECIMAL(18, 10),
    end_lng DECIMAL(18, 10),
    end_station_name NVARCHAR(MAX),
    end_station_id NVARCHAR(50)
);

-- completed, end only
INSERT INTO #TempTableEnd (end_lat, end_lng, end_station_name, end_station_id)
SELECT DISTINCT end_lat, end_lng, end_station_name, end_station_id
FROM cyclistic_bikeshare..combined_trip
WHERE end_station_name IS NOT NULL
	AND end_station_id IS NOT NULL
	AND end_lat IS NOT NULL
	AND end_lng IS NOT NULL;




-- fill in station_name and station_id
-- start and start (name and id)
UPDATE t1
SET t1.start_station_name = t2.start_station_name,
    t1.start_station_id = t2.start_station_id
FROM cyclistic_bikeshare..combined_trip AS t1
JOIN #TempTableStart AS t2
    ON ABS(t1.start_lat - t2.start_lat) <= 0.001
    AND ABS(t1.start_lng - t2.start_lng) <= 0.001
WHERE t1.start_station_name IS NULL
    AND t1.start_station_id IS NULL;


-- start and end (name and id)
UPDATE t1
SET t1.start_station_name = t2.end_station_name,
    t1.start_station_id = t2.end_station_id
FROM combined_trip AS t1
JOIN #TempTableEnd AS t2
    ON t1.start_lat = t2.end_lat
    AND t1.start_lng = t2.end_lng
WHERE t1.start_station_name IS NULL
    AND t1.start_station_id IS NULL;



-- end and start (name and id)
UPDATE t1
SET t1.end_station_name = t2.start_station_name,
    t1.end_station_id = t2.start_station_id
FROM combined_trip AS t1
JOIN #TempTableStart AS t2
    ON t1.end_lat = t2.start_lat
    AND t1.end_lng = t2.start_lng
WHERE t1.end_station_name IS NULL
    AND t1.end_station_id IS NULL;


-- end and end (name and id)
UPDATE t1
SET t1.end_station_name = t2.end_station_name,
    t1.end_station_id = t2.end_station_id
FROM combined_trip AS t1
JOIN #TempTableEnd AS t2
    ON t1.end_lat = t2.end_lat
    AND t1.end_lng = t2.end_lng
WHERE t1.end_station_name IS NULL
    AND t1.end_station_id IS NULL;



-- fill in null lat and lng
-- start and start (name and id)
UPDATE t1
SET t1.start_lat = t2.start_lat,
    t1.start_lng = t2.start_lng
FROM combined_trip AS t1
JOIN #TempTableStart AS t2
    ON t1.start_station_name = t2.start_station_name
    AND t1.start_station_id = t2.start_station_id
WHERE t1.start_lat IS NULL
    AND t1.start_lng IS NULL;


-- start and end (name and id)
UPDATE t1
SET t1.start_lat = t2.end_lat,
    t1.start_lng = t2.end_lng
FROM combined_trip AS t1
JOIN #TempTableEnd AS t2
    ON t1.start_station_name = t2.end_station_name
    AND t1.start_station_id = t2.end_station_id
WHERE t1.start_lat IS NULL
    AND t1.start_lng IS NULL;



-- end and start (name and id)
UPDATE t1
SET t1.end_lat = t2.start_lat,
    t1.end_lng = t2.start_lng
FROM combined_trip AS t1
JOIN #TempTableStart AS t2
    ON t1.end_station_name = t2.start_station_name
    AND t1.end_station_id = t2.start_station_id
WHERE t1.end_lat IS NULL
    AND t1.end_lng IS NULL;


-- end and end (name and id)
UPDATE t1
SET t1.end_lat = t2.end_lat,
    t1.end_lng = t2.end_lng
FROM combined_trip AS t1
JOIN #TempTableEnd AS t2
    ON t1.end_station_name = t2.end_station_name
    AND t1.end_station_id = t2.end_station_id
WHERE t1.end_lat IS NULL
    AND t1.end_lng IS NULL;


-- Delete temp table
DROP TABLE #TempTableStart;
DROP TABLE #TempTableEnd;


-----------------------------------------------------------------------------------------------------------------

SELECT *
INTO [cyclistic_bikeshare].[dbo].[combined_trip_clean]
FROM [cyclistic_bikeshare].[dbo].[combined_trip]
WHERE
	start_station_name IS NOT NULL
	AND start_station_id IS NOT NULL
	AND end_station_name IS NOT NULL
	AND end_station_id IS NOT NULL
	AND start_lat IS NOT NULL
	AND start_lng IS NOT NULL
	AND end_lat IS NOT NULL
    AND end_lng IS NOT NULL; 



SELECT ride_id, started_at, ended_at, DATEDIFF(minute, started_at, ended_at) AS time_spent
FROM combined_trip_clean
WHERE DATEDIFF(minute, started_at, ended_at) > 0;


SELECT COUNT(*)
FROM cyclistic_bikeshare..combined_trip_clean;


-- create new column time_spent_minute
ALTER TABLE combined_trip_clean
ADD time_spent_minute INT,
	start_time TIME,
	end_time TIME;

-- calculate the time spent in a single trip
UPDATE combined_trip_clean
SET time_spent_minute = DATEDIFF(MINUTE, started_at, ended_at),
	start_time = CONVERT(TIME, started_at),
	end_time = CONVERT(TIME, ended_at);



-- add day of the week to the table
ALTER TABLE combined_trip_clean
ADD day_of_week_start VARCHAR(10),
	day_of_week_end VARCHAR(10);

UPDATE combined_trip_clean
SET day_of_week_start = DATENAME(WEEKDAY, started_at),
	day_of_week_end = DATENAME(WEEKDAY, ended_at);

-----------------------------------------------------------------------------------------------------------------

-- create view for data analysis
CREATE VIEW combined_trip_view
AS
SELECT rideable_type, CAST(started_at AS DATE) AS start_day, CAST(ended_at AS DATE) AS end_day, start_time, end_time, day_of_week_start, day_of_week_end, time_spent_minute, start_station_name, end_station_name, member_casual
FROM combined_trip_clean
WHERE time_spent_minute > 0;