CREATE TABLE raw.open_meteo_forecast (
    target_time_utc TIMESTAMPTZ,
    temperature_day1 NUMERIC,
    temperature_day2 NUMERIC,
    temperature_day3 NUMERIC,
    temperature_day4 NUMERIC,
    temperature_day5 NUMERIC,
    temperature_day6 NUMERIC,
    temperature_day7 NUMERIC,
    latitude NUMERIC,
    longitude NUMERIC,
    elevation NUMERIC
    generation_time_ms NUMERIC,
    utc_offset_seconds INTEGER,
    timezone TEXT,
    timezone_abbreviation TEXT,
    hourly_units JSONB
);


-- Import data to raw.open_meteo_forecast

CREATE TEMP TABLE staging_raw_open_meteo_json (
    data JSONB
);

\copy staging_raw_open_meteo_json(data) 
FROM PROGRAM 'jq -c . /mnt/data/Databases/weather-forecast-reliability/raw-api-calls/open-meteo/response.json'


WITH src AS (
    SELECT
        data,
        data -> 'hourly' AS hourly
    FROM staging_raw_open_meteo_json
)
INSERT INTO raw.open_meteo_forecast (
    target_time_utc,
    temperature_day1,
    temperature_day2,
    temperature_day3,
    temperature_day4,
    temperature_day5,
    temperature_day6,
    temperature_day7,
    latitude,
    longitude,
    elevation,
    generation_time_ms,
    utc_offset_seconds,
    timezone,
    timezone_abbreviation,
    hourly_units
)
SELECT
    (hourly -> 'time' ->> i)::timestamp AT TIME ZONE 'UTC',

    (hourly -> 'temperature_2m_previous_day1' ->> i)::numeric,
    (hourly -> 'temperature_2m_previous_day2' ->> i)::numeric,
    (hourly -> 'temperature_2m_previous_day3' ->> i)::numeric,
    (hourly -> 'temperature_2m_previous_day4' ->> i)::numeric,
    (hourly -> 'temperature_2m_previous_day5' ->> i)::numeric,
    (hourly -> 'temperature_2m_previous_day6' ->> i)::numeric,
    (hourly -> 'temperature_2m_previous_day7' ->> i)::numeric,

    (data ->> 'latitude')::numeric,
    (data ->> 'longitude')::numeric,
    (data ->> 'elevation')::numeric,

    (data ->> 'generationtime_ms')::numeric,
    (data ->> 'utc_offset_seconds')::integer,
    data ->> 'timezone',
    data ->> 'timezone_abbreviation',
    data -> 'hourly_units'

FROM src
CROSS JOIN LATERAL generate_series(
    0,
    jsonb_array_length(hourly -> 'time') - 1
) AS g(i);