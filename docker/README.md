# Alpha Miner Docker Container

This Docker container provides a convenient way to run Alpha Miner with minimal setup.

## Building the Docker Image

From the root of the repository:

```bash
docker build -t alpha-miner -f docker/Dockerfile .
```

## Running the Container

### Default Configuration

If you run the container without arguments, it will use these defaults:

```bash
docker run --rm -v $(pwd)/addrs.txt:/home/miner/addrs.txt alpha-miner
```

This will run the miner with:
```
./minerd -o 127.0.0.1:8589 -O user:password --largepages --no-affinity --afile=addrs.txt -t <CPU_COUNT>
```

Where `<CPU_COUNT>` is automatically set to the number of CPUs allocated to the container.

### CPU Allocation

The container automatically detects how many CPUs are allocated to it by Docker:

```bash
# Limit to 4 CPUs
docker run --rm --cpuset-cpus="0-3" -v $(pwd)/addrs.txt:/home/miner/addrs.txt alpha-miner

# Alternative way to limit CPUs
docker run --rm --cpu-quota=400000 --cpu-period=100000 -v $(pwd)/addrs.txt:/home/miner/addrs.txt alpha-miner
```

The detected CPU count will be used for mining threads (`-t` parameter) unless you manually specify a different thread count.

### Completely Overriding Arguments

Any arguments you provide will **completely replace** the default arguments:

```bash
# Run benchmark mode (no need for addresses file)
docker run --rm alpha-miner --benchmark

# Solo mining with custom parameters
docker run --rm -v $(pwd)/addrs.txt:/home/miner/addrs.txt alpha-miner -o mining.pool.com:8589 -O myuser:mypassword -t 4
```

### Required: Addresses File

An addresses file is required for mining (not for benchmarking). This file contains the Alpha wallet addresses where mining rewards will be sent.

Create an addresses file with one address per line:

```
alpha1qhhjespxz2wrd8l39d0m5ntswhsxza7dxz02yfg
alpha1q54mypfl9wyx7z6h523qx242dr77nmensthmfu5
alpha1qmmqcy66tyjfq5rgngxk4p2r34y9ny7cnnfq3wmfw8fyx03yahxkq0ck3kh
```

Mount this file when running the container:

```bash
docker run --rm -v $(pwd)/addrs.txt:/home/miner/addrs.txt alpha-miner
```

### Common Usage Examples

1. Run benchmark (no addresses file needed):
   ```bash
   docker run --rm alpha-miner --benchmark
   ```

2. Run benchmark with 4 threads:
   ```bash
   docker run --rm alpha-miner --benchmark -t 4
   ```

3. Connect to a mining pool:
   ```bash
   docker run --rm -v $(pwd)/addrs.txt:/home/miner/addrs.txt alpha-miner -o pool.example.com:3333 -O myusername:mypassword
   ```

4. Use a custom addresses file with a different name:
   ```bash
   docker run --rm -v $(pwd)/my-addresses.txt:/home/miner/my-addresses.txt alpha-miner -o pool.example.com:3333 -O myuser:mypassword --afile=my-addresses.txt
   ```

5. Limit to specific CPU cores:
   ```bash
   # Use only cores 0 and 1
   docker run --rm --cpuset-cpus="0,1" -v $(pwd)/addrs.txt:/home/miner/addrs.txt alpha-miner
   ```

## Networking

When connecting to a local node on the host machine, you need to use the host network mode:

```bash
docker run --rm --network=host -v $(pwd)/addrs.txt:/home/miner/addrs.txt alpha-miner
```

Or use the host's IP address instead of 127.0.0.1:

```bash
docker run --rm -v $(pwd)/addrs.txt:/home/miner/addrs.txt alpha-miner -o host.docker.internal:8589 -O user:password
```