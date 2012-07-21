NODE_BIN=./node_modules/.bin
STYLUS=$(NODE_BIN)/stylus
HTTP_SERVER=$(NODE_BIN)/http-server
HTTP_PORT = 4242
R_JS=$(NODE_BIN)/r.js
BUILD_DIR=./build

all: build style
.PHONY: all build start clean stylus

start:
	@echo '***  Serving at  http://0.0.0.0:$(HTTP_PORT)/  ***'
	$(HTTP_SERVER) ./ -p $(HTTP_PORT)

clean:
	rm -rf $(BUILD)/

build:
	$(R_JS) -o build.js
	rm -f $(BUILD)/style/*.styl
	rm -fr $(BUILD)/app
	rm -fr $(BUILD)/lib/[^srj]*
	mv $(BUILD)/build.txt .



style:
	$(STYLUS) -I src/style < src/style/main.styl > src/style/main.css
