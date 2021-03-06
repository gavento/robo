NODE_BIN=./node_modules/.bin

STYLUS=$(NODE_BIN)/stylus
R_JS=$(NODE_BIN)/r.js
DOCKER=$(NODE_BIN)/docker
COFFEE=$(NODE_BIN)/coffee
COFFEELINT=$(NODE_BIN)/coffeelint
HTTP_SERVER=$(NODE_BIN)/http-server

HTTP_PORT=4242
#HTTP_PORT=80
#IP=77.93.202.43
IP=0.0.0.0
BUILD_DIR=./build
INSTALL_URL=gavento@jabberwock.ucw.cz:/home/gavento/www/view/robo/

all: build docs
.PHONY: all build start clean stylus docs tests

start:
	@echo '***  Serving at  http:$(IP):$(HTTP_PORT)/  ***'
	$(COFFEE) ./src/server/server.coffee $(HTTP_PORT)

clean:
	rm -rf $(BUILD_DIR)
	rm -f build.txt

build:
	$(R_JS) -o build.js
	rm -fr $(BUILD_DIR)/style/
	rm -fr $(BUILD_DIR)/app/
	rm -fr $(BUILD_DIR)/server/
	rm -f $(BUILD_DIR)/lib/cs.js
	rm -f $(BUILD_DIR)/lib/coffee-script.js
	$(COFFEE) --compile --output $(BUILD_DIR)/server/ src/server/
	mv $(BUILD_DIR)/build.txt .

docs:
	$(DOCKER) --input_dir src/ --exclude lib --output_dir $(BUILD_DIR)/docs

tests:
	$(COFFEE) -c test/

lint:
	$(COFFEELINT) -f coffeelint.json -r ./src ./test

install: clean style build
	rsync --rsh=ssh -rlvvzuO --exclude='*\~' "$(BUILD_DIR)/" "${INSTALL_URL}/" 

