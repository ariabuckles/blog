.PHONY: all create_build_dir build perseus_dev_tools build_ke build_perseus npm_install clean

all: install build

AL_COMPILER = ./node_modules/.bin/alc
AL_SOURCE_FILES := $(wildcard src/*.al)
AL_OUTPUT_FILES := $(AL_SOURCE_FILES:src/%.al=build/%.js)

install: npm_install build_ke build_perseus

npm_install:
	npm install

build: create_build_dir $(AL_OUTPUT_FILES)

create_build_dir:
	mkdir -p build

perseus_dev_tools:
	cd node_modules/perseus && npm install

build_perseus: create_build_dir node_modules/perseus
	cd node_modules/perseus && make build
	cp node_modules/perseus/build/perseus-0.js build/perseus.js
	cp node_modules/perseus/build/perseus-0.css build/perseus.css
	rm -rf build/perseus/
	cp -R node_modules/perseus/lib build/perseus/

build_ke: create_build_dir perseus_dev_tools node_modules/perseus
	cd node_modules/khan-exercises && ../perseus/node_modules/.bin/r.js -o requirejs.config.js out=../../build/ke.js

$(AL_OUTPUT_FILES): build/%.js: src/%.al node_modules
	$(AL_COMPILER) $< $@

clean:
	rm -rf $(AL_OUTPUT_FILES)
