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

## Linux

### Ubuntu/Debian

#### Install dependencies
```bash
sudo apt update
sudo apt upgrade
sudo apt install autoconf git build-essential pkg-config libcurl4-openssl-dev
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
pacman -S git autoconf pkgconf automake make mingw-w64-ucrt-x86_64-curl mingw-w64-ucrt-x86_64-gcc
```

### Build instructions (for running in MSYS2)

To build a native Windows application which must run in a MSYS2 terminal.
In MSYS2 terminal:

```
git clone https://github.com/unicitynetwork/alpha-miner --recursive
cd alpha-miner
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
- www.nopoolnogain.net community operated pool


```
./minerd -o stratum+tcp://unicity-pool.com:3054 -u YOUR_WALLET_ADDRESS
```

- Pool mining with large pages:

```
./minerd -o stratum+tcp://unicity-pool.com:3054 -u YOUR_WALLET_ADDRESS --largepages
```

## Docker

### Using Pre-built Docker Image

The official Docker image is available at `ghcr.io/unicitynetwork/alpha-miner:latest`. You can use it directly without building:

#### Solo Mining with Docker

```bash
docker run --rm --name alpha-miner \
  --cpus=1 \
  --add-host=host.docker.internal:host-gateway \
  -v $(pwd)/addrs.txt:/home/miner/addrs.txt \
  ghcr.io/unicitynetwork/alpha-miner:latest \
  -o 'host.docker.internal:8589' \
  -O user:password \
  --largepages \
  --no-affinity
```

**Docker arguments explained:**
- `--rm`: Automatically remove the container when it stops
- `--name alpha-miner`: Give the container a name for easy management
- `--cpus=1`: Limit the container to use 1 CPU core (adjust as needed)
- `--add-host=host.docker.internal:host-gateway`: Allow the container to connect to services on the host machine
- `-v $(pwd)/addrs.txt:/home/miner/addrs.txt`: Mount your local addresses file into the container

**Miner arguments explained:**
- `-o 'host.docker.internal:8589'`: Connect to Alpha node on host machine port 8589
- `-O user:password`: RPC credentials (replace with your actual credentials from alpha.conf)
- `--largepages`: Enable large memory pages for ~2x performance improvement
- `--no-affinity`: Disable CPU affinity (recommended for containers)

#### Pool Mining with Docker

```bash
docker run --rm --name alpha-pool-miner \
  --cpus=1 \
  --add-host=host.docker.internal:host-gateway \
  ghcr.io/unicitynetwork/alpha-miner:latest \
  -o 'stratum+tcp://unicity-pool.com:3054' \
  -u YOUR_ADDRESS \
  -t 1 \
  --largepages \
  --no-affinity
```

**Additional arguments for pool mining:**
- `-u alpha1qek8v...`: Your wallet address for receiving mining rewards
- `-t 1`: Number of mining threads (should match --cpus value)

### Building Docker Image Locally

If you want to build the Docker image yourself:

```bash
# Clone the repository with submodules
git clone https://github.com/unicitynetwork/alpha-miner --recursive
cd alpha-miner

# Build the Docker image
docker build -t alpha-miner ./docker

# Run your locally built image
docker run --rm --name alpha-miner alpha-miner [miner arguments]
```

### Docker Tips

1. **CPU Allocation**: Adjust `--cpus` to control how many CPU cores the miner uses
2. **Running in Background**: Add `-d` flag to run the container in detached mode
3. **View Logs**: Use `docker logs alpha-miner` to see miner output
4. **Stop Mining**: Use `docker stop alpha-miner` to gracefully stop the container
5. **Large Pages**: The container needs appropriate privileges for large pages to work effectively
