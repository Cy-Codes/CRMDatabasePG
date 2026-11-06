#!/usr/bin/env bash
# ============================================================================
# Script: run_tests.sh
# Description: Executes PostgreSQL CRM Database Test Suites
# ============================================================================
set -euo pipefail

readonly DEFAULT_DB_HOST="localhost"
readonly DEFAULT_DB_PORT="5432"
readonly DEFAULT_DB_NAME="CRMDatabase"
readonly DEFAULT_DB_USER="postgres"
readonly DEFAULT_DB_PASSWORD="postgres"

readonly TEST_SUITES=(
    "01_schema_structure_tests.sql"
    "02_data_integrity_and_seed_tests.sql"
    "03_constraint_enforcement_tests.sql"
)

DB_HOST="${DB_HOST:-${PGHOST:-${DEFAULT_DB_HOST}}}"
DB_PORT="${DB_PORT:-${PGPORT:-${DEFAULT_DB_PORT}}}"
DB_NAME="${DB_NAME:-${PGDATABASE:-${DEFAULT_DB_NAME}}}"
DB_USER="${DB_USER:-${PGUSER:-${DEFAULT_DB_USER}}}"
DB_PASSWORD="${DB_PASSWORD:-${PGPASSWORD:-${DEFAULT_DB_PASSWORD}}}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PGPASSWORD="${DB_PASSWORD}"

run_psql_suite() {
    local suite_file="$1"
    psql \
        -h "${DB_HOST}" \
        -p "${DB_PORT}" \
        -U "${DB_USER}" \
        -d "${DB_NAME}" \
        -v ON_ERROR_STOP=1 \
        -f "${SCRIPT_DIR}/${suite_file}"
}

echo "========================================================================"
echo "CRM Database PG - Database-Level Test Harness"
echo "Target: ${DB_USER}@${DB_HOST}:${DB_PORT}/${DB_NAME}"
echo "========================================================================"

for suite in "${TEST_SUITES[@]}"; do
    run_psql_suite "${suite}"
done

echo "========================================================================"
echo "All PostgreSQL CRM Database Tests PASSED successfully!"
echo "========================================================================"
