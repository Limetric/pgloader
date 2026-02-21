# pgloader (MySQL 8.4+ compatibility fork)

This is a fork of [dimitri/pgloader](https://github.com/dimitri/pgloader) that fixes MySQL 8.4+ and 9.0+ connectivity.

Upstream pgloader fails to connect to MySQL 8.4+ because these versions use `caching_sha2_password` as the default authentication method. The underlying MySQL protocol library ([qmynd](https://github.com/qitab/qmynd)) has two issues:

1. **Auth-switch packet type mismatch** — The `auth-switch-request` packet defines the auth plugin data as a string instead of raw octets. When the server sends an auth-switch (e.g., a `mysql_native_password` user on a MySQL 8.4+ server), the binary scramble is incorrectly converted to a Lisp string, causing a type error in the cryptographic functions. This fork patches qmynd at build time to fix this.

2. **Missing RSA dependencies** — Full `caching_sha2_password` authentication over TCP requires RSA encryption. qmynd declares the needed packages (`asn1`, `trivia`) as optional, so they aren't downloaded automatically. This fork adds them as explicit dependencies.

Together, these changes enable pgloader to connect to any MySQL 8.4+ or 9.0+ server regardless of the user's authentication plugin.

## Docker quick start

```bash
docker pull ghcr.io/limetric/pgloader:latest
```

Migrate a MySQL database to PostgreSQL:

```bash
docker run --rm --network host ghcr.io/limetric/pgloader:latest \
  pgloader mysql://user:pass@localhost/sourcedb \
           pgsql://user:pass@localhost/targetdb
```

If your databases are in Docker, use service names instead of `localhost` and connect via a shared network:

```bash
docker run --rm --network my-network ghcr.io/limetric/pgloader:latest \
  pgloader mysql://root:pass@mysql-host/mydb \
           pgsql://postgres:pass@pg-host/mydb
```

Migrate a SQLite file (mount it into the container):

```bash
docker run --rm -v /path/to/data:/data ghcr.io/limetric/pgloader:latest \
  pgloader /data/source.db pgsql://user:pass@localhost/targetdb
```

Use a `.load` command file for advanced options (cast rules, schema renaming, filtering):

```bash
docker run --rm --network host -v /path/to/commands:/commands ghcr.io/limetric/pgloader:latest \
  pgloader /commands/migration.load
```

## Changes from upstream

- **`pgloader.asd`** — Added `#:asn1` and `#:trivia` dependencies for RSA support in `caching_sha2_password`
- **`Makefile`** — Patches qmynd's `auth-switch-request` packet to use `(octets :eof)` instead of `(string :eof)` after cloning
- **`Dockerfile`** — Updated base image to Debian Trixie

## Building from source

```bash
make clean && make
./build/bin/pgloader --version
```

Or via Docker:

```bash
docker build -t pgloader .
```

## Upstream documentation

Full pgloader documentation is available at [pgloader.readthedocs.io](https://pgloader.readthedocs.io/en/latest/), including the command file syntax, cast rules, and supported source formats (MySQL, SQLite, MS SQL Server, CSV, fixed-width, DBF, IXF).

## Licence

pgloader is available under [The PostgreSQL Licence](http://www.postgresql.org/about/licence/).
