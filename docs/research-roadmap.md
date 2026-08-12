# Weather Forecast Reliability - Research Roadmap

## Current Status

Completed:

- Project idea and motivation
- Initial problem statement
- Project goal
- Initial project scope
- New York City selected as the first location
- Initial research-question structure
- Initial assumptions
- Repository structure planned
- Forecast and observation data sources investigated
- Open-Meteo Previous Runs API selected for historical forecasts
- GFS Global selected as the initial forecast model for V1
- NOAA KNYC Central Park selected as the observation station
- NOAA NCEI Global Hourly selected as the historical observation source
- Historical forecast and observation samples successfully retrieved
- Initial data-source limitations and data-quality issues documented

## Current Stage

> **Phase 2 — Raw Data Inspection and Data Dictionary**

Phase 1 — Data Source Validation is complete.

The next stage focuses on understanding the raw data structure before
designing the database schema or implementing forecast-observation matching.

Current questions include:

- How should NOAA `TMP` values be interpreted?
- What do the NOAA report types represent?
- How should quality-control fields be interpreted?
- Which values represent missing or invalid measurements?
- What is the exact meaning of each Open-Meteo and NOAA field?
- How are multiple observations within the same hour represented?

No final database schema or matching methodology should be designed yet.

---

# Phase 1 - Validate the Data Sources ✅

## Goal

Understand whether the selected data sources can actually support the research question.

## Research Tasks

Investigate both data sources separately.

For each source, determine:

* What data is available?
* What period is available?
* What geographic resolution is available?
* What time resolution is available?
* What timestamps are provided?
* In what timezone are timestamps represented?
* What temperature measurements are available?
* Are values raw measurements, forecasts, estimates, or processed values?
* Are there missing values?
* How is the data accessed?
* Are there usage or licensing restrictions?
* Are historical records truly historical records, or reconstructed data?

### Forecast Source

Research the historical forecast source.

The most important question is:

> Can the source provide a forecast as it was actually available at a specific point in the past?

Do not assume this from the API name or documentation title.

### Observation Source

Research the NOAA observation data.

Determine:

* Which stations exist around New York City?
* What kind of measurements they provide.
* Which station or stations could reasonably represent the study area.
* What historical period is available.
* What time resolution exists.

## Output

Create or update:

`docs/data-sources.md`

Do not design tables yet.

---

# Phase 2 - Select the Exact Dataset

## Goal

Reduce the broad idea into one well-defined first experiment.

## Decisions to Make

You should decide:

* Which forecast source/version/model will be used?
* Which NOAA station will be used?
* What date range will be analyzed?
* What time resolution will be used?
* Which temperature measurement will be compared?
* How large should the first dataset be?

The first dataset does not need to be large.

The objective is to prove that the comparison is possible.

## Questions to Ask Yourself

* Can both sources represent approximately the same place?
* Can both sources represent the same target times?
* Is the time resolution compatible?
* Is there sufficient historical overlap?
* Can I identify when each forecast was originally issued?
* Can I determine which observation corresponds to each forecast?

## Output

A short section in:

`docs/data-sources.md`

describing the selected data for V1.

Also update:

`docs/assumptions-and-limitations.md`

with decisions or limitations discovered during this phase.

---

# Phase 3 - Inspect Raw Data

## Goal

Understand the data before designing the database.

Download only a small sample from each source.

Do not immediately clean it.

Do not immediately transform it.

First inspect it.

## Investigate

For each dataset:

* What does one row represent?
* What columns exist?
* What are their data types?
* Which fields appear to identify a record?
* Which timestamps exist?
* Which fields may contain `NULL`?
* Which units are used?
* Are there duplicate-looking records?
* Are there unexpected values?
* How often are measurements recorded?
* How often are forecasts produced?

## Important Principle

Do not ask:

> "What database tables should I create?"

Ask:

> "What does this data actually represent?"

Database design comes afterward.

## Output

Start:

`docs/data-dictionary.md`

and create initial exploratory SQL only if the data has already been loaded into PostgreSQL.

Possible repository area:

`sql/exploration/`

---

# Phase 4 - Define the Unit of Analysis

