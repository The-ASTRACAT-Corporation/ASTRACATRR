#!/bin/bash
# tests/dnsperf.sh
# Performance test for ASTRACAT Recursive Resolver using dnsperf

set -e

# Path to the resolver binary
RESOLVER_BIN="./build/astracat-resolver"

# Check if the resolver binary exists
if [ ! -f "$RESOLVER_BIN" ]; then
    echo "Resolver binary not found. Build the project first."
    exit 1
fi

echo "Starting resolver for performance test..."
# Start the resolver in the background
$RESOLVER_BIN &
RESOLVER_PID=$!

# Allow the resolver to start
sleep 2

# Create a sample data file for dnsperf
cat << EOF > dnsperf_data.txt
example.com A
google.com A
github.com AAAA
EOF

echo "Running dnsperf benchmark..."
# Run dnsperf against the local resolver
dnsperf -s 127.0.0.1 -p 53 -d dnsperf_data.txt -c 10 -l 30 -q 1000

# Stop the resolver
echo "Benchmark finished. Shutting down resolver..."
kill $RESOLVER_PID
wait $RESOLVER_PID

# Clean up the temporary data file
rm dnsperf_data.txt

echo "Performance test completed."
