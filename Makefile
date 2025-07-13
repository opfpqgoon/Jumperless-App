.PHONY: clean packager_env Packager/constraints.txt app app_env package
# Base python interpreter
BASE_PYTHON=python3
# Packager venv vars
BUILDDST=./envs
ENV=$(BUILDDST)/.env
PYTHON=$(ENV)/bin/python
# Requirements files split into multiple for future
# package size minimization.
# Ideally PyInstaller would run in a venv with only the minimum
# packages required to build the executable
REQUIREMENTS=requirements.txt
REQUIREMENTS_TEST=requirements_test.txt
REQUIREMENTS_PACKAGER=requirements_packager.txt
REQUIREMENTS_ALL=requirements_all.txt
CONSTRAINTS=constraints.txt
# Constraints venv vars
CONST_ENV=$(BUILDDST)/.constraints_env
CONST_PYTHON=$(CONST_ENV)/bin/python

# Separate requirements and constraints files
# This allows for easier management of dependencies
# and ensures reproducible builds
# requirements.txt should only list versions if absolutely necessary
# constraints.txt is auto-generated and pins exact versions


app: env
	$(PYTHON) JumperlessWokwiBridge.py

black: env
	$(PYTHON) -m black .

env: $(ENV)/bin/activate
$(ENV)/bin/activate: $(REQUIREMENTS_ALL)
	rm -rf $(ENV)
	$(BASE_PYTHON) -m venv $(ENV)
	$(PYTHON) -m pip install --upgrade pip
	$(PYTHON) -m pip install -r $(REQUIREMENTS_ALL) -c $(CONSTRAINTS)
	touch $(ENV)/bin/activate

# Target to create constraints file
# Dependencies: requirements.txt
# Run `make constraints.txt` to update the versions of packages
# that will be used in the build environment
# This is useful when adding new packages or updating existing ones
$(CONSTRAINTS): $(REQUIREMENTS) $(REQUIREMENTS_PACKAGER) $(REQUIREMENTS_TEST)
	rm -rf $(CONST_ENV)
	$(BASE_PYTHON) -m venv $(CONST_ENV)
	$(CONST_PYTHON) -m pip install --upgrade pip
	$(CONST_PYTHON) -m pip install --no-input -U -r $(REQUIREMENTS_ALL)
	$(CONST_PYTHON) -m pip freeze > $(CONSTRAINTS)
	rm -rf $(CONST_ENV)

# Target to build the application
# Dependencies: env and constraints
package: env
	$(PYTHON) Packager/JumperlessAppPackager.py

# Target to clean up build artifacts
clean:
	rm -rf $(BUILDDST)
	rm -rf $(APP_ENV)
	rm -rf builds
	rm -rf build
	rm -rf dist
	rm -rf JumperlessFiles
