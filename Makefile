NODE_BIN=./node_modules/.bin
STYLUS=$(NODE_BIN)/stylus
HTTP_SERVER=$(NODE_BIN)/http-server
HTTP_PORT = 4242
R_JS=$(NODE_BIN)/r.js
BUILD_DIR=./build
INSTALL_URL=gavento@jabberwock.ucw.cz:/home/gavento/www/view/robo/

all: style build
.PHONY: all build start clean stylus

start:
	@echo '***  Serving at  http://0.0.0.0:$(HTTP_PORT)/  ***'
	$(HTTP_SERVER) ./ -p $(HTTP_PORT)

clean:
	rm -rf $(BUILD_DIR)
	rm -f build.txt

build:
	$(R_JS) -o build.js
	rm -f $(BUILD_DIR)/style/*.styl
	rm -fr $(BUILD_DIR)/app
	rm -f $(BUILD_DIR)/lib/[c]*.js
	rm -fr $(BUILD_DIR)/lib/spinelib/
	mv $(BUILD_DIR)/build.txt .

style:
	$(STYLUS) -I src/style < src/style/main.styl > src/style/main.css

install: clean style build
	rsync --rsh=ssh -rlvvzuO --exclude='*\~' "$(BUILD_DIR)/" "${INSTALL_URL}/" 

