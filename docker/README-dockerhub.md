# Alpha Miner Docker Image

This is the official Docker image for Alpha Miner, a high-performance CPU miner for Alpha cryptocurrency.

## Features

- Based on Alpine Linux for minimal image size
- Auto-detects CPU limits for optimal thread allocation
- Built with static linking for maximum performance
- Supports all Alpha Miner command line options

## Quick Start

```bash
# Create an addresses file (essential for mining)
cat > addrs.txt << EOF
alpha1qhhjespxz2wrd8l39d0m5ntswhsxza7dxz02yfg
alpha1qmmqcy66tyjfq5rgngxk4p2r34y9ny7cnnfq3wmfw8fyx03yahxkq0ck3kh
EOF

# Run the miner with default parameters
docker run --rm -v $(pwd)/addrs.txt:/home/miner/addrs.txt unicitynetwork/alpha-miner

# Connect to a specific pool
docker run --rm -v $(pwd)/addrs.txt:/home/miner/addrs.txt unicitynetwork/alpha-miner -o pool.example.com:3333 -O username:password
```

## CPU Allocation

The container automatically detects how many CPUs are allocated to it by Docker:

```bash
# Limit to 4 CPUs (will use 4 mining threads)
docker run --rm --cpuset-cpus="0-3" -v $(pwd)/addrs.txt:/home/miner/addrs.txt unicitynetwork/alpha-miner

# Alternative way to limit CPUs
docker run --rm --cpu-quota=400000 --cpu-period=100000 -v $(pwd)/addrs.txt:/home/miner/addrs.txt unicitynetwork/alpha-miner
```

## Benchmarking

To run in benchmark mode:

```bash
# No addresses file needed for benchmarking
docker run --rm unicitynetwork/alpha-miner --benchmark
```

## Source Code

This Docker image is built from the [official Alpha Miner repository](https://github.com/unicitynetwork/alpha-miner).

## License

This image and Alpha Miner are released under the GNU General Public License v3.0.