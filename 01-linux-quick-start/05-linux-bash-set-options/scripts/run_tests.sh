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
