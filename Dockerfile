# Stage 1: Build electrs with liquid feature
FROM rust:1.82-bookworm AS builder

RUN apt-get update && apt-get install -y \
    clang \
    cmake \
    libsnappy-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Clone Blockstream's electrs fork
ARG ELECTRS_VERSION=new-index
RUN git clone --branch ${ELECTRS_VERSION} --depth 1 \
    https://github.com/Blockstream/electrs.git .

# Apply compact headers patch to reduce RAM usage during sync
COPY compact-headers.patch /build/
RUN git apply compact-headers.patch

# Build with liquid feature
RUN cargo build --locked --features liquid --release --bin electrs

# Stage 2: Minimal runtime image
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    libsnappy1v5 \
    && rm -rf /var/lib/apt/lists/* \
    && adduser --disabled-password --uid 1000 --home /data electrs

COPY --from=builder /build/target/release/electrs /usr/local/bin/electrs

USER electrs

EXPOSE 60601

STOPSIGNAL SIGINT

ENTRYPOINT ["electrs"]
