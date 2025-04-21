# YTD
YTD is a CLI YouTube downloader written in Python

## Requirements
- python3
- pip
- ffmpeg
- yt-dlp

## How to install
Installation works on (not ancient) Arch- and Debian-based systems.

- *(Recommended)* To install YTD for current user 
  - make sure `~/.local/bin/` is in `PATH` 
  - run `make install`.
  - run `ytd --help` to see how to use

- For development install using venv run
  1. `make`
  2. `source .venv/bin/activate`
  3. `make reqs`
  4. `./ytd.py`

- Manual Installation
  - install [requirements](#requirements)
  - put `ytd.py` in `PATH` (e.g. `cp ytd.py ~/.local/bin/ytd`)
  - run `ytd --help` to see how to use

## Usage
- Run `ytd` and follow the prompts
- Run `ytd <YouTube-URL>` to download the mp3 of the video. Replace `<YouTube-URL>` with the actual URL of the YouTube video you want to download.
