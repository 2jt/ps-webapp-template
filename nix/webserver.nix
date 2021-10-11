{
  network.enableRollback = true;

  webserver = { config, pkgs, ... }:
    let app = (import ./default.nix { });
    in {
      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_13;
        enableTCPIP = true;
        authentication = ''
          host    all        all             0.0.0.0/0         md5
        '';
      };
      services.postgresqlBackup.enable = true;

      environment.systemPackages = with pkgs; [ htop wget emacs-nox ];
      security.acme.email = "me@jtomas.com";

      security.acme.acceptTerms = true;
      networking.firewall.allowedTCPPorts = [ 80 443 5432 5555 8080 ];

      systemd.services.my-app = {
        enable = true;
        serviceConfig = {
          WorkingDirectory = "${app}";
          ExecStart = "${app}/my-app";
        };
        wantedBy = [ "multi-user.target" ];
      };

      services.nginx = {
        enable = true;

        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;

        virtualHosts."my-app" = {
          forceSSL = true;
          enableACME = true;
          locations = { "/" = { proxyPass = "http://127.0.0.1:8080"; }; };
        };
      };

      users.users.tomas = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        shell = pkgs.zsh;
      };
    };
}
