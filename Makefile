
BIN ?= chserver
PREFIX ?= /usr/local

install:
	cp chserver.sh $(PREFIX)/bin/$(BIN)
	chmod +x $(PREFIX)/bin/$(BIN)

uninstall:
	rm -f $(PREFIX)/bin/$(BIN)
	