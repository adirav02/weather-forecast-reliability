# Research Questions

## Main Research Question

How does the accuracy of historical temperature forecasts change according to the amount of time between the forecast publication and the target forecast time?

## Core Research Questions

### Overall Forecast Accuracy

* How accurate are the temperature forecasts in general?
* What is the typical difference between the forecasted temperature and the observed temperature?
* How much variation exists in forecast errors?

### Forecast Horizon

* Are forecasts made closer to the target time more accurate than forecasts made further in advance?
* How does forecast error change across different forecast horizons?
* At what forecast horizon does accuracy begin to decrease significantly?

### Error Direction

* Do forecasts tend to predict temperatures that are higher than the observed temperature?
* Do forecasts tend to predict temperatures that are lower than the observed temperature?
* Is the direction of the error consistent across different forecast horizons?

### Time-Related Patterns

* Does forecast accuracy change according to the hour of the day?
* Does forecast accuracy change across different months or seasons?
* Are there specific time periods in which forecast errors are larger?

### Weather and Context Conditions

* Are larger forecast errors associated with particular weather conditions?
* Are forecasts less reliable during periods of rapid temperature change?
* Are extreme temperatures associated with larger forecast errors?

## Data Quality Questions

Before answering the analytical questions, the project should also examine:

* How many forecast records contain missing values?
* How many observed measurements contain missing values?
* Are there duplicate forecast or observation records?
* How many forecasts cannot be matched with an observed measurement?
* How many observed measurements do not have a corresponding forecast?
* Are there invalid or unexpected relationships between forecast publication time and target time?
* Are temperature values stored in consistent units?
* Does the matching process create duplicate results?

## Secondary Questions

These questions may be investigated after the main analysis is working:

* Does forecast accuracy change over the full historical period?
* Are certain hours or seasons more difficult to forecast?
* Are large forecast errors isolated events or part of longer periods of low accuracy?
* Does forecast accuracy improve consistently as the target time approaches?
* Are there conditions in which longer-range forecasts perform unexpectedly well?

## Future Research Questions

The following questions are outside the first version of the project:

* Does forecast accuracy differ between cities?
* Does forecast accuracy differ between forecasting models?
* Is the same forecasting model equally accurate in the United States and Israel?
* Are rainfall, wind, and humidity forecasts affected by forecast horizon in the same way as temperature forecasts?
* Can historical forecast errors be used to estimate the expected error of a new forecast?
* Can the system assign a reliability level to a newly published forecast?

## Initial Research Priority

The first analysis should focus on:

1. Measuring overall temperature forecast error.
2. Comparing forecast accuracy across forecast horizons.
3. Checking whether forecasts tend to overpredict or underpredict temperatures.
4. Validating that forecasts and observations are matched correctly.
5. Identifying missing, duplicate, invalid, or unmatched records.
