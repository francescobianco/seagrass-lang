TOOLCHAIN_FILE := .seagrass-toolchain.mk

-include $(TOOLCHAIN_FILE)

ERL      ?= erl
REBAR3   ?= rebar3
TOOLCHAIN_PATH_PREFIX ?=
DEFAULT_OTP_BIN := /usr/lib/erlang/bin
BIN      := _build/default/bin/sg
INSTALL  := $(HOME)/.local/bin/sg

.PHONY: all build install uninstall check clean dev-ubuntu verify-toolchain

all: build

## Build the sg escript binary
build:
	@env PATH="$(if $(TOOLCHAIN_PATH_PREFIX),$(TOOLCHAIN_PATH_PREFIX):)$$PATH" $(REBAR3) compile

## Install sg for the current user (~/.local/bin/sg)
install: build
	mkdir -p $(dir $(INSTALL))
	cp $(BIN) $(INSTALL)
	chmod +x $(INSTALL)
	@echo "Installed: $(INSTALL)"
	@echo "Make sure $(HOME)/.local/bin is in your PATH."

## Prepare a Ubuntu development environment with system packages
dev-ubuntu:
	sudo apt update
	sudo apt install -y git make curl erlang rebar3
	@printf '%s\n' \
		'ERL := /usr/bin/erl' \
		'REBAR3 := /usr/bin/rebar3' \
		'TOOLCHAIN_PATH_PREFIX := $(DEFAULT_OTP_BIN):/usr/bin' \
		> $(TOOLCHAIN_FILE)
	@$(MAKE) verify-toolchain
	@echo "Ubuntu development environment ready."
	@echo "Pinned project toolchain: $(TOOLCHAIN_FILE)"
	@echo "This repository will now use the Ubuntu system toolchain."

## Verify that Erlang + rebar3 can actually build this project
verify-toolchain:
	@set -eu; \
	ERL_BIN="$$(command -v "$(ERL)" 2>/dev/null || true)"; \
	REBAR3_BIN="$$(command -v "$(REBAR3)" 2>/dev/null || true)"; \
	if [ -z "$$ERL_BIN" ]; then \
		echo "toolchain check failed: '$(ERL)' not found in PATH"; \
		echo "This machine cannot build Seagrass."; \
		exit 1; \
	fi; \
	if [ -z "$$REBAR3_BIN" ]; then \
		echo "toolchain check failed: '$(REBAR3)' not found in PATH"; \
		echo "This machine cannot build Seagrass."; \
		exit 1; \
	fi; \
	echo "Detected erl binary: $$ERL_BIN"; \
	echo "Detected rebar3 binary: $$REBAR3_BIN"; \
	if [ -n "$(TOOLCHAIN_PATH_PREFIX)" ]; then \
		echo "Using PATH prefix: $(TOOLCHAIN_PATH_PREFIX)"; \
	fi; \
	OTP="$$("$$ERL_BIN" -noshell -eval 'io:format("~s", [erlang:system_info(otp_release)]), halt().' 2>/dev/null || true)"; \
	if [ -z "$$OTP" ]; then \
		echo "toolchain check failed: unable to detect Erlang/OTP release"; \
		echo "This machine cannot build Seagrass."; \
		exit 1; \
	fi; \
	echo "Detected Erlang/OTP: $$OTP"; \
	if [ -x /usr/bin/erl ]; then \
		SYS_OTP="$$(/usr/bin/erl -noshell -eval 'io:format("~s", [erlang:system_info(otp_release)]), halt().' 2>/dev/null || true)"; \
		if [ -n "$$SYS_OTP" ]; then \
			echo "Detected system Erlang/OTP: $$SYS_OTP (/usr/bin/erl)"; \
		fi; \
	fi; \
	if [ -x /usr/bin/rebar3 ]; then \
		echo "Detected system rebar3: /usr/bin/rebar3"; \
	fi; \
	if ! env PATH="$(if $(TOOLCHAIN_PATH_PREFIX),$(TOOLCHAIN_PATH_PREFIX):)$$PATH" "$$REBAR3_BIN" version >/dev/null 2>&1; then \
		echo "toolchain check failed: '$(REBAR3) version' did not run successfully"; \
		echo "This usually means rebar3 is incompatible with the installed Erlang/OTP."; \
		if [ -n "$${SYS_OTP:-}" ] && [ "$$OTP" != "$$SYS_OTP" ]; then \
			echo "PATH mismatch detected: 'erl' resolves to OTP $$OTP, but /usr/bin/erl is OTP $$SYS_OTP."; \
			echo "Your shell is not using the same Erlang that Ubuntu packages installed."; \
		fi; \
		echo "This machine cannot build Seagrass."; \
		exit 1; \
	fi; \
	echo "Detected rebar3: $$(env PATH=\"$(if $(TOOLCHAIN_PATH_PREFIX),$(TOOLCHAIN_PATH_PREFIX):)\$$PATH\" "$$REBAR3_BIN" version 2>/dev/null | head -n 1)"; \
	if ! env PATH="$(if $(TOOLCHAIN_PATH_PREFIX),$(TOOLCHAIN_PATH_PREFIX):)$$PATH" "$$REBAR3_BIN" compile >/dev/null 2>rebar3.crashdump.tmp; then \
		echo "toolchain check failed: '$(REBAR3) compile' failed"; \
		if [ -s rebar3.crashdump.tmp ]; then \
			cat rebar3.crashdump.tmp; \
		fi; \
		rm -f rebar3.crashdump.tmp; \
		if [ -n "$${SYS_OTP:-}" ] && [ "$$OTP" != "$$SYS_OTP" ]; then \
			echo "PATH mismatch detected: 'erl' resolves to OTP $$OTP, but /usr/bin/erl is OTP $$SYS_OTP."; \
			echo "Your shell is not using the same Erlang that Ubuntu packages installed."; \
		fi; \
		echo "This machine cannot build Seagrass."; \
		exit 1; \
	fi; \
	rm -f rebar3.crashdump.tmp; \
	echo "Toolchain OK: this machine can build Seagrass."

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
	@env PATH="$(if $(TOOLCHAIN_PATH_PREFIX),$(TOOLCHAIN_PATH_PREFIX):)$$PATH" $(REBAR3) clean
	rm -rf _build erl_crash.dump
