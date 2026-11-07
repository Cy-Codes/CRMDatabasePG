# CRMDatabasePG Coding Standards & Best Practices

This document is the complete, self-contained specification of both the **Universal Coding Standards** and the **PostgreSQL 16, Flyway Migration, PL/pgSQL, Python, and Bash Standards** for the **CRMDatabasePG** repository.

---

# Part I: Universal Coding Standards

```
┌────────────────────────────────────────────────────────────────────────┐
│                        Universal Standards Pillars                     │
├───────────────────┬───────────────────┬────────────────────────────────┤
│  Functional First │ Immutable Always  │ Explicit Side Effects          │
│  Maps over Loops  │ Records & Freezes │ Command/Query Segregation     │
├───────────────────┴──────┬────────────┴────────────────────────────────┤
│  Helper & Extension Fns  │ Zero Magic Numbers & Anti-Pattern Tolerance │
└──────────────────────────┴─────────────────────────────────────────────┘
```

## 1. Core Universal Principles

1. **Functional & Set-Based Logic Over Imperative Loops**:
   - Choose declarative set-based transformations (`generate_series`, CTEs, window functions, `jsonb_agg`, Python `map()`/`tuple` comprehensions) over state-mutating imperative loops (`FOR ... LOOP`, cursors, mutable list accumulators).
   - **Acceptable Exceptions for Loops**: Chunked administrative maintenance on massive tables where a single transaction would hold locks too long. Every exception loop must include an inline comment explaining why a set-based construct was not feasible.
2. **Immutability by Default**:
   - Merged Flyway migration files (`migrations/V1..V6__*.sql`) are **strictly immutable** once committed.
   - Python migration and test runners use `@dataclass(frozen=True)` (`PostgresMigrationConfig`, `MigrationDescriptor`, `PostgresTestConfig`) and `tuple` collections.
3. **Explicit Demarcation of Side Effects (Command-Query Segregation)**:
   - **Queries (Pure / Read-Only)**: `IMMUTABLE` / `STABLE` SQL functions, views, and pure Python descriptor/command builders (`parse_migration_descriptor`, `build_psql_command`).
   - **Commands (Side-Effecting)**: `CREATE PROCEDURE` batch operations (`sp_SeedStandardData`, `sp_SimulateHeavyETLLoad`, `sp_CleanupAllCRMData`) and explicit I/O runners (`apply_migration_if_pending`, `execute_suite`).
4. **Zero Magic Numbers & String Literals**:
   - Replace magic numbers and strings with domain `CHECK` constraints, SQL constants, and `readonly` / typed module constants (`DEFAULT_PGPORT = "5432"`, `MS_PER_SECOND = 1000`).
5. **Eliminate Redundancy via Helper Functions**:
   - Consolidate repeated `psql` CLI invocations and migration parsing into reusable helper functions (`run_psql`, `run_psql_query`, `run_psql_suite`).

---

# Part II: PostgreSQL 16 & Flyway Specific Standards

## 2. Migration-Based Lifecycle & Migration Immutability

### 2.1 Strict Immutability of Applied Migrations
- Migration files in `migrations/` (`V1__init_schemas.sql` through `V6__indexes_and_optimizations.sql`) are **strictly immutable** once merged into version control.
- Never edit, reorder, or delete an existing migration file. Modifying an applied migration corrupts checksum history and breaks deployment pipelines.
- Schema evolutions must always be introduced by appending a new sequentially versioned migration (`V7__...`).

### 2.2 Schema Isolation
PostgreSQL schemas provide clean namespace boundaries for CRM domains:
- `"Salesforce"`: 15 tables modeling Salesforce Sales Cloud.
- `"HubSpot"`: 11 tables modeling HubSpot CRM object entities.
- `"Dynamics365"`: 11 tables modeling Dataverse / Common Data Model.
- Cross-schema queries must always qualify tables with their schema prefix.

### 2.3 File & Folder Naming
Follow PostgreSQL and Flyway defaults (lowercase `snake_case`):
- **Folders** are lowercase (`migrations/`, `scripts/`, `tests/`).
- **Migrations** use the Flyway pattern `V<version>__<snake_case_description>.sql` (`V6__indexes_and_optimizations.sql`).
- **Operational and test SQL scripts** use a two-digit run-order prefix followed by `snake_case` words (`scripts/01_seed_standard_50records.sql`, `tests/04_run_all_tests.sql`).
- **Reference DDL files** under `schema/<Schema>/` are named after the quoted object they define (`schema/Salesforce/Account.sql` → `"Salesforce"."Account"`).

---

## 3. Set-Based Logic Over Procedural Loops

### 3.1 Set Generators (`generate_series`) Over Loops
Use `generate_series` for data synthesis, seeding, or range transformations rather than procedural `FOR ... LOOP` blocks:

```sql
-- ❌ ANTI-PATTERN: Imperative PL/pgSQL loop
DO $$
DECLARE i INT;
BEGIN
    FOR i IN 1..50 LOOP
        INSERT INTO "Salesforce"."Account" ("Id", "Name", "CreatedById", "LastModifiedById")
        VALUES ('001' || LPAD(i::text, 15, '0'), 'Acme Corp ' || i, 'USR001', 'USR001');
    END LOOP;
END $$;

-- ✅ BEST PRACTICE: Declarative set generator
INSERT INTO "Salesforce"."Account" ("Id", "Name", "CreatedById", "LastModifiedById")
SELECT
    '001' || LPAD(s.i::text, 15, '0'),
    'Acme Corp ' || s.i,
    'USR001',
    'USR001'
FROM generate_series(1, 50) AS s(i);
```

