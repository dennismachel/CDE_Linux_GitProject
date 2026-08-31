#!/usr/bin/env bash
set -euo pipefail

# Simple validation test for etl_corelinuxgit.sh
# - runs the script in an isolated temp dir
# - asserts directories are created and output contains expected message

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/etl_corelinuxgit.sh"

TMPDIR="$(mktemp -d)"
cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

pushd "$TMPDIR" >/dev/null

# Ensure clean state
if [ -d raw ] || [ -d Transformed ] || [ -d Gold ]; then
  echo "Pre-existing directories present in temp dir" >&2
  exit 1
fi

OUTPUT="$(bash "$SCRIPT_PATH" 2>&1)"

# Check exit success (set -e will exit on failure)

# Verify directories created
if [ ! -d raw ] || [ ! -d Transformed ] || [ ! -d Gold ]; then
  echo "Expected directories not created" >&2
  echo "Output was: $OUTPUT" >&2
  exit 1
fi

# Verify output contains confirmation
if ! echo "$OUTPUT" | grep -q "Directory structure verified"; then
  echo "Expected verification message not found in output" >&2
  echo "Output was: $OUTPUT" >&2
  exit 1
fi

popd >/dev/null

echo "TEST PASSED"
