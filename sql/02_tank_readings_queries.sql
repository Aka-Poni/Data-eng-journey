USE sensor_lab;

-- Query 1: Get all readings
SELECT * FROM tank_readings;

--Query 2: Get tank_id, reading_time and ph only
SELECT
    tank_id,
    reading_time,
    ph
    FROM tank_readings;

-- Query 3: Get readings for tank TQ-02 only
    SELECT * FROM tank_readings
    WHERE tank_id = 'TQ-02'; -- Filter for TQ-02, inside quotes because it's a string

-- Query 4: Only readings outside pH range (6.5-8.5)
SELECT * FROM tank_readings -- Select all data from tank_readings table
WHERE ph < 6.5 OR ph > 8.5; -- Filter pH values

-- Query 5: Order by newest reading first
SELECT * FROM tank_readings
ORDER BY reading_time DESC; -- Order by reading_time, newest first

-- Query 6: 5 newest readings overall
SELECT * FROM tank_readings
ORDER BY 
reading_time DESC, -- Order by reading_time, newest first
tank_id DESC -- Order by tank_id, newest first
LIMIT 5; -- Limit to 5 rows


-- Query 7: Readings without temperature (sensor failure)
SELECT * FROM tank_readings
WHERE temperature_c IS NULL; -- Filter for null values

-- Query 8: TQ-01 readings over 90% level on 19/11/2026
Select * FROM tank_readings
WHERE tank_id = 'TQ-01' -- Filter for TQ-01
AND level_pct > 90 -- Filter for level greater than 90%
AND reading_time BETWEEN '2026-11-19 00:00:00' AND '2026-11-19 23:59:59'; -- Filter for readings on 19/11/2026