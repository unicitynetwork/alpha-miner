FROM alpine:3.19.1 AS builder

# Install build dependencies
RUN apk update && apk add --no-cache \
    binutils \
    cmake \
    make \
    libstdc++ \
    libgcc \
    musl-dev \
    gcc \
    g++ \
    pkgconfig \
    autoconf \
    automake \
    libtool \
    git

# Install curl dependencies
RUN apk add --no-cache mbedtls-dev mbedtls-static curl-dev curl-static zlib-static

# Download and build curl with static linking
RUN wget -c https://curl.se/download/curl-8.7.1.tar.gz -O - | tar -xz -C /opt/
WORKDIR /opt/curl-8.7.1
RUN autoreconf -fi
RUN ./configure --with-mbedtls --disable-shared --disable-ftp --disable-file \
    --disable-ldap --disable-ldaps --disable-rtsp --disable-dict --disable-telnet \
    --disable-tftp --disable-pop3 --disable-imap --disable-smb --disable-smtp \
    --disable-gopher --disable-sspi --disable-mqtt --disable-manual --disable-docs \
    --disable-ntlm --disable-largefile --without-libidn2 --disable-tls-srp \
    --disable-libcurl-option --disable-alt-svc --disable-headers-api --disable-verbose \
    --disable-ares --disable-aws --disable-netrc --without-brotli --without-nghttp2 \
    --without-libpsl --without-zstd
RUN make -j $(nproc) install

# Copy alpha-miner source and build
WORKDIR /opt/alpha-miner
COPY . .
RUN ./autogen.sh
RUN LDFLAGS="-static -static-libgcc" ./configure
RUN make -j $(nproc)
RUN strip -s minerd

# Create minimal runtime image
FROM alpine:3.19.1

# Install runtime dependencies
RUN apk add --no-cache coreutils

# Create a non-root user to run the miner
RUN adduser -D miner

# Copy the helper scripts
COPY docker/entrypoint.sh /usr/local/bin/
COPY docker/detect_cpus.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/detect_cpus.sh

# Copy the built binary from the builder stage
COPY --from=builder /opt/alpha-miner/minerd /usr/local/bin/

# Switch to non-root user
USER miner
WORKDIR /home/miner

# Set entrypoint to our script - will use default args if none provided
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]