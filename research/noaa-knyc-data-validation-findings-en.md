**# NOAA KNYC — Data Source Validation Findings**

**## Context**

This document summarizes the initial validation and exploration of NOAA Global Hourly data for station KNYC, before creating the \`clean\` layer.

The goals at this stage are to:

\- Understand the RAW data structure.

\- Identify missing or invalid values.

\- Understand the \`TMP\` field format.

\- Inspect quality codes.

\- Check for duplicate observations.

\- Verify timezone handling.

\- Identify issues that must be resolved before joining NOAA observations with Open-Meteo forecasts.

**---**

**# 1. RAW Table Structure**

\`\`\`sql

CREATE TABLE raw\.noaa\_observation (

    station\_id TEXT,

    observation\_time TIMESTAMPTZ,

    latitude NUMERIC,

    longitude NUMERIC,

    elevation NUMERIC,

    tmp\_raw TEXT,

    report\_type TEXT,

    quality\_control TEXT

);

\`\`\`

Important decision:

\`tmp\_raw\` is stored as \`TEXT\` rather than \`NUMERIC\` because NOAA's \`TMP\` field contains both the temperature value and a quality code.

Examples:

\`\`\`text

+0206,5

+0194,5

+9999,9

\`\`\`

**---**

**# 2. Report Type Distribution**

\`\`\`sql

SELECT

    report\_type,

    COUNT(\*)

FROM raw\.noaa\_observation

GROUP BY report\_type

ORDER BY COUNT(\*) DESC;

\`\`\`

**### Finding**

Multiple \`report\_type\` values exist.

At this stage, we have not yet decided which report types are suitable to use as ground-truth temperature observations.

Values such as:

\`\`\`text

SOD

SOM

\`\`\`

were found among records with missing temperature values.

\> Some raw values contain trailing spaces, for example \`"SOD  "\`, so the clean layer will likely use \`TRIM(report\_type)\`.

**---**

**# 3. General Quality Control Distribution**

\`\`\`sql

SELECT

    quality\_control,

    COUNT(\*)

FROM raw\.noaa\_observation

GROUP BY quality\_control

ORDER BY COUNT(\*) DESC;

\`\`\`

The meaning and distribution of the general \`quality\_control\` field still require further investigation.

**---**

**# 4. Parsing the TMP Field**

To understand the structure of \`tmp\_raw\`, \`SPLIT\_PART\` was used.

\`\`\`sql

SELECT

    tmp\_raw,

    SPLIT\_PART(tmp\_raw, ',', 1) AS temperature\_raw

FROM raw\.noaa\_observation

LIMIT 20;

\`\`\`

**### Example Output**

\`\`\`text

tmp\_raw   | temperature\_raw

\----------|----------------

+0206,5   | +0206

+0194,5   | +0194

+0194,5   | +0194

+0189,5   | +0189

+0190,5   | +0190

+0183,5   | +0183

+9999,9   | +9999

\`\`\`

**### Conclusion**

The \`TMP\` field contains two components:

\`\`\`text

TMP

├── temperature value

└── temperature quality code

\`\`\`

For example:

\`\`\`text

+0206,5

\`\`\`

is parsed as:

\`\`\`text

temperature raw = +0206

quality code    = 5

\`\`\`

**---**

**# 5. Converting TMP to Celsius**

\`\`\`sql

SELECT

    tmp\_raw,

    ROUND(

        CASE

            WHEN SPLIT\_PART(tmp\_raw, ',', 1) = '+9999' THEN NULL

            ELSE SPLIT\_PART(tmp\_raw, ',', 1)::NUMERIC / 10

        END,

        1

    ) AS temperature\_c

FROM raw\.noaa\_observation

LIMIT 30;

\`\`\`

**### Observed Output**

\`\`\`text

tmp\_raw   | temperature\_c

\----------|--------------

+0206,5   | 20.6

+0194,5   | 19.4

+0194,5   | 19.4

+0189,5   | 18.9

+0190,5   | 19.0

+0189,5   | 18.9

+0183,5   | 18.3

+9999,9   | NULL

+9999,9   | NULL

+0180,5   | 18.0

+0178,5   | 17.8

+0172,5   | 17.2

+0170,5   | 17.0

+0200,5   | 20.0

+0206,5   | 20.6

+0211,5   | 21.1

+0217,5   | 21.7

\`\`\`

**### Conclusion**

Temperature conversion follows this rule:

\`\`\`text

+0206 → 20.6°C

+0194 → 19.4°C

+0170 → 17.0°C

\`\`\`

The value:

\`\`\`text

+9999

\`\`\`

does not represent a valid temperature and is converted to \`NULL\`.

**---**

**# 6. Min / Max / Average After Parsing**

\`\`\`sql

WITH temperatures AS (

    SELECT

        CASE

            WHEN SPLIT\_PART(tmp\_raw, ',', 1) = '+9999' THEN NULL

            ELSE SPLIT\_PART(tmp\_raw, ',', 1)::NUMERIC / 10

        END AS temperature\_c

    FROM raw\.noaa\_observation

)

SELECT

    MIN(temperature\_c) AS min\_temperature,

    MAX(temperature\_c) AS max\_temperature,

    AVG(temperature\_c) AS avg\_temperature

FROM temperatures;

\`\`\`

It is not correct to run \`MIN(tmp\_raw)\` or \`MAX(tmp\_raw)\` directly because \`tmp\_raw\` is stored as \`TEXT\`, so PostgreSQL would compare the values lexicographically rather than numerically.

**---**

**# 7. TMP Quality Code Distribution**

\`\`\`sql

SELECT

    SPLIT\_PART(tmp\_raw, ',', 2) AS tmp\_quality\_code,

    COUNT(\*)

FROM raw\.noaa\_observation

GROUP BY tmp\_quality\_code

ORDER BY COUNT(\*) DESC;

\`\`\`

**### Output**

\`\`\`text

tmp\_quality\_code | count

\-----------------|------

5                | 186

9                | 8

\`\`\`

**### Important Finding**

Most records have TMP quality code \`5\`.

All 8 records with quality code \`9\` were investigated separately.

**---**

**# 8. Records with TMP Quality Code = 9**

\`\`\`sql

SELECT

    observation\_time,

    tmp\_raw,

    report\_type,

    quality\_control

FROM raw\.noaa\_observation

WHERE SPLIT\_PART(tmp\_raw, ',', 2) = '9'

ORDER BY observation\_time;

\`\`\`

**### Output**

\`\`\`text

observation\_time         | tmp\_raw  | report\_type | quality\_control

\-------------------------|----------|-------------|----------------

2025-08-01 07:59:00+03   | +9999,9  | SOD         | V020

2025-08-01 07:59:00+03   | +9999,9  | SOM         | V020

2025-08-02 07:59:00+03   | +9999,9  | SOD         | V020

2025-08-03 07:59:00+03   | +9999,9  | SOD         | V020

2025-08-04 07:59:00+03   | +9999,9  | SOD         | V020

2025-08-05 07:59:00+03   | +9999,9  | SOD         | V020

2025-08-06 07:59:00+03   | +9999,9  | SOD         | V020

2025-08-07 07:59:00+03   | +9999,9  | SOD         | V020

\`\`\`

**### Conclusion**

Every record with TMP quality code \`9\` also has:

\`\`\`text

tmp\_raw = +9999,9

\`\`\`

In the inspected sample, there are no valid temperature observations with TMP quality code \`9\`.

Initial cleaning rule:

\`\`\`text

TMP value = +9999

→ no valid temperature

→ do not keep as a valid temperature observation in clean.observation

\`\`\`

**---**

**# 9. Initial TMP Parsing Rule**

\`\`\`text

tmp\_raw = "+0206,5"

→ temperature\_c = 20.6

tmp\_raw = "+9999,9"

→ invalid / missing temperature

→ discard from clean temperature observations

\`\`\`

\`\`\`sql

CASE

    WHEN SPLIT\_PART(tmp\_raw, ',', 1) = '+9999' THEN NULL

    ELSE SPLIT\_PART(tmp\_raw, ',', 1)::NUMERIC / 10

END

\`\`\`

**---**

**# 10. Timezone Validation**

The column is defined as:

\`\`\`sql

observation\_time TIMESTAMPTZ

\`\`\`

PostgreSQL displays \`TIMESTAMPTZ\` values according to the session timezone.

The following query was used:

\`\`\`sql

SELECT

    observation\_time,

    observation\_time AT TIME ZONE 'UTC' AS observation\_time\_utc

FROM raw\.noaa\_observation

LIMIT 10;

\`\`\`

**### Output**

\`\`\`text

observation\_time         | observation\_time\_utc

\-------------------------|------------------------

2025-08-01 03:51:00+03   | 2025-08-01 00:51:00

2025-08-01 04:51:00+03   | 2025-08-01 01:51:00

2025-08-01 04:58:00+03   | 2025-08-01 01:58:00

2025-08-01 05:40:00+03   | 2025-08-01 02:40:00

2025-08-01 05:49:00+03   | 2025-08-01 02:49:00

2025-08-01 05:51:00+03   | 2025-08-01 02:51:00

2025-08-01 06:27:00+03   | 2025-08-01 03:27:00

2025-08-01 06:51:00+03   | 2025-08-01 03:51:00

2025-08-01 07:51:00+03   | 2025-08-01 04:51:00

2025-08-01 07:59:00+03   | 2025-08-01 04:59:00

\`\`\`

**### Conclusion**

The timestamp is stored correctly.

For example:

\`\`\`text

2025-08-01 03:51:00+03

\`\`\`

represents the same instant as:

\`\`\`text

2025-08-01 00:51:00 UTC

\`\`\`

\`AT TIME ZONE 'UTC'\` does not fix or modify the stored value. It only displays the timestamp in UTC.

**---**

**# 11. Duplicate Check by Station + Timestamp**

\`\`\`sql

SELECT

    station\_id,

    observation\_time,

    COUNT(\*)

FROM raw\.noaa\_observation

WHERE SPLIT\_PART(tmp\_raw, ',', 1) <> '+9999'

GROUP BY station\_id, observation\_time

HAVING COUNT(\*) > 1

ORDER BY COUNT(\*) DESC;

\`\`\`

**### Result**

\`\`\`text

0 rows

\`\`\`

**### Conclusion**

In the inspected sample, there are no duplicate valid temperature observations for the same:

\`\`\`text

station\_id + observation\_time

\`\`\`

**---**

**# 12. New Issue — Multiple Observations Within the Same Hour**

Although no exact duplicate timestamps were found, NOAA contains timestamps such as:

\`\`\`text

00:51

01:51

01:58

02:40

02:49

02:51

03:27

03:51

04:51

04:59

\`\`\`

Open-Meteo, however, provides forecasts on exact hourly timestamps:

\`\`\`text

00:00

01:00

02:00

03:00

...

\`\`\`

**### Implication**

The future JOIN cannot necessarily rely on:

\`\`\`sql

forecast.target\_time\_utc = observation.observed\_at\_utc

\`\`\`

Before defining the matching logic, we need to understand:

\- How many observations exist within each hour.

\- Which \`report\_type\` values create extra observations.

\- Whether there is a regular report type that represents the hourly observation.

\- Whether the clean layer should select one observation, select the nearest one, or aggregate multiple observations.

**---**

**# 13. Next Research Queries**

**## Number of Observations Per Hour**

\`\`\`sql

SELECT

    DATE\_TRUNC(

        'hour',

        observation\_time AT TIME ZONE 'UTC'

    ) AS observation\_hour\_utc,

    COUNT(\*) AS observations

FROM raw\.noaa\_observation

WHERE SPLIT\_PART(tmp\_raw, ',', 1) <> '+9999'

GROUP BY observation\_hour\_utc

ORDER BY observations DESC;

\`\`\`

**## Report Type Distribution for Valid Temperature Observations**

\`\`\`sql

SELECT

    TRIM(report\_type) AS report\_type,

    COUNT(\*) AS observations

FROM raw\.noaa\_observation

WHERE SPLIT\_PART(tmp\_raw, ',', 1) <> '+9999'

GROUP BY TRIM(report\_type)

ORDER BY observations DESC;

\`\`\`

**---**

**# 14. CLEAN Rules We Can Already Define**

\`\`\`text

TMP +9999

→ Missing / invalid

→ do not keep as a valid observation

TMP numeric component

→ CAST to NUMERIC

→ divide by 10

→ temperature\_c

report\_type

→ TRIM(report\_type)

observation\_time

→ TIMESTAMPTZ

→ use UTC when matching against Open-Meteo

\`\`\`

**---**

**# 15. Decisions Still Open**

Before finalizing \`clean.observation\`, we still need to decide:

1\. Which \`report\_type\` values should be used.

2\. How to handle multiple observations within the same hour.

3\. How NOAA timestamps should be matched to Open-Meteo timestamps.

4\. Whether \`tmp\_quality\_code\` should be stored as a separate clean column.

5\. Whether the general \`quality\_control\` field should only be preserved or also be used for filtering.

**---**

**# Current Research Status**

\`\`\`text

✓ TMP raw format understood

✓ Temperature parsing works

✓ +9999 identified as missing

✓ TMP quality codes inspected

✓ All code-9 rows are missing temperatures

✓ Timezone behavior verified

✓ No duplicate valid station\_id + timestamp pairs

? Multiple observations can exist within one hour

? Need to investigate report\_type distribution

? Need to define hourly matching strategy with Open-Meteo

\`\`\`
---

# 16. Hourly Matching Research

The timestamp issue was investigated further before defining the CLEAN transformation.

NOAA observations do not always occur exactly on the hour, while Open-Meteo uses exact hourly target timestamps. Therefore, the goal was to determine whether each NOAA observation can be mapped safely to its nearest exact UTC hour.

## Distance from the Nearest Exact Hour

For every valid temperature observation, the nearest exact hour was calculated and the absolute time difference was measured.

### Result

```text
Distance from hour | Observations
-------------------|-------------
0-5 min            | 3
6-10 min           | 168
11-15 min          | 6
16-30 min          | 9
```

Out of 186 valid temperature observations:

```text
171 / 186 = 91.9% are within 10 minutes
177 / 186 = 95.2% are within 15 minutes
9 / 186   = 4.8% are more than 15 minutes away
```

The 9 observations more than 15 minutes from the nearest exact hour were inspected separately. In the inspected sample, all of them had:

```text
report_type = FM-16
```

This alone is not enough reason to discard the `FM-16` report type, because several NOAA observations can compete for the same hourly target and a closer observation may exist.

---

# 17. Selecting One Observation Per Hour

Instead of discarding every individual observation that is more than 15 minutes from an exact hour, the matching logic was tested in the correct order:

```text
valid NOAA observations
→ map each observation to its nearest exact UTC hour
→ group by station_id + matched_hour_utc
→ rank candidates by absolute timestamp distance
→ select the closest observation
→ validate the selected observation against a 15-minute cutoff
```

`ROW_NUMBER()` was used to select the closest candidate for each station and matched hour.

Example:

```text
Hourly target: 03:00 UTC

