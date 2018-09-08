# linuxify

Transparently transform the macOS CLI into a fresh GNU/Linux CLI experience by

- installing missing GNU programs
- updating outdated GNU programs
- replacing pre-installed BSD programs with their preferred GNU implementation
- installing other programs common among popular GNU/Linux distributions

You should review the script, but if you want to go back you can uninstall just
as easily as the install.

## Install

```bash
$ git clone git@github.com:fabiomaia/linuxify.git
$ cd linuxify/
$ chmod +x linuxify.sh
$ ./linuxify.sh install
```

## Uninstall

```bash
$ ./linuxify.sh uninstall
```
