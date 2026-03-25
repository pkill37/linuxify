# linuxify

Transparently transform the macOS CLI into a fresh GNU/Linux CLI experience by

- installing missing GNU programs
- updating outdated GNU programs
- replacing pre-installed BSD programs with their preferred GNU implementation
- installing other programs common among popular GNU/Linux distributions

Tested through macOS Big Sur (11), Monterey (12), Ventura (13), Sonoma (14), and Sequoia (15).

## Install

```bash
git clone https://github.com/pkill37/linuxify.git
cd linuxify/
./linuxify install
```

## Usage

At the end of the install, a file at `~/.linuxify` will be provided.
Sourcing this file will update your PATH, MANPATH, and other variables so you
get the GNU utilites first without needing to prepend them with `g`.

## Uninstall

```bash
./linuxify uninstall
```