02:40 → distance 20 min
02:49 → distance 11 min
02:51 → distance  9 min

Selected observation: 02:51
```

This means that a record such as `02:40` does not need to be filtered before matching. It simply loses to the better candidate for the same target hour.

---

# 18. 15-Minute Cutoff Validation

After selecting only the closest observation for each:

```text
station_id + matched_hour_utc
```

the selected rows were checked for observations more than 15 minutes from their target hour.

### Result

```text
0 rows
```

### Conclusion

In the inspected KNYC sample, every selected hourly observation is within 15 minutes of the exact hourly target.

Therefore, a 15-minute maximum matching distance is currently supported by the data.

---

# 19. Final Timestamp Matching Decision for CLEAN

The CLEAN layer will use the following rules:

```text
1. Preserve the original NOAA observation timestamp.
2. Convert / compare timestamps in UTC for hourly matching.
3. Assign each valid observation to its nearest exact UTC hour.
4. For each station_id + matched_hour_utc, select the observation with the smallest time difference.
5. Keep the selected observation only when its distance from the target hour is <= 15 minutes.
6. Store the matched hour separately from the original observation timestamp.
```

The original timestamp must not be overwritten by the hourly target.

Recommended CLEAN fields include:

```text
observed_at
matched_hour_utc
match_distance_minutes
```

This preserves traceability while still creating an hourly observation layer that can be joined safely to Open-Meteo.

---

# 20. Report Type Decision

At this stage, valid observations will not be filtered by `report_type`.

The CLEAN transformation will:

```text
TRIM(report_type)
→ preserve the value
→ continue investigating report-type behavior later
```

Reason:

The hourly matching research showed that observations farther from the target hour can simply lose to a closer candidate. There is currently not enough evidence to discard an entire report type solely because some of its observations occur at irregular timestamps.

---

# 21. Updated CLEAN Rules

```text
TMP +9999
→ invalid / missing temperature
→ discard from CLEAN temperature observations

TMP numeric component
→ CAST to NUMERIC
→ divide by 10
→ temperature_c

report_type
→ TRIM
→ preserve all currently valid report types

TMP quality code
→ preserve separately

quality_control
→ preserve for later investigation

observation_time
→ preserve original timestamp
→ use UTC for matching

hourly matching
→ assign nearest exact UTC hour
→ choose closest observation per station + hour
→ maximum selected distance = 15 minutes
```

---

# 22. Updated Research Status

```text
✓ TMP raw format understood
✓ Temperature parsing works
✓ +9999 identified as missing
✓ TMP quality codes inspected
✓ All code-9 rows are missing temperatures
✓ Timezone behavior verified
✓ No duplicate valid station_id + timestamp pairs
✓ Multiple observations within one hour investigated
✓ Distance-to-hour distribution measured
✓ Closest-observation selection tested
✓ 15-minute cutoff validated after ranking
✓ 0 selected hourly observations exceed the cutoff
✓ Hourly matching strategy defined
✓ report_type will be preserved for further research

? General quality_control meaning still requires deeper investigation
? report_type differences should be investigated later with a larger sample
```
