SELECT * FROM combined_trip_view;


-- get all the column name from table
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'combined_trip_view';

-- get data
SELECT TOP(1000) * 
FROM combined_trip_view;

-- data analysis

-- find the rideable type and member type with the most time spent
SELECT rideable_type, member_casual AS member_type, AVG(time_spent_minute) AS avg_time_spent_minute, SUM(time_spent_minute) AS total_time_spent_minute, COUNT(*) AS num_of_trip
FROM combined_trip_view
GROUP BY rideable_type, member_casual
ORDER BY avg_time_spent_minute DESC;


-- find the popularity of start station
SELECT start_station_name, COUNT(start_station_name) AS occurrence
FROM combined_trip_view
GROUP BY start_station_name
ORDER BY occurrence DESC;

-- find the popularity of end station
SELECT end_station_name, COUNT(end_station_name) AS occurrence
FROM combined_trip_view
GROUP BY end_station_name
ORDER BY occurrence DESC;

-- find the most popular day among member type, rideable type
SELECT rideable_type, member_casual, start_station_name, day_of_week_start, COUNT(day_of_week_start) AS total_trip
FROM combined_trip_view
GROUP BY rideable_type, member_casual, start_station_name, day_of_week_start
ORDER BY total_trip DESC;

-- find the details of ending station
SELECT rideable_type, member_casual, end_station_name, day_of_week_end, COUNT(day_of_week_end) AS total_trip
FROM combined_trip_view
GROUP BY rideable_type, member_casual, end_station_name, day_of_week_end
ORDER BY total_trip DESC;

-- number of user by rideable_type
SELECT rideable_type, member_casual AS member_type, COUNT(member_casual) AS total_trip
FROM combined_trip_view
GROUP BY rideable_type, member_casual
ORDER BY total_trip DESC;


-- find the most popular hour by day, rideable type, member type
SELECT rideable_type, member_casual, day_of_week_start, DATEPART(HOUR, start_time) AS start_hour, COUNT(DATEPART(HOUR, start_time)) AS number_of_trip
FROM combined_trip_view
GROUP BY rideable_type, member_casual, day_of_week_start, DATEPART(HOUR, start_time)
ORDER BY number_of_trip DESC;

-- monthly trip by rideable type, member type
SELECT start_day AS date, rideable_type, member_casual, COUNT(start_day) AS number_of_trip
FROM combined_trip_view
GROUP BY start_day, rideable_type, member_casual
ORDER BY start_day ASC;


-- find the most popular route and their user type
SELECT DISTINCT start_station_name, end_station_name, member_casual AS member_type, COUNT(*) AS number_of_trip, SUM(time_spent_minute) AS time_spent, AVG(time_spent_minute) AS avg_time_spent
FROM combined_trip_view
-- WHERE start_station_name != end_station_name
GROUP BY start_station_name, end_station_name, member_casual
ORDER BY number_of_trip DESC;


-- find the ending station for the most popular route (streeter dr & grand ave)
SELECT DISTINCT start_station_name, end_station_name, member_casual AS member_type, rideable_type, COUNT(*) AS number_of_trip, SUM(time_spent_minute) AS time_spent, AVG(time_spent_minute) AS avg_time_spent
FROM combined_trip_view
WHERE start_station_name = 'Streeter Dr & Grand Ave'
GROUP BY start_station_name, end_station_name, member_casual, rideable_type
ORDER BY number_of_trip DESC;

-- find the most popular route and their user type by day
SELECT DISTINCT start_station_name, end_station_name, member_casual AS member_type, COUNT(*) AS number_of_trip, SUM(time_spent_minute) AS time_spent, AVG(time_spent_minute) AS avg_time_spent, day_of_week_start
FROM combined_trip_view
-- WHERE start_station_name != end_station_name
GROUP BY start_station_name, end_station_name, member_casual, day_of_week_start
ORDER BY number_of_trip DESC;





-----------------------------------------------------------------------------------------------------------------

