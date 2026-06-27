-- ============================================================
--  The AI Workshop · SQL & AI Bootcamp
--  Window Functions — self-contained practice script
--
--  HOW TO RUN (GitHub Codespace):
--    SQL Server : sqlcmd -S localhost -U sa -P 'YourPassword' -i window_functions.sql
--    PostgreSQL : psql -d yourdb -f window_functions.sql
--
--  Just run the whole file top to bottom. The view is created
--  first, so everything below is ready to go.
-- ============================================================


-- ------------------------------------------------------------
--  SETUP — Runners data wrapped in a VIEW (self-contained)
-- ------------------------------------------------------------
DROP VIEW IF EXISTS Runners;
GO  -- (SQL Server batch separator — PostgreSQL users can ignore/remove GO lines)

CREATE VIEW Runners AS
SELECT * FROM (
    VALUES
        (1,  'Collins', 10, 55, 'Child'),
        (2,  'Alice',   12, 56, 'Child'),
        (3,  'Ben',     25, 40, 'Adult'),
        (4,  'Clara',   12, 51, 'Child'),
        (5,  'David',   10, 60, 'Child'),
        (6,  'Ella',    25, 42, 'Adult'),
        (7,  'Frank',   47, 44, 'Adult'),
        (8,  'Grace',   50, 50, 'Adult'),
        (9,  'Hannah',  29, 42, 'Adult'),
        (10, 'Ivan',    35, 39, 'Adult')
) AS r (RunnerID, Name, Age, FinishTime, Category);
GO

-- Sanity check — should return all 10 rows.
SELECT * FROM Runners;
GO


-- ============================================================
--  EXERCISES — run each SELECT and read the output.
-- ============================================================


-- ------------------------------------------------------------
--  Exercise 1 — Number the runners by finish time
--  Give every runner a position from fastest to slowest.
-- ------------------------------------------------------------
SELECT
    Name,
    FinishTime,
    ROW_NUMBER() OVER (ORDER BY FinishTime) AS Position
FROM Runners;
GO


-- ------------------------------------------------------------
--  Exercise 2 — Rank runners within their own category
--  A child shouldn't be ranked against an adult, so partition
--  by Category. Fastest in each category = rank 1.
-- ------------------------------------------------------------
SELECT
    Name,
    Category,
    FinishTime,
    RANK() OVER (PARTITION BY Category ORDER BY FinishTime) AS CategoryRank
FROM Runners;
GO


-- ------------------------------------------------------------
--  Exercise 3 — Gap to the fastest runner in each category
--  For each runner, show how far behind the category leader
--  they finished. The leader shows 0.
-- ------------------------------------------------------------
SELECT
    Name,
    Category,
    FinishTime,
    FinishTime - MIN(FinishTime) OVER (PARTITION BY Category) AS GapToLeader
FROM Runners;
GO


-- ============================================================
--  CLEANUP (optional)
-- ============================================================
-- DROP VIEW IF EXISTS Runners;
-- GO
