# Session 6 — Filtering Data
### WHERE, HAVING, and Filtering Strategies · Building Precise Analytical Queries

> **Instructor:** Stephen  
> **Format:** Live Online · SQL & AI Bootcamp  


---

## Learning Objectives

By the end of this session, you will be able to:

- Use `WHERE` to filter rows before any grouping
- Use `HAVING` to filter groups after aggregation
- Combine `AND`, `OR`, and `NOT` with parentheses for precise filtering
- Apply range, membership, and pattern-matching conditions
- Handle `NULL` values correctly in filter logic
- Build and query reusable **views** you can update and re-run instantly

---

## Setup — Create Your Views

 **How this works:** Each view is built directly from hard-coded values — no tables needed.  
> To change the data live, edit the values inside the view and runs `DROP VIEW` + `CREATE VIEW` again.  
> Students re-run their queries and see results update immediately.

---

### View 1 — `vw_orders`

A simple coffee shop order log.  
We use this for `WHERE`, `BETWEEN`, `IN`, `LIKE`, and `NULL` filtering.

```sql
-- ============================================================
-- DROP then CREATE — run both together each time you update
-- ============================================================
DROP VIEW IF EXISTS vw_orders;
GO

CREATE VIEW vw_orders AS
SELECT *
FROM (
    VALUES
    --  order_id  customer   product        order_date     qty  unit_price  promo_code
        (1,  'Alice',   'Latte',       '2024-01-05',   2,   3.50,  'SAVE10'),
        (2,  'Bob',     'Espresso',    '2024-01-12',   1,   2.00,   NULL   ),
        (3,  'Clara',   'Cappuccino',  '2024-02-03',   3,   3.20,  'SAVE10'),
        (4,  'David',   'Latte',       '2024-02-18',   1,   3.50,   NULL   ),
        (5,  'Eve',     'Tea',         '2024-03-07',   4,   1.80,   NULL   ),
        (6,  'Frank',   'Espresso',    '2024-03-22',   2,   2.00,  'VIP20' ),
        (7,  'Grace',   'Cappuccino',  '2024-04-10',   1,   3.20,   NULL   ),
        (8,  'Henry',   'Latte',       '2024-04-25',   5,   3.50,  'VIP20' ),
        (9,  'Isla',    'Tea',         '2024-05-01',   2,   1.80,   NULL   ),
        (10, 'James',   'Espresso',    '2024-05-14',   3,   2.00,  'SAVE10')
) AS t(order_id, customer, product, order_date, qty, unit_price, promo_code);
GO

-- Quick check
SELECT * FROM vw_orders;
```

> ✏️ **To update values live:** edit any row inside `VALUES(...)`, then re-run the `DROP VIEW` + `CREATE VIEW` block above.

---

### View 2 — `vw_sales_summary`

Monthly sales totals per product.  
We use this for `GROUP BY`, `HAVING`, and combining `WHERE` + `HAVING`.

```sql
-- ============================================================
-- DROP then CREATE — run both together each time you update
-- ============================================================
DROP VIEW IF EXISTS vw_sales_summary;
GO

CREATE VIEW vw_sales_summary AS
SELECT *
FROM (
    VALUES
    --  sale_id  product        month        units_sold  revenue
        (1,  'Latte',       'January',    45,   157.50),
        (2,  'Espresso',    'January',    30,    60.00),
        (3,  'Cappuccino',  'January',    20,    64.00),
        (4,  'Tea',         'January',    10,    18.00),
        (5,  'Latte',       'February',   50,   175.00),
        (6,  'Espresso',    'February',   25,    50.00),
        (7,  'Cappuccino',  'February',   15,    48.00),
        (8,  'Tea',         'February',    5,     9.00),
        (9,  'Latte',       'March',      60,   210.00),
        (10, 'Espresso',    'March',      40,    80.00),
        (11, 'Cappuccino',  'March',      30,    96.00),
        (12, 'Tea',         'March',       8,    14.40)
) AS t(sale_id, product, month, units_sold, revenue);
GO

-- Quick check
SELECT * FROM vw_sales_summary;
```

---

## 📖 Part 1 — WHERE Clause Fundamentals

`WHERE` filters **rows** before any grouping or aggregation happens.  
Think of it as a bouncer at the door — rows that don't pass the condition never make it through.

---

### 1.1 Equality and Inequality

```sql
-- All Latte orders
SELECT * FROM vw_orders
WHERE product = 'Latte';

-- Everything except Latte
SELECT * FROM vw_orders
WHERE product <> 'Latte';
```

