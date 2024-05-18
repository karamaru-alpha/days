include .env
GO_VERSION := $(shell grep -m 1 -o '[0-9]\+\.[0-9]\+\.[0-9]\+' go.mod)
export

.PHONY: install
install:
	go mod download
	go install golang.org/x/tools/cmd/goimports@v0.21.0
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.58.0

# e.g.) make image-build target=buf
.PHONY: image-rebuild
image-rebuild:
	docker compose build $(target)

.PHONY: run-db
run-db:
	docker compose up --build -d spanner-emulator

.PHONY: run-api
run-api: run-db
	go run cmd/api/main.go

.PHONY: buf-gen
buf-gen:
	docker compose run --rm --entrypoint sh buf ./scripts/buf-generate.sh
	make fmt

.PHONY: test
test:
	go test ./cmd/... ./pkg/...

.PHONY: lint
lint:
	golangci-lint run -v cmd/... pkg/... config/...

.PHONY: fmt
fmt:
	goimports -w -local "github.com/karamaru-alpha/days" pkg/
	gofmt -s -w pkg/
