.ONESHELL:
SHELL := /bin/bash

HAS_APT := $(shell if command -v apt > /dev/null 2>&1; then echo true; fi)
HAS_PACMAN := $(shell if command -v pacman > /dev/null 2>&1; then echo true; fi)
SUPPORTED := $(or $(HAS_APT), $(HAS_PACMAN))

all: distrocheck
	@make software
	@# Create venv
	@if [[ ! -d "venv" ]]; then echo "Creating venv..." && python3 -m venv venv && echo "Done";\
		else echo "venv already exists"; fi


ifneq ($(SUPPORTED), true)
distrocheck:
	@echo "Your distro is not supported. Please refer to manual installation." && exit 1
else
distrocheck:
	@:
endif

help: distrocheck
	@echo "Run 'make' to create the venv"
	@echo "Run 'make reqs' after sourcing the venv to install required modules"
	@echo "Run 'make install' install YTD"
	@echo "Run 'make uninstall' to uninstall YTD"

software: distrocheck
	@# Install pip, venv and ffmpeg
	@if [[ ! -f /usr/bin/pip3 ]]; then \
		echo "Installing python3-pip..."; \
		if [[ "$(HAS_APT)" == "true" ]]; then \
			sudo apt install -y python3-pip; \
		elif [[ "$(HAS_PACMAN)" == "true" ]]; then \
			sudo pacman -S --noconfirm --needed python-pip; \
		fi; \
	else \
		echo "pip3 is already installed"; \
	fi
	@if [[ ! -d /usr/lib/python$$(python3 -c "import platform; print(platform.python_version()[:-2])")/venv/ ]];\
		then echo "Installing python3-venv..."; \
		if [[ "$(HAS_APT)" == "true" ]]; then \
			sudo apt install -y python3-venv; \
		fi; \
	else \
		echo "venv is already installed"; \
	fi
	@if [[ ! -f /usr/bin/ffmpeg ]]; then \
		echo "Installing ffmpeg..."; \
		if [[ "$(HAS_APT)" == "true" ]]; then \
			sudo apt install -y ffmpeg; \
		elif [[ "$(HAS_PACMAN)" == "true" ]]; then \
			sudo pacman -S --noconfirm --needed ffmpeg; \
		fi; \
	else \
		echo "ffmpeg is already installed"; \
	fi

reqs: distrocheck
	@# Install required modules
	@if [[ -n "$$VIRTUAL_ENV" ]]; then \
		echo "Installing requirements into virtual environment..." && \
		python3 -m pip install yt-dlp && \
		echo "Done"; \
	else \
		echo "Error: No virtual environment is active."; \
	fi

# TODO: this should be done differently (where are the songs saved to, etc...)
install: distrocheck
	@make software
	@# TODO: this should differ for a system install
	@make reqs
	@echo "Creating an executable in .local/bin..."
	@# Make sure ~/.local/bin exists
	@mkdir -p ~/.local/bin
	@# Create an executable in .local/bin
	@./install.py
	@echo "YDT was successfully installed"

uninstall: distrocheck
	@# Delete the executable in .local/bin
	@if [[ -f ~/.local/bin/ytd ]]; then echo "Uninstalling YDT from .local/bin..." &&\
		rm -f ~/.local/bin/ytd && echo "YDT was successfully uninstalled"; fi

#################################### Run Tests ####################################################
container: distrocheck ## Build a docker container for testing
	@if ! command -v docker > /dev/null; then echo "Docker not found, install it first"; \
		elif [[ $$(docker images | grep ytdtest) ]]; then \
		echo 'Container "ytdtest" already exists'; else echo 'Building the "ytdtest" container' \
		&& docker build -t ytdtest . && echo "Built successfully"; fi

delcontainer: distrocheck
	@if [[ $$(docker images | grep ytdtest) ]]; then echo 'Deleting "ytdtest" container' && \
		docker image rm ytdtest:latest -f; \
		else echo 'Container "ytdtest" not found. Build it with \`make container\`.'; fi

rebuild: distrocheck delcontainer container ## Rebuild existing docker container

test: distrocheck ## Run the ytdtest container
	@if [[ $$(docker images | grep ytdtest) ]]; then docker run -it ytdtest; \
		else echo 'Container "ytdtest" not found. Build it with \`make container\`.'; fi

.PHONY: all distrocheck help software reqs install uninstall container delcontainer rebuild test
