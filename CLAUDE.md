# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
Alpha-miner is a CPU cryptocurrency miner for Alpha using the RandomX 1.2.1 algorithm. It supports solo mining, pool mining (Stratum V1), and HiveOS integration.

## Build Commands
- Standard build: `./autogen.sh && ./configure && make`
- Build with large pages (recommended): `./configure --with-largepages && make`
- Clean build: `make clean && make`
- Install dependencies (Ubuntu/Debian): `sudo apt install autoconf git build-essential pkg-config libcurl4-openssl-dev libgmp-dev`

## Testing Commands
- RandomX tests: `cd RandomX && cmake . && make && ./randomx-tests`
- Run specific test: `./randomx-tests <test_name>`
- Benchmark miner: `./minerd --benchmark`
- Benchmark with large pages: `./minerd --benchmark --largepages`

## Code Architecture
Key files and their purposes:
- `cpu-miner.c`: Main program entry, command-line parsing, thread management
- `randomx-miner.c`: RandomX algorithm integration and mining logic
- `util.c`: Network communication, JSON-RPC, Stratum protocol implementation
- `diff_to_target_gmp.c`: Difficulty/target conversions using GMP library
- `/RandomX/`: Complete RandomX PoW algorithm implementation with JIT support
- `/compat/jansson/`: Embedded JSON parsing library
- `/hiveon/`: HiveOS integration scripts (h-manifest.conf, h-config.sh, h-run.sh)

Mining flow:
1. Main thread initializes RandomX dataset and cache
2. Worker threads fetch work from node/pool via getblocktemplate or Stratum
3. Each thread runs RandomX hash function searching for valid nonces
4. Valid shares/blocks submitted back to node/pool

## Development Guidelines
- C standards: C++11 for RandomX, C99 for miner code
- Code style: 4-space indentation, snake_case naming, max 120 char lines
- Thread safety: Use mutexes for shared data (stratum_lock, applog_lock)
- Memory: Always free allocated resources, check RandomX allocation failures
- Logging: Use applog() for all output, never printf directly
- Platform code: Use #ifdef for OS-specific features (Windows, Linux, macOS)