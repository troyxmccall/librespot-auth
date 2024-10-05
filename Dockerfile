# Stage 1: Build the Rust application
FROM rust:alpine AS builder

# Install build dependencies
RUN apk add --no-cache musl-dev

# Set the working directory
WORKDIR /usr/src/app

# Copy source code
COPY . .

# Build the application
RUN cargo build --release

# Stage 2: Create a minimal Alpine runtime environment
FROM alpine:latest

# Install necessary runtime dependencies
RUN apk add --no-cache ca-certificates

# Copy the Rust binary from the builder stage
COPY --from=builder /usr/src/app/target/release/librespot-auth /usr/local/bin/librespot-auth

# Set the entry point
ENTRYPOINT ["/usr/local/bin/librespot-auth"]
