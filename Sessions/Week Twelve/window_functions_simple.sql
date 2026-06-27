-- ============================================================
--  The AI Workshop · SQL & AI Bootcamp
--  Window Functions — beginner script
--
--  HOW TO RUN (GitHub Codespace):
--    SQL Server : sqlcmd -S localhost -U sa -P 'YourPassword' -i window_functions_simple.sql
--    PostgreSQL : psql -d yourdb -f window_functions_simple.sql
--
--  Run the whole file top to bottom. The data is built in,
--  so there is nothing else to set up.
-- ============================================================


-- ------------------------------------------------------------
--  SETUP — our runners, wrapped in a VIEW (self-contained)
-- ------------------------------------------------------------
DROP VIEW IF EXISTS Runners;
GO  -- (SQL Server batch separator — PostgreSQL users can delete the GO lines)

CREATE VIEW Runners AS
SELECT * FROM (
    VALUES
        ('Ivan',  39),
        ('Ben',   40),
        ('Grace', 50),
        ('Clara', 51),
        ('David', 60)
) AS r (Name, FinishTime);
GO

-- Take a look at the data first.
SELECT * FROM Runners;
GO


-- ============================================================
--  THE MAIN IDEA
--  Give each runner a position, fastest first.
-- ============================================================
SELECT
    Name,
    FinishTime,
    ROW_NUMBER() OVER (ORDER BY FinishTime) AS Position
FROM Runners;
GO


-- ============================================================
--  TRY IT YOURSELF — change one word and re-run.
-- ============================================================


-- Try 1: number them from SLOWEST to fastest.
--        (We added DESC after FinishTime.)
SELECT
    Name,
    FinishTime,
    ROW_NUMBER() OVER (ORDER BY FinishTime DESC) AS Position
FROM Runners;
GO


-- Try 2: number them in ALPHABETICAL order by name.
SELECT
    Name,
    FinishTime,
    ROW_NUMBER() OVER (ORDER BY Name) AS Position
FROM Runners;
GO


-- ============================================================
--  CLEANUP (optional)
-- ============================================================
-- DROP VIEW IF EXISTS Runners;
-- GO
