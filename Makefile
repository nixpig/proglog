compile:
	protoc api/v1/*proto \
		--go_out="." \
		--go-grpc_out="." \
		--go_opt="paths=source_relative" \
		--go-grpc_opt="paths=source_relative" \
		--proto_path="."

.PHONY: test
test: export APP_ENV=test
test: 
	go test -v -race -buildvcs ./...

.PHONY: test_coverage
test_coverage:
	go test -v -race -buildvcs -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out

clean:
	rm -rf bin tmp 
