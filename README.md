# dotfiles.nix

Import `modules.homeManager.default` for writable Neovim and agent config links. Home Manager targets `~/.config/dotfiles`, which points to the checkout's `config/` directory. Set `zoldt.dotfiles.directory` to use a different location.

Import `modules.homeManager.sync` and set `zoldt.dotfiles.sync.enable = true;` for periodic Git pulls. It clones into `$XDG_DATA_HOME/dotfiles.nix` and links `~/.config/dotfiles` to its `config/` directory. The service fast-forwards the configured branch. Commit and push edits from the checkout when you want to share them.
