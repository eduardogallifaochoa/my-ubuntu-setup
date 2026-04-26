#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target_user="${SUDO_USER:-$(basename "$HOME")}"

log() { printf '%s\n' "$*"; }

copy_if_exists() {
  local src="$1"
  local dst="$2"
  if [ -e "$src" ]; then
    cp -a "$src" "$dst"
  fi
}

mkdir -p "$repo_dir/dotfiles" "$repo_dir/zsh" "$repo_dir/packages" "$repo_dir/vscode/User" "$repo_dir/gnome"

log "Exporting apt manual list..."
apt-mark showmanual > "$repo_dir/packages/apt-manual.txt"

if command -v snap >/dev/null 2>&1; then
  log "Exporting snap list..."
  if command -v timeout >/dev/null 2>&1; then
    timeout 15s snap list > "$repo_dir/packages/snap-list.txt" || true
  else
    snap list > "$repo_dir/packages/snap-list.txt" || true
  fi
else
  log "snap not available; skipping"
fi

if [ -d "$HOME/.vscode/extensions" ]; then
  log "Exporting VSCode extensions (from ~/.vscode/extensions)..."
  ls -1 "$HOME/.vscode/extensions" | sed -E 's/-[0-9]+\.[0-9]+\.[0-9]+.*$//' | sort -u > "$repo_dir/vscode/extensions.txt"
elif command -v code >/dev/null 2>&1; then
  log "Exporting VSCode extensions (via code CLI)..."
  code --list-extensions > "$repo_dir/vscode/extensions.txt" || true
fi

log "Copying dotfiles..."
copy_if_exists "$HOME/.zshrc" "$repo_dir/dotfiles/"
copy_if_exists "$HOME/.p10k.zsh" "$repo_dir/dotfiles/"
copy_if_exists "$HOME/.gitconfig" "$repo_dir/dotfiles/"

log "Copying zsh assets..."
if [ -d "$HOME/.oh-my-zsh/custom" ]; then
  rm -rf "$repo_dir/zsh/oh-my-zsh-custom"
  cp -a "$HOME/.oh-my-zsh/custom" "$repo_dir/zsh/oh-my-zsh-custom"
fi
if [ -d "$HOME/.zsh" ]; then
  rm -rf "$repo_dir/zsh/.zsh"
  cp -a "$HOME/.zsh" "$repo_dir/zsh/.zsh"
  find "$repo_dir/zsh/.zsh" -type d -name '*.bak_*' -prune -exec rm -rf {} +
fi

log "Copying VSCode portable settings..."
if [ -d "$HOME/.config/Code/User" ]; then
  rm -rf "$repo_dir/vscode/User"
  mkdir -p "$repo_dir/vscode/User"

  for file in settings.json keybindings.json tasks.json; do
    copy_if_exists "$HOME/.config/Code/User/$file" "$repo_dir/vscode/User/"
  done

  if [ -d "$HOME/.config/Code/User/snippets" ]; then
    cp -a "$HOME/.config/Code/User/snippets" "$repo_dir/vscode/User/snippets"
  fi
fi

log "Exporting system notes..."
{
  printf 'Date: '
  date -Iseconds
  printf 'Hostname: '
  hostname
  printf 'Kernel: '
  uname -a
  printf '\nOS release:\n'
  cat /etc/os-release
  printf '\nCPU architecture: '
  uname -m
  printf '\nDefault shell: '
  getent passwd "$target_user" | cut -d: -f7
} > "$repo_dir/packages/system-info.txt"

if command -v lpstat >/dev/null 2>&1; then
  log "Exporting printer notes..."
  {
    lpstat -p -v -d 2>/dev/null || true
    printf '\nModels:\n'
    lpinfo -m 2>/dev/null | grep -Ei 'L3250|Epson-L3250' || true
  } > "$repo_dir/packages/printers.txt"
fi

if command -v systemctl >/dev/null 2>&1; then
  log "Exporting VMware tools notes..."
  {
    systemctl is-enabled open-vm-tools 2>/dev/null || true
    systemctl is-active open-vm-tools 2>/dev/null || true
    dpkg -l | grep -E 'open-vm-tools|open-vm-tools-desktop|xserver-xorg-video-vmware' || true
    printf '\nGDM Wayland setting:\n'
    grep -n '^WaylandEnable=false' /etc/gdm3/custom.conf 2>/dev/null || true
  } > "$repo_dir/packages/vmware-tools.txt"
fi

if command -v dconf >/dev/null 2>&1; then
  log "Exporting GNOME settings (dconf)..."
  dconf dump / > "$repo_dir/gnome/dconf-settings.ini"
fi

log "Done. Review files before committing."
