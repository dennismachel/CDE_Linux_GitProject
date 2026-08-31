# etl_corelinuxgit.sh — Test Validation

Run the validation test for `etl_corelinuxgit.sh`:

```bash
make test
```

Or run directly:

```bash
bash tests/test_etl_corelinuxgit.sh
```

The test runs the script in an isolated temporary directory and asserts that the directories `raw`, `Transformed`, and `Gold` are created and that the script prints a verification message.
