FROM rust:latest AS builder
RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake pkg-config libssl-dev && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN git clone https://github.com/Mygod/slipstream-rust.git . && \
    git checkout bc772dd07d9a136dbd7553b0da575526de207847 && \
    git submodule update --init --recursive
RUN cargo build --release -p slipstream-server

FROM debian:bookworm-slim
RUN apt-get update && \
    apt-get install -y --no-install-recommends dante-server openssl ca-certificates && \
    rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/slipstream-server /usr/local/bin/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 53/udp
ENTRYPOINT ["/entrypoint.sh"]
