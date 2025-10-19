# Dockerfile for ASTRACAT Recursive Resolver

# ---- Builder Stage ----
# Use a slim Debian image for the build environment
FROM debian:bullseye-slim AS builder

# Install dependencies for adding the CZ.NIC Labs repository
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-transport-https ca-certificates wget

# Add the CZ.NIC Labs GPG key and repository
RUN wget -O /usr/share/keyrings/cznic-labs-pkg.gpg https://pkg.labs.nic.cz/gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cznic-labs-pkg.gpg] https://pkg.labs.nic.cz/knot-resolver bullseye main" > /etc/apt/sources.list.d/cznic-labs-knot-resolver.list

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    pkg-config \
    knot-resolver-dev \
    libuv1-dev \
    libssl-dev \
    libluajit-5.1-dev \
    lua5.3-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy the application source code
WORKDIR /app
COPY . .

# Create a build directory and run CMake
RUN cmake -B build -DENABLE_LUA=ON
RUN cmake --build build

# ---- Runtime Stage ----
# Use a small base image for the final container
FROM debian:bullseye-slim

# Install dependencies for adding the CZ.NIC Labs repository
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-transport-https ca-certificates wget

# Add the CZ.NIC Labs GPG key and repository
RUN wget -O /usr/share/keyrings/cznic-labs-pkg.gpg https://pkg.labs.nic.cz/gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cznic-labs-pkg.gpg] https://pkg.labs.nic.cz/knot-resolver bullseye main" > /etc/apt/sources.list.d/cznic-labs-knot-resolver.list

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    knot-resolver \
    lua5.3 \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user for security
RUN useradd --system --user-group --shell /bin/false astracat

# Copy the compiled binary and Lua scripts from the builder stage
WORKDIR /app
COPY --from=builder /app/build/astracat-resolver /usr/local/bin/
COPY lua/ /app/lua/

# Set the user and define the entrypoint
USER astracat:astracat
ENTRYPOINT ["/usr/local/bin/astracat-resolver"]
CMD ["/app/lua/example_filter.lua"]
