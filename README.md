# YTD
YTD is a CLI YouTube downloader written in Python
## Prerequisites
1. Install pytube with `pip install pytube`
2. Install ffmpeg to convert from mp4 to mp3 with `sudo apt install ffmpeg`

## Fixing Errors
### [BUG] 'NoneType' object has no attribute 'span'
This Error has been occuring recenly and isn't fixed by pytube devs yet,
although the [fix](https://github.com/pytube/pytube/issues/1243#issuecomment-1032242549) exists.
So I wrote a script to fix this Error. But it's only for the venv. So the setup should look like this:

1. Install pip and venv, if you don't have them yet:
```
sudo apt install python3-pip python3-venv
```
2. Create a virtual environment:
```
python3 -m venv venv
```
3. Activate the venv
```
source venv/bin/activate
```
4. Install requirements
```
pip install -r requirements.txt
```
5. Launch my script
```
./bugfix/fix.py
```
