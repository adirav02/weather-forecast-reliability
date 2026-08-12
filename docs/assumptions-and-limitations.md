# Assumptions

## Current Assumptions

The first version of the project is based on the following assumptions:

### Geographic Scope

* **New York City** will be used as the initial location for the analysis.
* A single city is sufficient for validating the methodology and data workflow before expanding the project to additional locations.
* Results from New York City will be treated as location-specific and will not automatically be generalized to other cities or regions.

### Weather Variable

* The first version of the project will focus on **temperature** as the primary weather variable.
* Other weather variables, such as precipitation, humidity, and wind speed, are outside the initial scope and may be added later.

### Forecast Data

* Historical forecast data will be treated as the prediction that was available before the target weather event occurred.
* The time at which a forecast was issued and the time for which the forecast was made are considered two separate and important timestamps.
* Forecast horizon will represent the amount of time between the forecast publication time and the target forecast time.

### Observed Weather Data

* NOAA weather-station measurements will be used as the reference representation of the weather conditions that actually occurred.
* Observed temperature measurements will be treated as the comparison baseline when calculating forecast error.
* Weather-station observations are assumed to provide sufficiently reliable measurements for the purposes of the initial analysis.

### Forecast and Observation Matching

* A forecast should only be compared with an observation that represents the same target location and time period.
* Forecast and observation timestamps must be converted to a consistent time basis before comparison.
* Temperature values must use consistent measurement units before forecast error is calculated.
* The exact rules used to match forecast records with observation records will be defined after the structure and resolution of both data sources are examined.

### Forecast Accuracy

* Forecast accuracy will be evaluated by comparing forecasted temperature with observed temperature.
* A smaller difference between forecasted and observed temperature will represent a more accurate forecast.
* Both the **size of the error** and the **direction of the error** may be relevant to the analysis.
* The exact statistical measures used to summarize forecast accuracy will be defined during the analysis stage.

### Data Quality

* Missing, duplicate, invalid, or unmatched records may affect the reliability of the analysis and must therefore be identified before drawing conclusions.
* Records should not automatically be considered valid simply because they were successfully retrieved from the original data source.
* Data-quality checks will be performed before the analytical results are treated as reliable.

### Initial Analysis Scope

* The first analysis will focus on historical data rather than real-time forecasting.
* The initial objective is to understand and measure forecast reliability, not to create a new weather forecasting model.
* Machine Learning will only be considered after a sufficiently reliable historical dataset and analysis workflow have been established.
