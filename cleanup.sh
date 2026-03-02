#!/bin/bash
# Cleanup script to remove all Neovim state, cache, and data

echo "Removing nvim-pro state, cache, and data..."

rm -rf ~/.local/state/nvim-pro
rm -rf ~/.local/share/nvim-pro
rm -rf ~/.cache/nvim-pro

echo "Cleanup complete. Restart nvim-pro to regenerate."