> 🔍 **Live demo:** Stephen changes `'Latte'` to `'Tea'` in the view — watch the result set shift.

---

### 1.2 AND, OR — Combining Conditions

```sql
-- Latte orders with more than 1 item
SELECT * FROM vw_orders
WHERE product = 'Latte'
AND qty > 1;

-- Latte or Espresso orders
SELECT * FROM vw_orders
WHERE product = 'Latte'
OR product = 'Espresso';
```

---

### 1.3 Parentheses — Controlling Evaluation Order

> ⚠️ `AND` binds more tightly than `OR` — just like multiplication before addition in maths.  
> Always use parentheses when mixing both.

```sql
-- ✅ (Latte OR Espresso) AND qty > 2
SELECT * FROM vw_orders
WHERE (product = 'Latte' OR product = 'Espresso')
AND qty > 2;

-- ⚠️ Without parentheses — this means something DIFFERENT
SELECT * FROM vw_orders
WHERE product = 'Latte'
OR product = 'Espresso'
AND qty > 2;
```

> 🔍 **Watch:** Run both versions. Compare the row counts. Spot the difference?

---

### 1.4 NOT Operator

```sql
-- Orders that are not Tea
SELECT * FROM vw_orders
WHERE NOT product = 'Tea';

-- Cleaner equivalent
SELECT * FROM vw_orders
WHERE product <> 'Tea';
```

---

### 1.5 Range Conditions — BETWEEN

```sql
-- Orders placed in Q1 2024
SELECT * FROM vw_orders
WHERE order_date BETWEEN '2024-01-01' AND '2024-03-31';

-- Orders where quantity is between 2 and 4
SELECT * FROM vw_orders
WHERE qty BETWEEN 2 AND 4;
```

> 💡 `BETWEEN` is always **inclusive** on both ends. Lower value must always come first.

```sql
-- ❌ Wrong order — returns nothing
SELECT * FROM vw_orders
WHERE qty BETWEEN 4 AND 2;
```

---

### 1.6 Membership Conditions — IN and NOT IN

```sql
-- Latte or Cappuccino (cleaner than two OR conditions)
SELECT * FROM vw_orders
WHERE product IN ('Latte', 'Cappuccino');

-- Everything except Espresso and Tea
SELECT * FROM vw_orders
WHERE product NOT IN ('Espresso', 'Tea');
```

---

### 1.7 Pattern Matching — LIKE

```sql
-- Customers whose name starts with 'A'
SELECT * FROM vw_orders
WHERE customer LIKE 'A%';

-- Products ending in 'o'
SELECT * FROM vw_orders
WHERE product LIKE '%o';

-- Products containing 'pp' anywhere
SELECT * FROM vw_orders
WHERE product LIKE '%pp%';
```

| Wildcard | Meaning |
|---|---|
| `%` | Any number of characters (including zero) |
| `_` | Exactly one character |

---

### 1.8 NULL — The Special Case

> ⚠️ `NULL` means *unknown* or *not provided*.  
> You **cannot** test for NULL with `=`. You must use `IS NULL` or `IS NOT NULL`.

```sql
-- Orders where no promo code was used
SELECT * FROM vw_orders
WHERE promo_code IS NULL;

-- Orders where a promo code was used
SELECT * FROM vw_orders
WHERE promo_code IS NOT NULL;

-- ❌ This returns NOTHING — even though NULLs exist in the data
SELECT * FROM vw_orders
WHERE promo_code = NULL;
```

> 🔍 **Watch:** Run the broken version first, then the correct version. Same data — completely different result.

---

### 1.9 NULL in Filtering — A Common Trap

```sql
-- ⚠️ This MISSES rows where promo_code IS NULL
SELECT * FROM vw_orders
WHERE promo_code <> 'VIP20';

-- ✅ Correct — explicitly include the NULLs
SELECT * FROM vw_orders
WHERE promo_code <> 'VIP20'
OR promo_code IS NULL;
```

> 💡 Whenever you write `<>` or `NOT IN`, ask yourself: *what happens to my NULL rows?*

---

## 📖 Part 2 — HAVING Clause

`HAVING` filters **groups** after `GROUP BY` has run.  
It works on aggregated results — not on individual rows.

| | WHERE | HAVING |
|---|---|---|
| Filters | Rows | Groups |
| Runs | Before GROUP BY | After GROUP BY |
| Can use aggregates? | ❌ No | ✅ Yes |

