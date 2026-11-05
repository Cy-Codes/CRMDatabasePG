# CRMDatabasePG: PostgreSQL Migration-Based CRM Database

A production-grade PostgreSQL implementation of multi-CRM enterprise schemas (**Salesforce**, **HubSpot**, and **Dynamics 365**) using an imperative, **migration-based version control strategy**.

This repository is designed as the direct architectural counterpart to **CRMDatabaseMS** (which utilizes a declarative, state-based DACPAC deployment strategy), allowing teams to evaluate, benchmark, and compare state-based vs. migration-based database lifecycles.

---

## 🏛️ Architecture Overview

The database manages 37 CRM entity tables partitioned across three dedicated PostgreSQL schemas, matching standard enterprise CRM data models:

```
CRMDatabase (PostgreSQL)
├── Salesforce Schema (15 Tables)
│   ├── User, Account, Contact, AccountContactRelation, Lead
│   ├── Campaign, CampaignMember, Opportunity, Product2, Pricebook2
│   ├── PricebookEntry, OpportunityLineItem, Case, Task, Event
├── HubSpot Schema (11 Tables)
│   ├── Owner, Company, Contact, Pipeline, DealStage, Deal
│   ├── Ticket, Product, LineItem, Engagement, ObjectAssociation
└── Dynamics365 Schema (11 Tables)
    ├── BusinessUnit, SystemUser, Account, Contact, Lead
    ├── PriceLevel, Product, Opportunity, OpportunityProduct
    ├── Incident, ActivityPointer
```

---

## 📁 Project Structure

```
CRMDatabasePG/
├── migrations/                               # Flyway-compatible versioned migrations
│   ├── V1__init_schemas.sql                  # Extensions and schema namespaces
│   ├── V2__salesforce_tables.sql             # 15 Salesforce tables and DDL
│   ├── V3__hubspot_tables.sql                # 11 HubSpot tables and DDL
│   ├── V4__dynamics365_tables.sql            # 11 Dynamics 365 tables and DDL
│   ├── V5__functions_and_procedures.sql      # Seeding and cleanup stored procedures
│   └── V6__indexes_and_optimizations.sql     # Foreign key and performance indexes
├── tests/                                    # Database-level test suites
│   ├── 01_schema_structure_tests.sql         # Schemas, 37 tables, PKs, FKs, index assertions
│   ├── 02_data_integrity_and_seed_tests.sql  # Cleanup verification, 1,850 rows, orphan checks
│   ├── 03_constraint_enforcement_tests.sql   # Negative constraint tests (FK, NOT NULL, UNIQUE)
│   ├── 04_run_all_tests.sql                  # Master SQL runner
│   ├── run_tests.sh                          # Bash test runner script
│   └── run_tests.py                          # Zero-dependency Python test runner
├── scripts/                                  # Operational & benchmarking scripts
│   ├── 00_cleanup_all_data.sql               # Full database TRUNCATE CASCADE
│   ├── 01_seed_standard_50records.sql        # Standard test dataset (1,850 rows)
│   ├── 02_simulate_heavy_etl_load.sql        # Heavy ETL benchmark (88,000+ rows)
│   └── 03_run_schema_and_integrity_tests.sql # Standalone test verification script
├── Dockerfile                                # PostgreSQL 16 Alpine container with auto-migration
├── docker-compose.yml                        # One-command orchestration with healthcheck
├── entrypoint.sh                             # Container startup and optional auto-seeding
├── migrate.sh                                # Standalone shell migration runner (psql-based)
├── migrate.py                                # Zero-dependency Python CLI migration runner
├── .env.example                              # Default environment variable template
├── .env                                      # Local connection configuration
├── README.md                                 # This document
└── MIGRATION_STRATEGY_COMPARISON.md          # In-depth architectural comparison (State vs Migration)
```

---

## 🔄 Migration-Based Deployment Strategy (Flyway / Delta Lifecycle)

### Core Paradigm: Immutable Versioned Transitions

Unlike declarative state-based tools (such as SSDT / DACPAC used in **CRMDatabaseMS**), this project utilizes an **imperative, migration-based deployment model** as defined in evolutionary database design:

