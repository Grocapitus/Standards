#!/bin/bash

# Grocapitus Organization: Enforce Claude Haiku model
# Run this script to add the Haiku alias to your shell

set -e

echo "[Grocapitus] Setting up Claude Haiku alias..."

# Add alias to ~/.bashrc if not already present
if [ -f "$HOME/.bashrc" ]; then
  if ! grep -q "alias claude=" "$HOME/.bashrc"; then
    echo "alias claude='claude --model claude-haiku-4-5-20251001'" >> "$HOME/.bashrc"
    echo "✅ Added 'claude' alias to ~/.bashrc"
  else
    echo "✅ 'claude' alias already exists in ~/.bashrc"
  fi
fi

# Add alias to ~/.zshrc if not already present (for zsh users)
if [ -f "$HOME/.zshrc" ]; then
  if ! grep -q "alias claude=" "$HOME/.zshrc"; then
    echo "alias claude='claude --model claude-haiku-4-5-20251001'" >> "$HOME/.zshrc"
    echo "✅ Added 'claude' alias to ~/.zshrc"
  fi
fi

echo ""
echo "🎯 Done! The 'claude' command now always uses Haiku."
echo "   If you need to override: run 'claude --model claude-opus-4-7' (not recommended)"
echo ""