---

### 2.1 Basic GROUP BY — No Filter Yet

```sql
-- Total units sold per product across all months
SELECT product, SUM(units_sold) AS total_units
FROM vw_sales_summary
GROUP BY product;
```

---

### 2.2 WHERE Before Grouping

```sql
-- Only count January and February, then group
SELECT product, SUM(units_sold) AS total_units
FROM vw_sales_summary
WHERE month IN ('January', 'February')
GROUP BY product;
```

---

### 2.3 HAVING After Grouping

```sql
-- Only show products that sold more than 80 units in total
SELECT product, SUM(units_sold) AS total_units
FROM vw_sales_summary
GROUP BY product
HAVING SUM(units_sold) > 80;

-- Products where average monthly revenue exceeds £60
SELECT product, AVG(revenue) AS avg_monthly_revenue
FROM vw_sales_summary
GROUP BY product
HAVING AVG(revenue) > 60;
```

> 🔍 **Live demo:** Stephen bumps up a `units_sold` value in the view — watch a product cross the threshold and appear.

---

### 2.4 WHERE and HAVING Together

```sql
-- Among March sales only, show products that brought in more than £50
SELECT product,
       SUM(units_sold) AS units_sold,
       SUM(revenue)    AS total_revenue
FROM vw_sales_summary
WHERE month = 'March'
GROUP BY product
HAVING SUM(revenue) > 50
ORDER BY total_revenue DESC;
```

> 💡 **Rule of thumb:**  
> Use `WHERE` to cut out rows you never want counted.  
> Use `HAVING` to cut out groups whose totals don't meet your threshold.

---

## ✏️ Classwork

Work individually or in pairs. Write your SQL, run it, and be ready to share your screen.

---

### Classwork 1 — Query the Views

Use `vw_orders` or `vw_sales_summary` to answer each question.

**Q1.** Find all orders for `'Latte'` or `'Cappuccino'` where the quantity is greater than 1.  
Return the customer name, product, and quantity.

**Q2.** Find all orders placed between `'2024-02-01'` and `'2024-04-30'` where a promo code was used.  
Return the customer, product, order date, and promo code.

**Q3.** Find all customers whose name starts with the letters `A`, `E`, or `I`.  
*(Hint: three `LIKE` conditions joined with `OR`)*

**Q4.** Find all orders where the promo code is `NULL` **or** the quantity is exactly `1`.

**Q5.** Using `vw_sales_summary`, show only the products whose **total revenue across all months** is greater than `£200`.  
*(Hint: `GROUP BY` + `HAVING`)*

---

### Classwork 2 — Build Your Own View

Your turn. Create a view from scratch — no tables, just `VALUES`.

**Pick any topic you like:** a playlist, a football table, a menu, a list of films, your favourite snacks — anything simple and easy to work with.

Create a view called `vw_my_data` that meets these requirements:

| Requirement | Detail |
|---|---|
| At least 5 columns | Include at least one number, one text column, and one nullable column |
| At least 8 rows | Mix your values so filters produce interesting results |
| DROP + CREATE | Follow the same structure as the session views above |

Once your view is created, write **three queries** against it that each use at least one of:

- A `WHERE` clause with `AND` / `OR` and parentheses
- `BETWEEN` or `IN`
- `IS NULL` or `IS NOT NULL`

Be ready to demo your view and queries to the group. 

---

##  Key Takeaways

- `WHERE` filters rows **before** grouping — it cannot use aggregate functions
- `HAVING` filters groups **after** `GROUP BY` — it works on aggregated results only
- Always use **parentheses** when mixing `AND` and `OR` to avoid logic surprises
- `NULL` means *unknown* — always use `IS NULL` / `IS NOT NULL`, never `= NULL`
- `BETWEEN` is inclusive on both ends — lower value always goes first
- `IN` keeps your code clean when filtering against multiple known values
- `LIKE` with `%` and `_` handles partial string matches

---

##  Further Reading

- *Learning SQL* — Alan Beaulieu, Chapter 4 (Filtering) & Chapter 8 (Grouping and Aggregates)
- [SQL Server WHERE clause docs](https://learn.microsoft.com/en-us/sql/t-sql/queries/where-transact-sql)
- [SQL Server HAVING clause docs](https://learn.microsoft.com/en-us/sql/t-sql/queries/select-having-transact-sql)

---

*The AI Workshop CIC · theaiworkshop.co.uk*
