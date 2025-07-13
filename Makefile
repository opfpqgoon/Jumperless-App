.PHONY: clean env
BUILDDST=./build
ENV=$(BUILDDST)/.env
REQ_ENV=$(BUILDDST)/.constraints_env
BASE_PYTHON=python3
PYTHON=$(ENV)/bin/python
PIP=$(ENV)/bin/pip
REQ_PIP=$(REQ_ENV)/bin/pip
# Separate requirements and constraints files
# This allows for easier management of dependencies
# and ensures reproducible builds
# requirements.txt should only list versions if absolutely necessary
# constraints.txt is auto-generated and pins exact versions
REQUIREMENTS=Packager/packagerRequirements.txt
CONSTRAINTS=Packager/constraints.txt

# Target to create and set up the virtual environment
# Dependencies: requirements.txt and constraints.txt
env: $(ENV)/bin/activate
$(ENV)/bin/activate: $(REQUIREMENTS) $(CONSTRAINTS)
	$(BASE_PYTHON) -m venv $(ENV)
	$(PIP) install --upgrade pip
	$(PIP) install -r $(REQUIREMENTS) -c $(CONSTRAINTS)

# Target to create constraints file
# Dependencies: requirements.txt
# Run `make constraints.txt` to update the versions of packages
# that will be used in the build environment
# This is useful when adding new packages or updating existing ones
$(CONSTRAINTS): $(REQUIREMENTS)
	rm -rf $(REQ_ENV)
	$(BASE_PYTHON) -m venv $(REQ_ENV)
	$(REQ_PIP) install --upgrade pip
	$(REQ_PIP) install --no-input -U -r $(REQUIREMENTS)
	$(REQ_PIP) freeze > $(CONSTRAINTS)
	rm -rf $(REQ_ENV)

# Target to build the application
# Dependencies: env and constraints
package: env
	$(PYTHON) Packager/JumperlessAppPackager.py

# Target to clean up build artifacts
clean:
	rm -rf build
	rm -rf builds
