#!/usr/bin/env python3

# Author: trimclain
# License: MIT
#
# Requirements: yt-dlp, ffmpeg

import os
import sys

import yt_dlp


def ytd():
    """Run yt_download_audio with user input"""

    if len(sys.argv) == 1:
        url = input("Enter the URL: ")
    else:
        url = sys.argv[1]

    running_from = sys.path[0]
    if running_from == os.path.expanduser('~/.local/bin'):
        download_path = os.path.expanduser("~/songs")
    else:
        download_path = os.path.abspath("./songs")

    yt_download_audio(url, download_path=download_path, verbose=True)


def yt_download_audio(url, download_path="out", verbose=False):
    """
    Download a video from YouTube as mp3

    Args:
        url: a string with a link to a YouTube video
        download_path: optional, a string with destinatio folder, defaults to 'out'

    Returns:
        None

    Raises:
        None
    """

    # Docs: https://github.com/yt-dlp/yt-dlp?tab=readme-ov-file#embedding-examples
    ydl_opts = {
        # opts: "worstaudio", "bestaudio[abr<=128]/worstaudio[abr>=64]", "bestaudio"
        "format": "bestaudio/best",
        "postprocessors": [{  # Post-process the download
            "key": "FFmpegExtractAudio",  # Extract the audio using ffmpeg
            "preferredcodec": "mp3",  # Convert to mp3
            "preferredquality": "192",  # Quality of the mp3 (192 kbps here)
        }],
        "outtmpl": os.path.join(download_path, "%(title)s.%(ext)s"),
        "logger": MyLogger(),
    }

    if not os.path.isdir(download_path):
        if verbose:
            print(f"Creating the folder {download_path}...")
        os.mkdir(download_path)

    if "youtube.com" not in url and "youtu.be" not in url:
        print("Not a valid YouTube URL. Aborting...")
        return

    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        info_dict = ydl.extract_info(url, download=False)
        video_title = info_dict.get("title", None)
        if verbose:
            print(f"Downloading '{video_title}.mp3' to the directory '{
                  download_path}'...", end=" ", flush="True")
        # I know this is slower but whatever it's pretty
        ydl.download([url])
        if verbose:
            print("Done")


class MyLogger:
    def debug(self, msg):
        # For compatibility with youtube-dl, both debug and info are passed into debug
        # You can distinguish them by the prefix "[debug] "
        if msg.startswith("[debug] "):
            pass
        else:
            self.info(msg)

    def info(self, msg):
        pass

    def warning(self, msg):
        pass

    def error(self, msg):
        print(msg)


if __name__ == "__main__":
    ytd()
