self:
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.chapman-shell;
  qs = lib.getExe' cfg.quickshell "qs";
  niri = "/run/current-system/sw/bin/niri";
  shellDir = "${cfg.package}/share/chapman-shell/shell";
  lock = "${qs} -p ${shellDir} ipc call lock lock";
  idleStep = pkgs.writeShellScript "chapman-shell-idle-step" ''
    online=$(cat /sys/class/power_supply/AC0/online)
    case "$1" in
      screen-off) [ "$online" = 0 ] && ${niri} msg action power-off-monitors ;;
      lock-battery) [ "$online" = 0 ] && ${lock} ;;
      suspend-battery) [ "$online" = 0 ] && systemctl suspend ;;
      lock-ac) [ "$online" = 1 ] && ${lock} ;;
      suspend-ac) [ "$online" = 1 ] && systemctl suspend ;;
    esac
    exit 0
  '';
in
{
  options.programs.chapman-shell = {
    enable = lib.mkEnableOption "chapman-shell";
    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };
    quickshell = lib.mkPackageOption pkgs "quickshell" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."chapman-shell/niri.kdl".source = "${cfg.package}/share/chapman-shell/niri.kdl";

    systemd.user.services.chapman-shell = {
      Unit = {
        Description = "chapman-shell";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${qs} -p ${shellDir}";
        Restart = "on-failure";
        RestartSec = "2s";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    systemd.user.services.chapman-usage = {
      Unit = {
        Description = "Fetch AI subscription and API key usage for chapman-shell";
        PartOf = [ "chapman-shell.service" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = lib.getExe' cfg.package "chapman-usage";
        Environment = "PATH=/etc/profiles/per-user/%u/bin:%h/.nix-profile/bin:/run/current-system/sw/bin";
      };
    };

    systemd.user.timers.chapman-usage = {
      Unit = {
        Description = "Refresh chapman-shell usage every 5 minutes";
        PartOf = [ "chapman-shell.service" ];
      };
      Timer = {
        OnActiveSec = "0";
        OnUnitActiveSec = "5min";
      };
      Install.WantedBy = [ "chapman-shell.service" ];
    };

    systemd.user.services.chapman-shell-idle = {
      Unit = {
        Description = "Lock chapman-shell after idle, suspend later, and lock before every sleep";
        PartOf = [ "chapman-shell.service" ];
        After = [ "chapman-shell.service" ];
      };
      Service = {
        ExecStart = ''${lib.getExe pkgs.swayidle} -w timeout 180 "${idleStep} screen-off" resume "${niri} msg action power-on-monitors" timeout 300 "${idleStep} lock-battery" timeout 600 "${idleStep} suspend-battery" timeout 1200 "${idleStep} lock-ac" timeout 1800 "${idleStep} suspend-ac" before-sleep "${lock}" after-resume "${niri} msg action power-on-monitors"'';
        Restart = "on-failure";
        RestartSec = "5s";
      };
      Install.WantedBy = [ "chapman-shell.service" ];
    };
  };
}
