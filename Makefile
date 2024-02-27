CONFIG_PATH=${HOME}/.proglog/

.PHONY: init
init:
	mkdir -p ${CONFIG_PATH}

.PHONY: install
install:
	curl -LJO https://github.com/protocolbuffers/protobuf/releases/download/v3.18.0/protoc-3.18.0-linux-x86_64.zip \
			&& unzip protoc-3.18.0-linux-x86_64.zip -d ~/.local/bin/protobuf
	go install github.com/cloudflare/cfssl/cmd/cfssl@v1.6.4
	go install github.com/cloudflare/cfssl/cmd/cfssljson@v1.6.4
	go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2

.PHONY: gencert
gencert:
	cfssl gencert \
		-initca test/ca-csr.json | cfssljson -bare ca
	cfssl gencert \
		-ca=ca.pem \
		-ca-key=ca-key.pem \
		-config=test/ca-config.json \
		-profile=server \
		test/server-csr.json | cfssljson -bare server
	mv *.pem *.csr ${CONFIG_PATH}

.PHONY: compile
compile:
	protoc api/v1/*proto \
		--go_out="." \
		--go-grpc_out="." \
		--go_opt="paths=source_relative" \
		--go-grpc_opt="paths=source_relative" \
		--proto_path="."

.PHONY: test
test: 
	go test -v -race -buildvcs ./...

.PHONY: test_coverage
test_coverage:
	go test -v -race -buildvcs -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out

.PHONY: clean
clean:
	rm -rf bin tmp 
