#!/usr/bin/env python3

# Author: trimclain
# License: MIT
#
# Requirements: yt-dlp, ffmpeg

import os
import sys
from itertools import cycle
from shutil import get_terminal_size
from threading import Thread
from time import sleep

import yt_dlp


def ytd():
    """Run yt_download_audio with user input"""

    if len(sys.argv) == 1:
        url = input("Enter the URL: ")
        print("\033[F", end='', flush=True)  # Move cursor up one line
        print("\033[K", end='', flush=True)  # Clear the entire line
    else:
        url = sys.argv[1]
    print("Entered URL: " + url, flush=True)

    running_from = sys.path[0]
    if running_from == os.path.expanduser("~/.local/bin"):
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
        if verbose:
            info_loader = Loader("Fetching track details from YouTube...", " ").start()
        info_dict = ydl.extract_info(url, download=False)
        if verbose:
            info_loader.stop()

        video_title = info_dict.get("title", None)
        if verbose:
            download_loader = Loader(
                f"Downloading '{video_title}.mp3' to the directory '{download_path}'..."
            ).start()
        # I know this is slower but whatever it's pretty
        ydl.download([url])
        if verbose:
            download_loader.stop()


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


# Credit: https://stackoverflow.com/a/66558182
class Loader:
    def __init__(self, desc="Loading...", end="Done!", timeout=0.1):
        """
        A loader-like context manager

        Args:
            desc (str, optional): The loader's description. Defaults to "Loading...".
            end (str, optional): Final print. Defaults to "Done!".
            timeout (float, optional): Sleep time between prints. Defaults to 0.1.

        Usage:
            with Loader("Loading with context manager..."):
                for i in range(10):
                    sleep(0.25)

            loader = Loader("Loading with object...", "That was fast!", 0.05).start()
            for i in range(10):
                sleep(0.25)
            loader.stop()
        """
        self.desc = desc
        self.end = end
        self.timeout = timeout

        self._thread = Thread(target=self._animate, daemon=True)
        # More animations: https://github.com/Silejonu/bash_loading_animations/blob/main/bash_loading_animations.sh
        # self.steps = ["|", "/", "-", "\\"]
        self.steps = ["⢿", "⣻", "⣽", "⣾", "⣷", "⣯", "⣟", "⡿"]
        # self.steps = ["[■□□□□□□□□□]", "[■■□□□□□□□□]", "[■■■□□□□□□□]", "[■■■■□□□□□□]", "[■■■■■□□□□□]", "[■■■■■■□□□□]", "[■■■■■■■□□□]", "[■■■■■■■■□□]", "[■■■■■■■■■□]", "[■■■■■■■■■■]"]
        self.done = False

    def start(self):
        self._thread.start()
        return self

    def _animate(self):
        for c in cycle(self.steps):
            if self.done:
                break
            print(f"\r{self.desc} {c}", flush=True, end="")
            sleep(self.timeout)

    def stop(self):
        self.done = True
        cols = get_terminal_size((80, 20)).columns
        print("\r" + " " * cols, end="", flush=True)
        # print(f"\r{self.end}", flush=True)
        print(f"\r{self.desc} {self.end}", flush=True)

    def __enter__(self):
        self.start()

    def __exit__(self, exc_type, exc_value, tb):
        # handle exceptions with those variables ^
        self.stop()


if __name__ == "__main__":
    ytd()
