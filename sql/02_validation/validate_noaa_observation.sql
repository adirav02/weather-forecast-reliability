-- ROW COUNT

SELECT COUNT(*) AS total_rows
FROM raw.noaa_observation;


-- REPORT TYPES

SELECT
    TRIM(report_type) AS report_type,
    COUNT(*) AS records
FROM raw.noaa_observation
GROUP BY TRIM(report_type)
ORDER BY records DESC;


-- QUALITY CONTROL VALUES

SELECT
    quality_control,
    COUNT(*) AS records
FROM raw.noaa_observation
GROUP BY quality_control
ORDER BY records DESC;


-- TMP QUALITY CODES

SELECT
    SPLIT_PART(tmp_raw, ',', 2) AS tmp_quality_code,
    COUNT(*) AS records
FROM raw.noaa_observation
GROUP BY tmp_quality_code
ORDER BY records DESC;


-- INVALID / MISSING TEMPERATURES

SELECT
    observation_time,
    tmp_raw,
    TRIM(report_type) AS report_type,
    quality_control
FROM raw.noaa_observation
WHERE SPLIT_PART(tmp_raw, ',', 1) = '+9999'
ORDER BY observation_time;


-- PARSED TEMPERATURE RANGE

WITH temperatures AS (
    SELECT
        CASE
            WHEN SPLIT_PART(tmp_raw, ',', 1) = '+9999' THEN NULL
            ELSE SPLIT_PART(tmp_raw, ',', 1)::NUMERIC / 10
        END AS temperature_c
    FROM raw.noaa_observation
)
SELECT
    MIN(temperature_c) AS min_temperature_c,
    MAX(temperature_c) AS max_temperature_c,
    ROUND(AVG(temperature_c), 1) AS avg_temperature_c
FROM temperatures;


-- EXACT DUPLICATE OBSERVATION TIMES

SELECT
    station_id,
    observation_time,
    COUNT(*) AS records
FROM raw.noaa_observation
WHERE SPLIT_PART(tmp_raw, ',', 1) <> '+9999'
GROUP BY station_id, observation_time
HAVING COUNT(*) > 1
ORDER BY records DESC;


-- OBSERVATIONS PER HOUR

SELECT
    DATE_TRUNC(
        'hour',
        observation_time AT TIME ZONE 'UTC'
    ) AS observation_hour_utc,
    COUNT(*) AS observations
FROM raw.noaa_observation
WHERE SPLIT_PART(tmp_raw, ',', 1) <> '+9999'
GROUP BY observation_hour_utc
ORDER BY observations DESC;


-- CHECK STATION METADATA CONSISTENCY

SELECT
    station_id,
    latitude,
    longitude,
    elevation,
    COUNT(*) AS records
FROM raw.noaa_observation
GROUP BY
    station_id,
    latitude,
    longitude,
    elevation
ORDER BY records DESC;