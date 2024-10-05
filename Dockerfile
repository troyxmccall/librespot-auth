# Stage 1: Build the Rust application for macOS
FROM rust:slim-bullseye AS builder

# Install build dependencies for macOS cross-compilation
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    pkg-config \
    cmake \
    clang \
    lld \
    curl \
    && rustup target add x86_64-apple-darwin aarch64-apple-darwin

# Set the working directory
WORKDIR /usr/src/app

# Copy source code
COPY . .

# Build the application for macOS (Intel/AMD)
RUN cargo build --release --target x86_64-apple-darwin

# Build the application for macOS (ARM - Apple Silicon)
RUN cargo build --release --target aarch64-apple-darwin

# Stage 2: Create a minimal runtime environment
FROM alpine:latest

# Install necessary runtime dependencies (only if running the app inside a Linux container)
RUN apk add --no-cache ca-certificates

# Copy the macOS Rust binary for Intel/AMD from the builder stage
COPY --from=builder /usr/src/app/target/x86_64-apple-darwin/release/librespot-auth /usr/local/bin/librespot-auth-amd64

# Copy the macOS Rust binary for Apple Silicon/ARM from the builder stage
COPY --from=builder /usr/src/app/target/aarch64-apple-darwin/release/librespot-auth /usr/local/bin/librespot-auth-arm64

# Note: You cannot run these binaries in the container itself
# This container is only used to build and extract the binaries

# Optionally set the entry point if you'd like, but these binaries won't run in a Linux environment
ENTRYPOINT ["/bin/sh"]
