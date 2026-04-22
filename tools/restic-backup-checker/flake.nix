{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        checkBackupScript = pkgs.writeScriptBin "check-backup.sh" (builtins.readFile ./check-backup.sh);
      in
      {
        packages.docker = pkgs.dockerTools.buildImage {
          name = "restic-backup-checker";
          copyToRoot = pkgs.buildEnv {
            name = "root";
            paths = with pkgs; [
              restic
              curl
              bashInteractive
              coreutils
              cacert
              checkBackupScript
            ];
            pathsToLink = [ "/bin" "/etc" ];
          };
          config = {
            Entrypoint = [ "/bin/check-backup.sh" ];
            Env = [
              "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
            ];
          };
        };

        defaultPackage = self.packages.${system}.docker;
      }
    );
}
