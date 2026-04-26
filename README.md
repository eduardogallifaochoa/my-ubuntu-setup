# my-ubuntu-setup

Portable Ubuntu setup for quickly restoring my environment.

## What this includes
- Zsh + Oh My Zsh + plugins
- Dotfiles (.zshrc, .p10k.zsh, .gitconfig)
- Apt packages (manual list)
- Snap packages (if exported)
- VSCode settings + extensions list
- GNOME settings (dconf)
- Printer notes, including the Epson L3250 queue
- VMware Tools notes for clipboard/display integration
- Nerd Font (JetBrains Mono Nerd Font)
- ChatGPT web shortcut (opens in default browser)

## Install on a fresh Ubuntu
```bash
git clone https://github.com/eduardogallifaochoa/my-ubuntu-setup.git
cd my-ubuntu-setup
bash install.sh
```

## One-liner install
```bash
git clone https://github.com/eduardogallifaochoa/my-ubuntu-setup.git && cd my-ubuntu-setup && bash install.sh
```

## Manual steps (if needed)
- Set default shell: `chsh -s /bin/zsh`
- Open a new terminal or run: `exec zsh`
- If VSCode CLI missing, install VSCode then re-run extensions step.
- GNOME settings will be restored from `gnome/dconf-settings.ini` if present.
- To recreate the Epson L3250 queue, see `packages/printers.txt`.
- For VMware clipboard issues, see `packages/vmware-tools.txt`.

## Notes
- Secrets are intentionally excluded. Do not commit SSH keys or tokens.
- VSCode history, globalStorage, sync state, and workspaceStorage are intentionally excluded because they can contain private sessions or machine-specific cache.
- `packages/snap-list.txt` may be a placeholder if snapd was not responding.

## Re-export from current machine
- Update package lists:
  - `apt-mark showmanual > packages/apt-manual.txt`
  - `snap list > packages/snap-list.txt`
- Update VSCode:
  - `code --list-extensions > vscode/extensions.txt`
- Copy dotfiles and zsh assets again if they changed.
- GNOME settings:
  - `dconf dump / > gnome/dconf-settings.ini`

## Quick update (this machine)
```bash
cd /home/eduardogallifa/Desktop/my-ubuntu-setup
./scripts/export_current.sh
git add .
git commit -m "Update setup"
git push
```
