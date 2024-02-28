CONFIG_PATH=${HOME}/.proglog/

.PHONY: init
init:
	mkdir -p ${CONFIG_PATH}

.PHONY: install
install:
	go install github.com/cloudflare/cfssl/cmd/cfssl@v1.6.4
	go install github.com/cloudflare/cfssl/cmd/cfssljson@v1.6.4
	go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2

.PHONY: gencert
gencert:
	# generate certificate authority cert files
	cfssl gencert \
		-initca test/ca-csr.json | cfssljson -bare ca
	# generate server cert files
	cfssl gencert \
		-ca=ca.pem \
		-ca-key=ca-key.pem \
		-config=test/ca-config.json \
		-profile=server \
		test/server-csr.json | cfssljson -bare server
	# generate client cert files
	cfssl gencert \
		-ca=ca.pem \
		-ca-key=ca-key.pem \
		-config=test/ca-config.json \
		-profile=client \
		test/client-csr.json | cfssljson -bare client
	# move cert files to config path
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
