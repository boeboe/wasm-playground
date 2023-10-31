FROM golang:1.21-alpine AS builder

RUN apk --no-cache add ca-certificates
WORKDIR /app
COPY go.mod ./
COPY go.sum* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o geo-service .


FROM scratch

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /app/geo-service /geo-service
ENTRYPOINT ["/geo-service"]
