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

-- Query 04: Count readings and maintenances per tank, in a single query with LEFT JOIN and COUNT
/* Expected results:
One row per tank
Wanted: 4 rows - TQ-01: 2/6, TQ-02: 1/7, TQ-03: 0/7, TQ-04: 0/0
Actual: 4 rows - TQ-01: 12/12, TQ-02: 7/7, TQ-03: 0/7, TQ-04: 0/0  
WRONG BY DESIGN, JOIN fan-out multiplies rows. Fixed in Q04.b
*/
SELECT
    reg.tank_id,
    COUNT(mt.maintenance_id) AS total_maintenance,
    COUNT(rd.reading_id) AS total_readings
FROM tank_registry AS reg
LEFT JOIN tank_maintenance AS mt
    ON reg.tank_id = mt.tank_id
LEFT JOIN tank_readings AS rd
    ON rd.tank_id = reg.tank_id
GROUP BY
    reg.tank_id
;

/* DRAFT A/B: Building blocks for Q04.b */

/*DRAFT A 
Total maintenance per tank, using tank_maintenance only 
Expected:
One row per tank that has maintenance records
2 rows: TQ-01 (2), TQ-02 (1) */
SELECT 
    mt.tank_id,
    COUNT(mt.maintenance_id) AS total_maintenance
FROM tank_maintenance AS mt
GROUP BY 
    mt.tank_id
;

/*DRAFT B
Total readings per tank, using tank_readings only 
Expected:
One row per tank that has readings
3 rows: TQ-01 (6), TQ-02 (7), TQ-03 (7)
*/
SELECT 
    rd.tank_id,
    COUNT(rd.reading_id) AS total_readings
FROM tank_readings AS rd
GROUP BY 
    rd.tank_id
;

-- Query 04.b: Maintenance and reading count per tank, without fan-out
/* Expected results:
One row per tank (tank_id, total_maintenance, total_readings)
Wanted: 4 rows - TQ-01: 2/6, TQ-02: 1/7, TQ-03: 0/7, TQ-04: 0/0
Actual: 4 rows - TQ-01: 2/6, TQ-02: 1/7, TQ-03: NULL/7, TQ-04: NULL/NULL (fixed in Q04.c)
TQ-03 has no maintenance records
TQ-04 has 0 maintenance records and 0 readings.
The LEFT JOINs create the NULLs in the total_maintenance and total_readings columns for tanks with no matching rows */
SELECT
    reg.tank_id,
    mt.total_maintenance,
    rd.total_readings
FROM tank_registry AS reg
LEFT JOIN (
    SELECT
        tank_id,
        COUNT(maintenance_id) AS total_maintenance
    FROM tank_maintenance
    GROUP BY
        tank_id
) AS mt
    ON mt.tank_id = reg.tank_id
LEFT JOIN (
    SELECT
        tank_id,
        COUNT(reading_id) AS total_readings
    FROM tank_readings
    GROUP BY
        tank_id
) AS rd
    ON rd.tank_id = reg.tank_id
;

-- Query 04.c: Maintenance and reading count per tank, without fan-out using COALESCE to resolve NULL values
/* Expected results:
One row per tank (tank_id, total_maintenance, total_readings)
4 rows - TQ-01: 2/6, TQ-02: 1/7, TQ-03: 0/7, TQ-04: 0/0
TQ-03 has no maintenance records
TQ-04 has 0 maintenance records and 0 readings.
The LEFT JOINs create the NULLs in the total_maintenance and total_readings columns for tanks with no matching rows
COALESCE changes NULL values to 0
*/

SELECT
    reg.tank_id,
    COALESCE(mt.total_maintenance, 0) AS total_maintenance,
    COALESCE(rd.total_readings, 0) AS total_readings
FROM tank_registry AS reg
LEFT JOIN (
    SELECT
        tank_id,
        COUNT(maintenance_id) AS total_maintenance
    FROM tank_maintenance
    GROUP BY
        tank_id
) AS mt
    ON mt.tank_id = reg.tank_id
LEFT JOIN (
    SELECT
        tank_id,
        COUNT(reading_id) AS total_readings
    FROM tank_readings
    GROUP BY
        tank_id
) AS rd
    ON rd.tank_id = reg.tank_id
;