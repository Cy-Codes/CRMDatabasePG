#!/usr/bin/env bash
set -euo pipefail

readonly DEFAULT_PGPORT=5432
readonly DEFAULT_PGUSER="postgres"
readonly DEFAULT_PGPASSWORD="postgres"
readonly DEFAULT_PGDATABASE="CRMDatabase"
readonly DEFAULT_SEED_MODE="standard"
readonly DEFAULT_SCALE_FACTOR="100"
readonly PG_UNIX_SOCKET="/var/run/postgresql/.s.PGSQL.5432"
readonly PG_SOCKET_DIR="/var/run/postgresql"

echo "========================================================================"
echo "Starting PostgreSQL CRM Database Migration Runner..."
echo "========================================================================"

if [ -S "${PG_UNIX_SOCKET}" ]; then
    export PGHOST="${PG_SOCKET_DIR}"
else
    export PGHOST="${PGHOST:-localhost}"
fi
export PGPORT="${PGPORT:-${DEFAULT_PGPORT}}"
export PGUSER="${POSTGRES_USER:-${DEFAULT_PGUSER}}"
export PGPASSWORD="${POSTGRES_PASSWORD:-${DEFAULT_PGPASSWORD}}"
export PGDATABASE="${POSTGRES_DB:-${DEFAULT_PGDATABASE}}"

# Run migrations
/workspace/migrate.sh

# Check if data seeding is requested on startup
SEED_MODE="${SEED_DATA:-${DEFAULT_SEED_MODE}}"
if [ "${SEED_MODE}" = "standard" ]; then
    echo "==> Seeding standard 50-record dataset across all CRM schemas..."
    psql -h "${PGHOST}" -U "${PGUSER}" -d "${PGDATABASE}" -v ON_ERROR_STOP=1 -f /workspace/scripts/01_seed_standard_50records.sql
elif [ "${SEED_MODE}" = "heavy" ]; then
    SCALE="${SCALE_FACTOR:-${DEFAULT_SCALE_FACTOR}}"
    echo "==> Simulating heavy production ETL load with scale factor ${SCALE}..."
    psql -h "${PGHOST}" -U "${PGUSER}" -d "${PGDATABASE}" -v ON_ERROR_STOP=1 -c "CALL \"public\".\"sp_SimulateHeavyETLLoad\"(${SCALE}, TRUE);"
else
    echo "==> SEED_DATA='${SEED_MODE}', skipping initial data load."
fi

echo "========================================================================"
echo "PostgreSQL CRM Database is ready for connections!"
echo "========================================================================"
