-- =============================================================
-- WEEK 10 - DATA PROFILING EXERCISES
-- 7 exercises. Numbers 1-4 in class, 5-7 as homework.
-- Database: BootcampDB (T-SQL)

-- SECTION ON THE FOUR LENSES (Mental model)
-- Every dataset gets profiled through four questions:
-- 1. Shape:        How big is it?
-- 2. Completeness: How much is missing?
-- 3. Uniqueness:   How varied is each column?
-- 4. Range:        Where do values fall?

-- =============================================================
-- Try writing each query yourself first. If stuck for more than
-- two minutes, ask AI - but verify the output before trusting it.
-- =============================================================

USE BootcampDB;
GO


-- =============================================================
-- EXERCISE 1 - SHAPE WARM-UP
-- Goal: Produce a single result set with the row count for every
-- table in BootcampDB, sorted by row count descending.
-- Hint: UNION ALL with literal strings for the table name.
-- =============================================================

-- Your query here:

-- Single table row count
SELECT COUNT(*) AS row_count
FROM Patients;

-- Your query here:
SELECT 'Patients'  AS table_name, COUNT(*) AS row_count
FROM Patients

-- Union All returns a shape in one go
UNION ALL
SELECT 'Admissions', COUNT(*) FROM Admissions
UNION ALL
SELECT 'Wards', COUNT(*) FROM Wards
UNION ALL
SELECT 'Observations', COUNT(*) FROM Observations
Order by row_count DESC;



-- =============================================================
-- EXERCISE 2 - LENS 2: COMPLETNESS (NULL PROFILE)
-- Goal: For the Patients table, produce a single-row result that
-- shows the total row count and the number of NULLs in EACH column
-- of the table (other than PatientID and CreatedDate).
-- Hint: SUM(CASE WHEN col IS NULL THEN 1 ELSE 0 END) per column.
-- =============================================================

-- Your query here:

SELECT 
COUNT(*) 												AS total_rows,
SUM(CASE WHEN NHSNumber IS NULL THEN 1 ELSE 0 END) 		AS null_nhs_num,
SUM(CASE WHEN FirstName IS NULL THEN 1 ELSE 0 END) 		AS null_first_name,
SUM(CASE WHEN LastName IS NULL THEN 1 ELSE 0 END) 		AS null_last_name,
SUM(CASE WHEN DateOfBirth IS NULL THEN 1 ELSE 0 END) 	AS null_date_of_birth,
SUM(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END) 		AS null_gender,
SUM(CASE WHEN Postcode IS NULL THEN 1 ELSE 0 END) 		AS null_postcode,
SUM(CASE WHEN RegisteredGP IS NULL THEN 1 ELSE 0 END) 	AS null_registered_gp,
SUM(CASE WHEN NHSNumber IS NULL THEN 1 ELSE 0 END) 		AS nhs_num
FROM Patients;



-- =============================================================
-- EXERCISE 3 - LENS 3: UNIQUENESS (CARDINALITY FREQUENCY TABLE)
-- Goal: For the Wards table, return each distinct WardType with
-- its frequency (how many rows have it) and percentage of the total,
-- ordered by frequency descending.
-- Hint: GROUP BY WardType, then COUNT(*) and a percentage column
--       using a window function: COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ().
-- =============================================================

-- Your query here:

SELECT 
WardType,
COUNT(*) AS frequency,
CAST(100.0 * COUNT(*) /
	SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) AS pct_of_total
FROM Wards
GROUP BY WardType
ORDER BY frequency DESC;



-- =============================================================
-- EXERCISE 4 - LENS 4: RANGE & DISTRIBUTION (AGE DISTRIBUTION HISTOGRAM)
-- Goal: Bucket patients into age bands and count how many fall into
-- each band. Use these bands:
--   < 40, 40-59, 60-79, 80+
-- Hint: Use CASE inside both SELECT and GROUP BY (or wrap in a CTE).
-- =============================================================

-- Your query here:

SELECT
	CASE
		WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) < 40 THEN '1. Under 40'
		WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) < 60 THEN '2.  40 - 59'
		WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) < 80 THEN '3.  60 - 79'
		ELSE								                       '4. 80+'
	END 	AS age_band,
	COUNT(*) 	AS patients
FROM Patients
GROUP BY 
	CASE
		WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) < 40 THEN '1. Under 40'
		WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) < 60 THEN '2.  40 - 59'
		WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) < 80 THEN '3.  60 - 79'
		ELSE								                       '4. 80+'
		END
ORDER BY age_band;



-- =============================================================
-- EXERCISE 5 - ANOMALY DETECTION: STATISTICAL OUTLIERS (LENGTH OF STAY OUTLIERS (BONUS))
-- Goal: For admissions that have been discharged, compute the length
-- of stay in days. Then list any admission whose stay is more than
-- 2 standard deviations away from the mean.
-- Hint: Use a CTE with AVG and STDEV, then join back.
-- Bonus: also return the z-score for each outlier.
-- =============================================================

