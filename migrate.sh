#!/usr/bin/env bash
# ============================================================================
# Migration Runner Script for PostgreSQL
# Applies all versioned migrations in order and records execution in schema_version.
# ============================================================================
set -euo pipefail

PGHOST="${PGHOST:-localhost}"
PGPORT="${PGPORT:-5432}"
PGUSER="${PGUSER:-postgres}"
PGPASSWORD="${PGPASSWORD:-postgres}"
PGDATABASE="${PGDATABASE:-CRMDatabase}"

export PGPASSWORD

echo "==> Connecting to PostgreSQL at ${PGHOST}:${PGPORT}/${PGDATABASE} as user '${PGUSER}'..."

# Ensure target database exists
psql -h "${PGHOST}" -p "${PGPORT}" -U "${PGUSER}" -tc "SELECT 1 FROM pg_database WHERE datname = '${PGDATABASE}'" | grep -q 1 || psql -h "${PGHOST}" -p "${PGPORT}" -U "${PGUSER}" -c "CREATE DATABASE "${PGDATABASE}";"

# Create migration tracking table if not exists
psql -h "${PGHOST}" -p "${PGPORT}" -U "${PGUSER}" -d "${PGDATABASE}" -c "
CREATE TABLE IF NOT EXISTS public.schema_version (
    installed_rank SERIAL PRIMARY KEY,
    version VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(200) NOT NULL,
    type VARCHAR(20) NOT NULL DEFAULT 'SQL',
    script VARCHAR(1000) NOT NULL,
    checksum VARCHAR(64) NULL,
    installed_by VARCHAR(100) NOT NULL DEFAULT CURRENT_USER,
    installed_on TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    execution_time_ms INTEGER NOT NULL DEFAULT 0,
    success BOOLEAN NOT NULL DEFAULT TRUE
);
"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MIGRATIONS_DIR="${SCRIPT_DIR}/migrations"

echo "==> Scanning migrations directory: ${MIGRATIONS_DIR}"

for migration_file in $(ls "${MIGRATIONS_DIR}"/V*.sql | sort -V); do
    filename="$(basename "${migration_file}")"
    version="$(echo "${filename}" | sed -E 's/^V([0-9]+)__.*$//')"
    description="$(echo "${filename}" | sed -E 's/^V[0-9]+__(.*)\.sql$//' | tr '_' ' ')"

    # Check if migration already applied
    applied=$(psql -h "${PGHOST}" -p "${PGPORT}" -U "${PGUSER}" -d "${PGDATABASE}" -tAc "SELECT 1 FROM public.schema_version WHERE version = '${version}' AND success = TRUE;")

    if [ "${applied}" = "1" ]; then
        echo "  [SKIP] Migration V${version} (${filename}) already applied."
    else
        echo "  [APPLYING] Migration V${version}: ${filename}..."
        start_time=$(date +%s%3N)
        
        # Execute migration in a single transaction
        psql -h "${PGHOST}" -p "${PGPORT}" -U "${PGUSER}" -d "${PGDATABASE}" -v ON_ERROR_STOP=1 --single-transaction -f "${migration_file}"
        
        end_time=$(date +%s%3N)
        duration=$((end_time - start_time))

        psql -h "${PGHOST}" -p "${PGPORT}" -U "${PGUSER}" -d "${PGDATABASE}" -c "
        INSERT INTO public.schema_version (version, description, script, execution_time_ms, success)
        VALUES ('${version}', '${description}', '${filename}', ${duration}, TRUE);
        "
        echo "  [SUCCESS] Migration V${version} applied in ${duration} ms."
    fi
done

echo "==> All migrations are up to date!"
