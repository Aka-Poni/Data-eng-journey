USE sensor_lab;

-- Query 01: INNER JOIN between tank_readings and tank_registry showing reading_id, tank_id, tank_name, reading_time and ph
/* Expected results:
One row per reading
20 rows
tank_name from tank_registry is added to each reading
TQ-04 does not appear (no readings) */
SELECT
    rd.reading_id,
    rd.tank_id,
    reg.tank_name,
    rd.reading_time,
    rd.ph
FROM tank_readings AS rd
INNER JOIN tank_registry AS reg
    ON rd.tank_id = reg.tank_id
;

-- Query 02: Show all registered tanks and respective readings, including tanks without readings
/* Expected results:
One row per reading + one row per registered tank with no readings
21 rows
tank_name from tank_registry is added to each reading
TQ-04 appears with NULL values. tank_name NULL from tank_registry, other NULL values from not having readings in tank_readings with TQ-04 */
SELECT
    rd.reading_id,
    reg.tank_id,
    reg.tank_name,
    rd.reading_time,
    rd.ph
FROM tank_registry AS reg
LEFT JOIN tank_readings AS rd
    ON reg.tank_id = rd.tank_id
;

-- Query 03: Total readings per tank. TQ-04 showing as 0
/* Expected results:
One row per tank
4 rows - TQ-01: 6, TQ-02: 7, TQ-03: 7, TQ-04: 0
*/
SELECT
    reg.tank_id,
    COUNT(rd.reading_id) AS total_readings 
FROM tank_registry AS reg
LEFT JOIN tank_readings AS rd
    ON reg.tank_id = rd.tank_id
GROUP BY
    reg.tank_id -- group by reg.tank_id: rd.tank_id is NULL for TQ-04
;