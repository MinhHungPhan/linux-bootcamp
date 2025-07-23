# Helper Scripts for CI/CD Pipeline Tutorial

This directory contains reference scripts that demonstrate the concepts covered in the main README tutorial about `set -e` and `set +e` in Bash.

## Scripts Overview

### Core Pipeline Scripts

- **`ci_cd_pipeline.sh`** - Main CI/CD pipeline script that demonstrates proper use of `set -e` and `set +e`
- **`build.sh`** - Simulates a build process (always succeeds)
- **`run_tests.sh`** - Simulates testing with 50% random failure rate
- **`lint_code.sh`** - Simulates code quality checks (always succeeds)
- **`deploy.sh`** - Simulates deployment process (always succeeds)

## How to Use

1. Make sure you're in the parent directory (where the main README.md is located)
2. Run the complete pipeline:

```bash
./scripts/ci_cd_pipeline.sh
```

3. Or test individual components:

```bash
./scripts/build.sh
./scripts/run_tests.sh
./scripts/lint_code.sh
./scripts/deploy.sh staging
```

## What You'll Learn

These scripts demonstrate:
- How `set -e` causes scripts to exit immediately on errors
- How `set +e` allows you to handle errors manually
- Real-world patterns for CI/CD error handling
- How to capture and check exit codes with `$?`

## Expected Behavior

- **Build**: Always succeeds
- **Tests**: Randomly fail ~50% of the time, but pipeline continues
- **Linting**: Always succeeds, but would stop pipeline if it failed
- **Deployment**: Always succeeds, but would stop pipeline if it failed

The pipeline demonstrates how different types of failures are handled differently in real-world scenarios.
