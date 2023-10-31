# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

.PHONY: build lint test run release clean docker-build docker-run docker-stop docker-release 

# Binary name for the application
BINARY_NAME=geo-service
BUILD_DIR=./build

# Docker parameters
DOCKER_IMAGE_NAME=boeboe/geo-service
DOCKER_IMAGE_VERSION=v1.0.0
DOCKER_CONTAINER_NAME=geo-service

# GitHub parameters
GITHUB_REPO=boeboe/wasm-playground
GITHUB_RELEASE_VERSION=v1.0.0

build: ## Build the binary
	@mkdir -p $(BUILD_DIR)
	go build -o $(BUILD_DIR)/$(BINARY_NAME) -v

lint: ## Lint the code
	golint ./...

test: ## Run unit tests
	go test -v ./...

run: ## Run the application
	go run main.go

release: ## Release the application on github release section
	gh release create $(GITHUB_RELEASE_VERSION) $(BUILD_DIR)/$(BINARY_NAME) -R $(GITHUB_REPO) -t $(GITHUB_RELEASE_VERSION) -n "Release $(GITHUB_RELEASE_VERSION)"

clean: ## Clean the build directory
	rm -rf $(BUILD_DIR)/*

docker-build: ## Build the docker image
	docker build -t $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION) .
	docker tag $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION) $(DOCKER_IMAGE_NAME):latest

docker-run: ## Run the docker image
	docker run -d --name $(DOCKER_CONTAINER_NAME) $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)

docker-stop: ## Stop the docker image
	docker stop $(DOCKER_CONTAINER_NAME)
	docker rm $(DOCKER_CONTAINER_NAME)

docker-release: ## Release the docker image on docker hub
	docker push $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)
	docker push $(DOCKER_IMAGE_NAME):latest

