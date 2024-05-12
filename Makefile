.ONESHELL:
SHELL := /bin/bash

OS := $(shell awk -F= '$$1=="ID" { print $$2 ;}' /etc/os-release)

all:
	@if [[ $(OS) != "ubuntu"  ]]; then \
		echo "Ubuntu is the only supported distro. Please refer to manual installation." && exit 0; fi

	@make software
	@# Create venv
	@if [[ ! -d "venv" ]]; then echo "Creating venv..." && python3 -m venv venv && echo "Done";\
		else echo "venv already exists"; fi

help:
	@echo "Supported Distros: Ubuntu"
	@echo "Run 'make' to create the venv"
	@echo "Run 'make reqs' after sourcing the venv to install modules using requirements.txt"
	@echo "Run 'make install' install YTD"
	@echo "Run 'make uninstall' to uninstall YTD"

software:
	@if [[ $(OS) == "ubuntu"  ]]; then \
		echo "Ubuntu is the only supported distro. Please refer to manual installation." && exit 0; fi

	@# Install pip, venv and ffmpeg
	@if [[ ! -f /usr/bin/pip3 ]]; then echo "Installing python3-pip..." && sudo apt install python3-pip -y;\
		else echo "pip3 is already installed"; fi
	@if [[ ! -d /usr/lib/python$$(python3 -c "import platform; print(platform.python_version()[:-2])")/venv/ ]];\
		then echo "Installing python3-venv..." && sudo apt install python3-venv -y;\
		else echo "venv is already installed"; fi
	@if [[ ! -f /usr/bin/ffmpeg ]]; then echo "Installing ffmpeg..." && sudo apt install ffmpeg -y;\
		else echo "ffmpeg is already installed"; fi

reqs:
	@if [[ $(OS) != "ubuntu"  ]]; then \
		echo "Ubuntu is the only supported distro. Please refer to manual installation." && exit 0; fi

	@# Install required modules
	@echo "Installing requirements..."
	@python3 -m pip install git+https://github.com/pytube/pytube
	@echo "Done"

install:
	@if [[ $(OS) != "ubuntu"  ]]; then \
		echo "Ubuntu is the only supported distro. Please refer to manual installation." && exit 0; fi

	@make software
	@make reqs
	@echo "Creating an executable in .local/bin..."
	@# Make sure ~/.local/bin exists
	@mkdir -p ~/.local/bin
	@# Create an executable in .local/bin
	@./install.py
	@echo "YDT was successfully installed"

uninstall:
	@# Delete the executable in .local/bin
	@if [[ -f ~/.local/bin/ytd ]]; then echo "Uninstalling YDT from .local/bin..." &&\
		rm -f ~/.local/bin/ytd && echo "YDT was successfully uninstalled"; fi

#################################### Run Tests ####################################################
container: ## Build a docker container for testing
	@if ! command -v docker > /dev/null; then echo "Docker not found, install it first"; \
		elif [[ $$(docker images | grep ytdtest) ]]; then \
		echo 'Container "ytdtest" already exists'; else echo 'Building the "ytdtest" container' \
		&& docker build -t ytdtest . && echo "Built successfully"; fi

delcontainer:
	@if [[ $$(docker images | grep ytdtest) ]]; then echo 'Deleting "ytdtest" container' && \
		docker image rm ytdtest:latest -f; \
		else echo 'Container "ytdtest" not found. Build it with \`make container\`.'; fi

rebuild: delcontainer container ## Rebuild existing docker container

test: ## Run the ytdtest container
	@if [[ $$(docker images | grep ytdtest) ]]; then docker run -it ytdtest; \
		else echo 'Container "ytdtest" not found. Build it with \`make container\`.'; fi

.PHONY: all help software reqs install uninstall container delcontainer rebuild test
