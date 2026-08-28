-- NOAA HOURLY MATCHING RESEARCH
--
-- Purpose:
-- Evaluate how NOAA observation timestamps should be matched to Open-Meteo's
-- exact hourly target timestamps before implementing the CLEAN layer.


-- 1. DISTANCE OF EACH VALID NOAA OBSERVATION FROM ITS NEAREST HOUR

WITH valid_observations AS (
    SELECT
        station_id,
        observation_time,
        observation_time AT TIME ZONE 'UTC' AS observation_time_utc
    FROM raw.noaa_observation
    WHERE SPLIT_PART(tmp_raw, ',', 1) <> '+9999'
),

distances AS (
    SELECT
        *,
        DATE_TRUNC(
            'hour',
            observation_time_utc + INTERVAL '30 minutes'
        ) AS nearest_hour_utc,
        ABS(
            EXTRACT(
                EPOCH FROM (
                    observation_time_utc
                    - DATE_TRUNC(
                        'hour',
                        observation_time_utc + INTERVAL '30 minutes'
                    )
                )
            )
        ) / 60 AS distance_minutes
    FROM valid_observations
)

SELECT
    CASE
        WHEN distance_minutes <= 5 THEN '0-5 min'
        WHEN distance_minutes <= 10 THEN '6-10 min'
        WHEN distance_minutes <= 15 THEN '11-15 min'
        WHEN distance_minutes <= 30 THEN '16-30 min'
    END AS distance_range,
    COUNT(*) AS observations
FROM distances
GROUP BY
    CASE
        WHEN distance_minutes <= 5 THEN '0-5 min'
        WHEN distance_minutes <= 10 THEN '6-10 min'
        WHEN distance_minutes <= 15 THEN '11-15 min'
        WHEN distance_minutes <= 30 THEN '16-30 min'
    END
ORDER BY MIN(distance_minutes);

-- Observed result:
-- 0-5 min   :   3
-- 6-10 min  : 168
-- 11-15 min :   6
-- 16-30 min :   9
--
-- 177 / 186 valid observations (95.2%) are within 15 minutes of an exact hour.


-- 2. INSPECT OBSERVATIONS MORE THAN 15 MINUTES FROM THE NEAREST HOUR

WITH observations AS (
    SELECT
        observation_time,
        observation_time AT TIME ZONE 'UTC' AS observation_time_utc,
        tmp_raw,
        TRIM(report_type) AS report_type
    FROM raw.noaa_observation
    WHERE SPLIT_PART(tmp_raw, ',', 1) <> '+9999'
)

SELECT
    observation_time_utc,
    DATE_TRUNC(
        'hour',
        observation_time_utc + INTERVAL '30 minutes'
    ) AS nearest_hour_utc,
    ROUND(
        ABS(
            EXTRACT(
                EPOCH FROM (
                    observation_time_utc
                    - DATE_TRUNC(
                        'hour',
                        observation_time_utc + INTERVAL '30 minutes'
                    )
                )
            )
        ) / 60
    ) AS distance_minutes,
    tmp_raw,
    report_type
FROM observations
WHERE
    ABS(
        EXTRACT(
            EPOCH FROM (
                observation_time_utc
                - DATE_TRUNC(
                    'hour',
                    observation_time_utc + INTERVAL '30 minutes'
                )
            )
        )
    ) / 60 > 15
ORDER BY observation_time_utc;

-- Observed result:
-- 9 observations were more than 15 minutes from an exact hour.
-- All inspected rows had report_type = 'FM-16'.
-- These rows are not necessarily a problem because another observation may be
-- closer to the same hourly target.


-- 3. SELECT THE CLOSEST VALID OBSERVATION FOR EACH STATION + HOURLY TARGET

WITH valid_observations AS (
    SELECT
        station_id,
        observation_time AT TIME ZONE 'UTC' AS observation_time_utc,
        tmp_raw,
        TRIM(report_type) AS report_type
    FROM raw.noaa_observation
    WHERE SPLIT_PART(tmp_raw, ',', 1) <> '+9999'
),

candidates AS (
    SELECT
        *,
        DATE_TRUNC(
            'hour',
            observation_time_utc + INTERVAL '30 minutes'
        ) AS matched_hour_utc
    FROM valid_observations
),

ranked AS (
    SELECT
        *,
        ROUND(
            ABS(
                EXTRACT(
                    EPOCH FROM (
                        observation_time_utc - matched_hour_utc
                    )
                )
            ) / 60
        ) AS distance_minutes,
        ROW_NUMBER() OVER (
            PARTITION BY station_id, matched_hour_utc
            ORDER BY ABS(
                EXTRACT(
                    EPOCH FROM (
                        observation_time_utc - matched_hour_utc
                    )
                )
            )
        ) AS rn
    FROM candidates
)

SELECT
    matched_hour_utc,
    observation_time_utc,
    distance_minutes,
    tmp_raw,
    report_type
FROM ranked
WHERE rn = 1
ORDER BY matched_hour_utc;


-- 4. VALIDATE THE 15-MINUTE MATCHING CUTOFF AFTER CHOOSING THE CLOSEST ROW

WITH valid_observations AS (
    SELECT
        station_id,
        observation_time AT TIME ZONE 'UTC' AS observation_time_utc,
        tmp_raw,
        TRIM(report_type) AS report_type
    FROM raw.noaa_observation
    WHERE SPLIT_PART(tmp_raw, ',', 1) <> '+9999'
),

candidates AS (
    SELECT
        *,
        DATE_TRUNC(
            'hour',
            observation_time_utc + INTERVAL '30 minutes'
        ) AS matched_hour_utc
    FROM valid_observations
),

ranked AS (
    SELECT
        *,
        ABS(
            EXTRACT(
                EPOCH FROM (
                    observation_time_utc - matched_hour_utc
                )
            )
        ) / 60 AS distance_minutes,
        ROW_NUMBER() OVER (
            PARTITION BY station_id, matched_hour_utc
            ORDER BY ABS(
                EXTRACT(
                    EPOCH FROM (
                        observation_time_utc - matched_hour_utc
                    )
                )
            )
        ) AS rn
    FROM candidates
)

SELECT *
FROM ranked
WHERE rn = 1
  AND distance_minutes > 15
ORDER BY matched_hour_utc;

-- Observed result: 0 rows.
--
-- Decision supported by this research:
-- For each station + exact UTC hour, choose the valid NOAA observation closest
-- to that hour. Keep the original observation timestamp, store the matched
-- hour separately, and require the selected observation to be within 15 minutes.
