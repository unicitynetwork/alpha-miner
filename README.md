# Alphaminer

- Alphaminer is a free, high performance, open source, cross platform CPU miner for mining Alpha.
- The software has been tested on Linux, Windows, macOS and on Intel/AMD x86-64 and ARM64 processors.
- Alphaminer uses RandomX 1.2.1 as its mining algorithm.

## Features

Alphaminer supports:
- Solo mining with Alpha node (RPC getblocktemplate)
- Mining pools (Stratum V1 protocol)
- Hiveon OS
- Large pages for improved performance
- Multi-threading capability


## Community Mining
If you would like to support the development, then you can add the community address to the list of mining addresses - see below for setup. Current ALPHA community address is 

```
alpha1qmmqcy66tyjfq5rgngxk4p2r34y9ny7cnnfq3wmfw8fyx03yahxkq0ck3kh
```

## Download

- [Binary Releases](https://github.com/unicitynetwork/alpha-miner/releases)
- [RandomX Algorithm](https://github.com/unicitynetwork/RandomX)

## Build dependencies

Alphaminer depends on the following libraries:
- libcurl, https://curl.se/libcurl/
- jansson, https://github.com/akheron/jansson (jansson is included locally)
- RandomX, https://github.com/unicitynetwork/RandomX (RandomX is included as a Git submodule)

## Docker

Alpha-miner is available as a Docker image for easy deployment without manual compilation.

### Pull the Docker image

```bash
docker pull ghcr.io/unicitynetwork/alpha-miner:latest
```

### Solo Mining with Docker

For solo mining, you need to connect to an Alpha full node and provide a file containing mining addresses.

#### Example: Solo mining with local Alpha node

```bash
docker run --rm --name alpha-miner \
  --cpus=1 \
  --add-host=host.docker.internal:host-gateway \
  -v $(pwd)/addrs.txt:/home/miner/addrs.txt \
  ghcr.io/unicitynetwork/alpha-miner \
  -o 'host.docker.internal:8589' \
  -O user:password \
  --largepages \
  --no-affinity
```

#### Parameters explained:
- `--rm`: Automatically remove the container when it stops
- `--name alpha-miner`: Name the container for easy management
- `--cpus=1`: Limit the container to 1 CPU (adjust as needed)
- `--add-host=host.docker.internal:host-gateway`: Allows the container to connect to services on the host machine (needed for local Alpha node)
- `-v $(pwd)/addrs.txt:/home/miner/addrs.txt`: Mount your addresses file into the container
- `-o 'host.docker.internal:8589'`: Connect to Alpha node RPC (use host.docker.internal for local node)
- `-O user:password`: RPC credentials (replace with your actual username:password from alpha.conf)
- `--largepages`: Enable large memory pages for better performance
- `--no-affinity`: Disable CPU affinity

#### Creating the addresses file

Create a file named `addrs.txt` with one Alpha address per line:
```
alpha1qhhjespxz2wrd8l39d0m5ntswhsxza7dxz02yfg
alpha1q54mypfl9wyx7z6h523qx242dr77nmensthmfu5
```

### Pool Mining with Docker

Pool mining is simpler as it doesn't require an addresses file or local node connection.

#### Example: Pool mining with Unicity Pool

```bash
docker run --rm --name alpha-pool-miner \
  --cpus=4 \
  ghcr.io/unicitynetwork/alpha-miner \
  -o 'stratum+tcp://unicity-pool.com:3054' \
  -u YOUR_WALLET_ADDRESS \
  --largepages \
  -t 4
```

#### Parameters explained:
- `-o 'stratum+tcp://unicity-pool.com:3054'`: Pool's stratum server address
- `-u YOUR_WALLET_ADDRESS`: Your Alpha wallet address (replace with your actual address)
- `-p x`: Password for the pool (usually 'x' for most pools)
- `-t 4`: Number of mining threads (should match --cpus value)

### Default Docker behavior

If you run the container without any arguments, it will use default solo mining settings:
```bash
# This requires addrs.txt to be mounted
docker run --rm -v $(pwd)/addrs.txt:/home/miner/addrs.txt ghcr.io/unicitynetwork/alpha-miner
```

Default settings:
- Connects to `127.0.0.1:8589` (local Alpha node)
- Uses `user:password` as RPC credentials
- Enables large pages and disables CPU affinity
- Auto-detects CPU count for thread count

### Docker performance tips

1. **CPU allocation**: Use `--cpus` to control how many CPUs the container can use
2. **Large pages**: Always use `--largepages` for approximately 2x performance improvement
3. **Thread count**: The container auto-detects available CPUs, but you can override with `-t`
4. **Benchmark**: Test performance with `docker run --rm ghcr.io/unicitynetwork/alpha-miner --benchmark`