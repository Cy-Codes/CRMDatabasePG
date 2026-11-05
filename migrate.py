#!/usr/bin/env python3
"""
Migration Runner for PostgreSQL CRM Database.
Provides a database-agnostic CLI runner compatible with Flyway naming conventions.
"""
import os
import sys
import glob
import time
import subprocess

PGHOST = os.environ.get("PGHOST", "localhost")
PGPORT = os.environ.get("PGPORT", "5432")
PGUSER = os.environ.get("PGUSER", "postgres")
PGPASSWORD = os.environ.get("PGPASSWORD", "postgres")
PGDATABASE = os.environ.get("PGDATABASE", "CRMDatabase")

def run_psql(sql=None, filepath=None, check=True):
    env = os.environ.copy()
    env["PGPASSWORD"] = PGPASSWORD
    cmd = ["psql", "-h", PGHOST, "-p", PGPORT, "-U", PGUSER, "-d", PGDATABASE, "-v", "ON_ERROR_STOP=1"]
    if sql:
        cmd.extend(["-c", sql])
    elif filepath:
        cmd.extend(["--single-transaction", "-f", filepath])
    res = subprocess.run(cmd, env=env, capture_output=True, text=True)
    if check and res.returncode != 0:
        print(f"Error executing SQL:
{res.stderr}", file=sys.stderr)
        sys.exit(res.returncode)
    return res

def main():
    print(f"==> Connecting to PostgreSQL at {PGHOST}:{PGPORT}/{PGDATABASE}...")
    
    # Initialize schema_version table
    init_table_sql = """
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
    """
    run_psql(sql=init_table_sql)

    base_dir = os.path.dirname(os.path.abspath(__file__))
    migrations_dir = os.path.join(base_dir, "migrations")
    migration_files = sorted(glob.glob(os.path.join(migrations_dir, "V*.sql")), key=lambda p: [int(x) if x.isdigit() else x for x in re.split(r'(\d+)', os.path.basename(p))])

    print(f"==> Found {len(migration_files)} migration files in {migrations_dir}")

    for mfile in migration_files:
        fname = os.path.basename(mfile)
        # Parse version
        parts = fname.split("__", 1)
        version = parts[0].replace("V", "")
        desc = parts[1].replace(".sql", "").replace("_", " ") if len(parts) > 1 else ""

        # Check status
        check_sql = f"SELECT 1 FROM public.schema_version WHERE version = '{version}' AND success = TRUE;"
        res = run_psql(sql=check_sql, check=False)
        if "1" in res.stdout.strip().splitlines():
            print(f"  [SKIP] Migration V{version} ({fname}) already applied.")
            continue

        print(f"  [APPLYING] Migration V{version}: {fname}...")
        t0 = time.time()
        run_psql(filepath=mfile)
        duration_ms = int((time.time() - t0) * 1000)

        record_sql = f"""
        INSERT INTO public.schema_version (version, description, script, execution_time_ms, success)
        VALUES ('{version}', '{desc}', '{fname}', {duration_ms}, TRUE);
        """
        run_psql(sql=record_sql)
        print(f"  [SUCCESS] Migration V{version} applied in {duration_ms} ms.")

    print("==> All migrations applied successfully!")

if __name__ == "__main__":
    import re
    main()
