VENV           = venv

ifeq ($(OS),Windows_NT) 
    detected_OS := Windows
	SYSTEM_PYTHON  = $(or $(where.exe python3), $(where.exe python))
else
    detected_OS := $(shell sh -c 'uname 2>/dev/null || echo Unknown')
	SYSTEM_PYTHON  = $(or $(shell which python3), $(shell which python))
endif

PYTHON         = $(or $(wildcard venv/bin/python), $(SYSTEM_PYTHON))

.PHONY: docs

venv-build: venv-create
	$(PYTHON) -m pip install -r src/python/requirements.txt
	$(PYTHON) -m pip install -e src/python/.

venv-create:
	ifeq ($(detected_OS),Windows)
		rm -Recurse -Force $(VENV)
	else
		rm -rf $(VENV)
	endif
	$(SYSTEM_PYTHON) -m virtualenv $(VENV)

venv-up:
	bash -c "source $(VENV)/bin/activate && jupyter lab"

test:
	$(PYTHON) -m pytest -s -vv --pyargs vimure

docs: 
	Rscript -e 'vimure::install_vimure(version="src/python/");setwd("src/R");pkgdown::build_site()'
	git add docs && git commit -m "Update docs"
	git push origin `git subtree split --prefix docs develop`:gh-pages --force
	rm -rf docs/