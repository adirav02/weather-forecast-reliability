# Data Source Validation

This document evaluates the data sources considered for the
Weather Forecast Reliability project.

The purpose of this stage is to verify that the selected sources
can support the research questions before designing the database
or implementing the final data pipeline.

The validation focuses on:

- Available variables
- Historical coverage
- Geographic coverage
- Temporal resolution
- Timestamp representation
- Units
- Forecast horizon availability
- Observation availability
- Missing and unusual values
- Data access method
- Suitability for historical forecast verification

---

# 1. Forecast Data — Open-Meteo

## Source Overview

Open-Meteo provides access to multiple global and regional weather
forecast models.

For this project, Open-Meteo is used as the source of historical
temperature forecasts.

The primary variable required for V1 is:

`temperature_2m`

The project focuses on hourly temperature forecasts.

---

## Historical Data Options Evaluated

Several historical products were investigated.

### Historical Weather / ERA5

ERA5 is reanalysis data.

It represents reconstructed historical weather conditions and is
therefore not suitable as the main forecast source for this project.

The project requires forecasts that were created before the target
weather event occurred.

---

### Historical Forecast API

The Historical Forecast API provides archived model output combined
into continuous historical time series.

It is useful for historical model analysis but does not directly
represent the fixed multi-day forecast horizons required by the
main research question.

---

### Single Runs API

The Single Runs API provides archived individual model runs based
on model initialization time.

This could be useful for more advanced model-run analysis later,
but it is not required for the initial version of the project.

---

### Previous Runs API

The Previous Runs API provides forecasts aligned to fixed forecast
lead times.

For example:

`temperature_2m_previous_day1`

represents a forecast for the target time approximately one day
earlier.

Similarly:

- previous_day1 → 1-day forecast horizon
- previous_day2 → 2-day forecast horizon
- previous_day3 → 3-day forecast horizon
- ...
- previous_day7 → 7-day forecast horizon

This API directly supports the main research question of comparing
forecast accuracy across forecast horizons.

Therefore, the Previous Runs API was selected for V1.

---

# 2. Forecast Model Evaluation

## HRRR

HRRR was evaluated because it is a high-resolution U.S. regional
forecast model.

Testing for New York City showed that short-range forecast values
were available, but longer Previous Runs horizons returned missing
values.

Because the project requires comparison across multiple forecast
horizons, HRRR was not selected as the primary model for V1.

---

## GFS Global

GFS Global was tested using New York City coordinates.

Historical tests successfully returned temperature forecasts for:

- Day 1
- Day 2
- Day 3
- Day 4
- Day 5
- Day 6
- Day 7

The availability was also successfully tested using historical
dates from 2021.

GFS therefore provides both the historical depth and multi-day
forecast horizons required by the project.

### V1 Decision

GFS Global was selected as the initial forecast model for V1.

The decision is still subject to full data-quality validation over
the final study period.

---

# 3. Open-Meteo Time and Location Representation

The Open-Meteo requests are currently configured to return
timestamps in GMT / UTC.

Example:

`utc_offset_seconds = 0`

`timezone = GMT`

The selected data uses hourly timestamps.

The API returns a model grid location that may differ slightly from
the coordinates originally requested.

Therefore, the forecast represents a model grid cell near New York
City rather than an exact physical measurement location.

This spatial difference must be considered when comparing the model
forecast with a physical observation station.

---

# 4. Observation Data — NOAA

The project requires measured temperature observations to act as
the reference against which the forecasts are evaluated.

Two NOAA data-access systems were investigated:

1. NWS API (`api.weather.gov`)
2. NOAA NCEI historical archives

---

# 5. NOAA NWS API

## New York City Observation Stations

The NWS `/points` endpoint was used to identify observation stations
associated with the selected New York City location.

Several nearby stations were identified, including:

- KNYC — New York City, Central Park
- KLGA — LaGuardia Airport
- KEWR — Newark International Airport
- KTEB — Teterboro Airport
- KJFK — Kennedy International Airport

---

## Selected Observation Station

KNYC — New York City, Central Park was selected as the primary
observation station for V1.

The station was selected because:

- It is physically located within New York City.
- It represents the geographic scope of the project.
- It provides temperature observations.
- It has a long historical observation record.
- It is geographically close enough to the selected GFS grid area
  for an initial single-city study.

