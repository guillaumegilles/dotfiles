# `~/.dotfiles`

Personal dotfiles, managed with **GNU Stow** (symlinks into `$HOME`) and
**Homebrew Bundle** (software declared in the `Brewfile`). Primary target:
macOS. Clone once, run a few commands, and a new machine is ready.

## 🚀 Bootstrap a new Mac

One-liner — prerequisite: an SSH key on the new machine, already added to
GitHub (see [GitHub docs](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)):

```sh
curl -fsSL https://raw.githubusercontent.com/skekcoon/dotfiles/main/bootstrap.sh | bash
```

`bootstrap.sh` is idempotent (safe to re-run) and automates the manual steps
below, which are kept for reference/debugging. It also installs the oh-my-zsh
custom plugins and `eza` (see caveats).

```sh
# 1. Apple Command Line Tools (provides git, make, clang, ...)
xcode-select --install

# 2. Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# Apple Silicon prefix: /opt/homebrew   |   Intel prefix: /usr/local

# 3. Clone this repo into a hidden directory
git clone git@github.com:skekcoon/dotfiles.git ~/.dotfiles
# (HTTPS works too; switch the remote later with:
#  git remote set-url origin git@github.com:skekcoon/dotfiles.git)

# 4. Install every formula / cask / uv tool declared in the Brewfile
brew bundle --file ~/.dotfiles/Brewfile

# 5. Symlink the dotfiles into $HOME
cd ~/.dotfiles && stow .

# 6. Make zsh the default shell (already the default on macOS Catalina+)
chsh -s "$(which zsh)"
```

Restart your terminal, then verify:

```sh
brew bundle check --file ~/.dotfiles/Brewfile     # everything installed?
stow --restow .                                   # re-link after edits
echo $SHELL                                       # /bin/zsh
```

## 📦 What gets installed (the `Brewfile`)

| Entry | Type | What it is |
|---|---|---|
| `brew "git"` | formula | Distributed version control |
| `brew "lazygit"` | formula | Terminal UI for git |
| `brew "stow"` | formula | Symlink farm manager — deploys the dotfiles |
| `brew "tree"` | formula | Directory listings as trees |
| `brew "zsh"` | formula | The shell |
| `brew "fzf"` | formula | Fuzzy finder (used by the `fzf` plugin in `.zshrc`) |
| `brew "starship"` | formula | Cross-shell prompt (used by `.zshrc`) |
| `cask "quarto"` | cask | Scientific publishing system (Pandoc-based) |
| `uv "mistral-vibe"` | uv tool | `brew bundle` runs `uv tool install mistral-vibe` → installs the Vibe CLI (`vibe`) into `~/.local/bin` |
| `uv "specify-cli"` | uv tool | Spec-driven development CLI (`specify`) → `~/.local/bin/specify` |

## 🗂️ Repo layout

```
~/.dotfiles/
├── .zshrc            # shell config          → stowed to ~/.zshrc
├── .gitconfig        # git identity          → stowed to ~/.gitconfig
├── .config/          # app configs           → stowed to ~/.config
│   ├── nvim/         #   Neovim (LazyVim)
│   ├── ghostty/      #   Ghostty terminal
│   ├── iterm2/       #   iTerm2 profiles
│   ├── starship.toml #   prompt
│   ├── lazygit/      #   lazygit config
│   ├── fish/ gh/ btop/ zed/ Positron/ uv/ ...
├── .oh-my-zsh/       # Oh My Zsh install     → stowed to ~/.oh-my-zsh
├── .vibe/            # Mistral Vibe CLI config
├── .agents/ .pi/     # agent configs (secrets are gitignored, see below)
├── Brewfile          # Homebrew Bundle manifest (NOT stowed)
├── bootstrap.sh      # one-command setup for a new Mac
└── README.md         # this file
```

`stow .` symlinks every top-level entry into `$HOME`. To exclude a file from
stowing, list it in `.stow-local-ignore`.

## ⚠️ Caveats when switching machines

### macOS 12 (Monterey): Homebrew has no bottles — Rust formulas build from source

Homebrew no longer ships prebuilt bottles for macOS 12 (Tier 3). Any
Rust-based formula (`eza`, `uv`, …) therefore compiles from source — including
`rust`, `llvm`, `ghc`, … — which takes hours and looks like a hang.

