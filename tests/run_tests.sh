#!/usr/bin/env bash
# ============================================================================
# Script: run_tests.sh
# Description: Executes PostgreSQL CRM Database Test Suites
# ============================================================================
set -eo pipefail

DB_HOST="${DB_HOST:-${PGHOST:-localhost}}"
DB_PORT="${DB_PORT:-${PGPORT:-5432}}"
DB_NAME="${DB_NAME:-${PGDATABASE:-CRMDatabase}}"
DB_USER="${DB_USER:-${PGUSER:-postgres}}"
DB_PASSWORD="${DB_PASSWORD:-${PGPASSWORD:-postgres}}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PGPASSWORD="${DB_PASSWORD}"

echo "========================================================================"
echo "CRM Database PG - Database-Level Test Harness"
echo "Target: ${DB_USER}@${DB_HOST}:${DB_PORT}/${DB_NAME}"
echo "========================================================================"

psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -v ON_ERROR_STOP=1 -f "${SCRIPT_DIR}/01_schema_structure_tests.sql"
psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -v ON_ERROR_STOP=1 -f "${SCRIPT_DIR}/02_data_integrity_and_seed_tests.sql"
psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -v ON_ERROR_STOP=1 -f "${SCRIPT_DIR}/03_constraint_enforcement_tests.sql"

echo "========================================================================"
echo "All PostgreSQL CRM Database Tests PASSED successfully!"
echo "========================================================================"
