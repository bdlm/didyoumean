GOCMD=go
GOBIN=bin
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test pkg/...
BINARY_NAME=didyoumean

all: clean build
build: build-linux-64 build-darwin-64
clean:
	$(GOCLEAN)
	rm -f $(GOBIN)/linux-amd64/$(BINARY_NAME)-linux-amd64
	rm -f $(GOBIN)/linux-amd64/$(BINARY_NAME)-darwin-amd64
run:
	$(GOBUILD) -o $(BINARY_NAME) -v ./...
	./$(BINARY_NAME)

# Target architectures
build-linux-64:
	CGO_ENABLED=0 GOARCH=amd64 GOOS=linux  $(GOBUILD) -o $(GOBIN)/linux-amd64/$(BINARY_NAME) ./cmd/didyoumean/
build-darwin-64:
	CGO_ENABLED=0 GOARCH=amd64 GOOS=darwin $(GOBUILD) -o $(GOBIN)/darwin-amd64/$(BINARY_NAME) ./cmd/didyoumean/
