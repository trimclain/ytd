SHELL := /bin/bash

all: software
	@# Create venv
	@if [[ ! -d "venv" ]]; then echo "Creating venv..." && python3 -m venv venv && echo "Done";\
		else echo "venv already exists"; fi

help:
	@echo "Run 'make' to create the venv"
	@echo "Run 'make reqs' after sourcing the venv to install modules using requirements.txt"
	@echo "Run 'make install' to be able to run YTD from anywhere"
	@echo "Run 'make uninstall' to uninstall YTD"

software:
	@# Install pip, venv and ffmpeg
	@if [[ ! -f /usr/bin/pip3 ]]; then echo "Installing python3-pip..." && sudo apt install python3-pip -y;\
		else echo "pip3 is already installed"; fi
	@if [[ ! -d /usr/lib/python$$(python3 -c "import platform; print(platform.python_version()[:-2])")/venv/ ]];\
		then echo "Installing python3-venv..." && sudo apt install python3-venv -y;\
		else echo "venv is already installed"; fi
	@if [[ ! -f /usr/bin/ffmpeg ]]; then echo "Installing ffmpeg..." && sudo apt install ffmpeg -y;\
		else echo "ffmpeg is already installed"; fi

reqs:
	@# Install required modules
	@echo "Installing requirements..."
	@pip install -r requirements.txt
	@echo "Done"

install: software reqs
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

.PHONY: all help software reqs install uninstall
