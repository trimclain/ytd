#!/usr/bin/env python3

# This script will create a bash file in .local/bin to launch ytd


import os
import subprocess
import sys
from pathlib import Path

SCRIPT_PATH = os.path.join(Path.home(), '.local/bin/ytd')
YTD_PATH = sys.path[0]


def main():
    content = (
        f'#!/usr/bin/env bash\n\npushd {YTD_PATH} > /dev/null\nif [ -z "$1" ];'
        ' then\n\t./ytd.py\nelse\n\t./ytd.py "$1"\nfi\npopd > /dev/null'
    )
    # Create the launcher
    with open(SCRIPT_PATH, 'w') as f:
        f.write(content)

    # Make it executable
    subprocess.run(['chmod', '+x', SCRIPT_PATH])


if __name__ == "__main__":
    main()
