# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
BINARY_MANAGER=jiaserver
BINARY_CLIENT=jiaclient
BINARY_MANAGER_UNIX=$(BINARY_MANAGER)_unix
BINARY_CLIENT_UNIX=$(BINARY_CLIENT)_unix
WORKDIR=./app
SERVERDIR=$(WORKDIR)/jiacrontab/server
CLIENTDIR=$(WORKDIR)/jiacrontab/client


.PHONY: all build test clean run build-linux build-windows
all: test build
build:
	mkdir $(WORKDIR)
	mkdir $(WORKDIR)/jiacrontab
	mkdir $(SERVERDIR)
	mkdir $(CLIENTDIR)
	cp server/server.ini $(SERVERDIR)
	cp -r server/template $(SERVERDIR)
	cp -r server/static $(SERVERDIR)
	cp client/client.ini $(CLIENTDIR)
	$(GOBUILD) -o $(BINARY_MANAGER) -v ./server
	$(GOBUILD) -o $(BINARY_CLIENT) -v ./client
	mv $(BINARY_MANAGER) $(SERVERDIR)
	mv $(BINARY_CLIENT) $(SERVERDIR)
test:
	$(GOTEST) -v ./server
	$(GOTEST) -v ./client
clean:
	$(GOCLEAN)
	rm -f $(BINARY_CLIENT_UNIX)
	rm -f $(BINARY_MANAGER_UNIX)
	rm -f $(BINARY_MANAGER)
	rm -f $(BINARY_CLIENT)
	rm -rf $(WORKDIR)
run:
	$(GOBUILD) -o $(BINARY_NAME) -v ./...
	./$(BINARY_NAME)


# Cross compilation
build-linux:
	mkdir $(WORKDIR)
	mkdir $(WORKDIR)/jiacrontab
	mkdir $(SERVERDIR)
	mkdir $(CLIENTDIR)
	cp server/server.ini $(SERVERDIR)
	cp -r server/template $(SERVERDIR)
	cp -r server/static $(SERVERDIR)
	cp client/client.ini $(CLIENTDIR)
	GOOS=linux GOARCH=amd64 $(GOBUILD) -o $(BINARY_MANAGER) -v ./server
	GOOS=linux GOARCH=amd64 $(GOBUILD) -o $(BINARY_CLIENT) -v ./client
	mv $(BINARY_MANAGER) $(SERVERDIR)
	mv $(BINARY_CLIENT) $(CLIENTDIR)

build-windows:
	mkdir $(WORKDIR)/jiacrontab
	mkdir $(SERVERDIR)
	mkdir $(CLIENTDIR)
	cp server/server.ini $(SERVERDIR)
	cp -r server/template $(SERVERDIR)
	cp -r server/static $(SERVERDIR)
	cp client/client.ini $(CLIENTDIR)
	GOOS=windows GOARCH=amd64 $(GOBUILD) -o $(BINARY_MANAGER).exe -v ./server
	GOOS=windows GOARCH=amd64 $(GOBUILD) -o $(BINARY_CLIENT).exe -v ./client

	mv $(BINARY_MANAGER).exe $(SERVERDIR)
	mv $(BINARY_CLIENT).exe $(CLIENTDIR)