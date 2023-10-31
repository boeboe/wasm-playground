# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

.PHONY: build lint test run release clean docker-build docker-run docker-stop docker-release 

BINARY_NAME            := geo-service
BUILD_DIR              := ./output
CMD_ARGS               := --interval 5 --download-folder ${BUILD_DIR} --daemon true
DOCKER_CONTAINER_NAME  := geo-service
DOCKER_IMAGE_NAME      := boeboe/geo-service
DOCKER_IMAGE_VERSION   ?= v1.0.0
GITHUB_RELEASE_VERSION ?= v1.0.0
GITHUB_REPO            := boeboe/wasm-playground

LINTER := github.com/golangci/golangci-lint/cmd/golangci-lint@v1.54.2
lint: ## Lint the code
	@echo "Running linter..."
	@go run $(LINTER) run --verbose ./...

test: ## Run unit tests
	@echo "Running tests..."
	@go test -v ./...

build: lint test ## Build the binary
	@mkdir -p $(BUILD_DIR)
	@go build -o $(BUILD_DIR)/$(BINARY_NAME) -v
	GOOS=linux GOARCH=amd64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-linux-x86_64 .
	GOOS=linux GOARCH=arm64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-linux-arm64 .
	GOOS=windows GOARCH=amd64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-windows-amd64.exe .
	GOOS=darwin GOARCH=amd64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-macos-amd64 .
	GOOS=darwin GOARCH=arm64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-macos-arm64 .

run: ## Run the application
	go run main.go $(CMD_ARGS)

release: build ## Release the application on github release section
	gh release create $(GITHUB_RELEASE_VERSION) \
		$(BUILD_DIR)/$(BINARY_NAME) \
		$(BUILD_DIR)/$(BINARY_NAME)-linux-x86_64 \
		$(BUILD_DIR)/$(BINARY_NAME)-linux-arm64 \
		$(BUILD_DIR)/$(BINARY_NAME)-windows-amd64.exe \
		$(BUILD_DIR)/$(BINARY_NAME)-macos-amd64 \
		$(BUILD_DIR)/$(BINARY_NAME)-macos-arm64 \
		--repo $(GITHUB_REPO) --title $(GITHUB_RELEASE_VERSION) --notes "Release $(BINARY_NAME) $(GITHUB_RELEASE_VERSION)"

clean: ## Clean the build directory
	rm -rf $(BUILD_DIR)/*

docker-build: ## Build the docker image
	docker build -t $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION) .
	docker tag $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION) $(DOCKER_IMAGE_NAME):latest

docker-run: ## Run the docker image
	docker run -d --name $(DOCKER_CONTAINER_NAME) -v $(BUILD_DIR):/output $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION) /$(BINARY_NAME) $(CMD_ARGS)

docker-stop: ## Stop the docker image
	docker stop $(DOCKER_CONTAINER_NAME)
	docker rm $(DOCKER_CONTAINER_NAME)

docker-release: docker-build ## Release the docker image on docker hub
	docker push $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)
	docker push $(DOCKER_IMAGE_NAME):latest
