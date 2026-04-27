# SQL Server — Admissions Analysis

*Writing basic queries • Using AI as a learning and query-writing assistant*

**Hospital Admissions Table · Two-Step Query Report**

## Overview

This report demonstrates a two-step SQL Server query against the `dbo.Admissions` table. Step 1 groups records by every combination of `AdmissionType` and `Diagnosis` to produce granular counts. Step 2 uses a Common Table Expression (CTE) to aggregate those combination-level counts up to unique `AdmissionType` totals.

## Step 1 — Count per AdmissionType & Diagnosis Combination

### SQL Query

```sql
-- Step 1: Count admissions per AdmissionType + Diagnosis combination
SELECT
    AdmissionType,
    Diagnosis,
    COUNT(*) AS AdmissionCount
FROM Admissions
GROUP BY AdmissionType, Diagnosis
ORDER BY AdmissionType, Diagnosis;
```

### Query Output

The table below shows the admission count for each unique pairing of Admission Type and Diagnosis (11 combinations across 15 records).

| Admission Type | Diagnosis          | Admission Count |
|----------------|--------------------|-----------------|
| Elective       | Cataract Surgery   | 1               |
| Elective       | Hip Replacement    | 2               |
| Elective       | Knee Replacement   | 2               |
| Emergency      | Appendicitis       | 1               |
| Emergency      | Chest Pain         | 2               |
| Emergency      | Fracture           | 1               |
| Emergency      | Pneumonia          | 2               |
| Urgent         | Appendicitis       | 1               |
| Urgent         | Chest Pain         | 1               |
| Urgent         | Fracture           | 1               |
| Urgent         | Pneumonia          | 1               |

## Step 2 — Unique Admission Types with Overall Counts

### SQL Query

```sql
-- Step 2: Unique AdmissionTypes with overall admission counts (via CTE)
WITH TypeDiagnosisCounts AS (
    SELECT
        AdmissionType,
        Diagnosis,
        COUNT(*) AS AdmissionCount
    FROM Admissions
    GROUP BY AdmissionType, Diagnosis
)
SELECT
    AdmissionType,
    SUM(AdmissionCount) AS TotalAdmissions
FROM TypeDiagnosisCounts
GROUP BY AdmissionType
ORDER BY TotalAdmissions DESC;
```

### Query Output

By wrapping Step 1 in a CTE, Step 2 collapses all diagnosis combinations back into three unique Admission Types and sums their counts. This guarantees that the final totals always equal the row-count produced by a simple `COUNT(*) ... GROUP BY AdmissionType`.

| Admission Type | Total Admissions |
|----------------|------------------|
| Emergency      | 6                |
| Elective       | 5                |
| Urgent         | 4                |

## Notes

- The CTE approach in Step 2 is logically equivalent to `SELECT AdmissionType, COUNT(*) AS TotalAdmissions FROM Admissions GROUP BY AdmissionType`, but explicitly passes through the combination-level grouping, satisfying the requirement to first calculate per-combination counts before rolling up.
- Results are ordered by `TotalAdmissions DESC` so the highest-volume admission type appears first.
- Sample dataset: 15 admissions across 3 types (Emergency, Elective, Urgent) and 5 diagnoses.

Admission Type	Total Admissions
Emergency	6
Elective	5
Urgent	4

Notes
• The CTE approach in Step 2 is logically equivalent to SELECT AdmissionType, COUNT(*) AS TotalAdmissions FROM Admissions GROUP BY AdmissionType, but explicitly passes through the combination-level grouping, satisfying the requirement to first calculate per-combination counts before rolling up.
• Results are ordered by TotalAdmissions DESC so the highest-volume admission type appears first.
• Sample dataset: 15 admissions across 3 types (Emergency, Elective, Urgent) and 5 diagnoses.
