# 🪟 Window Functions Made Simple

> **The AI Workshop · SQL & AI Bootcamp** — beginner session

---

## 🎯 What you'll learn today

Just **one idea**: how to give each row a number or a rank.

That's it. By the end you'll be able to answer questions like *"who came 1st, 2nd, 3rd?"* using SQL.

---

## 🏁 The story

Imagine a race has finished. Everyone crossed the line, and now you want to put them **in order** — 1st place, 2nd place, 3rd place, and so on.

You could do this by hand. Or you could let SQL do it for you in one line. That line uses a **window function**.

A window function looks at your rows and gives each one a number based on some order. Think of it as SQL handing out medals. 🥇🥈🥉

---

## 📋 Our data

We have a tiny table of runners and their finish times. A smaller number means they were **faster**.

| Name | FinishTime |
|------|-----------:|
| Ivan | 39 |
| Ben | 40 |
| Grace | 50 |
| Clara | 51 |
| David | 60 |

---

## ✨ The magic line

To number the runners from fastest to slowest, we write:

```sql
SELECT
    Name,
    FinishTime,
    ROW_NUMBER() OVER (ORDER BY FinishTime) AS Position
FROM Runners;
```

Let's break that down in plain English:

- `ROW_NUMBER()` → "give each row a number: 1, 2, 3…"
- `OVER (ORDER BY FinishTime)` → "…in order of finish time, smallest first"

**The result:**

| Name | FinishTime | Position |
|------|-----------:|---------:|
| Ivan | 39 | 1 |
| Ben | 40 | 2 |
| Grace | 50 | 3 |
| Clara | 51 | 4 |
| David | 60 | 5 |

Ivan was fastest, so he gets position 1. 🎉

---

## 🧠 The one thing to remember

```
ROW_NUMBER() OVER (ORDER BY  ... )
   │                    │
   │                    └──  what order to count in
   └──  hand out numbers 1, 2, 3...
```

If you can read that line, you understand window functions. Everything else is just variations on this idea.

---

## 🏋️ Try it yourself

Open the script `window_functions_simple.sql` in your Codespace and run it. Then try these:

1. **Number the runners** (already done for you — just run it and read the result).
2. **Reverse the order** — number them from slowest to fastest instead. *(Hint: add `DESC` after `FinishTime`.)*
3. **Number by name** — give each runner a number in alphabetical order. *(Hint: order by `Name`.)*

There are no trick questions here. Change one word, run it, see what happens. That's how you learn. 🚀

---

## ✅ You did it

You now know how to ask SQL to put rows in order and number them. That's a real, useful skill — and it's the foundation for everything else window functions can do.

Well done! See you next session. 👋
