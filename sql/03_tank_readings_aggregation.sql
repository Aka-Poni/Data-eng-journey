USE sensor_lab;

-- Query 01: Total of readings per tank
SELECT tank_id,
    COUNT(*) AS total_readings -- total_readings is an alias for counting the number of readings per tank
FROM tank_readings
GROUP BY tank_id -- Need to group by tank_id to get the count per tank
;

-- Query 02: Minimum, maximum and average pH per tank, rounded to 2 decimal places
SELECT tank_id,
    ROUND(MIN(ph),2) AS min_ph, -- Round tank_reading minimum ph value with 2 decimal places
    ROUND(MAX(ph),2) AS max_ph, -- Round tank_reading maximum ph value with 2 decimal places
    ROUND(AVG(ph),2) AS avg_ph -- Round tank_reading average ph value with 2 decimal places
FROM tank_readings
GROUP BY tank_id -- Collapse tank_id ph values in a single line
;

-- Query 03: Per tank, compare count (*) with count (temperature_c). Explain the difference in a comment
SELECT tank_id,
    COUNT(*) AS total_readings, -- Count ALL tank_readings
    COUNT(temperature_c) AS total_temp_readings -- Count ONLY rows with temperature_c values
FROM tank_readings
GROUP BY tank_id
    -- COUNT(column_name) counts only non-null values, while COUNT(*) counts all rows.
;

-- Query 04: Total readings per tank and per day
SELECT tank_id,
    DATE(reading_time) AS reading_date, -- Get tank_readings in date only format
    COUNT(*) AS total_readings -- Count ALL tank_readings
FROM tank_readings
GROUP BY
    tank_id, -- tank_id collapse GROUP    
    DATE(reading_time) -- Reading date collapse group
;

-- Query 05: Total readings with pH outside the range of 6.5-8.5 per tank
SELECT tank_id,
    COUNT(*) AS outside_range_readings -- Count tank_readings after the WHERE filter
FROM tank_readings
WHERE ph <6.5 OR ph>8.5 -- Filter tank readings outside the range
GROUP BY tank_id
;

-- Query 06: Only tanks with average level_pct above 70%
SELECT tank_id,
    ROUND(AVG(level_pct),2) AS avg_level_pct -- Get average level_pct per tank
FROM tank_readings
GROUP BY tank_id
HAVING AVG(level_pct) > 70 -- Show only tanks with high level readings
;

-- Query 07: Tanks with more than one anomalous pH reading
SELECT tank_id,
    COUNT(*) AS anomalous_readings -- Count all readings after WHERE filter
FROM tank_readings
WHERE ph <6.5 OR ph>8.5 -- Filter tank_readings outside the range before grouping
GROUP BY tank_id
HAVING COUNT(*) > 1 -- Show only tanks with more than one anomaly after grouping
;

-- Query 08: Show last reading from each tank and include their pH readings with GROUP BY only
SELECT tank_id,
    MAX(reading_time) AS last_reading, -- Get last reading time
    ph AS last_ph -- Get last ph value
FROM tank_readings
GROUP BY -- Won't work because it can't know which ph value to show for each tank_id, since there are multiple ph values per tank_id
    tank_id
;