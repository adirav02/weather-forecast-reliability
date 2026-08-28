-- OPEN-METEO RAW DATA EXPLORATION

-- 1. BASIC ROW COUNT AND DATE RANGE

SELECT
    COUNT(*) AS total_rows,
    MIN(target_time_utc) AS min_time,
    MAX(target_time_utc) AS max_time
FROM raw.open_meteo_forecast;


-- 2. CHECK UTC OFFSET CONSISTENCY

SELECT
    utc_offset_seconds,
    COUNT(*)
FROM raw.open_meteo_forecast
GROUP BY utc_offset_seconds
ORDER BY COUNT(*) DESC;


-- 3. TEMPERATURE RANGE BY FORECAST HORIZON

SELECT
    MIN(temperature_day1) AS min_d1,
    MAX(temperature_day1) AS max_d1,
    AVG(temperature_day1) AS avg_d1,

    MIN(temperature_day2) AS min_d2,
    MAX(temperature_day2) AS max_d2,
    AVG(temperature_day2) AS avg_d2,

    MIN(temperature_day3) AS min_d3,
    MAX(temperature_day3) AS max_d3,
    AVG(temperature_day3) AS avg_d3,

    MIN(temperature_day4) AS min_d4,
    MAX(temperature_day4) AS max_d4,
    AVG(temperature_day4) AS avg_d4,

    MIN(temperature_day5) AS min_d5,
    MAX(temperature_day5) AS max_d5,
    AVG(temperature_day5) AS avg_d5,

    MIN(temperature_day6) AS min_d6,
    MAX(temperature_day6) AS max_d6,
    AVG(temperature_day6) AS avg_d6,

    MIN(temperature_day7) AS min_d7,
    MAX(temperature_day7) AS max_d7,
    AVG(temperature_day7) AS avg_d7
FROM raw.open_meteo_forecast;


-- 4. NULL CHECK

SELECT
    COUNT(*) FILTER (WHERE temperature_day1 IS NULL) AS null_day1,
    COUNT(*) FILTER (WHERE temperature_day2 IS NULL) AS null_day2,
    COUNT(*) FILTER (WHERE temperature_day3 IS NULL) AS null_day3,
    COUNT(*) FILTER (WHERE temperature_day4 IS NULL) AS null_day4,
    COUNT(*) FILTER (WHERE temperature_day5 IS NULL) AS null_day5,
    COUNT(*) FILTER (WHERE temperature_day6 IS NULL) AS null_day6,
    COUNT(*) FILTER (WHERE temperature_day7 IS NULL) AS null_day7
FROM raw.open_meteo_forecast;


-- 5. METADATA CONSISTENCY

SELECT
    latitude,
    longitude,
    elevation,
    timezone,
    timezone_abbreviation,
    COUNT(*)
FROM raw.open_meteo_forecast
GROUP BY
    latitude,
    longitude,
    elevation,
    timezone,
    timezone_abbreviation;



-- FINDINGS:
-- 168 hourly rows were loaded.
-- No null forecast temperatures were found.
-- Temperature ranges appear plausible across all forecast horizons.
-- UTC offset is consistent.
-- Location metadata is consistent across all rows.
-- No obvious anomalies were detected in the Open-Meteo raw dataset.