#!/usr/bin/env python3

import sys
import os
import subprocess
from pytube import YouTube


def ytdownload_direct():
    """ytdownload as a script from user input"""

    # Get the video from the Link
    if len(sys.argv) == 1:
        link = input('Enter the Link: ')
    else:
        link = sys.argv[1]

    ytdownload(link, outpath="songs", verbose=True)


def ytdownload(link, outpath='out', verbose=False):
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
    if verbose:
        print(f'Visiting {link}...')

    # Create an object
    yt = YouTube(link)

    # Get the right stream
    ys = yt.streams.filter(only_audio=True)[0]  # [-1] for best quality
    default_filename = ys.default_filename
    title = yt.title

    # Download
    if verbose:
        print(f'Downloading "{title}" as mp4... ', end='')
    ys.download(outpath)
    if verbose:
        print('Done')

    # Convert mp4 to mp3
    new_filename = title + '.mp3'
    if verbose:
        print(f'Converting "{title}" to mp3... ', end='')
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
    if verbose:
        print('Done')

    # Delete mp4
    if verbose:
        print(f'Deleting "{title}.mp4"... ' )
    subprocess.run(['rm', os.path.join(outpath, default_filename)])
    if verbose:
        print(f'Success! The file "{title}.mp3" can be found in the "{outpath}" folder.')


if __name__ == '__main__':
    ytdownload_direct()
