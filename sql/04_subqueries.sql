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

-- Query 04: Readings above the average ph across all tanks. (reading_id, tank_id, reading_time, ph)
/* --Average ph standalone query
SELECT
    AVG(ph) AS avg_ph
FROM tank_readings
-- avg_ph = 7.38 */
-- Expected results: 9
SELECT 
    reading_id,
    tank_id,
    reading_time,
    ph
FROM tank_readings
WHERE ph > (
    SELECT
        AVG(ph)
    FROM tank_readings
)
;

-- Query 05: Show readings above the average for each tank.
/* -- Calculate the average ph for each tank.
SELECT
    tank_id,
    AVG(ph) as avg_ph
FROM tank_readings
GROUP BY tank_id
; */

/*  Averages: 01: 7.045; 02: 8.03; 03: 7.005714
    Expected results:
    01: 5 rows
    02: 3 rows
    03: 2 rows
 */

SELECT
    tr.reading_id,
    tr.tank_id,
    tr.ph
FROM tank_readings AS tr
WHERE tr.ph > (
    SELECT
        AVG(sq.ph)
    FROM tank_readings AS sq -- sq alias to indicate subquery table
    WHERE sq.tank_id = tr.tank_id
    )
ORDER BY
    tr.tank_id,
    tr.reading_id
;
/*  Q05 returns different results since it searches for above average readings using the tank's own average,
    while Q04 filters the table using a single average for all of them.
    e.g.:
    reading_id 1: Appears only in Q05. The ph for reading_id 1 is 7.10,
    below the overall average used in Q04(7.38) but above the TQ-01 average (7.045)
    reading_id 7: Appears only in Q04. Its pH is 7.80,
    above the overall average used in Q04 (7.38) but below the TQ-02 average (8.03) */

-- Q06.a: All readings from tanks with at least one reading ph>8.5
/*  Expected results:
    TQ-02 - 7 rows
    TQ-03 - 7 rows
*/
SELECT
    tr.reading_id,
    tr.tank_id,
    tr.ph
FROM tank_readings AS tr
WHERE EXISTS (
    SELECT 1
    FROM tank_readings AS sq
    WHERE sq.ph > 8.5
    AND sq.tank_id=tr.tank_id
)
ORDER BY
    tr.reading_id
;

-- Q06.b: Show only tanks with at least one reading ph>8.5 (DISTINCT)
/*  Expected results:
    TQ-02 - 1 row
    TQ-03 - 1 row
*/
SELECT DISTINCT 
    tr.tank_id
FROM tank_readings AS tr
WHERE EXISTS (
    SELECT 1
    FROM tank_readings AS sq
    WHERE sq.ph > 8.5 
    AND sq.tank_id=tr.tank_id
)
ORDER BY
    tr.tank_id
;

-- Q06.c: All readings from tanks with no readings ph>8.5 (reading_id, tank_id, ph)
/*  Expected results:
    TQ-01 - 6 rows
*/

SELECT
    tr.reading_id,
    tr.tank_id,
    tr.ph
FROM tank_readings AS tr
WHERE NOT EXISTS (
    SELECT 1
    FROM tank_readings AS sq
    WHERE sq.ph > 8.5
    AND sq.tank_id=tr.tank_id
)
ORDER BY
    tr.reading_id
;