### 3.2 Functional PostgreSQL Constructs
- **Window Functions**: Use `ROW_NUMBER() OVER (...)`, `RANK()`, and `DENSE_RANK()` for ranking and deduplication.
- **JSONB Aggregations**: Use `jsonb_agg` and `jsonb_build_object` to construct nested hierarchical payloads in a single round-trip.
- **CTEs (`WITH` Clauses)**: Break complex queries into composable, readable functional pipelines.

---

## 4. Function Volatility, Procedures & Audit Immutability

### 4.1 Explicit Volatility Declaration
Every PostgreSQL function must explicitly declare its volatility category:

| Volatility | Behavior | Optimizer Treatment | Use Case |
| :--- | :--- | :--- | :--- |
| **`IMMUTABLE`** | Cannot modify DB; always returns same result for same arguments | Result is cached; safe for expression indexes | Pure calculations, string formatting, hashing |
| **`STABLE`** | Cannot modify DB; returns same result within a single statement scan | Evaluated once per table scan | Current timestamp lookups, read-only lookups |
| **`VOLATILE`** | Can modify DB; results can change across calls | Evaluated on every row | Mutations, sequence generation, random values |

### 4.2 Procedures (`PROCEDURE`) vs Functions (`FUNCTION`)
- **Procedures (`CREATE PROCEDURE`)**: Reserved for side-effecting batch mutations and transaction control (`sp_CleanupAllCRMData`, `sp_SeedStandardData`, `sp_SimulateHeavyETLLoad`).
- **Functions (`CREATE FUNCTION`)**: Reserved for pure calculations or read-only table queries.

### 4.3 Timezone-Aware Audit Columns
Always use `TIMESTAMPTZ` (UTC-aware) instead of timezone-naive `TIMESTAMP` for audit metadata (`CreatedDate`, `LastModifiedDate`).

---

## 5. Anti-Pattern & Common Mistakes Catalog for PostgreSQL

1. **Unindexed Foreign Keys**: Defining `REFERENCES parent(id)` without a B-Tree index on the child column causes sequential scans and table locks during parent updates/deletes. Index all foreign keys (as enforced in `V6__indexes_and_optimizations.sql`).
2. **Using Legacy `SERIAL` Instead of Identity Columns**: `SERIAL` creates non-standard pseudo-types. Always use SQL standard `GENERATED BY DEFAULT AS IDENTITY` or `GENERATED ALWAYS AS IDENTITY`.
3. **Using Timezone-Naive `TIMESTAMP`**: Loses timezone context. Always declare `TIMESTAMPTZ`.
4. **Modifying Merged Migration Files**: Corrupts migration history; always append a new `V<n+1>__...` file and exclude `migrations/V*.sql` from auto-formatters.
5. **String Interpolation in `psql` Tooling Scripts**: Interpolating variables directly into SQL strings (`VALUES ('${version}', '${description}')`) risks broken syntax or SQL injection. Always pass `psql -v var="value"` and reference `:'var'` in SQL.

---

## 6. Python & Shell Harness & Pre-Commit Standards

- **Python (`migrate.py`, `tests/run_tests.py`)**: Zero-dependency, `from __future__ import annotations`, `@dataclass(frozen=True)` descriptors, `tuple(map(...))` pipelines, and parameterized `psql -v` bind variables (`:'mig_version'`, `:'mig_desc'`).
- **Bash (`migrate.sh`, `tests/run_tests.sh`, `entrypoint.sh`)**: Enforces `set -euo pipefail`, `readonly` constants, and reusable `run_psql_query` / `run_psql_suite` helper functions.
- **Pre-Commit Auto-Formatting**: On every `git commit`, the installed pre-commit hook automatically formats staged files (while protecting immutable `migrations/V*.sql` files), removes unused Python imports, validates `py_compile` and `bash -n` syntax, and re-stages changes.

---

## 7. Container Image & Cloud-Agnostic Schema Migrator

The repository image doubles as a one-shot schema migrator that `crm-infra/` points at any PostgreSQL endpoint (local container, Amazon RDS for PostgreSQL, Azure Database for PostgreSQL Flexible Server). See [crm-infra/CODING_STANDARDS.md](file:///Users/cy/codes/localstack-reference-architecture/crm-infra/CODING_STANDARDS.md) and ADR 4 in [docs/architecture-decisions.md](file:///Users/cy/codes/localstack-reference-architecture/docs/architecture-decisions.md). For the migration strategy rationale, see [MIGRATION_STRATEGY_COMPARISON.md](file:///Users/cy/codes/localstack-reference-architecture/CRMDatabasePG/MIGRATION_STRATEGY_COMPARISON.md).

- **Single Migration Path**: `entrypoint.sh` (installed as `/docker-entrypoint-initdb.d/99_crm_init.sh`) delegates to `migrate.sh`, which is the only migration + seed implementation used by the local container and by `crm-infra/terraform/modules/shared/database-schema`. Never duplicate migration logic elsewhere.
- **Environment-Only Inputs**: Targets are supplied via standard libpq variables (`PGHOST`, `PGPORT`, `PGSSLMODE`) plus `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, and `SEED_DATA`, with `readonly DEFAULT_*` fallbacks where a safe local default exists. When the local Unix socket exists it is preferred; otherwise the remote `PGHOST` is used.
- **Idempotent Re-Runs**: `migrate.sh` records each applied version in `public.schema_version` and skips versions already applied successfully, so re-running against an up-to-date database is a no-op; merged `V*.sql` files remain immutable (Section 2).
- **Secrets Hygiene**: Default development credentials live only in `.env.example` and script defaults for local use; real environments always inject credentials at runtime.
