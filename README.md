# YTD
YTD is a CLI YouTube downloader written in Python

## How to install

Installation works on Debian-based systems and was tested on Ubuntu 22.04.

- (Recommended) To install YTD for current user, make sure `~/.local/bin/` is in `PATH` and then run `make install`.
  Now you can run `ytd` from anywhere.

- To install the venv, the requirements and run YTD from this folder:
    1. `make`
    2. `source venv/bin/activate`
    3. `make reqs`
    4. `./ytd.py`

## Note
The library `pytube`, which `ytd` is based on, breaks very often. I try to install the fixed version as soon as I find one.<br>
Latest Update: 2023-05-01
