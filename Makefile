CC=nim
CFLAGS=-d:release

compile:
	nim c src/gonim.nim
	mv src/gonim gonim

build:
	nim c -r src/gonim.nim
	mv src/gonim gonim

release:
	nim c -d:release src/gonim.nim 
	mv src/gonim gonim
