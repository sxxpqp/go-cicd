# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy go mod file
COPY go.mod ./

# Download dependencies (this will create/update go.sum)
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o main .

# Final stage
FROM alpine:latest

# Add ca-certificates for HTTPS requests if needed
RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy the binary from builder
COPY --from=builder /app/main .

# Change ownership to the non-root user
RUN chown appuser:appgroup main

# Switch to non-root user
USER appuser

# Expose port 8080
EXPOSE 8080

# Run the application
CMD ["./main"]