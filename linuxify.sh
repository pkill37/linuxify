#! /usr/bin/env bash

set -euo pipefail

if ! [[ "$OSTYPE" =~ darwin* ]]; then
    echo "This is meant to be run on macOS only"
    exit
fi

formulas=(
    # GNU programs non-existing in macOS
    "watch"
    "wget"
    "wdiff --with-gettext"
    "gdb"

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
    "grep --with-default-names"
    "gzip"
    "screen"

    # GNU programs existing in macOS which are outdated
    "bash"
    "emacs"
    "gpatch"
    "less"
    "m4"
    "make --with-default-names"
    "nano"

    # Other common/preferred programs in GNU/Linux distributions
    "libressl"
    "file-formula"
    "git"
    "openssh"
    "perl"
    "python"
    "rsync"
    "svn"
    "unzip"
    "vim --override-system-vi"
)

linuxify_install() {
    # Install all formulas
    for (( i=0; i<${#formulas[@]}; i++ )); do
        brew install ${formulas[i]}
    done

    # Change default shell to brew-installed /usr/local/bin/bash
    grep -qF '/usr/local/bin/bash' /etc/shells || echo '/usr/local/bin/bash' | sudo tee -a /etc/shells
    chsh -s /usr/local/bin/bash

    # gdb requires special privileges to access Mach ports.
    # One can either codesign the binary as per https://sourceware.org/gdb/wiki/BuildingOnDarwin
    # Or, on 10.12 Sierra or later with SIP, declare `set startup-with-shell off` in `~/.gdbinit`:
    grep -qF 'set startup-with-shell off' ~/.gdbinit || echo 'set startup-with-shell off' | sudo tee -a ~/.gdbinit
}

linuxify_uninstall() {
    # Change default shell back to macOS /bin/bash
    sudo sed -i '/\/usr\/local\/bin\/bash/d' /etc/shells
    chsh -s /bin/bash

    # Remove gdb fix
    sed -i '/set startup-with-shell off/d' ~/.gdbinit

    # Uninstall all formulas in reverse order
    for (( i=${#formulas[@]}-1; i>=0; i-- )); do
        brew uninstall $(echo "${formulas[i]}" | cut -d ' ' -f1)
    done
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

    brew doctor
}

main "$@"
