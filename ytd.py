#!/usr/bin/env python3

import sys
import os
import subprocess
from pytube import YouTube


def ytdownload_direct():
    """ytdownload as a script from user input"""

    # Get the video from the Link
    if len(sys.argv) == 1:
        link = input("Enter the Link: ")
    else:
        link = sys.argv[1]

    print('Downloading...')
    ytdownload(link)
    print('Done')


def ytdownload(link, outpath='out'):
    """
    Download a video from YouTube as mp3

    Args:
        link: a string with a link to a YouTube video
        oupath: optional, a string with destinatio folder, defaults to 'out'

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
    ys.download(outpath)

    # Convert mp4 to mp3
    default_filename = ys.default_filename
    title = yt.title
    new_filename = title + '.mp3'
    subprocess.run(
        [
            'ffmpeg',
            '-y',
            '-i',
            os.path.join(outpath, default_filename),
            os.path.join(outpath, new_filename),
        ],
        # Get no output
        stdout=subprocess.DEVNULL,
        stderr=subprocess.STDOUT,
    )
    # Delete mp4
    subprocess.run(['rm', os.path.join(outpath, default_filename)])


if __name__ == '__main__':
    ytdownload_direct()
