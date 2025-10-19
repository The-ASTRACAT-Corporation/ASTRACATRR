#!/bin/bash
# This script installs the ASTRACAT Recursive Resolver and its dependencies on a Debian-based host system.

set -e

# --- Check for root privileges ---
if [[ "$EUID" -ne 0 ]]; then
  echo "Please run this script as root or with sudo."
  exit 1
fi

# --- Install Dependencies ---
echo "Installing dependencies..."

# Install tools for adding the CZ.NIC Labs repository
apt-get update
apt-get install -y --no-install-recommends apt-transport-https ca-certificates wget lsb-release

# Get OS codename
CODENAME=$(lsb_release -cs)

# Add the CZ.NIC Labs GPG key and repository
wget -O /usr/share/keyrings/cznic-labs-pkg.gpg https://pkg.labs.nic.cz/gpg
echo "deb [signed-by=/usr/share/keyrings/cznic-labs-pkg.gpg] https://pkg.labs.nic.cz/knot-resolver ${CODENAME} main" > /etc/apt/sources.list.d/cznic-labs-knot-resolver.list

# Update package lists and install build dependencies
apt-get update
apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    pkg-config \
    knot-resolver-dev \
    libuv1-dev \
    libssl-dev \
    libluajit-5.1-dev \
    lua5.3-dev

echo "Dependencies installed successfully."

# --- Build the Project ---
echo "Building the project..."

# Create a build directory and run CMake
cmake -B build -DENABLE_LUA=ON -DUSE_SYSTEM_LIBKRES=ON

# Build the project
cmake --build build

echo "Build complete."
echo "The binary is located at: ./build/astracat-resolver"
echo "To run the resolver, execute: ./build/astracat-resolver"
