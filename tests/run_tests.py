#!/usr/bin/env python3
"""
Test Runner for PostgreSQL CRM Database.
Executes DB-level test suites and provides clear pass/fail reporting.
"""

import os
import subprocess
import sys

def main():
    host = os.environ.get("DB_HOST", "localhost")
    port = os.environ.get("DB_PORT", "5432")
    dbname = os.environ.get("DB_NAME", "crm_database")
    user = os.environ.get("DB_USER", "postgres")
    password = os.environ.get("DB_PASSWORD", "postgres")

    test_dir = os.path.dirname(os.path.abspath(__file__))
    suites = [
        "01_schema_structure_tests.sql",
        "02_data_integrity_and_seed_tests.sql",
        "03_constraint_enforcement_tests.sql",
    ]

    print("=" * 72)
    print("CRM Database PG - Python Test Runner")
    print(f"Target: {user}@{host}:{port}/{dbname}")
    print("=" * 72)

    env = os.environ.copy()
    env["PGPASSWORD"] = password

    for suite in suites:
        suite_path = os.path.join(test_dir, suite)
        print(f"\n>> Executing: {suite}")
        cmd = [
            "psql",
            "-h", host,
            "-p", port,
            "-U", user,
            "-d", dbname,
            "-v", "ON_ERROR_STOP=1",
            "-f", suite_path,
        ]
        res = subprocess.run(cmd, env=env)
        if res.returncode != 0:
            print(f"\n[ERROR] Test suite {suite} failed with exit code {res.returncode}")
            sys.exit(res.returncode)

    print("\n" + "=" * 72)
    print("ALL POSTGRESQL CRM DATABASE TESTS COMPLETED SUCCESSFULLY!")
    print("=" * 72)

if __name__ == "__main__":
    main()