Other stations remain possible alternatives for future comparison.

---

## Latest Observation Validation

The NWS observation endpoint was tested successfully for KNYC.

The response contains:

- Observation timestamp
- Temperature
- Temperature unit
- Quality-control information
- Dew point
- Relative humidity
- Wind information
- Pressure
- Visibility
- Raw observation information

Temperature is returned in degrees Celsius.

Observation timestamps are returned in UTC.

---

## Observation Timing

Testing showed that regular KNYC observations are commonly reported
around 51 minutes past the hour.

For example:

00:51
01:51
02:51
03:51

Additional observations may also occur between the normal hourly
reports.

Therefore, NOAA observation timestamps do not directly align with
the hourly GFS timestamps.

A matching methodology will later be required to determine which
observation represents each GFS target time.

---

## Historical Limitation

The NWS operational observations API was tested for historical data.

Recent observations were successfully returned.

However, the API did not provide the historical depth required for
the 2021 study period.

Therefore:

`api.weather.gov` will be used for station discovery and recent
observation validation, but not as the primary historical
observation archive.

---

# 6. NOAA NCEI Historical Observations

NOAA NCEI was evaluated as the historical observation source.

The Global Hourly dataset was tested for Central Park.

The station is represented as:

Station ID:

`72505394728`

Call sign:

`KNYC`

Station name:

`NY CITY CENTRAL PARK, NY US`

Historical observations from August 2021 were successfully
retrieved.

Therefore, NCEI provides the historical depth required by the
project.

---

## NCEI Temperature Data

The Global Hourly response contains the `TMP` field for temperature.

Example values include:

`+0261,5`

`+0256,5`

`+0239,5`

The field uses an encoded representation rather than a direct
floating-point temperature value.

The exact parsing rules and quality-code representation must be
validated against the NCEI field documentation before the data is
transformed.

---

## Observation Report Types

The historical sample contains multiple report types.

Regular observations frequently use:

`REPORT_TYPE = FM-15`

These observations commonly appear at approximately 51 minutes past
the hour.

Additional records were observed with:

`REPORT_TYPE = FM-16`

These records may occur at additional times between the regular
hourly observations.

The dataset also contains:

`REPORT_TYPE = SOD`

For example, one SOD record contained:

`TMP = +9999,9`

This value cannot be treated as a normal temperature observation
and will require validation and appropriate handling during the
data-quality stage.

---

## Quality Information

The NCEI response also contains:

`QUALITY_CONTROL`

For the tested sample, records included values such as:

`V030`

The meaning of the complete quality-control representation must be
validated before defining the project's observation quality rules.

---

# 7. Current V1 Data Source Configuration

Forecast source:

Open-Meteo

Forecast model:

GFS Global

Forecast API:

Previous Runs API

Forecast variable:

Temperature at 2 meters

Forecast resolution:

Hourly

Forecast horizons:

1–7 days

Observation provider:

NOAA

Historical observation source:

NOAA NCEI Global Hourly

Observation station:

KNYC — Central Park

NCEI station identifier:

72505394728

Primary observed variable:

Temperature

---

# 8. Initial Data-Quality Findings

The source-validation stage has already identified several issues
that will need to be addressed later.

Open-Meteo and NOAA timestamps are not directly aligned.

The GFS data uses hourly target times such as:

14:00

while KNYC observations often occur at:

13:51
14:51

Additionally, multiple observations may exist within the same hour.

The historical NOAA data also contains multiple report types and
encoded temperature values.

Some records contain values that cannot directly be interpreted as
valid temperatures.

These issues must be resolved before forecast and observation data
are joined.

---

# 9. Open Questions

The following decisions are intentionally left open until the raw
data is explored further:

- What final historical period should be used?
- How should `TMP` be parsed?
- Which NOAA report types should be used?
- Which NOAA quality-control values are acceptable?
- How should missing or sentinel temperature values be represented?
- How should a GFS hourly target time be matched to a KNYC
  observation?
- What time tolerance should be allowed during matching?
- How should multiple observations within one hour be handled?
- Should all timestamps remain in UTC?
- How much missing data exists across the complete study period?
- Should the geographic distance between the GFS grid point and the
  KNYC station be explicitly included in the analysis?

These questions will be addressed during the methodology and
data-quality design stages.