-- Quick Admission's table check

SELECT TOP 5 *
FROM Admissions;


-- Your query here:

WITH stay AS (
    SELECT
        AdmissionID,
        DATEDIFF(DAY, AdmissionDate, DischargeDate) AS LengthOfStay_Days
    FROM Admissions
    WHERE DischargeDate IS NOT NULL
),
stats AS (
    SELECT
        AVG(CAST(LengthOfStay_Days AS FLOAT)) AS mean_Days,
        STDEV(CAST(LengthOfStay_Days AS FLOAT)) AS sd_Days
    FROM stay
)
SELECT
    s.AdmissionID,
    s.LengthOfStay_Days,
    st.mean_Days,
    st.sd_Days,
    (s.LengthOfStay_Days - st.mean_Days) / NULLIF(st.sd_Days, 0) AS z_score
FROM stay s
CROSS JOIN stats st
WHERE ABS((s.LengthOfStay_Days - st.mean_Days) / NULLIF(st.sd_Days, 0)) > 1.5;

-- =======================================================================


WITH stay AS (
    SELECT
        AdmissionID,
        -- Cast at source: FLOAT flows cleanly through every downstream CTE
        CAST(DATEDIFF(DAY, AdmissionDate, DischargeDate) AS FLOAT) AS LengthOfStay_Days
    FROM  Admissions
    WHERE DischargeDate IS NOT NULL
),

stats AS (
    SELECT
        AVG(LengthOfStay_Days)   AS mean_Days,   -- no CAST needed, already FLOAT
        STDEV(LengthOfStay_Days) AS sd_Days
    FROM stay
),

scored AS (
    SELECT
        s.AdmissionID,
        s.LengthOfStay_Days,
        st.mean_Days,
        st.sd_Days,
        -- 0.0 not 0 — keeps NULLIF arguments both FLOAT
        (s.LengthOfStay_Days - st.mean_Days) / NULLIF(st.sd_Days, 0.0) AS z_score
    FROM       stay  AS s
    CROSS JOIN stats AS st
)

SELECT *
FROM  scored
WHERE ABS(z_score) > 1.5          -- reference alias, not repeated expression
ORDER BY ABS(z_score) DESC;

-- =======================================================================
-- Alternative approach: IQR (Interquartile Range) method for outlier detection
WITH stay AS (
    -- compute the derived column first, cast early
    SELECT
        AdmissionID,
        CAST(DATEDIFF(DAY, AdmissionDate, DischargeDate) AS FLOAT) AS LengthOfStay_Days
    FROM  Admissions
    WHERE DischargeDate IS NOT NULL          -- exclude still-admitted patients
),

quartiles AS (
    -- PERCENTILE_CONT gives exact Q1/Q3 values, not just bucket labels
    SELECT
        AdmissionID,
        LengthOfStay_Days,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY LengthOfStay_Days) OVER () AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY LengthOfStay_Days) OVER () AS Q3
    FROM stay
),

iqr_bounds AS (
    -- derive IQR and the fence boundaries in one place
    SELECT
        AdmissionID,
        LengthOfStay_Days,
        Q1,
        Q3,
        (Q3 - Q1)                   AS IQR,
        Q1 - 1.5 * (Q3 - Q1)       AS lower_fence,   -- unusually short stays
        Q3 + 1.5 * (Q3 - Q1)       AS upper_fence     -- unusually long stays
    FROM quartiles
)

SELECT
    AdmissionID,
    LengthOfStay_Days,
    ROUND(Q1,           1) AS Q1,
    ROUND(Q3,           1) AS Q3,
    ROUND(IQR,          1) AS IQR,
    ROUND(lower_fence,  1) AS lower_fence,
    ROUND(upper_fence,  1) AS upper_fence,
    CASE
        WHEN LengthOfStay_Days < lower_fence THEN 'Unusually Short'
        WHEN LengthOfStay_Days > upper_fence THEN 'Unusually Long'
    END                    AS anomaly_flag
FROM  iqr_bounds
WHERE LengthOfStay_Days < lower_fence
   OR LengthOfStay_Days > upper_fence
ORDER BY LengthOfStay_Days DESC;


-- =============================================================
-- EXERCISE 6 - POSTCODE FORMAT CHECK (BONUS)
-- Goal: List any patient whose Postcode does NOT match the basic
-- UK pattern of "2-4 letters, space, 1 digit + 2 letters".
-- Hint: A simple LIKE pattern with [A-Z][A-Z]%[0-9][A-Z][A-Z]
--gets you most of the way. Don't worry about perfect coverage.
-- ===============================================================

SELECT TOP 5 * FROM Patients;


-- Your query here:

SELECT
	Postcode,
	LEN(Postcode) AS PostcodeLength,
	CASE
		WHEN Postcode NOT LIKE '[A-Z][A-Z]%[0-9][A-Z][A-Z]' THEN 'Wrong format'
		WHEN LEN(Postcode) <> 7 	THEN 'Wrong length'
		ELSE 'OK'
	END			AS problem
FROM Patients
WHERE Postcode NOT LIKE '[A-Z][A-Z]%[0-9][A-Z][A-Z]' AND LEN(Postcode) = 7;



-- =============================================================
-- EXERCISE 7 - AI PROMPTING PRACTICE (HOMEWORK)
-- Goal: Use the five-part template from the deck to write a prompt
-- that asks AI to generate a profile query for the Observations table.
-- Your profile should report:
--   - Total rows
--   - NULL count for each column
--   - Distinct ObsType count
--   - The most common RecordedBy value and its count
--
-- Paste the prompt and the AI's response into the cohort channel.
-- Then run the AI's query and tell us whether it worked first time
-- or needed corrections.
-- =============================================================

-- Your prompt and notes here:

-- you are working on Ptients Observations query using - Dialect: T-SQL on SQL Server
-- Schema: <ObservationID   INT PRIMARY KEY IDENTITY(1,1),
--     AdmissionID     INT NOT NULL REFERENCES Admissions(AdmissionID),
--     ObsDateTime     DATETIME NOT NULL,
--     ObsType         NVARCHAR(50),
--     ObsValue        NVARCHAR(20),
--     RecordedBy      NVARCHAR(100)>  
-- Goal: generate a profile query for the Observations table.
-- Your profile should report:
--   - Total row
--   - NULL count for each column
--   - Distinct ObsType count
--   - The most common RecordedBy value and its count. 
-- Quality bar: aliases, NULLs visible, ORDER BY. 
-- Verify: explain the join strategy in 2 sentences before the query.

-- Why it works: 
-- Join strategy: BaseStats performs a single pass over Observations to compute all aggregate and NULL-count metrics, 
--while TopRecorder does a separate grouped scan to rank recorders by frequency. 
-- A CROSS JOIN merges the two CTEs into one output row — safe here because each CTE is guaranteed to return exactly one row.

-- The query uses a CTE to calculate base statistics for the Observations table, including total rows, NULL counts for each column, 
--and distinct ObsType count. Another CTE identifies the most common RecordedBy value and its count. 
--The final SELECT statement combines these results using a CROSS JOIN to produce a single-row output with all required metrics.


WITH BaseStats AS (
    SELECT
        COUNT(*)                                                        AS TotalRows,
        SUM(CASE WHEN ObservationID IS NULL THEN 1 ELSE 0 END)         AS NullObservationID,   -- PK/IDENTITY: expect 0
        SUM(CASE WHEN AdmissionID   IS NULL THEN 1 ELSE 0 END)         AS NullAdmissionID,     -- NOT NULL FK: expect 0
        SUM(CASE WHEN ObsDateTime   IS NULL THEN 1 ELSE 0 END)         AS NullObsDateTime,     -- NOT NULL: expect 0
        SUM(CASE WHEN ObsType       IS NULL THEN 1 ELSE 0 END)         AS NullObsType,         -- nullable
        SUM(CASE WHEN ObsValue      IS NULL THEN 1 ELSE 0 END)         AS NullObsValue,        -- nullable
        SUM(CASE WHEN RecordedBy    IS NULL THEN 1 ELSE 0 END)         AS NullRecordedBy,      -- nullable
        COUNT(DISTINCT ObsType)                                         AS DistinctObsTypeCount
    FROM Observations
),

TopRecorder AS (
    SELECT TOP 1
        RecordedBy      AS TopRecordedBy,
        COUNT(*)        AS TopRecordedByCount
    FROM Observations
    WHERE RecordedBy IS NOT NULL           -- exclude NULLs from "most common" ranking
    GROUP BY RecordedBy
    ORDER BY COUNT(*) DESC                 -- drives the TOP 1 pick
)

SELECT
    bs.TotalRows,

    -- NULL counts — column-by-column
    bs.NullObservationID,
    bs.NullAdmissionID,
    bs.NullObsDateTime,
    bs.NullObsType,
    bs.NullObsValue,
    bs.NullRecordedBy,

    -- Cardinality
    bs.DistinctObsTypeCount,

    -- Most frequent recorder
    tr.TopRecordedBy,
    tr.TopRecordedByCount

FROM  BaseStats    AS bs
CROSS JOIN TopRecorder AS tr
ORDER BY bs.TotalRows DESC;   -- single-row result; ORDER BY satisfies cursor/tooling contracts

-- =============================================================
-- END OF EXERCISES
-- Solutions are in 03-solutions.sql - have a real go first!
-- =============================================================