* **Source of Truth**: The immutable sequence of ordered SQL migration scripts (`V1__...`, `V2__...`).
* **Execution Engine**: At deployment time, the migration runner (`migrate.sh`, `migrate.py`, or standard Flyway CLI) inspects the `schema_version` catalog table and executes only unapplied migration scripts in strict sequential order within explicit transactions.
* **Atomic Transformations**: Structural DDL changes (e.g. `ALTER TABLE ADD COLUMN`) and data DML transformations (e.g. backfilling lookup values) execute together inside transactional blocks (`BEGIN ... COMMIT`).

```
┌────────────────────────────────────────────────────────┐
│               Versioned Migration Files                │
│  migrations/V1__init.sql, V2__tables.sql, etc.        │
└───────────────────────────┬────────────────────────────┘
                            │  migrate.sh / Flyway
                            ▼
┌────────────────────────────────────────────────────────┐
│            Migration Engine (Flyway / Runner)          │
│  1. Query public.schema_version Table                  │
│  2. Compute Delta List of Unapplied Scripts            │
│  3. Execute Each Script in Order within Transaction    │
│  4. Record Execution Checksum, Timestamp, & Status     │
└───────────────────────────┬────────────────────────────┘
                            ▼
┌────────────────────────────────────────────────────────┐
│               Target PostgreSQL Database               │
│          (Schema Version Brought to N+1)               │
└────────────────────────────────────────────────────────┘
```

---

### Architectural & Industry References

For foundational reading on migration-based version control and database evolutionary design:

