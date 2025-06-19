#!/usr/bin/env bash

# Customize these
DOTFILES_REPO="$HOME/Dotfiles"
REPO_URL="https://github.com/esotuvaka/dotfiles.git"
STOW_PKGS="alacritty fish nvim starship tmux git"    # Folder names inside your dotfiles

header() {
    echo ""
    echo -e "\033[1;32m==> $1\033[0m"
}

check_and_install() {
    local pkg=$1
    if ! command -v "$pkg" &> /dev/null; then
        header "Installing $pkg..."
        if command -v nix-env &> /dev/null; then
            nix-env -iA nixpkgs."$pkg"
        elif command -v apt &> /dev/null; then
            sudo apt update && sudo apt install -y "$pkg"
        elif command -v pacman &> /dev/null; then
            sudo pacman -Sy --noconfirm "$pkg"
        elif command -v brew &> /dev/null; then
            brew install "$pkg"
        else
            echo "Unsupported package manager. Please install $pkg manually."
        fi
    else
        echo "$pkg is already installed."
    fi
}

header "Ensuring stow is installed..."
check_and_install stow

header "Cloning dotfiles (if needed)..."
if [ ! -d "$DOTFILES_REPO" ]; then
    git clone "$REPO_URL" "$DOTFILES_REPO"
else
    echo "Dotfiles already cloned at $DOTFILES_REPO"
fi

cd "$DOTFILES_REPO" || exit

header "Symlinking dotfiles with stow..."
for pkg in $STOW_PKGS; do
    stow "$pkg"
done

header "Ensuring additional tools are installed..."
check_and_install fish
check_and_install alacritty
check_and_install starship
check_and_install tmux
check_and_install nvim
check_and_install git

header "Setting fish as default shell (if not already)..."
if ! echo "$SHELL" | grep -q fish; then
    chsh -s "$(command -v fish)"
    echo "Please restart shell for change to take effect."
fi

header "All done! Go make a mess!"
