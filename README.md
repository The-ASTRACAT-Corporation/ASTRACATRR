# ASTRACAT Recursive Resolver

A high-performance recursive DNS resolver core written in C, built on `libkres`, `libknot`, and `libdnssec`.

## Features

- **High-performance:** Built for speed and efficiency.
- **Extensible:** Supports Lua plugins for filtering and logging.
- **Modern:** Includes a multi-stage `Dockerfile` and GitHub Actions CI.
- **Observability:** (Planned) Prometheus metrics endpoint.

## Build and Run

### Prerequisites

- `cmake`
- `build-essential`
- `pkg-config`
- `libknot-dev`
- `libkres-dev`
- `lua5.3-dev`

### Build Instructions

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/astracat-resolver.git
    cd astracat-resolver
    ```

2.  **Configure and build with CMake:**
    ```bash
    cmake -B build -DENABLE_LUA=ON -DUSE_SYSTEM_LIBKRES=ON
    cmake --build build
    ```

3.  **Run the resolver:**
    ```bash
    ./build/astracat-resolver
    ```

### Run with Docker

```bash
docker build -t astracat-resolver .
docker run -p 53:53/udp astracat-resolver
```

## Usage

### Using `dig`

```bash
dig @127.0.0.1 -p 53 example.com A
```

### Using `dnsperf`

```bash
./tests/dnsperf.sh
```

## MVP and Roadmap

### MVP

-   [x] Project skeleton with `libkres` initialization
-   [x] Simple A/AAAA record resolution
-   [x] In-memory cache (placeholder)
-   [x] Lua hooks for filtering
-   [ ] REST API for metrics (`/metrics`)

### Stage 2

-   [ ] DNSSEC validation
-   [ ] DNS-over-TLS (DoT) and DNS-over-HTTPS (DoH) support
-   [ ] Rate-limiting (RRL)

### Stage 3

-   [ ] Full observability with Prometheus/Grafana
-   [ ] Expanded API for control plane
-   [ ] Horizontal scaling and clustering

## Architecture

-   **Core Resolver:** C (`libkres`, `libknot`)
-   **Control Plane:** (Planned) Go/Node.js with REST/gRPC
-   **Plugins:** Lua/C
-   **Observability:** Prometheus/Grafana
-   **CI/CD:** GitHub Actions + Docker