## Goal

Decide what a single observation in your research actually represents.

This is one of the most important research-design decisions.

You should be able to explain:

> What exactly is one record in the final comparison?

Think about the relationship between:

* forecast creation time
* forecast target time
* location
* predicted temperature
* observation time
* observed temperature

## Questions to Resolve

* Can several forecasts exist for the same target time?
* If yes, are they separate observations?
* What distinguishes one forecast from another?
* What makes two records duplicates?
* What makes two records different versions of the same forecast?

## Output

Document the decision in:

`docs/methodology.md`

and, if necessary:

`docs/decision-log.md`

---

# Phase 5 - Define the Matching Logic

## Goal

Determine conceptually how a forecast and an observation become comparable.

Do not start by writing the `JOIN`.

First define the rule in plain language.

## Questions

* What makes a forecast and observation refer to the same event?
* How close must the locations be?
* Must timestamps match exactly?
* What happens if the resolutions differ?
* What happens if an observation is missing?
* What happens if multiple observations could match?
* What happens if no observation matches?

## Validation Question

After matching, you should eventually be able to explain:

> Why am I confident that this forecast is being compared with the correct observed temperature?

## Output

Document the rule in:

`docs/methodology.md`

Later, the implementation will live in SQL.

---

# Phase 6 - Define Forecast Horizon

## Goal

Give a precise meaning to one of the central concepts in the project.

You currently know conceptually that forecast horizon represents:

> The distance between the time the forecast was issued and the time it predicts.

Now you need to investigate how the actual data allows you to represent it.

## Decide

* What timestamps are required?
* What unit will be useful for analysis?
* Whether horizon should remain continuous or later be grouped into categories.
* How invalid horizons should be treated.

Do not choose groups only because they are convenient.

Look at the data first.

## Output

Add the definition to:

`docs/methodology.md`

and:

`docs/data-dictionary.md`

---

# Phase 7 - Define What "Accuracy" Means

## Goal

Turn the word **accuracy** into measurable quantities.

Do not rush this phase.

"Accurate forecast" can mean several different things.

## Questions to Research

* Do you care about the size of the error?
* Do you care about the direction of the error?
* Do you care about typical error?
* Do extreme failures matter?
* Is one metric sufficient?
* Should several metrics be reported together?

Research possible error metrics and understand what each one tells you.

Then choose the metrics yourself.

## Important Principle

Do not select a metric because it is common.

Select it because you can explain:

> What question does this metric answer in this project?

## Output

Document the chosen metrics and reasoning in:

`docs/methodology.md`

---

# Phase 8 - Finalize the First Research Questions

## Goal

Only now convert the broad questions into questions that the available data can actually answer.

Review:

`docs/research-questions.md`

For every research question ask:

* Do I have the required variables?
* Can I measure the concept?
* Is the question within V1 scope?
* Can SQL answer it?
* Is the question descriptive, comparative, or predictive?
* Am I accidentally making a causal claim?

## Prioritize

Choose:

* One main research question.
* A small number of core questions.
* Secondary questions.
* Future questions.

Do not try to answer everything in V1.

## Output

A finalized V1 section in:

`docs/research-questions.md`

---

# Phase 9 - Define Data Quality Rules

## Goal

Determine what must be true before you trust the analysis.

Do this before running the final analysis.

## Think About

* Completeness
* Uniqueness
* Validity
* Time consistency
* Unit consistency
* Matching quality
* Impossible values
* Unexpected values

For each rule, determine:

* What are you checking?
* Why does it matter?
* What would indicate a problem?
* Does failure invalidate the record or merely flag it?

## Output

Create:

`docs/data-quality-rules.md`

Later the implementation goes into:

`sql/quality-checks/`

---

# Phase 10 - Design the PostgreSQL Model

## Goal

Only after understanding the raw data, define how it should be stored.

Now ask:

* What entities exist?
* What belongs together?
* What needs its own identity?
* What relationships exist?
* What history must be preserved?
* Which values come from the source?
* Which values are derived?
* What uniqueness rules exist?
* What should PostgreSQL enforce?

