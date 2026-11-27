{config, ...}: let
  links = config.flake.modules.homeManager.default;
in {
  flake.modules.homeManager.sync = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.zoldt.dotfiles;
    checkout = lib.escapeShellArg cfg.sync.checkout;
    directory = lib.escapeShellArg cfg.directory;
    sync = pkgs.writeShellApplication {
      name = "dotfiles-sync";
      runtimeInputs = [pkgs.coreutils pkgs.git];
      text = ''
        checkout=${checkout}
        directory=${directory}
        if [ -e "$directory" ] || [ -L "$directory" ]; then
          if [ "$(readlink -f -- "$directory")" != "$(realpath -m -- "$checkout/config")" ]; then
            echo "$directory must point to $checkout/config" >&2
            exit 1
          fi
        fi
        if [ ! -d "$checkout/.git" ]; then
          git clone --branch ${lib.escapeShellArg cfg.sync.branch} -- ${lib.escapeShellArg cfg.sync.remote} "$checkout"
        else
          if [ "$(git -C "$checkout" branch --show-current)" != ${lib.escapeShellArg cfg.sync.branch} ]; then
            echo "$checkout must be on branch" ${lib.escapeShellArg cfg.sync.branch} >&2
            exit 1
          fi
          git -C "$checkout" pull --ff-only -- ${lib.escapeShellArg cfg.sync.remote} ${lib.escapeShellArg cfg.sync.branch}
        fi
        test -d "$checkout/config"
        if [ ! -L "$directory" ] && [ ! -e "$directory" ]; then
          mkdir -p -- "$(dirname -- "$directory")"
          ln -sT -- "$checkout/config" "$directory"
        fi
      '';
    };
  in {
    imports = [links];

    options.zoldt.dotfiles.sync = {
      enable = lib.mkEnableOption "periodic fast-forward pulls of the dotfiles checkout";
      checkout = lib.mkOption {
        type = lib.types.str;
        default = "${config.xdg.dataHome}/dotfiles.nix";
        description = "Location of the mutable Git checkout.";
      };
      remote = lib.mkOption {
        type = lib.types.str;
        default = "https://github.com/zoldt/dotfiles.nix.git";
        description = "Git remote to pull dotfiles from.";
      };
      branch = lib.mkOption {
        type = lib.types.str;
        default = "main";
        description = "Git branch to pull dotfiles from.";
      };
    };

    config = lib.mkIf cfg.sync.enable {
      systemd.user.services.dotfiles-sync = {
        Unit.Description = "Sync dotfiles checkout";
        Service = {
          Type = "oneshot";
          ExecStart = lib.getExe sync;
          Environment = "GIT_TERMINAL_PROMPT=0";
        };
      };
      systemd.user.timers.dotfiles-sync = {
        Unit.Description = "Periodically sync dotfiles checkout";
        Timer = {
          OnStartupSec = "1min";
          OnUnitActiveSec = "15min";
        };
        Install.WantedBy = ["timers.target"];
      };
    };
  };
}
