> [!CAUTION]
> This README is written for future me who keeps forgetting how to use stuff. I'm still writing instructions if anyone wants to follow. These are written with NixOS in mind.
## Building
### 1. dot
`dot` is a tool used to manage dotfiles with ease. It's a python file but can be built into an executable. It can be found under `scripts/dot`. 

To build an executable out of it, do the following steps:
> [!IMPORTANT]
> You will need to change the path of directories you keep your dotfiles in as well as your username in the python file.
1. Install `nuitka` at user level or just enter the shell with the package.
2. Enter the shell with nuitka by running the command `nix-shell -p python313Packages.nuitka`.
3. Run the command `nuitka --one-file dot.py` to build the executable.

## Usage
### 1. dot
`dot` can be used on any folder or file and it will automatically link it in the dots directory. Looks like this on my machine:
```
~$ dot meow.txt 
✔ Moved /home/quun/meow.txt → /home/quun/.dotfiles/dots/meow.txt
✔ Symlink created at /home/quun/meow.txt
```
