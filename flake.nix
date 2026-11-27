{
  description = "Zoldt out-of-store dotfiles";
  outputs = inputs: import ./outputs inputs;
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    import-tree.url = "github:denful/import-tree";
  };
}
