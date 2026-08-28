CREATE TABLE raw.noaa_observation (
    station_id TEXT,
    observation_time TIMESTAMPTZ,
    latitude NUMERIC,
    longitude NUMERIC,
    elevation NUMERIC,
    tmp_raw TEXT,
    report_type TEXT,
    quality_control TEXT
);

-- Import data to raw.noaa_observation
CREATE TEMP TABLE staging_raw_noaa_json (
    data JSONB
);

\copy staging_raw_noaa_json(data) 
FROM PROGRAM 'jq -c . /mnt/data/Databases/weather-forecast-reliability/raw-api-calls/noaa/global-hourly-2026-08-28T16-06-41.json'


INSERT INTO raw.noaa_observation (
    station_id,
    observation_time,
    latitude,
    longitude,
    elevation,
    tmp_raw,
    report_type,
    quality_control
)
SELECT
    observation ->> 'STATION',
    (observation ->> 'DATE')::timestamp AT TIME ZONE 'UTC',
    (observation ->> 'LATITUDE')::numeric,
    (observation ->> 'LONGITUDE')::numeric,
    (observation ->> 'ELEVATION')::numeric,
    observation ->> 'TMP',
    observation ->> 'REPORT_TYPE',
    observation ->> 'QUALITY_CONTROL'
FROM staging_raw_noaa_json
CROSS JOIN LATERAL jsonb_array_elements(data) AS observation;