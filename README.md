# YTD
YTD is a CLI YouTube downloader written in Python

## Requirements
- python3
- pip
- ffmpeg
- yt-dlp

## How to install
Installation works on Debian-based systems and was tested on Ubuntu 22.04.

- (Recommended) To install YTD for current user, make sure `~/.local/bin/` is in `PATH` and then run `make install`.
  Now you can run `ytd` from anywhere.

- To install the venv, the requirements and run YTD from this folder:
    1. `make`
    2. `source venv/bin/activate`
    3. `make reqs`
    4. `./ytd.py`
