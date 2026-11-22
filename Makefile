BIN := bin/sync-9router-opencode
PREFIX ?= /usr/local

.PHONY: check help install clean

check:
	node --check $(BIN)

help:
	node $(BIN) --help

install: check
	install -m 0755 $(BIN) $(PREFIX)/bin/sync-9router-opencode
	@echo "Installed to $(PREFIX)/bin/sync-9router-opencode"

clean:
	rm -f .9router-sync-cache.json .9router-sync-state.json
