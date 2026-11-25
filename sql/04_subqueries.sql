USE sensor_lab;

-- Query 01: For each tank, show tank_id + last reading time using only GROUP BY
-- Expected results: 3 rows. 01: 2026-11-19 16:00:00; 02: 2026-11-19 20:00:00; 03: 2026-11-19 16:00:00
SELECT tank_id,
    MAX(reading_time) AS last_reading_time
FROM tank_readings
GROUP BY tank_id
; 

-- Query 02: Last complete reading for each tank (tank_id, reading_time, level_pct, ph, temperature_c) using Q01 as subquery in the WHERE
/* Expected results: 3 rows.
    01: ('TQ-01', '2026-11-19 16:00:00', 93.75, 7.45, 26.40)
    02: ('TQ-02', '2026-11-19 20:00:00', 46.10, 7.70, 23.40)
    03: ('TQ-03', '2026-11-19 16:00:00', 84.05, 7.15, 26.20)
 */
SELECT tank_id,
    reading_time,
    level_pct,
    ph,  
    temperature_c
FROM tank_readings
WHERE (tank_id, reading_time) IN
(
    SELECT tank_id,
        MAX(reading_time)
    FROM tank_readings
    GROUP BY tank_id
)
;

-- Query 03: Last complete reading for each tank (tank_id, reading_time, level_pct, ph, temperature_c) using Q01 as subquery as a derived table in a JOIN
/* Expected results: 3 rows.
    01: ('TQ-01', '2026-11-19 16:00:00', 93.75, 7.45, 26.40)
    02: ('TQ-02', '2026-11-19 20:00:00', 46.10, 7.70, 23.40)
    03: ('TQ-03', '2026-11-19 16:00:00', 84.05, 7.15, 26.20)
 */
SELECT
    tr.tank_id,
    tr.reading_time,
    tr.level_pct,
    tr.ph,
    tr.temperature_c
FROM tank_readings AS tr -- convenient alias for tank_readings
JOIN (
    SELECT tank_id,
        MAX(reading_time) AS last_reading_time
    FROM tank_readings
    GROUP BY tank_id
) AS last_readings -- alias needed: tank_id exists in both sides
    ON tr.tank_id = last_readings.tank_id
    AND tr.reading_time = last_readings.last_reading_time 
;
    