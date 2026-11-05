#!/usr/bin/env bash
set -e

echo "========================================================================"
echo "Starting PostgreSQL CRM Database Migration Runner..."
echo "========================================================================"

if [ -S "/var/run/postgresql/.s.PGSQL.5432" ]; then
    export PGHOST="/var/run/postgresql"
else
    export PGHOST="${PGHOST:-localhost}"
fi
export PGPORT=5432
export PGUSER="${POSTGRES_USER:-postgres}"
export PGPASSWORD="${POSTGRES_PASSWORD:-postgres}"
export PGDATABASE="${POSTGRES_DB:-CRMDatabase}"

# Run migrations
/workspace/migrate.sh

# Check if data seeding is requested on startup
if [ "${SEED_DATA:-standard}" = "standard" ]; then
    echo "==> Seeding standard 50-record dataset across all CRM schemas..."
    psql -h "${PGHOST}" -U "${PGUSER}" -d "${PGDATABASE}" -f /workspace/scripts/01_seed_standard_50records.sql
elif [ "${SEED_DATA:-}" = "heavy" ]; then
    SCALE="${SCALE_FACTOR:-100}"
    echo "==> Simulating heavy production ETL load with scale factor ${SCALE}..."
    psql -h "${PGHOST}" -U "${PGUSER}" -d "${PGDATABASE}" -c "CALL \"public\".\"sp_SimulateHeavyETLLoad\"(${SCALE}, TRUE);"
else
    echo "==> SEED_DATA='${SEED_DATA}', skipping initial data load."
fi

echo "========================================================================"
echo "PostgreSQL CRM Database is ready for connections!"
echo "========================================================================"
