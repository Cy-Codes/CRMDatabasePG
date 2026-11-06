#!/usr/bin/env python3
"""
Test Runner for PostgreSQL CRM Database.
Executes DB-level test suites and provides clear pass/fail reporting.
"""
from __future__ import annotations

from dataclasses import dataclass
import os
import subprocess
import sys

DEFAULT_DB_HOST: str = "localhost"
DEFAULT_DB_PORT: str = "5432"
DEFAULT_DB_NAME: str = "CRMDatabase"
DEFAULT_DB_USER: str = "postgres"
DEFAULT_DB_PASSWORD: str = "postgres"
BANNER_WIDTH: int = 72

TEST_SUITES: tuple[str, ...] = (
    "01_schema_structure_tests.sql",
    "02_data_integrity_and_seed_tests.sql",
    "03_constraint_enforcement_tests.sql",
)


@dataclass(frozen=True)
class PostgresTestConfig:
    """Immutable connection configuration for PostgreSQL test execution."""
    host: str
    port: str
    dbname: str
    user: str
    password: str
    test_dir: str


def resolve_config() -> PostgresTestConfig:
    """Pure query reading PostgreSQL connection parameters from environment variables."""
    return PostgresTestConfig(
        host=os.environ.get("DB_HOST", os.environ.get("PGHOST", DEFAULT_DB_HOST)),
        port=os.environ.get("DB_PORT", os.environ.get("PGPORT", DEFAULT_DB_PORT)),
        dbname=os.environ.get("DB_NAME", os.environ.get("PGDATABASE", DEFAULT_DB_NAME)),
        user=os.environ.get("DB_USER", os.environ.get("PGUSER", DEFAULT_DB_USER)),
        password=os.environ.get("DB_PASSWORD", os.environ.get("PGPASSWORD", DEFAULT_DB_PASSWORD)),
        test_dir=os.path.dirname(os.path.abspath(__file__)),
    )


def build_psql_command(config: PostgresTestConfig, suite_filename: str) -> tuple[str, ...]:
    """Pure builder assembling the psql CLI argument tuple for a given test suite."""
    suite_path = os.path.join(config.test_dir, suite_filename)
    return (
        "psql",
        "-h", config.host,
        "-p", config.port,
        "-U", config.user,
        "-d", config.dbname,
        "-v", "ON_ERROR_STOP=1",
        "-f", suite_path,
    )


def execute_suite(config: PostgresTestConfig, env: dict[str, str], suite_filename: str) -> int:
    """Explicit side-effecting execution of a single SQL test suite."""
    print(f"\n>> Executing: {suite_filename}")
    cmd = build_psql_command(config, suite_filename)
    res = subprocess.run(cmd, env=env, check=False)
    if res.returncode != 0:
        print(f"\n[ERROR] Test suite {suite_filename} failed with exit code {res.returncode}")
    return res.returncode


def main() -> None:
    config = resolve_config()
    separator = "=" * BANNER_WIDTH

    print(separator)
    print("CRM Database PG - Python Test Runner")
    print(f"Target: {config.user}@{config.host}:{config.port}/{config.dbname}")
    print(separator)

    env = {**os.environ, "PGPASSWORD": config.password}

    failed_code = next(
        (
            code
            for code in map(lambda suite: execute_suite(config, env, suite), TEST_SUITES)
            if code != 0
        ),
        0,
    )
    if failed_code != 0:
        sys.exit(failed_code)

    print(f"\n{separator}")
    print("ALL POSTGRESQL CRM DATABASE TEST SUITES PASSED SUCCESSFULLY!")
    print(separator)


if __name__ == "__main__":
    main()
