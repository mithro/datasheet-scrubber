# Makefile to setting up a self contained conda environment.
CONDA_PATH ?= $(PWD)/env
export PATH := $(CONDA_PATH)/bin:$(PATH)

$(CONDA_PATH):
	make -p $(CONDA_PATH)

$(CONDA_PATH)/Miniconda3-latest-Linux-x86_64.sh: $(CONDA_PATH)
	wget -c https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O .Miniconda3-latest-Linux-x86_64.sh
	mv -f .Miniconda3-latest-Linux-x86_64.sh Miniconda3-latest-Linux-x86_64.sh

$(CONDA_PATH)/bin/conda: $(CONDA_PATH)/Miniconda3-latest-Linux-x86_64.sh $(CONDA_PATH)
	chmod a+x Miniconda3-latest-Linux-x86_64.sh
	$(CONDA_PATH)/Miniconda3-latest-Linux-x86_64.sh -p $(CONDA_PATH) -b

$(CONDA_PATH)/.condarc: conda.mk $(CONDA_PATH)
	conda config --system --set always_yes yes --set changeps1 no
	conda config --system --add channels timvideos

$(CONDA_PATH)/bin/%: $(CONDA_PATH)/bin/conda $(CONDA_PATH)/.condarc $(CONDA_PATH)
	conda install $(shell basename $@)

$(CONDA_PATH)/.modules/%: $(CONDA_PATH)/bin/conda $(CONDA_PATH)/.condarc $(CONDA_PATH)
	mkdir -p $(shell dirname $@)
	pip install $(shell basename $@)
	touch $@

PYTHON_MODULES = pyusb pep8 autopep8 setuptools-pep8

DEPS := \
	$(foreach P,$(PYTHON_PACKAGES),$(CONDA_PATH)/.modules/$(P)) \
	$(foreach P,$(CONDA_PACKAGES),$(CONDA_PATH)/bin/$(P))

env:
	make check-env || @true

check-env:
	[ -d $(CONDA_PATH) ]

clean-env:
	rm -rf $(CONDA_PATH)

update:
	# Check for clean git tree
	# Capture the current revision info
	# Get latest head from the conda-mk remote
	@git remote rm conda || true
	git remote add conda https://github.com/mithro/conda-mk.git
	git fetch conda
	# Start the merge
	git merge conda/master \
		--no-commit \
		--quiet
	# Reset everything apart from the conda.mk file
	git checkout 
	# Commit
	git commit --message "Updating conda.mk file"

.PHONY: check-env clean-env
