.PHONY: build lint run test test_watch

build:
	@luarocks make --local

run:
	@echo "Running"
	@echo "TODO"

test: build
	@busted
	#@rm -f ./luacov.stats.out
	#@luacov

test_watch:
	@ls **/*.lua | entr make test

lint:
	@luacheck src

