#! /usr/bin/env bash

set -euo pipefail

if ! [[ "$OSTYPE" =~ darwin* ]]; then
    echo "This is meant to be run on macOS only"
    exit
fi

formulas=(
    # GNU programs non-existing in macOS

    # GNU programs whose BSD counterpart is installed in macOS
    "coreutils"
    "binutils"
    "diffutils"
    "ed --with-default-names"
    "findutils --with-default-names"
    "gawk"
    "gnu-indent --with-default-names"
    "gnu-sed --with-default-names"
    "gnu-tar --with-default-names"
    "gnu-which --with-default-names"
    "gnutls"
    "grep --with-default-names"
    "gzip"
    "screen"
    "watch"
    "wdiff --with-gettext"
    "wget"

    # GNU programs existing in macOS which are outdated
    "bash"
    "emacs"
    "gdb"  # gdb requires further actions to make it work. See `brew info gdb`.
    "gpatch"
    "less"
    "m4"
    "make --with-default-names"
    "nano"

    # Other common programs in GNU/Linux distributions
    "file-formula"
    "git"
    "openssh"
    "perl"
    "python"
    "rsync"
    "svn"
    "unzip"
    "vim --override-system-vi"
    "zsh"
)

linuxify_install() {
    # Install all formulas
    brew install "${formulas[@]}"

    # Change default shell to brew-installed /usr/local/bin/bash
    grep -qF '/usr/local/bin/bash' /etc/shells || echo '/usr/local/bin/bash' | sudo tee -a /etc/shells
    chsh -s /usr/local/bin/bash

    # gdb requires special privileges to access Mach ports.
    # One can either codesign the binary as per https://sourceware.org/gdb/wiki/BuildingOnDarwin
    # Or, on 10.12 Sierra or later with SIP, declare `set startup-with-shell off` in `~/.gdbinit`:
    grep -qF 'set startup-with-shell off' ~/.gdbinit || echo 'set startup-with-shell off' | sudo tee -a ~/.gdbinit

    # Review installation to troubleshoot issues
    brew doctor
}

linuxify_uninstall() {
    # Uninstall all formulas
    brew uninstall "${formulas[@]}"

    # Change default shell back to macOS /bin/bash
    sudo sed -i '/\/usr\/local\/bin\/bash/d' /etc/shells
    chsh -s /bin/bash

    # Remove gdb fix
    sed -i '/set startup-with-shell off/d' ~/.gdbinit

    # Review installation to troubleshoot issues
    brew doctor
}

linuxify_info() {
    for formula in "${formulas[@]}"; do
        echo "==============================================================================================================================="
        brew info $(echo "$formula" | cut -d " " -f1)
    done
}

main() {
    if [ $# -eq 1 ]; then
        if [ "$1" == "install" ]; then
            linuxify_install
        elif [ "$1" == "uninstall" ]; then
            linuxify_uninstall
        elif [ "$1" == "info" ]; then
            linuxify_info
        fi
    else
        echo "Invalid usage"
        exit
    fi
}

main "$@"
