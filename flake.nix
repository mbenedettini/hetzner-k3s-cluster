{
  description = "Development environment for hetzner-k3s-cluster";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:

    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
            "terraform"
          ];
        };
      in
      {
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            kubectl
            direnv
            terraform
            kubernetes-helm
            yq-go
          ];

          shellHook = ''
            eval "$(direnv hook bash)"
          '';
        };
      }
    );
}
