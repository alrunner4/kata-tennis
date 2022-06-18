IDRIS2 ?= idris2

test-results: build/exec/tests
	build/exec/tests | tee test-results

build/exec/tests: Main.idr tests.ipkg
	$(IDRIS2) --build tests.ipkg
