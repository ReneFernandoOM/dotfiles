#!/usr/bin/env bash
set -euo pipefail

cd ~/dev/personal/dotfiles

# Helper function to safely stow configs
safe_stow() {
  local target_dir=$1
  local source_dir=$2

  echo ">>> Stowing $source_dir into $target_dir"

  # Ensure target directory exists
  mkdir -p "$target_dir"

  # Run stow
  stow -vv --restow -t "$target_dir" "$source_dir"
}

safe_stow "$HOME/.config/nvim" nvim
safe_stow "$HOME/.config/wezterm" wezterm
safe_stow "$HOME/.config/i3" i3
safe_stow "$HOME/.config/polybar" polybar
safe_stow "$HOME/.config/picom" picom
safe_stow "$HOME" zsh

echo "✅ Dotfiles successfully stowed."
