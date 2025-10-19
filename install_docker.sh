#!/bin/bash
# This script builds and runs the ASTRACAT Recursive Resolver in a Docker container.

set -e

# Build the Docker image
echo "Building the Docker image..."
docker build -t astracat-resolver .

# Run the Docker container
echo "Running the Docker container..."
docker run -p 53:53/udp --name astracat-resolver-container -d astracat-resolver

echo "ASTRACAT Recursive Resolver is running in a detached container."
echo "To view logs, run: docker logs astracat-resolver-container"
echo "To stop the container, run: docker stop astracat-resolver-container"
