BINARY_NAME=carch-installer
VERSION?=1.0.0
BUILD_DIR=build
DIST_DIR=dist

GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod

LDFLAGS=-ldflags "-X main.version=$(VERSION) -s -w"

.PHONY: all build clean test deps dist install

all: clean deps build

build:
	@echo "Building $(BINARY_NAME)..."
	@mkdir -p $(BUILD_DIR)
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME) ./
	@echo "Build complete: $(BUILD_DIR)/$(BINARY_NAME)"

build-all:
	@echo "Building for multiple architectures..."
	@mkdir -p $(BUILD_DIR)

	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-linux-amd64 ./

	CGO_ENABLED=0 GOOS=linux GOARCH=arm64 $(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-linux-arm64 ./

	@echo "Multi-architecture build complete"

deps:
	@echo "Downloading dependencies..."
	$(GOMOD) download
	$(GOMOD) tidy

test:
	@echo "Running tests..."
	$(GOTEST) -v ./...

clean:
	@echo "Cleaning..."
	$(GOCLEAN)
	rm -rf $(BUILD_DIR)
	rm -rf $(DIST_DIR)

dist: build-all
	@echo "Creating distribution packages..."
	@mkdir -p $(DIST_DIR)

	tar -czf $(DIST_DIR)/$(BINARY_NAME)-$(VERSION)-linux-amd64.tar.gz -C $(BUILD_DIR) $(BINARY_NAME)-linux-amd64
	tar -czf $(DIST_DIR)/$(BINARY_NAME)-$(VERSION)-linux-arm64.tar.gz -C $(BUILD_DIR) $(BINARY_NAME)-linux-arm64

	@echo "Distribution packages created in $(DIST_DIR)/"

install: build
	@echo "Installing $(BINARY_NAME)..."
	sudo cp $(BUILD_DIR)/$(BINARY_NAME) /usr/local/bin/
	@echo "Installation complete. Run 'carch-installer --help' to get started."

uninstall:
	@echo "Uninstalling $(BINARY_NAME)..."
	sudo rm -f /usr/local/bin/$(BINARY_NAME)
	@echo "Uninstallation complete."

run: build
	@echo "Running $(BINARY_NAME)..."
	./$(BUILD_DIR)/$(BINARY_NAME)

help:
	@echo "Available targets:"
	@echo "  build      - Build the binary for current platform"
	@echo "  build-all  - Build for all supported platforms"
	@echo "  deps       - Download tidy dependencies"
	@echo "  test       - Run tests"
	@echo "  clean      - Clean build artifacts"
	@echo "  dist       - Create distribution packages"
	@echo "  install    - Install binary to system"
	@echo "  uninstall  - Remove binary from system"
	@echo "  run        - Build and run the binary"
	@echo "  help       - Show this help message"
