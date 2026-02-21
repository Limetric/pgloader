# AGENTS.md

pgloader is a data loading tool for PostgreSQL written in Common Lisp. It migrates data from MySQL, SQLite, MS SQL Server, PostgreSQL, CSV, fixed-width, DBF, and IXF sources into PostgreSQL using the COPY protocol, with automatic error handling (rejected rows go to a separate file instead of aborting the whole load).

## Build Commands

```bash
make                    # Build pgloader binary → build/bin/pgloader
make CL=ccl             # Build with Clozure CL instead of SBCL
make DYNSIZE=1024       # Adjust dynamic space size (default 16384 MB)
make clean              # Remove all build artifacts
```

First build downloads Quicklisp and all dependencies — takes significant time. Requires: SBCL (or CCL), git, curl, libsqlite3-dev, freetds-dev.

## Testing

Tests require a running PostgreSQL instance.

```bash
# Prepare test databases (needs postgres superuser)
make -C test prepare

# Run regression suite
make test

# Run a single test
cd test && ../build/bin/pgloader csv.load

# Run single regression test (compares output)
cd test && ../build/bin/pgloader --regress csv.load
```

Test `.load` files are in `test/`. Regression tests are defined in `test/Makefile` REGRESS variable (32 tests). Some tests need MySQL (sakila) or external archives (REMOTE).

## Architecture

### Data Flow

```
Source → Parser → Source Object → Copy Pipeline (batched, parallel) → PostgreSQL COPY → Target DB
                                        ↓
                                  Reject File (bad rows logged, good rows continue)
```

### Key Directories

- **`src/parsers/`** — PEG parser (esrap) for pgloader's `.load` file DSL. `command-*.lisp` files parse individual syntax elements; `command-parser.lisp` orchestrates.
- **`src/sources/`** — CLOS-based source implementations. Each format (csv/, mysql/, sqlite/, mssql/, pgsql/, fixed/, db3/, ixf/) extends `md-connection` and `md-copy` from `common/`.
- **`src/pgsql/`** — PostgreSQL target: connections (postmodern), DDL generation, schema discovery, index/constraint creation.
- **`src/pg-copy/`** — COPY protocol: batch processing, format conversion, queue-based streaming, retry logic. S3 integration for Redshift.
- **`src/load/`** — Orchestration: `api.lisp` defines `copy-from`, `copy-to`, `copy-database`. `migrate-database.lisp` handles full migrations.
- **`src/utils/`** — State tracking, monitoring, reject handling, threading (lparallel), catalog metadata (CLOS structs), transforms/casting.
- **`src/main.lisp`** — CLI entry point (`main` function), argument parsing.

### Extension Pattern

Adding a new source format: create a subdirectory in `src/sources/`, define CLOS classes extending `md-connection` and `md-copy`, implement the generic functions from `src/sources/common/`, add parser rules in `src/parsers/`.

### Build System

- **pgloader.asd** — ASDF system definition (all ~287 components)
- **Quicklisp** — Package manager, bootstrapped into `build/quicklisp/`
- **buildapp** — Creates standalone executable from compiled Lisp image
- Local project overrides cloned into `build/quicklisp/local-projects/`: qmynd, cl-ixf, cl-db3, cl-csv

### Key Dependencies

postmodern (PostgreSQL), qmynd (MySQL protocol), esrap (PEG parser), lparallel (threading), cl-csv, sqlite, mssql (FreeTDS), drakma (HTTP), cl-ppcre (regex), zs3 (AWS S3).
