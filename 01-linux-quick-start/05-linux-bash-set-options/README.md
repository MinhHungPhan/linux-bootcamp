# Linux Bash `set` Options

Welcome! 👋 If you've ever written a Bash script and wondered what `set -e` or `set +e` really do — or why your script stops halfway for no clear reason — you're in the right place. We'll walk through what these options mean, how they behave in real-world scripts, and when to use (or avoid) them.

## Table of Contents

- [What is `set` in Bash?](#what-is-set-in-bash)
- [Understanding `set -e`](#understanding-set--e)
- [Understanding `set +e`](#understanding-set-+e)
- [Why Switch Between `-e` and `+e`](#why-switch-between--e-and-+e)
- [Real-World Example: CI/CD Script](#real-world-example-cicd-script)
- [Best Practices](#best-practices)
- [Key Takeaways](#key-takeaways)
- [Conclusion](#conclusion)
- [References](#references)

## What is `set` in Bash?

The `set` command in Bash is used to change the behavior of your shell. It accepts options that let you control how Bash reacts in different situations.

For example:

- `set -x`: print each command before executing it (useful for debugging)
- `set -u`: exit on undefined variables
- `set -e`: exit on error

## Understanding `set -e`

When you run `set -e` at the beginning of a script, you're telling Bash:

> "If any command fails (i.e., returns a non-zero exit status), **immediately stop the script**."

This is called **"fail fast"** behavior — and it's incredibly useful in automation or deployment scripts where you don't want to continue if something goes wrong.

### Example

```bash
#!/bin/bash
set -e

echo "Starting..."
false                               # This command fails (returns 1)
echo "This will never be printed"   # This line is never executed
```

🔍 What happens here?

- `echo "Starting..."` runs fine.
- `false` fails with exit code `1`.
- Because of `set -e`, the script stops **right there**.
- `"This will never be printed"` is skipped.

## Understanding `set +e`

On the flip side, `set +e` disables the "fail fast" behavior.

With `set +e`, the script **continues even if a command fails**. This gives you more flexibility to **handle failures manually**.

### Example

```bash
#!/bin/bash
set +e

echo "Trying something risky..."
false.                                      # This fails, but script continues
echo "Still going, even after failure."     # This line is executed    
```

Here, even though `false` fails, the script keeps running. You can decide later what to do about it.

## Why Switch Between `-e` and `+e`

Sometimes, you want your script to fail fast **most of the time**, but **ignore errors in certain places** (like flaky test results or optional cleanup steps).

In that case, you can temporarily disable `-e` using `set +e`, then re-enable it afterward with `set -e`.

### Example: Controlled Flexibility

```bash
#!/bin/bash
set -e

echo "Building..."
make build  # or any build command

# Temporarily allow test failures
set +e
./run_tests.sh
TEST_RESULT=$?
set -e

if [ $TEST_RESULT -ne 0 ]; then
  echo "[Warning] Tests failed — continuing anyway."
fi

echo "Deploying..."
./deploy.sh
```

In this example:

- We want the script to **fail fast by default**.
- We **manually check** if tests fail and print a warning, but don't exit.
- We **resume strict mode** to ensure deployment doesn't happen silently if it fails.

## Real-World Example: Complete CI/CD Script

Let's create a complete, runnable CI/CD pipeline that you can actually execute. First, we'll create all the helper scripts, then the main pipeline script.

### Step 1: Create the Helper Scripts

```bash
# Create a simple build script
cat > build.sh << 'EOF'
#!/bin/bash
echo "🔨 Compiling source code..."
sleep 1
echo "📦 Creating build artifacts..."
sleep 1
echo "✅ Build completed successfully!"
# Simulate build success (exit code 0)
exit 0
EOF
chmod +x build.sh

# Create a test script that sometimes fails
cat > run_tests.sh << 'EOF'
#!/bin/bash
echo "🧪 Running unit tests..."
sleep 1
echo "🧪 Running integration tests..."
sleep 1

# Simulate flaky tests - 50% chance of failure
if [ $((RANDOM % 2)) -eq 0 ]; then
    echo "❌ Some tests failed!"
    exit 1
else
    echo "✅ All tests passed!"
    exit 0
fi
EOF
chmod +x run_tests.sh

# Create a linting script
cat > lint_code.sh << 'EOF'
#!/bin/bash
echo "🔍 Checking code style..."
sleep 1
echo "🔍 Running static analysis..."
sleep 1
echo "✅ Code quality checks passed!"
# Always succeed
exit 0
EOF
chmod +x lint_code.sh

# Create a deployment script
cat > deploy.sh << 'EOF'
#!/bin/bash
ENVIRONMENT=${1:-staging}
echo "🚀 Deploying to $ENVIRONMENT..."
sleep 2
echo "🌐 Updating load balancer..."
sleep 1
echo "✅ Deployment to $ENVIRONMENT completed!"
exit 0
EOF
chmod +x deploy.sh
```

### Step 2: Create the Main CI/CD Pipeline

```bash
# Create the main pipeline script
cat > ci_cd_pipeline.sh << 'EOF'
#!/bin/bash

set -e  # Stop on first failure

echo "🎯 Starting CI/CD Pipeline..."
echo "================================"

echo "[1/4] Building project..."
./build.sh

echo
echo "[2/4] Running tests..."
set +e
./run_tests.sh
TEST_STATUS=$?
set -e

if [ $TEST_STATUS -ne 0 ]; then
  echo "[⚠️  Warning] Some tests failed. Proceeding with deployment anyway."
fi

echo
echo "[3/4] Checking code quality..."
./lint_code.sh

echo
echo "[4/4] Deploying to staging..."
./deploy.sh staging

echo
echo "✅ Pipeline completed successfully!"
EOF
chmod +x ci_cd_pipeline.sh
```

### Step 3: Run the Complete Pipeline

```bash
# Execute the pipeline
./ci_cd_pipeline.sh
```

> 💡 **CloudShell Tip**: You can copy and paste these commands directly into Google CloudShell, AWS CloudShell, or any Linux terminal. The pipeline will create realistic build, test, lint, and deploy processes!

### Step-by-Step Breakdown

Let's walk through what happens at each stage:

**Step 1: Building** 
- `./build.sh` must succeed or the entire script stops
- If the build fails, there's no point continuing since we have nothing to deploy

**Step 2: Testing (Flexible)**
- We temporarily disable strict mode with `set +e`
- Run tests and capture the exit code in `TEST_STATUS`
- Re-enable strict mode with `set -e`
- Check the test results and warn if they failed, but don't stop the deployment
- *Rationale*: In some CI/CD pipelines, you might want to deploy even with failing tests (e.g., to a staging environment for debugging)

**Step 3: Linting (Critical)**
- `./lint_code.sh` runs in strict mode
- If linting fails, the script stops immediately and deployment never happens
- *Rationale*: Code that doesn't meet style/quality standards shouldn't be deployed

**Step 4: Deployment (Critical)**
- `./deploy.sh staging` also runs in strict mode
- If deployment fails, we want to know immediately
- *Rationale*: A failed deployment is always a critical error

### What You'll See When Running

When you run the pipeline, you might see output like this:

```
🎯 Starting CI/CD Pipeline...
================================
[1/4] Building project...
🔨 Compiling source code...
📦 Creating build artifacts...
✅ Build completed successfully!

[2/4] Running tests...
🧪 Running unit tests...
🧪 Running integration tests...
❌ Some tests failed!
[⚠️  Warning] Some tests failed. Proceeding with deployment anyway.

[3/4] Checking code quality...
🔍 Checking code style...
🔍 Running static analysis...
✅ Code quality checks passed!

[4/4] Deploying to staging...
🚀 Deploying to staging...
🌐 Updating load balancer...
✅ Deployment to staging completed!

✅ Pipeline completed successfully!
```

Notice how the pipeline continues even when tests fail, but would stop immediately if build, linting, or deployment failed.

### Why This Pattern Works

This script demonstrates a common CI/CD philosophy:
- **Build failures**: Always fatal (can't deploy what doesn't build)
- **Test failures**: Configurable (might want to deploy to staging for debugging)
- **Linting failures**: Usually fatal (maintain code quality)
- **Deployment failures**: Always fatal (need to know if deployment succeeded)

This script uses `set -e` by default to **fail fast on critical errors**, but **allows test flexibility** while still protecting the most important steps.

### Try Different Scenarios

Run the pipeline multiple times to see different behaviors:

```bash
# Run it several times - sometimes tests pass, sometimes they fail
./ci_cd_pipeline.sh
./ci_cd_pipeline.sh
./ci_cd_pipeline.sh
```

You can also modify the test script to always fail and see how the pipeline handles it:

```bash
# Make tests always fail
sed -i 's/RANDOM % 2/1/' run_tests.sh
./ci_cd_pipeline.sh

# Make tests always pass  
sed -i 's/1/0/' run_tests.sh
./ci_cd_pipeline.sh
```

## Try It Yourself in CloudShell

Let's create some simple scripts you can test right now in CloudShell or any Linux terminal:

### Experiment 1: Basic `set -e` behavior

```bash
# Create a test script
cat > test_set_e.sh << 'EOF'
#!/bin/bash
set -e

echo "Step 1: This will work"
echo "Step 2: This will also work"
false  # This command always fails
echo "Step 3: You'll never see this message"
EOF

# Make it executable and run it
chmod +x test_set_e.sh
./test_set_e.sh
```

### Experiment 2: Without `set -e`

```bash
# Create a script without set -e
cat > test_no_set_e.sh << 'EOF'
#!/bin/bash
# No set -e here

echo "Step 1: This will work"
echo "Step 2: This will also work"
false  # This fails, but script continues
echo "Step 3: You WILL see this message"
EOF

# Make it executable and run it
chmod +x test_no_set_e.sh
./test_no_set_e.sh
```

### Experiment 3: Controlled error handling

```bash
# Create a script that handles errors selectively
cat > test_controlled.sh << 'EOF'
#!/bin/bash
set -e

echo "Starting critical operations..."

# This must succeed
echo "Creating important file..."
touch important_file.txt

# Allow this operation to fail
set +e
echo "Trying optional operation..."
ls non_existent_file.txt 2>/dev/null
OPTIONAL_RESULT=$?
set -e

if [ $OPTIONAL_RESULT -ne 0 ]; then
  echo "Optional operation failed, but that's OK!"
fi

# This must succeed
echo "Finishing critical operations..."
echo "Success!" > important_file.txt
cat important_file.txt
EOF

# Make it executable and run it
chmod +x test_controlled.sh
./test_controlled.sh
```

Try running these experiments to see the different behaviors in action!

## Best Practices

- Use `set -e` at the top of your scripts to avoid silent failures.
- If you're temporarily allowing failure, **always capture the exit code** (using `$?`) and handle it.
- Turn strict mode back **on** after using `set +e` — otherwise, you might miss future errors.
- Combine with `set -u` (undefined variable detection) and `set -o pipefail` for even better safety.

## Key Takeaways

- `set -e` helps catch errors early by stopping the script on the first failure.
- `set +e` gives you flexibility to handle errors manually.
- Switching between them gives you **granular control** in complex scripts.
- Always check and handle exit codes if you use `set +e`.
- Re-enable `set -e` after any critical section where you disable it.

## Conclusion

Bash scripting can feel tricky at times, especially when things "just stop working." Understanding `set -e` and `set +e` gives you one of the most important tools to **write reliable, safe, and predictable scripts**. Use them wisely, and your scripts will be easier to debug, safer to run, and more pleasant to maintain.

## References

- [GNU Bash Manual - The Set Builtin](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)
- [Bash Pitfalls](https://mywiki.wooledge.org/BashPitfalls)
- [ShellCheck – A shell script linter](https://www.shellcheck.net/)
- [CI/CD Bash Best Practices](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#example-using-set-e)
