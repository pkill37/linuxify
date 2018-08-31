# linuxify

Transparently transform macOS into a GNU/Linux experience by installing missing GNU programs, updating outdated GNU programs and replacing their pre-installed BSD counterparts.
Uninstall everything just as easily if you need to.

## Installation

Clone the repository and make the script executable:

```bash
$ git clone git@github.com:fabiomaia/linuxify.git
$ cd linuxify/
$ chmod +x linuxify.sh
```

Optionally make the script available in your `$PATH`:

```bash
$ ln -s linuxify.sh /usr/local/bin/linuxify
```

Run the install procedure:

```bash
$ linuxify install
```

Source the created `~/.macos` file from `~/.bashrc`, `~/.bash_profile` or similar:

```bash
[[ "$OSTYPE" =~ ^darwin ]] && source ~/.macos
```

## Updating

In case `linuxify` is significantly updated and you wish to stay up to date, it is recommended that you:

1. Run the uninstall procedure
2. Pull the latest code or otherwise obtain a fresh copy of the code
3. Run the install procedure again

```bash
$ linuxify uninstall
$ # ...
$ git pull
$ linuxify install
```

## Uninstallation

Run the uninstall procedure:

```bash
linuxify uninstall
```

Remove the `.macos` source from `~/.bashrc`, `~/.bash_profile` or similar.
