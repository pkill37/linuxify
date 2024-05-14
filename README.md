# linuxify

Permanently forked from `pkill37/linuxify:master`. Now with Braidwell standards.

Transparently transform the macOS CLI into a fresh GNU/Linux CLI experience by

- installing missing GNU programs
- updating outdated GNU programs
- replacing pre-installed BSD programs with their preferred GNU implementation
- installing other programs common among popular GNU/Linux distributions

&nbsp;

As we update Braidwell standard utilities this repo will be automatically pulled
to your machine and installed when you open a new shell.

&nbsp;

## Login shell

Add this block neat the top of your __~/.zshrc__ file:

```shell
#######################################
## use gnu utils in lieu of OSX/BSD
#######################################
[[ ! -d ./linuxify ]] && (echo Cloning the linuxify repo ... && git clone git@github.com:braidwell/linuxify.git && cd ./linuxify 1>/dev/null && ./linuxify install)
pushd ./linuxify 1>/dev/null && git remote update 1>/dev/null && git status -uno | grep 'up to date' 1>/dev/null || (echo Pulling latest linuxify update && git pull && ./linuxify install)
popd 1>/dev/null
. ~/.linuxify
touch ~/.linuxify
```