1. **Evolutionary Database Design (Pramod Sadalage & Martin Fowler)**
   * Foundational paper on managing database schema changes via versioned, automated migration scripts.
   * Read at: [martinfowler.com - Evolutionary Database Design](https://martinfowler.com/articles/evodb.html)

2. **Martin Fowler: Database Migrations Pattern**
   * Pattern catalog entry explaining transition-based schema migrations and execution ordering.
   * Read at: [martinfowler.com - Database Migration Pattern](https://martinfowler.com/patterns/database-migration.html)

3. **Flyway Documentation (Redgate): How Flyway Works**
   * Detailed explanation of migration immutability, schema history tables, and checksum validation.
   * Read at: [documentation.red-gate.com - How Flyway Works](https://documentation.red-gate.com/fd/how-flyway-works-184127223.html)

4. **PostgreSQL Documentation: DDL & Transactional Schemas**
   * Official documentation on PostgreSQL transactional DDL capabilities (`CREATE`, `ALTER`, `DROP` within transactions).
   * Read at: [postgresql.org - DDL Documentation](https://www.postgresql.org/docs/current/ddl.html)

For an in-depth architectural breakdown comparing **State-Based (CRMDatabaseMS / DACPAC)** against **Migration-Based (CRMDatabasePG / Flyway)** across 15+ evaluation criteria:

👉 [MIGRATION_STRATEGY_COMPARISON.md](./MIGRATION_STRATEGY_COMPARISON.md)

---

## 🧪 Testing Strategy: Architectural Division of Responsibilities

### Architectural Rationale: API-First Testing vs. Database Invariants

Modern software architecture and testing consensus strongly advocate for **placing domain validation, business rules, and comprehensive automated test suites in the API / Application layer**, while reserving the database layer for **relational structural guarantees, ACID persistence, and schema integrity**.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        API / Application Layer                         │
│  - Domain models, state machines, business workflows, validation rules │
│  - Rich test pyramids (unit, component, contract, integration tests)   │
│  - Horizontal, inexpensive, stateless scaling (containers / pods)     │
│  - Rich developer tooling: IDEs, linters, debuggers, profilers, CI/CD  │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ SQL Queries / ORM
┌───────────────────────────────────▼────────────────────────────────────┐
│                         Database / Storage Layer                       │
│  - Persistence, ACID transactions, data consistency invariants         │
│  - Relational constraints (FKs, unique keys, nullability, check types) │
│  - Indexes, physical layout, performance optimization                  │
│  - Lightweight structural & smoke verification                         │
└────────────────────────────────────────────────────────────────────────┘
```

#### Why Industry Best Practices Favor API Layer Testing:

1. **Scaling Economics & Compute Cost**:
   * API servers are stateless and scale horizontally across commodity compute instances or Kubernetes pods at low cost.
   * Relational database instances scale vertically; database CPU cycles, IOPS, and connection pools are among the most expensive and contention-prone resources in an infrastructure stack (see [aws.amazon.com - Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)).

2. **Test Pyramid Velocity & Feedback Cycles**:
   * According to Martin Fowler's *The Practical Test Pyramid* ([martinfowler.com - Practical Test Pyramid](https://martinfowler.com/articles/practical-test-pyramid.html)) and *Microservice Testing* ([martinfowler.com - Microservice Testing](https://martinfowler.com/articles/microservice-testing/)), fast feedback loops depend on lightweight, in-memory unit tests executing in milliseconds.
   * Testing complex business workflows exclusively in database stored procedures requires standing up isolated database instances, managing transactional state resets, and enduring disk I/O latency, which slows down CI/CD pipelines.

3. **Smart Endpoints and Dumb Pipes**:
   * A core tenet of modern microservice and web architecture is keeping domain logic in cohesive application services while treating infrastructure and transport mechanisms as decoupled backing services (see [martinfowler.com - Smart Endpoints and Dumb Pipes](https://martinfowler.com/articles/microservices.html#SmartEndpointsAndDumbPipes) and [12factor.net - Stateless Processes & Backing Services](https://12factor.net/)).

4. **Clean Architecture & Domain Decoupling**:
   * Placing business logic in the API allows databases to be treated as swappable persistence plugins (as outlined in Microsoft's [learn.microsoft.com - Common Web Application Architectures](https://learn.microsoft.com/en-us/dotnet/architecture/modern-web-apps-azure/common-web-application-architectures)), preventing vendor lock-in to proprietary database dialects (T-SQL, PL/pgSQL).

---

### What Belongs at the Database Level

The database layer remains responsible for enforcing hard structural invariants that protect data consistency regardless of which client or process connects to the database:

1. **Schema & Namespace Verification**: Confirming all 3 CRM schemas (`Salesforce`, `HubSpot`, `Dynamics365`) and 37 entity tables exist.
2. **Key Constraints & Referential Integrity**: Ensuring primary keys and foreign key constraints are registered and prevent orphaned records.
3. **Engine-Level Invariant Enforcement (Negative Tests)**: Verifying the database engine rejects foreign key violations, `NOT NULL` violations, and duplicate unique keys.
4. **Data Seeding & Migration Idempotency**: Ensuring cleanup scripts (`sp_CleanupAllCRMData`) and standard seed scripts (`sp_SeedStandardData` inserting 1,850 rows) execute reliably without deadlocks.

---

### Automated Database Test Suites

The repository includes automated database verification suites in `tests/` (and packaged in `scripts/03_run_schema_and_integrity_tests.sql`):

1. **`tests/01_schema_structure_tests.sql`**:
   - Asserts existence of `Salesforce`, `HubSpot`, and `Dynamics365` schemas.
   - Verifies exact table counts (15 Salesforce + 11 HubSpot + 11 Dynamics 365 = **37 Tables total**).
   - Validates that primary keys exist on all 37 tables.
   - Validates that foreign key constraints and performance indexes are registered.
   - Validates existence of utility stored procedures (`sp_CleanupAllCRMData`, `sp_SeedStandardData`, `sp_SimulateHeavyETLLoad`).

2. **`tests/02_data_integrity_and_seed_tests.sql`**:
   - Tests `sp_CleanupAllCRMData` wipes all 37 tables cleanly (0 rows remaining).
   - Tests `sp_SeedStandardData(TRUE)` seeds exactly 50 records per entity (**1,850 total rows** across 37 tables).
   - Tests referential integrity (0 orphaned Contacts/Opportunities in Salesforce, 0 orphaned LineItems in HubSpot, 0 orphaned Contacts in Dynamics 365).

3. **`tests/03_constraint_enforcement_tests.sql`**:
   - Negative / Invariant tests asserting that invalid FK inserts (error `23503`), `NOT NULL` violations (error `23502`), and duplicate unique keys (error `23505`) are rejected by the database engine.
   - Asserts generated column evaluation (`Salesforce.User.Name`, `Salesforce.Opportunity.ExpectedRevenue`).

4. **`tests/04_run_all_tests.sql`**:
   - Master SQL runner executing all 3 suites with structured `[PASS]` / `[FAIL]` reporting.

---

### Running the Database Tests

#### Option 1: Via Docker Container
```bash
# Execute master test suite inside the running container
docker compose exec postgres psql -U postgres -d CRMDatabase -f /workspace/tests/04_run_all_tests.sql
```

#### Option 2: Via Shell Test Runner (`tests/run_tests.sh`)
```bash
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=CRMDatabase
export DB_USER=postgres
export DB_PASSWORD=postgres

./tests/run_tests.sh
```

#### Option 3: Via Python Test Runner (`tests/run_tests.py`)
```bash
python3 tests/run_tests.py
```

---

## 🚀 Quick Start with Docker

The fastest way to spin up the database, execute all migrations, and pre-seed standard test data is using Docker Compose:

```bash
cd CRMDatabasePG

# 1. Start the PostgreSQL container (migrations and standard seed run automatically)
docker compose up -d

# 2. View initialization and migration logs
docker compose logs -f

# 3. Connect to the PostgreSQL database with psql
docker compose exec postgres psql -U postgres -d CRMDatabase
```

### Environment Configuration (`.env`)

| Variable | Default | Description |
| :--- | :--- | :--- |
| `POSTGRES_DB` | `CRMDatabase` | Target database name |
| `POSTGRES_USER` | `postgres` | Superuser username |
| `POSTGRES_PASSWORD` | `postgres` | Superuser password |
| `PGPORT` | `5432` | Host port mapping |
| `SEED_DATA` | `standard` | Startup seeding mode: `standard`, `heavy`, or `none` |
| `SCALE_FACTOR` | `100` | Scale multiplier for `heavy` ETL simulation |

---

## 🔄 Running Migrations Manually

### Using the Shell Runner (`migrate.sh`)
```bash
export PGHOST=localhost
export PGPORT=5432
export PGDATABASE=CRMDatabase
export PGUSER=postgres
export PGPASSWORD=postgres

./migrate.sh
```

### Using the Python Runner (`migrate.py`)
```bash
python3 migrate.py
```

### Using Flyway CLI
Because all migrations follow standard Flyway naming conventions (`V<version>__<description>.sql`), you can point standard Flyway directly at the `migrations/` folder:

```bash
flyway -url=jdbc:postgresql://localhost:5432/CRMDatabase \
       -user=postgres \
       -password=postgres \
       -locations=filesystem:migrations \
       migrate
```

---

## 🧪 Data Seeding & ETL Benchmarking

### 1. Standard Dataset (1,850 Records)
Populates 50 realistic rows per table with consistent foreign key associations across all 37 tables:

```sql
CALL "public"."sp_SeedStandardData"(p_clean_existing => TRUE);
```
Or execute via CLI:
```bash
psql -h localhost -U postgres -d CRMDatabase -f scripts/01_seed_standard_50records.sql
```

### 2. Heavy Production ETL Load Simulation (88,000+ Records)
Simulates high-volume enterprise ETL throughput with configurable scale factor:

```sql
-- Scale Factor 100 generates ~5,000 accounts, ~15,000 contacts, ~10,000 opportunities per CRM
CALL "public"."sp_SimulateHeavyETLLoad"(p_scale_factor => 100, p_clean_existing => TRUE);
```
Or execute via CLI:
```bash
psql -h localhost -U postgres -d CRMDatabase -f scripts/02_simulate_heavy_etl_load.sql
```

### 3. Cleanup All Data
Instantly truncates all 37 entity tables in foreign-key safe cascade order:

```sql
CALL "public"."sp_CleanupAllCRMData"();
```
