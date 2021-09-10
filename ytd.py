#!/usr/bin/env python3

import sys
import os
import subprocess
from pytube import YouTube

OUTPATH = 'out'

# Get the video from the Link
if len(sys.argv) == 1:
    link = input("Enter the Link: ")
    yt = YouTube(link)
else:
    link = sys.argv[1]
    yt = YouTube(link)

# Create the object
title = yt.title

# Get the right stream
ys = yt.streams.filter(only_audio=True)[0]  # [-1] for best quality

# Download
print('Downloading...')
ys.download(OUTPATH)

# Convert mp4 to mp3
default_filename = ys.default_filename
new_filename = title + '.mp3'
subprocess.run([
    'ffmpeg',
    '-y',
    '-i', os.path.join(OUTPATH, default_filename),
    os.path.join(OUTPATH, new_filename)
], stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT) # Get no output at all
# Delete mp4
subprocess.run(['rm', os.path.join(OUTPATH, default_filename)])
print('Done')
