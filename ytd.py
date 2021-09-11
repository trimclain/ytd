#!/usr/bin/env python3

import sys
import os
import subprocess
from pytube import YouTube

OUTPATH = 'out'

# Get the video from the Link
if len(sys.argv) == 1:
    link = input("Enter the Link: ")
else:
    link = sys.argv[1]

def ytdownload(link):
    """
    Download a video from YouTube as mp3

    Args:
        link: a link to a YouTube video

    Returns:
        None

    Raises:
        None
    """
    # Create an object
    yt = YouTube(link)

    # Get the right stream
    ys = yt.streams.filter(only_audio=True)[0]  # [-1] for best quality

    # Download
    ys.download(OUTPATH)

    # Convert mp4 to mp3
    default_filename = ys.default_filename
    title = yt.title
    new_filename = title + '.mp3'
    subprocess.run([
        'ffmpeg',
        '-y',
        '-i', os.path.join(OUTPATH, default_filename),
        os.path.join(OUTPATH, new_filename)
    ], stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT) # Get no output
    # Delete mp4
    subprocess.run(['rm', os.path.join(OUTPATH, default_filename)])


if __name__ == '__main__':
    print('Downloading...')
    ytdownload(link)
    print('Done')
