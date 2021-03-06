FROM ghcr.io/jrcichra/sccache-rust:sha-240e206 as builder
ARG SCCACHE_BUCKET
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG SCCACHE_REGION
ARG SCCACHE_ENDPOINT
ARG RUSTC_WRAPPER
ARG SCCACHE_LOG
ARG SCCACHE_ERROR_LOG
WORKDIR /usr/src/app
RUN apt-get update && apt-get install -y pkg-config libssl-dev ca-certificates && rm -rf /var/lib/apt/lists/*
COPY . .
RUN (touch /tmp/sccache_log.txt && tail -f /tmp/sccache_log.txt &) && printenv && cargo build --release -j8

FROM debian:bullseye-20220711-slim
RUN apt-get update && apt-get install -y pkg-config libssl-dev ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/src/app/target/release/email-fanout /email-fanout
ENTRYPOINT ["/email-fanout"]
