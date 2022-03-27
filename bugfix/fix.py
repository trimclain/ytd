#!/usr/bin/env python3

import os
import pathlib
import subprocess


def main():
    bugfix_folder = pathlib.Path(__file__).parent.resolve()
    ytd_folder = bugfix_folder.parent.resolve()
    venvlib_folder = os.path.join(ytd_folder, 'venv/lib/')
    pyversion = os.listdir(venvlib_folder)
    lineend = 'site-packages/pytube/cipher.py'
    # file to be replaced
    fullpath = os.path.join(venvlib_folder, pyversion[0], lineend)
    # my file with correct function
    fixfilepath = os.path.join(bugfix_folder, 'cipher.py')
    subprocess.run(['cp', fixfilepath, fullpath])


if __name__ == "__main__":
    main()