- **eza** — `brew install eza` stalls building `eza` + `rust` + `llvm` + `ghc`
  + `pandoc` + `cabal-install` from source. Installed via cargo instead
  (brew's `rustc` is 1.87 and eza 0.23.5 needs ≥ 1.90, so pin 0.23.4):

  ```sh
  cargo install eza --locked --version 0.23.4
  cp ~/.cargo/bin/eza /usr/local/bin/eza   # not managed by brew
  # upgrade: re-run cargo install, then copy the binary again
  ```

- **uv** — `brew install uv` would also build `uv` + `rust` + `llvm` from
  source. Use the standalone installer instead (already installed here as
  `~/.local/bin/uv`):

  ```sh
  curl -LsSf https://astral.sh/uv/install.sh | sh
  uv self update                            # upgrade
  # note: ~/.local/bin comes first in PATH, so it shadows /usr/local/bin/uv
  ```

- **fzf warning in new terminals** (`Cannot find fzf installation directory`):
  the oh-my-zsh `fzf` plugin needs the `fzf` binary on PATH *before* oh-my-zsh
  loads. `.zshrc` puts `~/.local/bin` on PATH at the very top for this reason.
  On macOS ≤ 12, `bootstrap.sh` installs the prebuilt fzf release binary into
  `~/.local/bin` (brew would build Go from source).

- On macOS 13+ (with bottles) none of this applies — `brew install eza uv fzf`
  just works.

### Homebrew prefix, `.zshrc`, and plugins

- brew's prefix differs per platform: `/opt/homebrew` (Apple Silicon),
  `/usr/local` (Intel macOS), `/home/linuxbrew/.linuxbrew` (Linux). The
  `.zshrc` in this repo detects whichever exists, so the same file works
  everywhere.
- `bootstrap.sh` clones the oh-my-zsh custom plugins (`zsh-autosuggestions`,
  `zsh-syntax-highlighting`) into `.oh-my-zsh/custom/plugins/`. That directory
  is gitignored and re-cloned on each new machine.
- `.vibe/config.toml` (Vibe CLI settings) is part of the repo and is stowed to
  `~/.vibe` automatically; the `uv "mistral-vibe"` Brewfile line installs the
  CLI itself (bootstrap installs `uv` first, since `brew bundle` needs it).
- On macOS ≤ 12 this also applies to `fzf`/`starship` — every formula builds
  from source there. On macOS 13+ everything above is a prebuilt bottle.

### Secrets are not in the repo

`.gitignore` excludes `.pi/agent/auth.json` and `.config/kaggle/kaggle.json`.
Copy those credential files manually to a new machine.

## 🔄 Day-to-day maintenance

```sh
# Update everything
git -C ~/.dotfiles pull
brew update && brew bundle --file ~/.dotfiles/Brewfile   # formulas, casks, uv tools
uv self update                                            # uv itself
# eza (cargo-installed): cargo install eza --locked && cp ~/.cargo/bin/eza /usr/local/bin/

# Add a dotfile: create/edit a file in ~/.dotfiles, then re-stow
cd ~/.dotfiles && stow .        # or: stow .config/nvim for a single package

# Undo the symlinks (e.g. before wiping a machine)
cd ~/.dotfiles && stow -D .     # remove all symlinks created by stow
```

## 🧹 Decommissioning an old Mac

```sh
brew bundle cleanup --file ~/.dotfiles/Brewfile --force   # uninstall Brewfile software
cd ~/.dotfiles && stow -D .                                # remove symlinks
# TODO: export app licenses, backups, SSH keys, ... (see TODO list)
```

## TODO List

- Learn how tu use `defaults` to record and restore System Preferences and other macOS configurations.
- Organize these growing steps into multiple scripts.
- Automate symlinks and run script files with a boostrapping tool like [dotbot](https://github.com/anishathalye/dotbot) or [GNU Stow](https://www.gnu.org/software/stow/).
- M@ake a checklist of steps to decommission your computer before wiping your hard drive.
- Create a [bootable USB installer for macOS](https://support.apple.com/en-us/101578).
- Integrate other cloud services into your Dotfiles process (Dropbox, Google Drive, etc.).
- Find inspiration and examples in other Dotfiles repositories at [dotfiles.github.io](https://dotfiles.github.io/).
