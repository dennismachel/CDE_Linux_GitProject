
# etl_corelinuxgit.sh — Initialization helper

Small helper script that initializes the directory structure used by the Core Data Engineers ETL demo.

## Purpose
Create the basic data staging directories used by the pipeline so downstream steps can assume a consistent layout.

## What the script does
- Ensures directories `raw`, `Transformed`, and `Gold` exist (creates them if missing).
- Prints an initialization summary message.

## Prerequisites
- macOS or Linux with a POSIX-compatible `bash` (script uses `#!/usr/bin/env bash`).

## Usage
Run the script from the repository root:

```bash
bash etl_corelinuxgit.sh
```

Example expected output:

```
==================================================
CoreDataEngineers ETL Pipeline: Initializing...
==================================================
[INIT] Directory structure verified: /raw, /Transformed, /Gold
```

## Environment & Configuration
No external environment variables are required. The script defines the following directories internally:

- `RAW_DIR="raw"`
- `TRANSFORMED_DIR="Transformed"`
- `GOLD_DIR="Gold"`

If you need a different layout, wrap or modify the script accordingly.

## Files created
The script creates the directories (if they don't already exist) in the current working directory:

- `raw/`
- `Transformed/`
- `Gold/`

## Testing / Validation
This repository previously included a small local test harness; that has been removed. To verify locally, run the script in an isolated temporary directory:

```bash
mkdir -p /tmp/etl-sanity && pushd /tmp/etl-sanity
bash /path/to/repo/etl_corelinuxgit.sh
ls -l raw Transformed Gold
popd
```

Replace `/path/to/repo` with your local repository path.

## Contributing
- Make small, focused changes and include a short description in your commit message.

## License
Specify your license here if applicable.

