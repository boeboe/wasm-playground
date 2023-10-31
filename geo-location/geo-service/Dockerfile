# Start from a Debian-based image with the Go tools installed
# to build our application.
FROM golang:1.21 as builder

# Set the working directory outside of the default GOPATH
# to enable Go modules.
WORKDIR /app

# Copy the Go Modules manifests and download the dependencies.
# This is done separately from copying the rest of the source code
# to leverage Docker cache and speed up subsequent builds.
COPY go.mod ./
COPY go.sum* ./
RUN go mod download

# Copy the rest of the source code.
COPY . .

# Build the Go app as a static binary.
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o geo-service .

# Start from a scratch image to create a minimal image.
FROM scratch

# Copy the binary from the builder stage.
COPY --from=builder /app/geo-service /geo-service

# Command to run the executable.
ENTRYPOINT ["/geo-service"]