Draw the model before writing all of the SQL.

## Output

* Initial ERD
* Database-design notes
* Setup SQL

Repository area:

`sql/setup/`

Do not optimize yet.

---

# Phase 11 - Load a Small End-to-End Dataset

## Goal

Prove that the entire analytical path works on a manageable sample.

The flow should now exist:

```text
Forecast source
      ↓
Raw forecast data

Observation source
      ↓
Raw observation data

      ↓
PostgreSQL
      ↓
Data-quality checks
      ↓
Matching
      ↓
Forecast error
```

## What You Are Testing

Not the final conclusion.

You are testing whether the **methodology works**.

## Output

* Reproducible SQL files
* Small sample dataset if licensing allows
* Initial quality results
* Notes about problems discovered

---

# Phase 12 - Exploratory Analysis

## Goal

Understand the behavior of the matched dataset before answering the main research questions.

Investigate:

* distributions
* ranges
* missingness
* unusual values
* forecast horizons
* error behavior
* time coverage
* sample sizes

Do not immediately interpret every pattern as meaningful.

## Output

SQL:

`sql/exploration/`

Selected results:

`results/tables/`

Important discoveries should also update:

* assumptions
* methodology
* research questions
* limitations

Research is iterative.

---

# Phase 13 - Core Analysis

## Goal

Answer the V1 research questions.

For each question follow the same structure:

```text
Question
↓
Required data
↓
Quality checks
↓
SQL analysis
↓
Result
↓
Interpretation
↓
Limitation
```

## Repository

SQL:

`sql/analysis/`

Results:

`results/tables/`

Later:

`results/figures/`

Documentation:

`docs/findings.md`

---

# Phase 14 - Challenge Your Own Results

## Goal

Try to find reasons your conclusions may be wrong.

Ask:

* Is the sample large enough?
* Could missing data bias the result?
* Does one unusual period dominate the statistics?
* Could station location affect the comparison?
* Could timezone handling change the result?
* Did the matching logic introduce duplicates?
* Are different forecast horizons represented equally?
* Am I generalizing beyond New York City?
* Am I confusing correlation with causation?

## Output

Update:

`docs/assumptions-and-limitations.md`

This is where the limitations section becomes much more important.

---

# Phase 15 - Write the Findings

## Goal

Present what the data actually supports.

For every important result separate:

### Result

What the data showed.

### Interpretation

What you think it means.

### Limitation

Why the conclusion should not be overstated.

Avoid writing conclusions first and looking for supporting data afterward.

## Output

`docs/findings.md`

---

# Phase 16 - Make the Repository Reproducible

## Goal

Someone who did not build the project should understand what happened.

The repository should eventually explain:

```text
What is the question?
↓
Where is the data from?
↓
How is the database built?
↓
What quality checks exist?
↓
How is the analysis executed?
↓
Where are the results?
↓
What conclusions were reached?
```

Review:

* README
* Repository structure
* SQL execution order
* Data-source documentation
* Research methodology
* Findings
* Limitations
* Sample data
* Results

---

# Phase 17 - Stop V1

Do not immediately expand the project.

First declare the first research version complete.

V1 should answer:

* Can historical forecasts be reliably matched with observations?
* Can forecast error be measured?
* Can forecast accuracy be analyzed by forecast horizon?
* Are the results reproducible?
* Are the limitations understood?

Only after V1 works should you consider:

* More U.S. cities
* Israel
* Additional weather variables
* Multiple forecast models
* Automated ingestion
* FastAPI
* Data pipelines
* Machine Learning

---

# How We Will Work Together

For each phase:

1. You research the subject.
2. You make an initial decision.
3. You explain your reasoning to me.
4. I challenge the reasoning and point out possible gaps.
5. You revise it if necessary.
6. You implement it yourself.
7. You show me the result for review.

When possible, I will avoid giving you the final solution.

Instead, I will ask questions such as:

* What does this field represent?
* What assumption are you making here?
* What would happen in this edge case?
* How could you verify this?
* Does the data actually support this conclusion?
* What alternative explanation exists?

The goal is that by the end of the project you can defend every important decision yourself.
