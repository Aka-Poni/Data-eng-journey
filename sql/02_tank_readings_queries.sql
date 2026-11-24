USE sensor_lab;

-- Query 1: Get all readings
SELECT * FROM tank_readings;

-- Query 2: Get tank_id, reading_time and ph only
SELECT
    tank_id,
    reading_time,
    ph
FROM tank_readings;

-- Query 3: Get readings for tank TQ-02 only
SELECT * FROM tank_readings
WHERE tank_id = 'TQ-02'; -- Filter for TQ-02, inside quotes because it's a string

-- Query 4: Only readings outside pH range (6.5-8.5)
SELECT * FROM tank_readings 
WHERE ph < 6.5 OR ph > 8.5; 

-- Query 5: Order by newest reading first
SELECT * FROM tank_readings
ORDER BY reading_time DESC; 

-- Query 6: 5 newest readings overall
SELECT * FROM tank_readings
ORDER BY 
    reading_time DESC, 
    reading_id DESC -- Tiebreaker: if same time, order by reading_id (auto-incremented, never repeats, unlike tank_id)
LIMIT 5; 

-- Query 7: Readings without temperature (sensor failure)
SELECT * FROM tank_readings
WHERE temperature_c IS NULL; 

-- Query 8: TQ-01 readings over 90% level on 19/11/2026
SELECT * FROM tank_readings
WHERE tank_id = 'TQ-01' 
    AND level_pct > 90 
    AND reading_time >= '2026-11-19 00:00:00' -- Includes this value and everything after it
    AND reading_time < '2026-11-20 00:00:00'; -- Excludes this value; includes everything before it 
 