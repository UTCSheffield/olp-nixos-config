all: client server

bin:
	mkdir -p ./bin

client: bin
	go build -o ./bin/client ./cmd/client

server: bin
	go build -o ./bin/server ./cmd/server

clean:
	rm -rf ./bin