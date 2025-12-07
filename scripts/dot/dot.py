#!/usr/bin/env python3

import os
import shutil
import sys
from pathlib import Path

def main():
    if len(sys.argv) != 2:
        print("Usage: dot <path-to-file-or-folder>")
        sys.exit(1)

    target = Path(sys.argv[1]).expanduser().resolve()
    if not target.exists():
        print(f"Error: {target} does not exist.")
        sys.exit(1)

    dotfiles_dir = Path("~/.dotfiles/dots").expanduser()
    dotfiles_dir.mkdir(parents=True, exist_ok=True)

    dest = dotfiles_dir / target.name

    # Avoid overwriting something in ~/.dotfiles/dots/
    if dest.exists():
        print(f"Error: {dest} already exists in ~/.dotfiles/dots/.")
        sys.exit(1)

    # Copy file or folder
    if target.is_file():
        shutil.copy2(target, dest)
    else:
        shutil.copytree(target, dest)

    # Remove original
    if target.is_dir():
        shutil.rmtree(target)
    else:
        target.unlink()

    # Create symlink
    os.symlink(dest, target)

    print(f"✔ Moved {target} → {dest}")
    print(f"✔ Symlink created at {target}")

if __name__ == "__main__":
    main()
