{
  flake.modules.homeManager.default = {
    config,
    lib,
    ...
  }: let
    cfg = config.zoldt.dotfiles;
    link = path: config.lib.file.mkOutOfStoreSymlink "${cfg.directory}/${path}";
  in {
    options.zoldt.dotfiles.directory = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.config/dotfiles";
      description = "Path to the mutable config directory from the dotfiles checkout.";
    };

    config = {
      home.file = {
        ".agents".source = link "agents";
        ".pi".source = link "pi";
        ".pi-lens".source = link "pi/packages/pi-lens";
      };
      xdg.configFile = {
        nvim.source = link "nvim";
        billion-context.source = link "pi/packages/billion-context";
        ponytail.source = link "pi/packages/ponytail";
      };
    };
  };
}
