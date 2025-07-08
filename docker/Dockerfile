FROM alpine:3.19.1 AS builder

# Build arguments
ARG VERSION="dev"
ARG GIT_COMMIT="unknown"
ARG BUILD_DATE="unknown"

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
    git \
    gmp-dev

# Install development dependencies for libcurl
RUN apk add --no-cache \
    curl-dev

# Copy alpha-miner source and build
WORKDIR /opt/alpha-miner
COPY . .
RUN ./autogen.sh
RUN ./configure
RUN make -j $(nproc)
RUN strip -s minerd

# Create minimal runtime image
FROM alpine:3.19.1

# Build arguments again for labeling
ARG VERSION="dev"
ARG GIT_COMMIT="unknown"
ARG BUILD_DATE="unknown"

# Add labels
LABEL org.opencontainers.image.title="Alpha Miner"
LABEL org.opencontainers.image.description="CPU miner for Alpha cryptocurrency"
LABEL org.opencontainers.image.version=$VERSION
LABEL org.opencontainers.image.revision=$GIT_COMMIT
LABEL org.opencontainers.image.created=$BUILD_DATE
LABEL org.opencontainers.image.vendor="Unicity Network"
LABEL org.opencontainers.image.url="https://github.com/unicitynetwork/alpha-miner"
LABEL org.opencontainers.image.licenses="GPL-3.0"

# Install runtime dependencies
RUN apk add --no-cache \
    coreutils \
    libcurl \
    libgcc \
    libstdc++ \
    gmp

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