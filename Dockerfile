# RUST + CARGO-CHEF
FROM rust:alpine as builder_base
RUN apk add --no-cache musl-dev
RUN cargo install cargo-chef --locked
WORKDIR /usr/src/rustdesk-server

# PLANNER
FROM builder_base AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

# BUILDER
FROM builder_base as builder

# Copy recipe.json
COPY --from=planner /usr/src/rustdesk-server/recipe.json recipe.json
# Install build dependencies
RUN apk add --no-cache file make
# Build dependencies
RUN cargo chef cook --release --recipe-path recipe.json
# Build application
COPY . .
RUN cargo build --release

# HBBS server
FROM alpine:latest AS hbbr
COPY --from=builder /usr/src/rustdesk-server/target/release/hbbr /usr/local/bin/hbbr
ENTRYPOINT ["/usr/local/bin/hbbr"]

# HBBS server
FROM alpine:latest AS hbbs
COPY --from=builder /usr/src/rustdesk-server/target/release/hbbs /usr/local/bin/hbbs
ENTRYPOINT ["/usr/local/bin/hbbs"]