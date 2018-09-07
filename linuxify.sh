#! /usr/bin/env bash

set -euo pipefail

if ! [[ "$OSTYPE" =~ darwin* ]]; then
    echo "This is meant to be run on macOS only"
    exit
fi

linuxify_formulas=(
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
    "bison"

    # BSD programs existing in macOS which are outdated
    "flex"

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
    for (( i=0; i<${#linuxify_formulas[@]}; i++ )); do
        brew install ${linuxify_formulas[i]}
    done

    # Change default shell to brew-installed /usr/local/bin/bash
    grep -qF '/usr/local/bin/bash' /etc/shells || echo '/usr/local/bin/bash' | sudo tee -a /etc/shells
    chsh -s /usr/local/bin/bash

    # gdb requires special privileges to access Mach ports.
    # One can either codesign the binary as per https://sourceware.org/gdb/wiki/BuildingOnDarwin
    # Or, on 10.12 Sierra or later with SIP, declare `set startup-with-shell off` in `~/.gdbinit`:
    grep -qF 'set startup-with-shell off' ~/.gdbinit || echo 'set startup-with-shell off' | sudo tee -a ~/.gdbinit

    # Make changes to PATH/MANPATH/INFOPATH/LDFLAGS/CPPFLAGS
    cp ".linuxify" "$HOME/.linuxify"
    grep -qF '[[ "$OSTYPE" =~ ^darwin ]] && [ -f ~/.linuxify ] && source ~/.linuxify' ~/.bashrc || echo '[[ "$OSTYPE" =~ ^darwin ]] && [ -f ~/.linuxify ] && source ~/.linuxify' | sudo tee -a ~/.bashrc
}

linuxify_uninstall() {
    # Change default shell back to macOS /bin/bash
    sudo sed -i.bak '/\/usr\/local\/bin\/bash/d' /etc/shells
    chsh -s /bin/bash

    # Remove gdb fix
    sed -i.bak '/set startup-with-shell off/d' ~/.gdbinit

    # Remove changes to PATH/MANPATH/INFOPATH/LDFLAGS/CPPFLAGS
    sed -i.bak '/\[\[ "\$OSTYPE" =~ \^darwin \]\] && \[ -f ~\/.linuxify \] && source ~\/.linuxify/d' ~/.bashrc
    rm -f "$HOME/.linuxify"

    # Uninstall all formulas in reverse order
    for (( i=${#linuxify_formulas[@]}-1; i>=0; i-- )); do
        brew uninstall $(echo "${linuxify_formulas[i]}" | cut -d ' ' -f1)
    done
}

linuxify_caveats() {
    for formula in "${linuxify_formulas[@]}"; do
        echo "==============================================================================================================================="
        brew info $(echo "$formula" | cut -d " " -f1)
    done
}

linuxify_main() {
    if [ $# -eq 1 ]; then
        if [ "$1" == "install" ]; then
            linuxify_install
        elif [ "$1" == "uninstall" ]; then
            linuxify_uninstall
        elif [ "$1" == "caveats" ]; then
            linuxify_caveats
        fi
    else
        echo "Invalid usage"
        exit
    fi
}

linuxify_main "$@"
