REBAR3   := ./rebar3
BIN      := _build/default/bin/sg
INSTALL  := $(HOME)/.local/bin/sg

.PHONY: all build install uninstall check clean

all: build

## Build the sg escript binary
build:
	$(REBAR3) compile

## Install sg for the current user (~/.local/bin/sg)
install: build
	cp $(BIN) $(INSTALL)
	chmod +x $(INSTALL)
	@echo "Installed: $(INSTALL)"
	@echo "Make sure $(HOME)/.local/bin is in your PATH."

## Remove the installed binary
uninstall:
	rm -f $(INSTALL)
	@echo "Removed: $(INSTALL)"

## Syntax-check all .sg files under examples/
check:
	@find examples -name '*.sg' | while read f; do \
	    $(BIN) check "$$f" && echo "ok  $$f" || echo "ERR $$f"; \
	done

## Remove build artefacts
clean:
	$(REBAR3) clean
	rm -rf _build erl_crash.dump
