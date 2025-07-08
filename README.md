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
- GMP (GNU Multiple Precision Arithmetic Library), https://gmplib.org/

## Linux

### Ubuntu/Debian

#### Install dependencies
```bash
sudo apt update
sudo apt upgrade
sudo apt install autoconf git build-essential pkg-config libcurl4-openssl-dev libgmp-dev
```

#### Build instructions
```bash
git clone https://github.com/unicitynetwork/alpha-miner --recursive
cd alpha-miner
./autogen.sh
./configure
make
```

### CentOS/RHEL/Fedora

#### Install dependencies

For CentOS/RHEL 8+:
```bash
sudo dnf install autoconf git gcc gcc-c++ make pkgconfig libcurl-devel
```

For older CentOS/RHEL 7:
```bash
sudo yum install autoconf git gcc gcc-c++ make pkgconfig libcurl-devel
```

#### Build instructions

```bash
git clone https://github.com/unicitynetwork/alpha-miner --recursive
cd alpha-miner
./autogen.sh
./configure
make
```

### Arch Linux

#### Install dependencies

```bash
sudo pacman -S autoconf git gcc make pkg-config curl
```

#### Build instructions

```bash
git clone https://github.com/unicitynetwork/alpha-miner --recursive
cd alpha-miner
./autogen.sh
./configure
make
```


## MacOS

### Install dependencies
```bash
brew install git automake libtool pkg-config curl
```
### Build instructions
```bash
git clone https://github.com/unicitynetwork/alpha-miner --recursive
cd alpha-miner
./autogen.sh
./configure
make
```


## Windows

MSYS2 is required to create a native Windows executable.

### Install MSYS2

Download and run installer (https://www.msys2.org/)
* Launch the MSYS2 terminal running default UCRT64 environment.
* You should see 'UCRT64' in the terminal prompt.

### Install dependencies

In MSYS2 terminal:

```
pacman -S git autoconf pkgconf automake make mingw-w64-ucrt-x86_64-curl mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-gmp
```

### Build instructions (for running in MSYS2)

To build a native Windows application which must run in a MSYS2 terminal.
In MSYS2 terminal:

```
git clone https://github.com/unicitynetwork/alpha-miner --recursive
cd Alphaminer
./autogen.sh
LIBCURL="-lcurl.dll" ./configure
make
```

### Build instructions (for running anywhere on Windows)

To build a native Windows application which can run in Terminal and PowerShell.
In MSYS2 terminal, build a static version of libcurl which uses Windows SSL (Schannel) instead of OpenSSL.

```
pacman -S libtool
wget https://curl.se/download/curl-8.7.1.tar.gz
tar xf curl-8.7.1.tar.gz
cd curl-8.7.1
autoreconf -fi
./configure --with-schannel --disable-shared --disable-ftp --disable-file --disable-ldap --disable-ldaps --disable-rtsp --disable-dict --disable-telnet --disable-tftp --disable-pop3 --disable-imap --disable-smb --disable-smtp --disable-gopher --disable-sspi --disable-mqtt --disable-manual --disable-docs --disable-ntlm --disable-largefile --without-libidn2 --disable-tls-srp --disable-libcurl-option --disable-alt-svc --disable-headers-api --disable-verbose --disable-ares --disable-aws --disable-netrc --without-brotli --without-nghttp2 --without-libpsl --without-zstd
make
make install
```

Now build the miner using this new static version of libcurl.

```
git clone https://github.com/unicitynetwork/alpha-miner --recursive
cd alpha-miner
./autogen.sh
LIBCURL=`pkg-config --static --libs libcurl` LDFLAGS="-static -static-libgcc" ./configure CFLAGS="-DCURL_STATICLIB"
make
```

## How to use

- Help message and options:
```
./minerd -h
```

- First test the performance

```
./minerd --benchmark 
```

- Test the performance with largepages. Largepages can give a 2x improvement in hashrate. 

```
./minerd --benchmark --largepages
```

- Ensure you have access to a node that accepts RPC calls. Use the -server flag when running the node daemon or add the following to the **alpha.conf** configuration file. Choose a secure username and password.

```
server=1
rpcuser=YOUR_RPC_USERNAME
rpcpassword=YOUR_RPC_PASSWORD
```

- If the node software is running on a different machine from the miner then you need to allow the miner to make RPC calls by adding the following to the node **alpha.conf** configuration file. 

```
rpcbind=0.0.0.0
rpcallowip= MINER_IP_ADDRESS
```

- For editing the **alpha.conf** file in the node software UI:
  - go to **"Settings"** tab -> **"Options"** -> click **"Open Configuration File"**, make the necessary edits and save the file
  - make sure that **"Enable RPC server"** is ticked under **"Options"**


- Create an addresses file, e.g. **"addresses.txt"**. This allows for a different address to be randomly selected every time the miner wins a block reward. If you would like to support developement then add the community address to the list of addresses. The addresses file should contain one address per line:

```
alpha1qhhjespxz2wrd8l39d0m5ntswhsxza7dxz02yfg
alpha1q54mypfl9wyx7z6h523qx242dr77nmensthmfu5
...
```


- Solo mine on 4 CPU threads, connected to a local Alpha node. Replace username:password with the RPC user and password in the Alpha configuration file **alpha.conf**. 

```
./minerd -o 127.0.0.1:8589 -O YOUR_RPC_USERNAME:YOUR_RPC_PASSWORD -t 4 --afile="addresses.txt" 
```


- Solo mine using large memory pages 

```
./minerd -o 127.0.0.1:8589 -O username:password  --afile="addresses.txt" --largepages
```

## Pool Mining (Stratum)

- Connect to a mining pool using your wallet address:
- www.unicity-pool.com is a pool for testing


```
./minerd -o stratum+tcp://unicity-pool.com:3054 -u YOUR_WALLET_ADDRESS
```

- Pool mining with large pages:

```
./minerd -o stratum+tcp://unicity-pool.com:3054 -u YOUR_WALLET_ADDRESS --largepages
```

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
