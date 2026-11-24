#!/usr/bin/env bash
#
# bootstrap.sh — set up a new Mac from this dotfiles repo.
#
# Usage (from a fresh Mac, after adding an SSH key to GitHub):
#   curl -fsSL https://raw.githubusercontent.com/skekcoon/dotfiles/main/bootstrap.sh | bash
# or from a local clone:
#   ./bootstrap.sh
#
# Idempotent: safe to re-run on an already-configured machine.

set -euo pipefail

DOTFILES_DIR="$HOME/.dotfiles"
REPO_SSH="git@github.com:skekcoon/dotfiles.git"
REPO_HTTPS="https://github.com/skekcoon/dotfiles.git"

echo "==> 1/7 Xcode Command Line Tools"
if ! xcode-select -p &>/dev/null; then
  xcode-select --install
  echo "    Install dialog is open — click Install, this script waits..."
  until xcode-select -p &>/dev/null; do sleep 5; done
fi

echo "==> 2/7 Homebrew"
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# brew's prefix differs: /opt/homebrew (Apple Silicon) vs /usr/local (Intel)
if ! command -v brew &>/dev/null; then
  for p in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$p" ]]; then eval "$("$p" shellenv)"; break; fi
  done
fi
command -v brew &>/dev/null || { echo "ERROR: brew not available after install" >&2; exit 1; }

echo "==> 3/7 Clone dotfiles repo"
if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
  git clone "$REPO_SSH" "$DOTFILES_DIR" || git clone "$REPO_HTTPS" "$DOTFILES_DIR"
fi
cd "$DOTFILES_DIR"

echo "==> 4/7 uv (standalone installer — avoids source builds on old macOS)"
if ! command -v uv &>/dev/null; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

echo "==> 5/7 Install software declared in the Brewfile"
brew bundle --file "$DOTFILES_DIR/Brewfile"

echo "==> 6/7 Symlink dotfiles into \$HOME (stow)"
stow .

echo "==> 7/7 Shell, oh-my-zsh plugins, eza, fzf"

# Default shell
if [[ "$SHELL" != "$(command -v zsh)" ]]; then chsh -s "$(command -v zsh)"; fi

# oh-my-zsh custom plugins (not bundled with oh-my-zsh — see README)
plugins_dir="$DOTFILES_DIR/.oh-my-zsh/custom/plugins"
mkdir -p "$plugins_dir"
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  if [[ ! -d "$plugins_dir/$plugin" ]]; then
    git clone --depth 1 "https://github.com/zsh-users/$plugin" "$plugins_dir/$plugin"
  fi
done

macos_major="$(sw_vers -productVersion | cut -d. -f1)"

# eza: on macOS <= 12 Homebrew ships no bottles, so build via cargo instead
# (needs rust; eza 0.23.5 requires rustc >= 1.90, hence the 0.23.4 pin)
if ! command -v eza &>/dev/null; then
  if [[ "$macos_major" -le 12 ]] && command -v cargo &>/dev/null; then
    cargo install eza --locked --version 0.23.4
    cp "$HOME/.cargo/bin/eza" "$(brew --prefix)/bin/eza"
  else
    brew install eza
  fi
fi

# fzf: on macOS <= 12 brew would build Go from source — use the prebuilt release
if ! command -v fzf &>/dev/null; then
  if [[ "$macos_major" -le 12 ]]; then
    fzf_ver="0.75.0"
    arch="$(uname -m)"; [[ "$arch" == "x86_64" ]] && arch="amd64"
    curl -fsSL "https://github.com/junegunn/fzf/releases/download/v${fzf_ver}/fzf-${fzf_ver}-darwin_${arch}.tar.gz" -o /tmp/fzf.tgz
    tar -xzf /tmp/fzf.tgz -C /tmp fzf && mv /tmp/fzf "$HOME/.local/bin/fzf" && rm -f /tmp/fzf.tgz
  else
    brew install fzf
  fi
fi

echo "==> Done. Restart your terminal (or run: exec zsh)"
