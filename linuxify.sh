#! /usr/bin/env bash

set -euo pipefail

if ! [[ "$OSTYPE" =~ darwin* ]]; then
    echo "This is meant to be run on macOS only"
    exit
fi

if ! command -v brew > /dev/null; then
    echo "Homebrew not installed!"
    echo "In order to use this script please install homebrew from https://brew.sh"
    exit
fi

linuxify_installs=(
    # GNU programs non-existing in macOS
    "watch"
    "wget"
    "wdiff --with-gettext"
    "gcc"
    "gdb"

    # Other common/preferred programs in GNU/Linux distributions
    "libressl"
    "file-formula"
    "git"
    "openssh"
    "perl"
    "python"
    "rsync"
    "unzip"
    "vim --override-system-vi"
) 

linuxify_updates=(

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
)

linuxify_install() {

    # Install new programs
    for app in $linuxify_installs; do
    	if ! command -v $(echo $app | awk '{print $1}')> /dev/null; then
            	brew install $app
    	else
    		echo "$app already installed"
        fi
    done

    # Install updates 
    for (( i=0; i<${#linuxify_updates[@]}; i++ )); do
      	brew install ${linuxify_updates[i]}
    done


    # Change default shell to brew-installed /usr/local/bin/bash
    grep -qF '/usr/local/bin/bash' /etc/shells || echo '/usr/local/bin/bash' | sudo tee -a /etc/shells
    chsh -s /usr/local/bin/bash

    # gdb requires special privileges to access Mach ports.
    # One can either codesign the binary as per https://sourceware.org/gdb/wiki/BuildingOnDarwin
    # Or, on 10.12 Sierra or later with SIP, declare `set startup-with-shell off` in `~/.gdbinit`:
    grep -qF 'set startup-with-shell off' ~/.gdbinit || echo 'set startup-with-shell off' | tee -a ~/.gdbinit

    # Make changes to PATH/MANPATH/INFOPATH/LDFLAGS/CPPFLAGS
    cp .linuxify ~/.linuxify
    grep -qF '[[ "$OSTYPE" =~ ^darwin ]] && [ -f ~/.linuxify ] && source ~/.linuxify' ~/.bashrc || { sed -i.bak -e '1i [[ "$OSTYPE" =~ ^darwin ]] && [ -f ~/.linuxify ] && source ~/.linuxify' ~/.bashrc && rm ~/.bashrc.bak; }
}

linuxify_uninstall() {
    # Remove changes to PATH/MANPATH/INFOPATH/LDFLAGS/CPPFLAGS
    sed -i.bak '/\[\[ "\$OSTYPE" =~ \^darwin \]\] && \[ -f ~\/.linuxify \] && source ~\/.linuxify/d' ~/.bashrc && rm ~/.bashrc.bak
    rm -f ~/.linuxify

    # Remove gdb fix
    sed -i.bak '/set startup-with-shell off/d' ~/.gdbinit && rm ~/.gdbinit.bak

    # Change default shell back to macOS /bin/bash
    sudo sed -i.bak '/\/usr\/local\/bin\/bash/d' /etc/shells && sudo rm /etc/shells.bak
    chsh -s /bin/bash

    # Uninstall all formulas in reverse order
    for (( i=${#linuxify_formulas[@]}-1; i>=0; i-- )); do
        brew uninstall $(echo "${linuxify_formulas[i]}" | cut -d ' ' -f1)
    done
}

linuxify_info() {
    for (( i=0; i<${#linuxify_formulas[@]}; i++ )); do
        echo "==============================================================================================================================="
        brew info ${linuxify_formulas[i]}
    done
}

linuxify_main() {
    if [ $# -eq 1 ]; then
        case $1 in
            "install") linuxify_install ;;
            "uninstall") linuxify_uninstall ;;
            "info") linuxify_info ;;
        esac
    else
        echo "Invalid usage"
        exit
    fi
}

linuxify_main "$@"
