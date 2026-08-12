# Project Overview

## Background

Weather forecasts are published every day around the world using meteorological instruments, forecasting models, and professional analysis.

People receive these forecasts through news channels, websites, and mobile applications, and use them to make everyday decisions, such as choosing suitable clothing, carrying an umbrella, or planning outdoor activities.

However, forecasts do not always match the weather conditions that eventually occur. For example, rain may be predicted but never occur, or unusually hot weather may be expected while the actual temperature is lower.

## Problem Statement

Weather forecasts usually provide an expected temperature or weather condition, but they do not always explain how reliable that prediction is.

Forecast accuracy may vary depending on how far in advance the forecast was published and on other weather, location, and time-related conditions.

The problem addressed by this project is the lack of a clear way to compare forecasted weather conditions with the conditions that were actually observed and to understand when forecasts are more or less reliable.

## Project Goal

The goal of this project is to evaluate the reliability of weather forecasts by comparing predicted temperatures with the temperatures that were actually recorded.

The project will also examine whether forecast accuracy changes according to the amount of time between the forecast publication and the target forecast time, as well as other conditions that may influence the forecast error.

## What the project Does

The project compares and analyzes:

* The temperature that was forecasted in advance.
* The temperature that was actually recorded.
* The forecast horizon, representing how far in advance the forecast was made relative to its target time.
* Additional conditions that may affect forecast accuracy.

The analysis is intended to support questions such as:

* How accurate are weather forecasts in general?
* Are short-range forecasts more accurate than long-range forecasts?
* Are there specific times or conditions in which forecasts are less reliable?
* Do forecasts tend to predict temperatures that are higher or lower than the actual temperature?
* Which factors are associated with larger forecast errors?

The system then calculates forecast errors and analyzes how those errors change across different forecast horizons and conditions.

## Target Users and Use Cases

The project may be useful for:

* People who want to better understand how much confidence to place in a weather forecast.
* Data analysts studying patterns in forecast accuracy.
* Weather applications that may later display a reliability measure alongside a forecast.
* Researchers comparing forecast performance across locations, time periods, or forecasting models.

The first version is primarily a data analysis and data engineering project rather than a complete consumer-facing weather application.

## Current Scope

The first version of the project will focus on:

- Temperature forecasts only.
- New York City in the United States.
- Historical forecast data from the Open-Meteo Previous Runs API.
- GFS Global as the initial forecast model.
- Hourly temperature forecasts at 2 meters.
- Forecast horizons from 1 to 7 days.
- Historical observed temperature data from NOAA NCEI Global Hourly.
- KNYC — New York City, Central Park as the primary observation station.
- Comparing forecasted temperatures with observed temperatures for corresponding target times.
- Examining how forecast accuracy changes according to forecast horizon.
- Using PostgreSQL and SQL for data storage, validation, matching, and analysis.

## The initial version will not include:

* A user interface.
* Real*time weather alerts.
* A machine learning model.
* A fully automated data pipeline.
* A comparison between multiple countries.
* Analysis of every city in the United States.

## Future Scope

Possible future extensions include:

* Adding more cities in the United States.
* Expanding the analysis to Israel.
* Comparing forecast accuracy between the United States and Israel.
* Comparing different forecasting models.
* Adding variables such as rainfall, wind speed, and humidity.
* Automating data collection with Python.
* Adding data-quality monitoring.
* Building a FastAPI backend.
* Creating dashboards or visual reports.
* Developing a machine learning model that estimates the expected error of a new forecast.

## Expected Outputs

The project is expected to produce:

* A structured PostgreSQL database containing forecast and observed weather data.
* SQL scripts for database setup, data exploration, quality checks, and analysis.
* Matched records connecting forecasts with the corresponding observed temperatures.
* Forecast-error measurements.
* Summary results grouped by forecast horizon and other relevant conditions.
* Data-quality results for missing, duplicate, invalid, or unmatched records.
* Selected result tables and visualizations.
* Documentation describing the data sources, assumptions, methodology, decisions, and findings.

## Success Criteria

The first version of the project will be considered successful when:

* Forecast data and observed temperature data can be loaded consistently.
* The meaning of all important time fields is clearly documented.
* Forecasts can be matched with the correct observed measurements.
* Forecast error can be calculated consistently.
* Forecasts can be compared across different forecast horizons.
* The project can answer its main research questions.
* Missing, duplicate, invalid, and unmatched records can be identified.
* The SQL workflow can be reproduced from the files in the repository.
* Another person can understand the project structure, data sources, and analysis process from the documentation.