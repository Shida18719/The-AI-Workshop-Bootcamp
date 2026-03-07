# T-SQL Bootcamp 🏥

A ready-to-run T-SQL learning environment using GitHub Codespaces — no installation required.

## ▶️ Open in Codespaces

Click the green **Code** button → **Codespaces** tab → **Create codespace on main**

Wait ~2 minutes for setup to complete, then open any file in the `exercises/` folder.

---

## 🗄️ The Database

We use **BootcampDB** — an NHS-inspired dataset with:

| Table         | Description                              |
|---------------|------------------------------------------|
| `Patients`    | 10 fictional patients with NHS numbers   |
| `Wards`       | 6 wards including Virtual Wards          |
| `Admissions`  | Admission history (some still admitted)  |
| `Observations`| Vital signs (BP, HR, SpO2, Temperature)  |

---

## 📚 Exercises

| File                              | Topic                          |
|-----------------------------------|--------------------------------|
| `week-01-select-basics.sql`       | SELECT, WHERE, ORDER BY, TOP   |
| `week-02-filtering-functions.sql` | Date functions, GROUP BY, HAVING |
| `week-03-joins.sql`               | INNER JOIN, LEFT JOIN, multi-table queries |

---

## ⌨️ How to Run Queries

1. Open a `.sql` file from the `exercises/` folder
2. Highlight the query you want to run
3. Press **Ctrl+Shift+E** (or right-click → **Run Query**)
4. Results appear in the panel below

---

## 🔌 Database Connection

The mssql extension is pre-configured. If prompted:
- **Server:** `sqlserver`
- **Database:** `BootcampDB`
- **Username:** `sa`
- **Password:** `Bootcamp123!`
- **Trust server certificate:** Yes

---

## 🆓 GitHub Free Tier

Each GitHub account gets **60 hours/month** of free Codespace time — more than enough for a weekly bootcamp session. Always **stop your Codespace** after each session to preserve your hours (Codespaces menu → Stop).
