#!/bin/bash
# tests/integration.sh
# Basic integration test for ASTRACAT Recursive Resolver

set -e

# Path to the resolver binary
RESOLVER_BIN="./build/astracat-resolver"

# Check if the resolver binary exists
if [ ! -f "$RESOLVER_BIN" ]; then
    echo "Resolver binary not found. Build the project first."
    exit 1
fi

echo "Starting resolver in the background..."
# Start the resolver as a background process
$RESOLVER_BIN &
RESOLVER_PID=$!

# Wait a moment for the resolver to initialize and start listening
sleep 2

echo "Performing DNS query for example.com..."
# Use dig to query the resolver and check for a successful response
# The +noall +answer options ensure we only see the answer, not stats
dig @127.0.0.1 -p 53 example.com A +noall +answer

# Check if dig returned a successful status code
if [ $? -ne 0 ]; then
    echo "Test failed: dig command was unsuccessful."
    kill $RESOLVER_PID
    exit 1
fi

echo "Test successful. Shutting down resolver..."
# Gracefully shut down the resolver
kill $RESOLVER_PID

# Wait for the process to terminate
wait $RESOLVER_PID

echo "Integration test completed."
