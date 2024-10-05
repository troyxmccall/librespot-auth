# Stage 1: Build the Rust application
FROM rust:alpine as builder

# Install dependencies
RUN apk add --no-cache build-base

# Create a new empty shell project and copy the current directory
WORKDIR /usr/src/app
COPY . .

# Build the Rust program in release mode
RUN cargo build --release

# Stage 2: Create a minimal Alpine runtime environment
FROM alpine:latest

# Install necessary runtime dependencies (if any, you can adjust as needed)
RUN apk add --no-cache ca-certificates

# Copy the Rust binary from the builder stage
COPY --from=builder /usr/src/app/target/release/librespot-auth /usr/local/bin/librespot-auth

# Set the binary as the entry point
ENTRYPOINT ["/usr/local/bin/librespot-auth -name \"Mopidy\" --class=computer"]

