---
title: Use Covering Indexes to Avoid Table Lookups
impact: MEDIUM-HIGH
impactDescription: 2-5x faster queries by eliminating heap fetches
tags: indexes, covering-index, include, index-only-scan
---

## Use Covering Indexes to Avoid Table Lookups

Covering indexes include all columns needed by a query, enabling index-only scans that skip the table entirely.

**Incorrect (index scan + heap fetch):**

```sql
create index users_email_idx on users (email);

-- Must fetch name and created_at from table heap
select email, name, created_at from users where email = 'user@example.com';
```

**Correct (index-only scan with INCLUDE):**

```sql
-- Include non-searchable columns in the index
create index users_email_idx on users (email) include (name, created_at);

-- All columns served from index, no table access needed
select email, name, created_at from users where email = 'user@example.com';
```

Use INCLUDE for columns you SELECT but don't filter on:

```sql
-- Searching by status, but also need customer_id and total
create index orders_status_idx on orders (status) include (customer_id, total);

select status, customer_id, total from orders where status = 'shipped';
```

## Audit Unused Indexes & Protect HOT Updates

- Audit every index against actual `WHERE` / `JOIN` / `ORDER BY` queries, trigger lookups, and uniqueness constraints. Drop speculative or unused indexes to avoid write amplification and bloat.
- Pair `INCLUDE (...)` covering indexes with narrowed `SELECT` projections so Postgres can execute Index-Only Scans without heap fetches.
- Keep frequently mutated columns (e.g., hot balance or counter columns) **out** of `INCLUDE (...)` on heavily updated tables so PostgreSQL can still perform Heap-Only Tuple (HOT) updates.

Reference: [Index-Only Scans](https://www.postgresql.org/docs/current/indexes-index-only-scans.html)
