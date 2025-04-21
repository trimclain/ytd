.ONESHELL:
SHELL := /bin/bash
# Remove "Entering directory" messages
MAKEFLAGS += --no-print-directory

# has to be the first target
all: distrocheck
	@make software
	@# Create venv
	@if [[ ! -d ".venv" ]]; then \
		echo "Creating .venv..."; \
		$(CREATE_VENV); \
		echo "Done";\
	else \
		echo ".venv already exists"; \
	fi

HAS_APT := $(shell if command -v apt > /dev/null 2>&1; then echo true; fi)
HAS_PACMAN := $(shell if command -v pacman > /dev/null 2>&1; then echo true; fi)
SUPPORTED := $(or $(HAS_APT), $(HAS_PACMAN))
ifneq ($(SUPPORTED), true)
distrocheck:
	@echo "Your distro is not supported. Please refer to manual installation." && exit 1
else
distrocheck:
	@:
endif

HAS_UV := $(shell if command -v uv > /dev/null 2>&1; then echo true; fi)
ifeq ($(HAS_UV),true)
	CREATE_VENV := uv venv
	INSTALL_REQS_VENV := uv pip install yt-dlp
else
	CREATE_VENV := python3 -m venv venv
	INSTALL_REQS_VENV := python3 -m pip install yt-dlp
endif

help: distrocheck
	@echo "Run 'make' to create the venv"
	@echo "Run 'make reqs' to install requirements"
	@echo "Run 'make install' install YTD"
	@echo "Run 'make uninstall' to uninstall YTD"

software: distrocheck
	@# Install pip
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
	@# Install venv (on arch it comes with python)
	@if [[ "$(HAS_APT)" == "true" ]]; then \
		if [[ ! -d /usr/lib/python$$(python3 -c "import platform; print(platform.python_version()[:-2])")/venv/ ]]; then \
			echo "Installing python3-venv..."; \
			sudo apt install -y python3-venv; \
		fi; \
	else \
		echo "venv is already installed"; \
	fi
	@# Install ffmpeg
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
	@# Install requirements
	@if ! command -v yt-dlp > /dev/null; then \
		if [[ -n "$$VIRTUAL_ENV" ]]; then \
			echo "Installing yt-dlp into venv..."; \
			$(INSTALL_REQS_VENV); \
			echo "Done"; \
		else \
			echo "Installing yt-dlp..."; \
			if [[ "$(HAS_APT)" == "true" ]]; then \
				sudo apt install -y yt-dlp; \
			elif [[ "$(HAS_PACMAN)" == "true" ]]; then \
				sudo pacman -S --noconfirm --needed yt-dlp; \
			fi; \
		fi; \
	else \
		echo "yt-dlp is already installed"; \
	fi

install: distrocheck
	@make software
	@make reqs
	@echo "Installing YTD to ~/.local/bin..."
	@mkdir -p ~/.local/bin
	@rm -f ~/.local/bin/ytd
	@cp ./ytd.py ~/.local/bin/ytd
	@chmod +x ~/.local/bin/ytd
	@echo "YDT was successfully installed"

uninstall: distrocheck
	@# Delete the executable in .local/bin
	@if [[ -f ~/.local/bin/ytd ]]; then \
		echo "Uninstalling YDT from .local/bin..."; \
		rm -f ~/.local/bin/ytd; \
		echo "YDT was successfully uninstalled"; \
	else \
		echo "YTD is already uninstalled"; \
	fi

#################################### Tests in Docker ##############################################
container: distrocheck ## Build a docker container for testing
	@if ! command -v docker > /dev/null; then \
		echo "Docker not found, install it first"; \
	elif [[ $$(docker images | grep ytdtest) ]]; then \
		echo 'Container "ytdtest" already exists'; \
	else \
		echo 'Building the "ytdtest" container'; \
		docker build -t ytdtest . && echo "Built successfully"; \
	fi

delcontainer: distrocheck
	@if [[ $$(docker images | grep ytdtest) ]]; then \
		echo 'Deleting "ytdtest" container'; \
		docker image rm ytdtest:latest -f; \
	else \
		echo 'Container "ytdtest" not found. Build it with \`make container\`.'; \
	fi

rebuild: distrocheck delcontainer container ## Rebuild existing docker container

test: distrocheck ## Run the ytdtest container
	@if [[ $$(docker images | grep ytdtest) ]]; then \
		docker run -it ytdtest; \
	else \
		echo 'Container "ytdtest" not found. Build it with \`make container\`.'; \
	fi

.PHONY: all distrocheck help software reqs install uninstall container delcontainer rebuild test
